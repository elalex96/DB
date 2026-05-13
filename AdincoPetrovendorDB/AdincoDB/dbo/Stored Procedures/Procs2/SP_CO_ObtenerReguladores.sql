CREATE PROCEDURE [dbo].[SP_CO_ObtenerReguladores]
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    SELECT IdRegulador,
           CONCAT(Regulador, ' - ', NombreRegulador) AS NombreRegulador
    FROM CO_Regulador (NOLOCK)
    ORDER BY NombreRegulador ASC
END