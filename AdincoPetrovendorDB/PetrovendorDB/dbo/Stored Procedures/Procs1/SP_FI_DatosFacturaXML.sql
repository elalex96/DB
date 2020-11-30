-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/10/2019>
-- Description:	<Consulta datos del xml de la factura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_DatosFacturaXML] 
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		F.Emisor,
		PRSUB.RazonSocial,
		F.Receptor,
		PROPE.RazonSocial,
		F.FechaTimbrado,
		F.TipoComprobante,
		F.FormaPago,
		F.MetodoPago,
		F.Folio,
		ISNULL(F.Moneda,TM.TipoMonedaCorto),
		F.UUID,
		F.XML,
		F.MontoConIva
	FROM dbo.FI_Factura AS F
		LEFT JOIN dbo.S_Proveedor AS PROPE ON PROPE.RFC = F.Receptor
		LEFT JOIN dbo.S_Proveedor AS PRSUB ON PRSUB.RFC = F.Emisor
		LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = F.IdMoneda
	WHERE F.IdFactura = @IdFactura
	GROUP BY ISNULL(F.Moneda, TM.TipoMonedaCorto),
             F.Emisor,
             PROPE.RazonSocial,
             F.Receptor,
             PRSUB.RazonSocial,
             F.FechaTimbrado,
             F.TipoComprobante,
             F.FormaPago,
             F.MetodoPago,
             F.Folio,
             F.UUID,
             F.XML,
             F.MontoConIva;


END
