USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_MM_CartaProveedorDetalle_MV1_5'
)
    DROP PROCEDURE SP_MPY_MM_CartaProveedorDetalle_MV1_5; 
GO
/****** Object:  StoredProcedure [dbo].[SP_MPY_MM_CartaProveedorDetalle_MV1_5]    Script Date: 31/07/2023 04:53:54 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- Author:		Alexander Gomez
-- Update: 19/07/2023
-- Description:	se agregan validaciones de configuraciones issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
-- Author:		Alexander Gomez
-- Update: 27/07/2023
-- Description:	se iguala el calculo de partidas a 3 decimales sin redondear issue: https://github.com/Adinco/petrovendor/issues/2397
-- =============================================
-- Author:	Daniel AC
-- Update: 31/07/2023
-- Description:	se agregan validaciones para evitar mostrar información de mercadeo cuando es murphy https://github.com/Adinco/petrovendor/issues/2407
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_MM_CartaProveedorDetalle_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdPedido INT,
    @IdContrato    INT = NULL,
    @IdUsuario     INT = NULL,
    @FechaRegistro DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	SET FMTONLY OFF
    DECLARE @IdMonedaNacional INT = 1,
		@RFC_ACTUAL NVARCHAR(200), 
		@EXISTE_RFC INT, 
		@RFC_PR NVARCHAR(100), 
		@CONFIGURACION_CARTA NVARCHAR(100);   
    -- Insert statements for procedure here 
	
	CREATE TABLE #ACTIVIDAD(IdRow INT, CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), ValorFactura MONEY, PCN FLOAT, IdTipoMaterial INT, DescPartidas NVARCHAR(max))
	CREATE TABLE #ACTIVIDAD_AGRUPADA(CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), CN FLOAT, MontoAcumulado MONEY, IdTipoMaterial INT,DescPartidas NVARCHAR(max))
	/*OBTENER TODOS LOS MATERIALES/SERVICIOS DE UNA ACEPTACIÓN DE PEDIDO Y AGREGARLOS A LA TABLA ACTIVIDA PARA LUEGO AGRUPARLOS POR TIP0 DE MATERIAL*/

	IF @IdContrato = 1 --> PARAMETRO QUE SE RECIBE SI SE TRATA DE UNA CONFIGURACIÓN DE CARTA_PR_PR
	BEGIN
	
		SELECT TOP 1
			@RFC_ACTUAL = P.RFC,
			@IdContrato = PD.IdContrato
		FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
			JOIN dbo.S_Proveedor AS P (NOLOCK) 
				ON AP.IdProveedor = P.IdProveedor
			JOIN MM_Pedido AS PD (NOLOCK) 
				ON AP.IdPedido = PD.IdPedido
		WHERE AP.IdAceptacionPedido = @IdPedido;

		--SE VERIFICA EL RFC ESTE EN LA CONFIGURACION DE CARTA_PR_PR
		SET @CONFIGURACION_CARTA = (SELECT
									TipoConfiguracion
								FROM PV_ConfiguracionProveedoresOperadoras (NOLOCK)
								WHERE IdContrato = @IdContrato
									AND TipoConfiguracion = 'CARTA_PR_PR'
									AND Operadora = 1
									AND Activo = 1);

	END 
	

	IF ISNULL(@IdContrato,0) > 0 OR ISNULL(@CONFIGURACION_CARTA,'') = 'CARTA_PR_PR'
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
				   APD.PCN AS PCN,
				   V.IdTipoMaterialServicio AS  IdTipoMaterial,
				   ISNULL(POD.MaterialCotizadoTextoC,APD.Detalle)
			FROM MM_AceptacionPedidoDetalle AS APD (NOLOCK)
				LEFT JOIN MM_AceptacionPedido AS AP (NOLOCK)
					ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MM_PCN_ValoresPesos AS V (NOLOCK)
					ON  APD.IdAceptacionPedidoDetalle = V.IdAceptacionPedidoDetalle     
				LEFT JOIN dbo.MM_BS_Actividad AS BSA (NOLOCK)
					ON V.IdCatalogoHidrocarburos = BSA.IdActividad
				LEFT JOIN MM_PedidoDetalle AS PD (NOLOCK)
					ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
				LEFT JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
					ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
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
					SELECT ' \ ' + SUBSTRING([DescPartidas], 1, 50)
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
					SELECT ' \ ' + SUBSTRING([DescPartidas], 1, 50)
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
			CAST(SUBSTRING(CAST(ISNULL((CASE 
			WHEN  ISNULL(SUM(CN),0) > 0 THEN SUM(CN)/SUM(MontoAcumulado)
			ELSE  0
			END),0) AS nvarchar),1,5) AS nvarchar) AS PorcentajeContenidoNacional,
			 SUM(MontoAcumulado) AS MontoFacturado,
			 DescPartidas AS MaterialCotizadoTextoC
			FROM #ACTIVIDAD_AGRUPADA
			GROUP BY CodigoCatalogo,NombreActividad,DescPartidas
			ORDER BY CodigoCatalogo DESC

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
			   APD.PCN AS PCN,
			   V.IdTipoMaterialServicio AS  IdTipoMaterial,
			   APD.Detalle
		FROM MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			LEFT JOIN MPY_MM_AceptacionPedido AS AP (NOLOCK)
				ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
			LEFT JOIN dbo.MPY_MM_PCN_ValoresPesos AS V (NOLOCK)
			ON APD.IdAceptacionPedidoDetalle = V.IdAceptacionPedidoDetalle     
			LEFT JOIN dbo.MM_BS_Actividad AS BSA (NOLOCK)
				ON V.IdCatalogoHidrocarburos = BSA.IdActividad
		WHERE AP.IdAceptacionPedido = @IdPedido
		ORDER BY ISNULL(BSA.Codigo, 'NO CONTENIDO') DESC;

		
	
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
				SELECT ' \ ' + SUBSTRING([DescPartidas], 1, 50)
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
				SELECT ' \ ' + SUBSTRING([DescPartidas], 1, 50)
				FROM #ACTIVIDAD 
				WHERE (NombreActividad = ACT.NombreActividad) 
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			  ,1,2,'')
		FROM #ACTIVIDAD AS ACT
		WHERE IdTipoMaterial =2  --> SERVICIO
		GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial
		ORDER BY CodigoCatalogo DESC


		/*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
		SELECT CodigoCatalogo, 
		NombreActividad,
		CAST(SUBSTRING(CAST(ISNULL((CASE 
			WHEN  ISNULL(SUM(CN),0) > 0 THEN SUM(CN)/SUM(MontoAcumulado)
			ELSE  0
		END),0) AS nvarchar),1,5) AS nvarchar) AS PorcentajeContenidoNacional,
		 SUM(MontoAcumulado) AS MontoFacturado,
		 DescPartidas AS MaterialCotizadoTextoC
		FROM #ACTIVIDAD_AGRUPADA
		GROUP BY CodigoCatalogo,NombreActividad,DescPartidas
		ORDER BY CodigoCatalogo DESC

	END

	 

END;