CREATE  PROCEDURE [dbo].[SP_DOC_DescargarDocPlantilla]

@IdProveedor INT,
@IdDocumento INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		NombreDocumento,
		Extension,
		Mime,
		Carpeta,
		Identificador,
		ISNULL(Bucket,'') Bucket
	FROM dbo.S_Documento_S3
	WHERE IdDocumento = @IdDocumento;
END