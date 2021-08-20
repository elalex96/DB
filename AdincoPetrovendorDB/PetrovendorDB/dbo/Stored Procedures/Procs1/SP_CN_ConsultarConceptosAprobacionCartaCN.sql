USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_CN_ConsultarConceptosAprobacionCartaCN]    Script Date: 20/08/2021 02:59:58 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Alexander Gomez
-- Create date: 05/06/2018
-- Description: Consulta de los conceptos de la carta de contenido nacional
-- =============================================
ALTER PROCEDURE [dbo].[SP_CN_ConsultarConceptosAprobacionCartaCN] --10901
    -- Add the parameters for the stored procedure here
    @IdAceptacion INT,
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
    -- Insert statements for procedure here
	SET @IdAceptacion = (SELECT TOP 1 IdAceptacionPedido FROM MM_AceptacionCartaPCN WHERE IdAceptacionCartaPCN = @IdAceptacion);
    DECLARE @IdMonedaNacional INT = 1;   
    -- Insert statements for procedure here 
    
    CREATE TABLE #ACTIVIDAD(
							IdRow INT,
							IdAceptacionDetalle int,
							 CodigoCatalogo NVARCHAR(MAX),
							  NombreActividad NVARCHAR(MAX), 
							  ValorFactura MONEY, PCN FLOAT, 
							  IdTipoMaterial INT, 
							  IdClasificacionCN INT, 
							  DescPartida NVARCHAR(MAX),
							  TipoMaterial NVARCHAR(max)
							  )
    /*OBTENER TODOS LOS MATERIALES/SERVICIOS DE UNA ACEPTACIÓN DE PEDIDO Y AGREGARLOS A LA TABLA ACTIVIDA PARA LUEGO AGRUPARLOS POR TIP0 DE MATERIAL*/
    INSERT INTO #ACTIVIDAD
    (
        IdRow,
        IdAceptacionDetalle,
        CodigoCatalogo,
        NombreActividad,
        ValorFactura,
        PCN,
        IdTipoMaterial,
        IdClasificacionCN,
		DescPartida,
		TipoMaterial
    )   
    SELECT ROW_NUMBER() OVER (ORDER BY BSA.Codigo ASC)  AS IdRow,
            APD.IdAceptacionPedidoDetalle,
           ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
           ISNULL(BSA.Nombre, 'NO CONTENIDO')AS NombreActividad,
           ISNULL(V.ValorFactura,0) AS ValorFactura,
		   CAST(SUBSTRING(CAST(ISNULL(APD.PCN,0) AS nvarchar(10)),1,5) AS float) AS PCN,
           --ROUND(APD.PCN, 3) AS PCN,
           V.IdTipoMaterialServicio AS  IdTipoMaterial,
           APD.ClasificacionCN,
		   POD.MaterialCotizadoTextoC,
		   TMP.Descripcion AS TipoMaterial
		  
    FROM MM_AceptacionPedidoDetalle AS APD
        LEFT JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        LEFT JOIN dbo.MM_PCN_ValoresPesos AS V 
        ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        LEFT JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle        
        LEFT JOIN dbo.MM_BS_Actividad AS BSA
            ON BSA.IdActividad = V.IdCatalogoHidrocarburos       
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
        LEFT JOIN dbo.MM_Pedido AS PE 
			ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
        LEFT JOIN MM_PeticionOfertaDetalle AS POD 
			ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
		LEFT JOIN dbo.MM_TipoMaterialProcura AS TMP
			ON TMP.IdTipoMaterialProcura = V.IdTipoMaterialServicio
            
    WHERE AP.IdAceptacionPedido = @IdAceptacion;
    CREATE TABLE #ACTIVIDAD_AGRUPADA(CodigoCatalogo NVARCHAR(MAX),
									 IdAceptacionDetalle int, 
									 NombreActividad NVARCHAR(MAX), 
									 CN FLOAT, MontoAcumulado MONEY, 
									 IdTipoMaterial INT, 
									 IdClasificacionCN INT,
									 DescPartida NVARCHAR(MAX)
									)
    
    /*AGRUPAR ACTIVIDAD POR TIPO DE MATERIAL(MATERIAL/SERVICIO)*/
    INSERT INTO #ACTIVIDAD_AGRUPADA
    (
        CodigoCatalogo,
        IdAceptacionDetalle,
        NombreActividad,
        CN,
        MontoAcumulado,
        IdTipoMaterial,
        IdClasificacionCN,
		DescPartida
    )
    
    SELECT CodigoCatalogo, 
        IdAceptacionDetalle,    
       NombreActividad,
       SUM(ValorFactura*PCN) AS CNB,
       SUM(ValorFactura)  AS MontoAculadoFactura,
       IdTipoMaterial,
       IdClasificacionCN,
	   '(' + NombreActividad + ') - ' + DescPartida +' - ' + TipoMaterial
    FROM #ACTIVIDAD 
    WHERE IdTipoMaterial = 1 --> MATERIAL
    GROUP BY CodigoCatalogo,
			 NombreActividad, 
			 IdTipoMaterial, 
			 IdClasificacionCN,
			 IdAceptacionDetalle,
			 DescPartida,
			 TipoMaterial
		
    
    UNION ALL 
    SELECT CodigoCatalogo,
        IdAceptacionDetalle,       
       NombreActividad,
       SUM(ValorFactura*PCN) AS CNS,
       SUM(ValorFactura)  AS MontoAculadoFactura,
       IdTipoMaterial,
       IdClasificacionCN,
	   '(' + NombreActividad + ') - ' + DescPartida+' - ' + TipoMaterial
    FROM #ACTIVIDAD 
    WHERE IdTipoMaterial =2  --> SERVICIO
    GROUP BY CodigoCatalogo,
			 NombreActividad, 
			 IdTipoMaterial, 
			 IdClasificacionCN,
			 IdAceptacionDetalle,
			 DescPartida,
			 TipoMaterial
			 
    /*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
    SELECT CodigoCatalogo,
    IdAceptacionDetalle, 
    NombreActividad,
    CASE WHEN  ISNULL(SUM(CN),0) > 0 THEN 
    (SUM(CN)/SUM(MontoAcumulado))
    ELSE 
     0
    END  
     AS PorcentajeContenidoNacional,
     SUM(MontoAcumulado) AS MontoFacturado,
     IdClasificacionCN,
	 DescPartida  AS MaterialCotizadoTextoC
    FROM #ACTIVIDAD_AGRUPADA
    GROUP BY CodigoCatalogo,
			 NombreActividad, 
			 IdClasificacionCN,
			 IdAceptacionDetalle,
			 DescPartida
    ORDER BY PorcentajeContenidoNacional DESC 
END
