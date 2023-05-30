CREATE PROCEDURE [dbo].[SP_AP_ObtenerCalendarioExcepciones]
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    SELECT ROW_NUMBER() OVER (ORDER BY [IdFecha] DESC) AS Id,
           [IdFecha],
           [IdRegulador],
           [Descripcion],
           [DiaDeSemana],
           ISNULL([Activo], 0) AS [Activo]
    FROM [Adinco].[dbo].[AP_CalendarioExcepciones] (NOLOCK)
    ORDER BY [IdFecha] DESC
END