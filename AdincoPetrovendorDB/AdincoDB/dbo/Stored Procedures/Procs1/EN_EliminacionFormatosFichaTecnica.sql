CREATE PROCEDURE [dbo].[EN_EliminacionFormatosFichaTecnica]--10061,3
@idTipoFormatoFichaTecnica int
AS
BEGIN
    SET NOCOUNT ON;
	Delete EN_DocumentoFormatoFichaTecnica where IdFormatoFichaTecnica=@idTipoFormatoFichaTecnica
END