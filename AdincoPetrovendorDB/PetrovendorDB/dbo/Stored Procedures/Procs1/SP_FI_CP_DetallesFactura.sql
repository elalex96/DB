-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <13/01/2020>
-- Description:	<consulta de los detalles de la factura con complementos de pago>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CP_DetallesFactura]
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UUID NVARCHAR(100) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura)
	DECLARE @IFACTURAADINCO INT = (SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID);
	DECLARE @TIPOMONEDA INT = (SELECT IdMoneda FROM Adinco.dbo.FI_Factura WHERE IdFactura = @IFACTURAADINCO);

	DECLARE @MONTOACUMULADO FLOAT = (SELECT 
										SUM(
											CASE 
												WHEN @TIPOMONEDA = 1 AND DRCP.MonedaDR = 'MXN' THEN ISNULL(DRCP.ImpPagado,0)
												WHEN @TIPOMONEDA = 1 AND DRCP.MonedaDR = 'USD' THEN ISNULL(dbo.FN_DolaresPesosTipoCambio(DRCP.ImpPagado,F.FechaRecepcion),0)
												WHEN @TIPOMONEDA = 2 AND DRCP.MonedaDR = 'MXN' THEN ISNULL(dbo.FN_PesosDolaresTipoCambio(DRCP.ImpPagado,F.FechaRecepcion),0)
												WHEN @TIPOMONEDA = 2 AND DRCP.MonedaDR = 'USD' THEN ISNULL(DRCP.ImpPagado,0)
											END) 
										FROM Adinco.dbo.FI_CPDocRelacionado AS DRCP
										LEFT JOIN Adinco.dbo.FI_ComplementoDePago AS CP
											ON CP.IdComplementoDePago = DRCP.IdComplementoDePago
										LEFT JOIN Adinco.dbo.FI_Factura AS F
											ON F.IdFactura = CP.IdFactura
										WHERE IdDocumento = @UUID);

	SELECT
		F.IdFactura,
		F.UUID,
		ISNULL(MTP.MetodoPago,'') + ' (' + MTP.C_FormaPago + ')' AS MetodoPago,
		FORMAT(F.FechaTimbrado,'dd/MM/yyyy HH:mm:ss tt') AS FechaTimbrado,
		FORMAT(F.FechaRecepcion,'dd/MM/yyyy HH:mm:ss tt') AS FechaRecepcion,
		F.Emisor AS RFCEmisor,
		PR.RazonSocial AS NombreProveedor,
		TM.TipoMonedaCorto AS TipoMoneda,
		F.SubTotal,
		F.MontoConIva AS Total,
		@MONTOACUMULADO AS MontoAcumulado,
		(F.MontoConIva - @MONTOACUMULADO) AS MontoInsoluto,
		 FP.ComprobantePDFByte,
		 FP.ComprobanteXMLByte
	FROM Adinco.dbo.FI_Factura AS F
		LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = F.IdMoneda
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = F.Emisor
		LEFT JOIN Petrovendor.dbo.FI_Factura AS FP
			ON FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = F.UUID
		LEFT JOIN Adinco.dbo.PV_MetodoPago AS MTP
			ON MTP.C_FormaPago = F.MetodoPago
	WHERE F.IdFactura = @IFACTURAADINCO;

END
