-- =============================================
-- Author:		Alexander Gomez
-- Create date: 11/05/2018
-- Description:	Consulta de detalles de la Factura
-- =============================================
-- Author:		Marcos Garcia
-- Alter date:  04/02/2020
-- Description:	AgregarCapoConcat Serie/Folio
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaDetallesFactura]
--[SP_FI_ConsultaDetallesFactura] 56744
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		FAC.IdFactura, 
		FAC.Serie, 
		FAC.Folio, 
		FAC.Emisor,
		FAC.Receptor,
		FAC.SubTotal, 
		FAC.MontoConIva, 
		FAC.Moneda, 
		FAC.LugarExpedicion, 
		FAC.FechaTimbrado, 
		FAC.FechaRecepcion,
		CONVERT(DATE,FAC.Fecha) AS Fecha,
		FAC.CondicionesDePago,
		FAC.UUID,
		FAC.TipoComprobante,
		FDOC.DocumentoByte,
		ISNULL(FAC.XML,'') AS XML,
		ISNULL(EFAC.Estatus,'En Aprobación de Pago') AS EstatusPago, 
		ISNULL(US.Nombre,'Sin Aprobador') AS UsuarioAprobador,
		PSB.RazonSocial,
		FAC.FormaPago,
		FAC.UsoCFDI,
		FAC.VersionCFDI,
		LTRIM(CONCAT('Serie: ',ISNULL(FAC.Serie,'-'),' | Folio: ',ISNULL(FAC.Folio,'-'))) AS SerieFolio
	FROM dbo.FI_Factura AS FAC
	LEFT JOIN dbo.FI_AprobacionFactura AS AFAC ON AFAC.IdFactura = FAC.IdFactura
	LEFT JOIN dbo.FI_Estatus AS EFAC ON EFAC.IdEstatus = AFAC.IdEstatus
	LEFT JOIN dbo.AP_Usuario AS US ON US.UsuarioID = AFAC.IdUsuarioAprobador
	LEFT JOIN dbo.FI_Documento AS FDOC ON FDOC.IdFactura = FAC.IdFactura
	LEFT JOIN dbo.PV_Subcontratista AS PSB ON PSB.IdSubcontratista = FAC.IdSubcontratista
	WHERE FAC.IdFactura = @IdFactura
	ORDER BY FAC.Fecha DESC
END
