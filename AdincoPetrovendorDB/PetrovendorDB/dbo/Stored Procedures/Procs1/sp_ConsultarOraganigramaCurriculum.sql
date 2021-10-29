-- =============================================
-- Author:		<Pedro, Acuña>
-- Modified date: <09/10/2018>
-- Description:	<descarga del documento para el s3>
-- =============================================

CREATE PROCEDURE [dbo].sp_ConsultarOraganigramaCurriculum
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, @Tipo INT
AS
	BEGIN
		SET NOCOUNT ON ;

		IF ( @Tipo = 0 ) --curriculum
		BEGIN
			SELECT		doc.Carpeta, doc.Identificador, doc.Mime, doc.NombreDocumento, doc.Bucket
			FROM		dbo.PV_PerfilEmpresa per
			INNER JOIN	dbo.S_Documento_S3 doc
				ON doc.IdDocumento = per.IdDocumentoCurriculum
			WHERE		per.IdProveedor = @IdProveedor
		END
	ELSE
		BEGIN -- organigrama
			SELECT		doc.Carpeta, doc.Identificador, doc.Mime, doc.NombreDocumento, doc.Bucket
			FROM		dbo.PV_PerfilEmpresa perf
			INNER JOIN	dbo.S_Documento_S3 doc
				ON perf.IdDocumentoOrganigrama = doc.IdDocumento
			WHERE		perf.IdProveedor = @IdProveedor
		END
	END
