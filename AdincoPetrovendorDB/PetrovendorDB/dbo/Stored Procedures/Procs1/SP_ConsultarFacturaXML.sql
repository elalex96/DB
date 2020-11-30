-- =============================================
-- Author:		Daniel AC
-- Create date: 25/09/2019
-- Description: Add column IdLectorXMLSAT
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarFacturaXML]
	-- Add the parameters for the stored procedure here
	@IdFactura INT 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT ComprobantePDFByte, 
	ComprobanteXMLByte, 
	XML, 
	IdContrato,
	UUID,
	ISNULL(ArchivoPDF,'') AS ArchivoPDF,
    ISNULL(IdTipoPedido,0),
	ISNULL(IdLectorXMLSAT,1) AS IdLectorXMLSAT
	FROM [dbo].[FI_Factura]
	WHERE [IdFactura]=@IdFactura
	 
END

		