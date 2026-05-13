-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/07/2018
-- Description:	Consulta el contenido nacional de un contrato y sus detalles
-- =============================================
-- Author:		Jose Roman
-- Create date: 14-12-2018
-- Description:	Se toman en cuenta todas las facturas dadas de alta en adinco 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_CalculoContenidoNacionalContratoDetalleMensual]--3
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--IF 1=0 BEGIN
	--	SET FMTONLY OFF
	--END  
    -- Insert statements for procedure here
	CREATE TABLE #MONTOSFACTURA(ValorFactura FLOAT, PCN FLOAT, MontoPCN FLOAT, Fecha DATE, FechaOr DATE, IdFactura INT, SubTotal FLOAT, uuid NVARCHAR(max))
	
	INSERT INTO #MONTOSFACTURA
	(
		ValorFactura,
		PCN,
		MontoPCN,
		Fecha,
		FechaOr,
		IdFactura,
		SubTotal,
		uuid
	)
	SELECT 
		   ISNULL(CASE WHEN FI.IdMoneda = 2 THEN dbo.FN_DolaresPesosTipoCambio(FI.SubTotal, FI.FechaTimbrado) ELSE FI.SubTotal END,0) AS ValorFactura,
           ISNULL(ROUND(APD.PCN, 3),0) AS PCN,
		   ISNULL(ROUND(APD.PCN, 3),0) * ISNULL(V.ValorFactura,0) AS MontoPCN,
		   FI.FechaTimbrado,
		   DATEADD(MONTH, DATEDIFF(MONTH, 0, FI.FechaTimbrado), 0),
		   FI.IdFactura,
		   CASE WHEN FI.IdMoneda = 2 THEN dbo.FN_DolaresPesosTipoCambio(FI.SubTotal, FI.FechaTimbrado) ELSE FI.SubTotal END,
		   fi.UUID
    FROM MM_AceptacionPedidoDetalle AS APD
        JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		JOIN dbo.MM_PCN_ValoresPesos AS V 
		ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        JOIN MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle       
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
		LEFT JOIN dbo.MM_Pedido AS PE ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
		LEFT JOIN dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		LEFT JOIN dbo.FI_Factura AS FI ON FI.IdFactura = AF.IdFactura
    WHERE AF.IdEstatusXML = 2
		AND FI.IdContrato = @IDCONTRATO
	GROUP BY V.ValorFactura,APD.PCN,FI.FechaTimbrado,FI.IdFactura,FI.SubTotal, FI.IdMoneda, FI.UUID
	ORDER BY FI.FechaTimbrado DESC

	INSERT INTO	#MONTOSFACTURA
	(
	   ValorFactura,
		PCN,
		MontoPCN,
		Fecha,
		FechaOr,
		IdFactura,
		SubTotal,
		uuid
	)
	SELECT
		CASE WHEN f.IdMoneda = 2 THEN dbo.FN_DolaresPesosTipoCambio(f.SubTotal, f.FechaTimbrado) ELSE f.SubTotal END,
		0,
		0,
		f.FechaTimbrado,
		DATEADD(MONTH, DATEDIFF(MONTH, 0, f.FechaTimbrado), 0),
		f.IdFactura,
		CASE WHEN f.IdMoneda = 2 THEN dbo.FN_DolaresPesosTipoCambio(f.SubTotal, f.FechaTimbrado) ELSE f.SubTotal END,
		f.UUID
	FROM Adinco.dbo.FI_Factura f
	LEFT JOIN #MONTOSFACTURA mf ON mf.UUID = f.UUID
	WHERE f.IdContrato = @IDCONTRATO
		AND mf.IdFactura IS NULL
	
	SELECT
		SUM(ValorFactura) AS ValorFactura,
		SUM(MontoPCN) AS MontoPCN,
		--YEAR(Fecha) AS Anio,
		--MONTH(Fecha) AS Mes,
		CAST(YEAR(ISNULL(FechaOr, '')) AS NVARCHAR(50)) + '/' + CAST(MONTH(ISNULL(FechaOr,'')) AS NVARCHAR(50)) AS Fecha,
		CASE 
			WHEN ISNULL(SUM(ValorFactura), 0) > 0 THEN ROUND(SUM(MontoPCN) / SUM(ValorFactura),4) 
			ELSE 0
		END AS PCN,
		SUM(SubTotal) AS TotalFacturas,
		FechaOr
	FROM #MONTOSFACTURA
	GROUP BY FechaOr
	ORDER BY FechaOr ASC

END


