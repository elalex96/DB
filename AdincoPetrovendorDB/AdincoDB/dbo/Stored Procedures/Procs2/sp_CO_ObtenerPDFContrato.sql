
CREATE PROCEDURE [dbo].[sp_CO_ObtenerPDFContrato]
@pIdContrato	INT
AS
BEGIN
	SELECT
		A.AWSDocumentoId, 
		A.Bucket,
		A.Folder,
		A.UUIDAmazon,
		A.NombreArchivo,
		A.Meta,
		A.CreadoPor,
		A.CreadoEl,
		A.ModificadoPor,
		A.ModificadoEl
	FROM 
		CO_ContratoPDF PDF
	JOIN
		AWS_Documentos	A
		ON	PDF.AWSDocumentoId	=	A.AWSDocumentoId
	WHERE 
		PDF.IdContrato = @pIdContrato
END

