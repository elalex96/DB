drop procedure if exists SP_DOC_DescargaDocumentosOCD
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/12/2020>
-- Description:	<Descarga de documentos de compra directa>
-- =============================================
-- Author:		<Luis David>
-- Create date: <20/01/2022>
-- Description:	<Se corrgige la descarga, asignando el idfactura correcto (@IdOperacion)>
CREATE PROCEDURE SP_DOC_DescargaDocumentosOCD
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdTipoOperacion INT
AS
BEGIN
	IF @IdTipoOperacion = 14
	BEGIN
		SELECT 
			ISNULL([ArchivoPDF],''), 
			'Factura_'+CAST(@IdOperacion AS NVARCHAR(300)),
			ComprobantePDFByte,
			'application/pdf',
			'.pdf'
		FROM [dbo].[FI_Factura]
		WHERE [IdFactura]= @IdOperacion
	END
END