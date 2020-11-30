-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Referencias al s3 
-- =============================================

CREATE PROCEDURE [dbo].[SP_PV_ConsultaSGDocumentoProveedor]
	-- Add the parameters for the stored procedure here
	@iddocsg INT
AS
	BEGIN
		SET NOCOUNT ON

		SELECT		SG.IdSistemaGestion, DSG.DocSistemaGestion, SG.NombreCertificacion, '' AS Documento, Activo, SG.Carpeta, SG.Mime, SG.Extension, SG.Identificador
		FROM		PV_SistemaGestion SG
		INNER JOIN	PV_DocSistemGestion AS DSG
			ON DSG.IdDocSistemaGestion = SG.IdTipoDocSG
		WHERE		SG.IdSistemaGestion = @iddocsg
	END
