CREATE PROCEDURE ObtenerUnidades
AS
BEGIN
	SELECT IdUnidad, NombreUnidad, Activo FROM PR_Unidades (NOLOCK)
END


