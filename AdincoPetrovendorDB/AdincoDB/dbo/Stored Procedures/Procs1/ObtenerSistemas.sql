CREATE PROCEDURE ObtenerSistemas
AS
BEGIN
	SELECT IdSistema, NombreSistema, Activo FROM PR_Sistemas (NOLOCK)
END


