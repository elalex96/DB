-- =============================================
-- Author: DANIEL AC 
-- Create date: 16-05-18
-- Description:	Actualización agrupación de actividades 
-- =============================================
-- =============================================
-- Author: Alexander Gomez 
-- Create date: 18-02-21
-- Description:	adecuacion para reporte DEA PROVEEDOR A PROVEEDOR
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_MM_CartaProveedorDetalle_MV1_5] --2682
    -- Add the parameters for the stored procedure here
    @IdPedido INT,
	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT = NULL,
    @IdUsuario     INT = NULL,
    @FechaRegistro DATETIME = NULL
  /*--------------------
  --------------------*/
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	SET FMTONLY OFF
    DECLARE @IdMonedaNacional INT = 1;   
    -- Insert statements for procedure here 
	
	CREATE TABLE #ACTIVIDAD(IdRow INT, CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), ValorFactura MONEY, PCN FLOAT, IdTipoMaterial INT, DescPartidas NVARCHAR(max))
	CREATE TABLE #ACTIVIDAD_AGRUPADA(CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), CN FLOAT, MontoAcumulado MONEY, IdTipoMaterial INT,DescPartidas NVARCHAR(max))
	/*OBTENER TODOS LOS MATERIALES/SERVICIOS DE UNA ACEPTACIÓN DE PEDIDO Y AGREGARLOS A LA TABLA ACTIVIDA PARA LUEGO AGRUPARLOS POR TIP0 DE MATERIAL*/

	IF @IdContrato IS NOT NULL
	BEGIN
		
			INSERT INTO #ACTIVIDAD
			(
				IdRow,
				CodigoCatalogo,
				NombreActividad,
				ValorFactura,
				PCN,
				IdTipoMaterial,
				DescPartidas
			)	
			SELECT ROW_NUMBER() OVER (ORDER BY BSA.Codigo ASC)  AS IdRow,
				   ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
				   ISNULL(BSA.Nombre, 'NO CONTENIDO')AS NombreActividad,
				   ISNULL(V.ValorFactura,0) AS ValorFactura,
				   ROUND(APD.PCN, 3) AS PCN,
				   V.IdTipoMaterialServicio AS  IdTipoMaterial,
				   APD.Detalle
			FROM MM_AceptacionPedidoDetalle AS APD
				LEFT JOIN MM_AceptacionPedido AS AP
					ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
				LEFT JOIN dbo.MM_PCN_ValoresPesos AS V 
				ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle       
				LEFT JOIN dbo.MM_BS_Actividad AS BSA
					ON BSA.IdActividad = V.IdCatalogoHidrocarburos
			WHERE AP.IdAceptacionPedido = @IdPedido;

	
			/*AGRUPAR ACTIVIDAD POR TIPO DE MATERIAL(MATERIAL/SERVICIO)*/
			INSERT INTO #ACTIVIDAD_AGRUPADA
			(
				CodigoCatalogo,
				NombreActividad,
				CN,
				MontoAcumulado,
				IdTipoMaterial,
				DescPartidas
			)
	
			SELECT CodigoCatalogo, 	
			   NombreActividad,
			   SUM(ValorFactura * PCN) AS CNB,
			   SUM(ValorFactura)  AS MontoAculadoFactura,
			   IdTipoMaterial,
			   '(' + NombreActividad + ') - ' +
			   STUFF((
					SELECT ' \ ' + SUBSTRING([DescPartidas],1,10)
					FROM #ACTIVIDAD 
					WHERE (NombreActividad = ACT.NombreActividad) 
					FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
				  ,1,2,'')
			FROM #ACTIVIDAD AS ACT
			WHERE IdTipoMaterial = 1 --> MATERIAL
			GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial	
	
			UNION ALL 

			SELECT CodigoCatalogo, 	   
			   NombreActividad,
			   SUM(ValorFactura*PCN) AS CNS,
			   SUM(ValorFactura)  AS MontoAculadoFactura,
			   IdTipoMaterial,
			   '(' + NombreActividad + ') - ' +
			   STUFF((
					SELECT ' \ ' + SUBSTRING([DescPartidas],1,10)
					FROM #ACTIVIDAD 
					WHERE (NombreActividad = ACT.NombreActividad) 
					FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
				  ,1,2,'')
			FROM #ACTIVIDAD AS ACT
			WHERE IdTipoMaterial =2  --> SERVICIO
			GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial	


			/*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
			SELECT CodigoCatalogo, 
			NombreActividad,
			CASE WHEN  ISNULL(SUM(CN),0) > 0 THEN 
			ROUND((SUM(CN)/SUM(MontoAcumulado)),3)
			ELSE 
			 0
			END  
			 AS PorcentajeContenidoNacional,
			 SUM(MontoAcumulado) AS MontoFacturado,
			 DescPartidas AS MaterialCotizadoTextoC
			FROM #ACTIVIDAD_AGRUPADA
			GROUP BY CodigoCatalogo,NombreActividad,DescPartidas
			ORDER BY PorcentajeContenidoNacional DESC

	END
	ELSE
	BEGIN
		
		INSERT INTO #ACTIVIDAD
		(
			IdRow,
			CodigoCatalogo,
			NombreActividad,
			ValorFactura,
			PCN,
			IdTipoMaterial,
			DescPartidas
		)	
		SELECT ROW_NUMBER() OVER (ORDER BY BSA.Codigo ASC)  AS IdRow,
			   ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
			   ISNULL(BSA.Nombre, 'NO CONTENIDO')AS NombreActividad,
			   ISNULL(V.ValorFactura,0) AS ValorFactura,
			   ROUND(APD.PCN, 3) AS PCN,
			   V.IdTipoMaterialServicio AS  IdTipoMaterial,
			   APD.Detalle
		FROM MPY_MM_AceptacionPedidoDetalle AS APD
			LEFT JOIN MPY_MM_AceptacionPedido AS AP
				ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
			LEFT JOIN dbo.MPY_MM_PCN_ValoresPesos AS V 
			ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle       
			LEFT JOIN dbo.MM_BS_Actividad AS BSA
				ON BSA.IdActividad = V.IdCatalogoHidrocarburos
		WHERE AP.IdAceptacionPedido = @IdPedido;

		
	
		/*AGRUPAR ACTIVIDAD POR TIPO DE MATERIAL(MATERIAL/SERVICIO)*/
		INSERT INTO #ACTIVIDAD_AGRUPADA
		(
			CodigoCatalogo,
			NombreActividad,
			CN,
			MontoAcumulado,
			IdTipoMaterial,
			DescPartidas
		)
	
		SELECT CodigoCatalogo, 	
		   NombreActividad,
		   SUM(ValorFactura * PCN) AS CNB,
		   SUM(ValorFactura)  AS MontoAculadoFactura,
		   IdTipoMaterial,
		   '(' + NombreActividad + ') - ' +
		   STUFF((
				SELECT ' \ ' + SUBSTRING([DescPartidas],1,10)
				FROM #ACTIVIDAD 
				WHERE (NombreActividad = ACT.NombreActividad) 
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			  ,1,2,'')
		FROM #ACTIVIDAD AS ACT
		WHERE IdTipoMaterial = 1 --> MATERIAL
		GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial	
	
		UNION ALL 

		SELECT CodigoCatalogo, 	   
		   NombreActividad,
		   SUM(ValorFactura*PCN) AS CNS,
		   SUM(ValorFactura)  AS MontoAculadoFactura,
		   IdTipoMaterial,
		   '(' + NombreActividad + ') - ' +
		   STUFF((
				SELECT ' \ ' + SUBSTRING([DescPartidas],1,10)
				FROM #ACTIVIDAD 
				WHERE (NombreActividad = ACT.NombreActividad) 
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			  ,1,2,'')
		FROM #ACTIVIDAD AS ACT
		WHERE IdTipoMaterial =2  --> SERVICIO
		GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial	


		/*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
		SELECT CodigoCatalogo, 
		NombreActividad,
		CASE WHEN  ISNULL(SUM(CN),0) > 0 THEN 
		ROUND((SUM(CN)/SUM(MontoAcumulado)),3)
		ELSE 
		 0
		END  
		 AS PorcentajeContenidoNacional,
		 SUM(MontoAcumulado) AS MontoFacturado,
		 DescPartidas AS MaterialCotizadoTextoC
		FROM #ACTIVIDAD_AGRUPADA
		GROUP BY CodigoCatalogo,NombreActividad,DescPartidas
		ORDER BY PorcentajeContenidoNacional DESC

	END

	 

END;
