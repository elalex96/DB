-- =============================================
-- Author:		ALexander Gomez
-- Create date: 29/10/2018
-- Description:	Consulta de los detalles de la PRE-SES
-- =============================================
CREATE procedure [dbo].[SP_MPY_DetallesPre_SES]
	-- Add the parameters for the stored procedure here
	@PONumber NVARCHAR(20),
	@RFCProveedor NVARCHAR(20),
	@IdPRESES INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT
		PSES.IdPRESES,--0
		PSES.IdEstatus,--1
		DOCPRESES.NombreDoc,--2
		DOCPRESES.Identificador,--3
		DOCPRESES.Extension,--4
		DOCPRESES.Mime,--5
		DOCPRESES.Carpeta,
		PSES.SAPSESNumber,
		PSES.MontoTotalPrefactura,
		ISNULL(PSES.Plant,'') AS Plant,
		ISNULL(DOCPRESES.Bucket,'') AS Bucket
	FROM Adinco.dbo.CO_SAPPRESES AS PSES
		JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PSES.SAPVendorNumber
		JOIN Adinco.dbo.MPY_DocumentosPRESES AS DOCPRESES ON DOCPRESES.IdPRESES = PSES.IdPRESES
	WHERE PSES.SAPPONumber = @PONumber
		AND PSES.IdPRESES = @IdPRESES
		AND V.TaxID = @RFCProveedor
		AND DOCPRESES.IdTipoDocumento = 1
	ORDER BY PSES.CreadoEl DESC

END