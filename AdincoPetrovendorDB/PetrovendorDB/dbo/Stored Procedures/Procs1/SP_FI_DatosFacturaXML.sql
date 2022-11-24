-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/10/2019>
-- Description:	<Consulta datos del xml de la factura>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
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
	FROM dbo.FI_Factura AS F (NOLOCK)
		LEFT JOIN dbo.S_Proveedor AS PROPE  (NOLOCK)
			ON  F.Receptor = PROPE.RFC 
		LEFT JOIN dbo.S_Proveedor AS PRSUB  (NOLOCK)
			ON F.Emisor = PRSUB.RFC 
		LEFT JOIN dbo.PV_TipoMoneda AS TM  (NOLOCK)
			ON F.IdMoneda = TM.IdMoneda 
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
