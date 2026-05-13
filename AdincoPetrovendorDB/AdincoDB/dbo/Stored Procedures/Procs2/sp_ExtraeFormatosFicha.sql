---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- Author:		Reyna Olvera
-- Create date: 19/08/2019
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_ExtraeFormatosFicha]--10061,3
@pIdEntregable int,
@idTipoFormatoFichaTecnica int
AS
BEGIN
    SET NOCOUNT ON;
	Select
	IdFormatoFichaTecnica,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta
	from EN_DocumentoFormatoFichaTecnica doc
	where IdEntregable = @pIdEntregable AND
	 idTipoFormatoFichaTecnica=@idTipoFormatoFichaTecnica
END
