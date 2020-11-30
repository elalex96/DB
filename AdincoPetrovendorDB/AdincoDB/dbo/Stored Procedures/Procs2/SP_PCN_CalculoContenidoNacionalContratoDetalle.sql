
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/10/2018
-- Description:	Consulta el contenido nacional de un contrato y sus detalles
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_CalculoContenidoNacionalContratoDetalle] --3
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
    -- Insert statements for procedure here
	
	DECLARE @TOTALCN FLOAT;
	DECLARE @TOTALFACTURADO FLOAT;
	DECLARE @CONTRATO NVARCHAR(50);

	DECLARE @IdMonedaNacional INT = 1;   
 --   -- Insert statements for procedure here 
	
	CREATE TABLE #ACTIVIDAD(IdRow INT, CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), ValorFactura MONEY, PCN FLOAT, IdTipoMaterial INT)
	--/*OBTENER TODOS LOS MATERIALES/SERVICIOS DE UNA ACEPTACIÓN DE PEDIDO Y AGREGARLOS A LA TABLA ACTIVIDA PARA LUEGO AGRUPARLOS POR TIP0 DE MATERIAL*/
	INSERT INTO #ACTIVIDAD
	(
	    IdRow,
	    CodigoCatalogo,
	    NombreActividad,
	    ValorFactura,
	    PCN,
	    IdTipoMaterial
	)	
    SELECT ROW_NUMBER() OVER (ORDER BY BSA.Codigo ASC)  AS IdRow,
	       ISNULL(BSA.Codigo, 'NO CONTENIDO') AS CodigoCatalogo,
           ISNULL(BSA.Nombre, 'NO CONTENIDO')AS NombreActividad,
		   ISNULL(V.ValorFactura,0) AS ValorFactura,
           ROUND(APD.PCN, 3) AS PCN,
		   V.IdTipoMaterialServicio AS  IdTipoMaterial
    FROM Petrovendor.dbo.MM_AceptacionPedidoDetalle AS APD
        JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		JOIN Petrovendor.dbo.MM_PCN_ValoresPesos AS V ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle        
        LEFT JOIN Petrovendor.dbo.MM_BS_Actividad AS BSA ON BSA.IdActividad = V.IdCatalogoHidrocarburos       
        INNER JOIN Petrovendor.dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
		LEFT JOIN Petrovendor.dbo.MM_Pedido AS PE ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
		LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		LEFT JOIN Petrovendor.dbo.FI_Factura AS FI ON FI.IdFactura = AF.IdFactura
    WHERE AF.IdEstatusXML = 2
		AND FI.IdContrato = @IDCONTRATO

	CREATE TABLE #ACTIVIDAD_AGRUPADA(CodigoCatalogo NVARCHAR(MAX), NombreActividad NVARCHAR(MAX), CN FLOAT, MontoAcumulado MONEY, IdTipoMaterial INT)
	

	/*AGRUPAR ACTIVIDAD POR TIPO DE MATERIAL(MATERIAL/SERVICIO)*/
	INSERT INTO #ACTIVIDAD_AGRUPADA
	(
	    CodigoCatalogo,
	    NombreActividad,
	    CN,
	    MontoAcumulado,
	    IdTipoMaterial
	)
	SELECT CodigoCatalogo, 	
	   NombreActividad,
	   SUM(ValorFactura*PCN) AS CNB,
	   SUM(ValorFactura)  AS MontoAculadoFactura,
	   IdTipoMaterial
	FROM #ACTIVIDAD 
	WHERE IdTipoMaterial = 1 --> MATERIAL
	GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial	
	
	UNION ALL 

	SELECT CodigoCatalogo, 	   
	   NombreActividad,
	   SUM(ValorFactura*PCN) AS CNS,
	   SUM(ValorFactura)  AS MontoAculadoFactura,
	   IdTipoMaterial
	FROM #ACTIVIDAD 
	WHERE IdTipoMaterial =2  --> SERVICIO
	GROUP BY CodigoCatalogo,NombreActividad, IdTipoMaterial	


	--/*AGRUPADO POR ACTIVIDAD PCN DE CADA ACTIVIDAD*/
	SELECT CodigoCatalogo, 
	NombreActividad AS MaterialCotizadoTextoC,
	CASE WHEN  ISNULL(SUM(CN),0) > 0 THEN 
	ROUND((SUM(CN)/SUM(MontoAcumulado)),3)
	ELSE 
	 0
	END  
	 AS PorcentajeContenidoNacional,
	 SUM(MontoAcumulado) AS MontoFacturado
	FROM #ACTIVIDAD_AGRUPADA
	GROUP BY CodigoCatalogo,NombreActividad
	ORDER BY PorcentajeContenidoNacional DESC 

	--SELECT
	--CodigoCatalogo,
	--MaterialCotizadoTextoC,
	--PorcentajeContenidoNacional,
	--MontoFacturado
	--FROM dbo.TablaCN1


	--SELECT 
	--CodigoCatalogo, 
	--NombreActividad AS MaterialCotizadoTextoC,
	--CN AS PorcentajeContenidoNacional,
	--MontoAcumulado AS MontoFacturado
	--FROM #ACTIVIDAD_AGRUPADA

END
