USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_CN_ConsultarConceptosAprobacionCartaCN'
)
    DROP PROCEDURE SP_CN_ConsultarConceptosAprobacionCartaCN; 
GO
/****** Object:  StoredProcedure [dbo].[SP_CN_ConsultarConceptosAprobacionCartaCN]    Script Date: 16/02/2024 05:09:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Alexander Gomez
-- Create date: 05/06/2018
-- Description: Consulta de los conceptos de la carta de contenido nacional
-- =============================================
-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 18/05/2022
-- Description: truncado a 3 digitos sin redondeo del PCN segun la SE y optimizacion
-- =============================================  
-- =============================================  
-- Author:  Daniel AC
-- Create date: 16/02/2024
-- Description: Regresar el formato de PCN en 3 decimales 0.000 --> 0.600
-- =============================================  
CREATE PROCEDURE [dbo].[SP_CN_ConsultarConceptosAprobacionCartaCN]-- 17262
    -- Add the parameters for the stored procedure here
    @IdAceptacion INT,
    @IdContrato    INT = NULL,
    @IdUsuario     INT = NULL,
    @FechaRegistro DATETIME = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
	SET @IdAceptacion = (SELECT TOP 1 IdAceptacionPedido FROM MM_AceptacionCartaPCN WHERE IdAceptacionCartaPCN = @IdAceptacion);
    DECLARE @IdMonedaNacional INT = 1;   
	CREATE TABLE #ACTIVIDAD_AGRUPADA(CodigoCatalogo NVARCHAR(MAX),
									 IdAceptacionDetalle int, 
									 NombreActividad NVARCHAR(MAX), 
									 CN FLOAT, MontoAcumulado MONEY, 
									 IdTipoMaterial INT, 
									 IdClasificacionCN INT,
									 DescPartida NVARCHAR(MAX)
									);
    
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
							  );
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
		   APD.PCN,
           V.IdTipoMaterialServicio AS  IdTipoMaterial,
           APD.ClasificacionCN,
		   POD.MaterialCotizadoTextoC,
		   TMP.Descripcion AS TipoMaterial
    FROM MM_AceptacionPedidoDetalle AS APD
        JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
			AND AP.IdAceptacionPedido = @IdAceptacion
        LEFT JOIN dbo.MM_PCN_ValoresPesos AS V 
			ON APD.IdAceptacionPedidoDetalle = V.IdAceptacionPedidoDetalle
        JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle        
        LEFT JOIN dbo.MM_BS_Actividad AS BSA
            ON V.IdCatalogoHidrocarburos = BSA.IdActividad        
        JOIN dbo.MM_Pedido AS PE 
			ON PD.IdPedido = PE.IdPedido
				AND PE.IdPedido = AP.IdPedido
        JOIN MM_PeticionOfertaDetalle AS POD 
			ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
		LEFT JOIN dbo.MM_TipoMaterialProcura AS TMP
			ON V.IdTipoMaterialServicio = TMP.IdTipoMaterialProcura;
    
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
	--> PorcentajeContenidoNacional Primero se corta a 3 decimales para evitar redondeo, luego se pasa a decimal con 3 decimales, para luego retornarlo como string con formato 3 decimales #.###
    SELECT CodigoCatalogo,
    IdAceptacionDetalle, 
    NombreActividad,
	CASE 
		WHEN ISNULL(SUM(CN),0) > 0 THEN FORMAT(CAST(CAST(SUBSTRING(CAST((SUM(CN)/SUM(MontoAcumulado)) AS nvarchar),1,5) AS nvarchar) AS decimal(12,3)),'0.000') 
		ELSE '0.000' 
	END AS PorcentajeContenidoNacional,
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