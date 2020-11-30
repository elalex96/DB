-- =============================================
-- Author:		Reyna Olvera
-- Create date: 19/08/2019
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_PR_ExtraeFormatosProduccion]--10061,3
@IdContrato int,
@IdTipoFormato int,
@IdUsuario int
AS
BEGIN
    SET NOCOUNT ON;
	Select
	IdFormatoProduccionAWS,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta
	from PR_FormatoProduccionAWS doc
	where IdTipoFormato= @IdTipoFormato AND
	 IdContrato=@IdContrato

END


