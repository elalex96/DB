CREATE PROCEDURE [dbo].[SP_EN_ObtenConjunciones]
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
	SELECT *
	FROM EN_ConjuncionesDocumentos
	WHERE Activo = 1
	ORDER BY ID DESC
END;