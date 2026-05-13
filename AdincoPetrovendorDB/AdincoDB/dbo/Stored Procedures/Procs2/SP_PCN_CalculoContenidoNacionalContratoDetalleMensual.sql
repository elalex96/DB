
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/10/2018
-- Description:	Consulta el contenido nacional de un contrato y sus detalles
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_CalculoContenidoNacionalContratoDetalleMensual] --3
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

	CREATE TABLE #MONTOSFACTURA(ValorFactura FLOAT, PCN FLOAT, MontoPCN FLOAT, Fecha DATE, FechaOr DATE, IdFactura INT, SubTotal FLOAT)


	INSERT INTO #MONTOSFACTURA
	SELECT 
		   ISNULL(V.ValorFactura,0) AS ValorFactura,
           ISNULL(ROUND(APD.PCN, 3),0) AS PCN,
		   ISNULL(ROUND(APD.PCN, 3),0) * ISNULL(V.ValorFactura,0) AS MontoPCN,
		   FI.FechaTimbrado,
		   CAST(CONCAT(YEAR(FI.FechaTimbrado),'/',MONTH(FI.FechaTimbrado),'/01') AS DATE),
		   FI.IdFactura,
		   FI.SubTotal
    FROM Petrovendor.dbo.MM_AceptacionPedidoDetalle AS APD
        JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		JOIN Petrovendor.dbo.MM_PCN_ValoresPesos AS V 
		ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle       
        INNER JOIN Petrovendor.dbo.MM_Pedido AS P
            ON P.IdPedido = PD.IdPedido
		LEFT JOIN Petrovendor.dbo.MM_Pedido AS PE ON PE.IdPedido = PD.IdPedido AND AP.IdPedido = PE.IdPedido
		LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
		LEFT JOIN Petrovendor.dbo.FI_Factura AS FI ON FI.IdFactura = AF.IdFactura
    WHERE AF.IdEstatusXML = 2
		AND FI.IdContrato = @IDCONTRATO
	GROUP BY V.ValorFactura,APD.PCN,FI.FechaTimbrado,FI.IdFactura,FI.SubTotal
	ORDER BY FI.FechaTimbrado DESC
	
	SELECT
		SUM(ValorFactura) AS ValorFactura,
		SUM(MontoPCN) AS MontoPCN,
		--YEAR(Fecha) AS Anio,
		--MONTH(Fecha) AS Mes,
		CAST(YEAR(FechaOr) AS NVARCHAR(50)) + '/' + CAST(MONTH(FechaOr) AS NVARCHAR(50)) AS Fecha,
		ROUND(SUM(MontoPCN) / SUM(ValorFactura),4) AS PCN,
		SUM(SubTotal) AS TotalFacturas,
		FechaOr
	FROM #MONTOSFACTURA
	GROUP BY FechaOr
	ORDER BY FechaOr ASC

END
