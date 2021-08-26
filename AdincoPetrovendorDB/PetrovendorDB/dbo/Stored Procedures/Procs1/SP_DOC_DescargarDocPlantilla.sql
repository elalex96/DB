-- =============================================
-- Author:		Alexander Gomez
-- Create date: <22/07/2020>
-- Description:	<Descargar el documento de una plantilla obligatoria para el proveedor>
-- =============================================
-- Author:		Luis David
-- Create date: <26/08/2021>
-- Description:	retorna el bucket
-- =============================================
DROP PROCEDURE IF EXISTS SP_DOC_DescargarDocPlantilla
GO
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


