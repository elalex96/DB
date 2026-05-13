-- =============================================
-- Author: DANIEL AC 
-- Create date: 16-05-18
-- Description:	Actualización agrupación de actividades 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_CartaProveedorDetalle_MV1_5] --12720
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
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END;
    DECLARE @IdMonedaNacional INT = 1;   
    -- Insert statements for procedure here 
	
	CREATE TABLE #ACTIVIDAD(IdRow INT, CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), ValorFactura MONEY, PCN FLOAT, IdTipoMaterial INT, DescPartidas NVARCHAR(max))
	/*OBTENER TODOS LOS MATERIALES/SERVICIOS DE UNA ACEPTACIÓN DE PEDIDO Y AGREGARLOS A LA TABLA ACTIVIDA PARA LUEGO AGRUPARLOS POR TIP0 DE MATERIAL*/
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
           CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar(10)),1,5) AS float) AS PCN,
		   --ROUND(APD.PCN, 3) AS PCN,
		   V.IdTipoMaterialServicio AS  IdTipoMaterial,
		   POD.MaterialCotizadoTextoC
    FROM MM_AceptacionPedidoDetalle AS APD
        JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		JOIN dbo.MM_PCN_ValoresPesos AS V 
		ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle        
        LEFT JOIN dbo.MM_BS_Actividad AS BSA
            ON BSA.IdActividad = V.IdCatalogoHidrocarburos       
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
		LEFT JOIN dbo.MM_Pedido AS PE ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
		LEFT JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
    WHERE AP.IdAceptacionPedido = @IdPedido;

	CREATE TABLE #ACTIVIDAD_AGRUPADA(CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), CN FLOAT, MontoAcumulado MONEY, IdTipoMaterial INT,DescPartidas NVARCHAR(max))
	
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
	   SUM(ValorFactura*PCN) AS CNB,
	   SUM(ValorFactura)  AS MontoAculadoFactura,
	   IdTipoMaterial,
	   '(' + NombreActividad + ') - ' +
	   STUFF((
			SELECT ' \ ' + SUBSTRING(DescPartidas,1,20)
			FROM #ACTIVIDAD 
			WHERE (NombreActividad = ACT.NombreActividad) 
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
		  ,1,2,'')
	FROM #ACTIVIDAD AS ACT
	WHERE IdTipoMaterial = 1 --> MATERIAL
	GROUP BY CodigoCatalogo,IdTipoMaterial,NombreActividad
	
	UNION ALL 

	SELECT CodigoCatalogo, 	   
	   NombreActividad,
	   SUM(ValorFactura*PCN) AS CNS,
	   SUM(ValorFactura)  AS MontoAculadoFactura,
	   IdTipoMaterial,
	   '(' + NombreActividad + ') - ' +
	   STUFF((
			SELECT ' \ ' + SUBSTRING([DescPartidas],1,20)
			FROM #ACTIVIDAD 
			WHERE (NombreActividad = ACT.NombreActividad) 
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)'
			)
		  ,1,2,'')
	FROM #ACTIVIDAD AS ACT
	WHERE IdTipoMaterial =2  --> SERVICIO
	GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial


	/*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
	SELECT CodigoCatalogo, 
	NombreActividad AS MaterialCotizadoTextoC,
	CASE WHEN  ISNULL(SUM(CN),0) > 0 THEN 
	ROUND((SUM(CN)/SUM(MontoAcumulado)),3)
	ELSE 
	 0
	END  
	 AS PorcentajeContenidoNacional,
	 SUM(MontoAcumulado) AS MontoFacturado,
	 DescPartidas
	FROM #ACTIVIDAD_AGRUPADA
	GROUP BY CodigoCatalogo,NombreActividad,DescPartidas
	ORDER BY PorcentajeContenidoNacional DESC 


	 -- SELECT ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
  --         ISNULL(BSA.Nombre, 'NO CONTENIDO')AS MaterialCotizadoTextoC,
  --         ROUND(APD.PCN, 3) AS PorcentajeContenidoNacional,
  --         ISNULL(V.ValorFactura,0) AS MontoFacturado		   
  --  FROM MM_AceptacionPedidoDetalle AS APD
  --      JOIN MM_AceptacionPedido AS AP
  --          ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		--JOIN dbo.MM_PCN_ValoresPesos AS V 
		--ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
  --      JOIN MM_PedidoDetalle AS PD
  --          ON PD.IdPedidoDetalle = APD.IdPedidoDetalle        
  --      LEFT JOIN dbo.MM_BS_Actividad AS BSA
  --          ON BSA.IdActividad = V.IdCatalogoHidrocarburos       
  --      INNER JOIN MM_Pedido AS P
  --          ON P.IdPedido = PD.IdPedido
		--LEFT JOIN dbo.MM_Pedido AS PE ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
		--LEFT JOIN MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
  --  WHERE AP.IdAceptacionPedido = @IdPedido;2260400.00
END;