CREATE PROCEDURE [dbo].[SP_ValidarAdministracionDeCalendarios]
    @IdFecha DATE,
    @IdRegulador INT,
    @Tipo VARCHAR(100),
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Mensaje VARCHAR(100) = 'VALIDO',
            @CountActivos INT = 0,
            @CountInactivos INT = 0;

    SELECT @CountActivos = COUNT(IdFecha)
    FROM AP_CalendarioExcepciones
    WHERE IdFecha = @IdFecha
          AND IdRegulador = @IdRegulador
          AND ISNULL(Activo, 0) <> 0

    SELECT @CountInactivos = COUNT(IdFecha)
    FROM AP_CalendarioExcepciones
    WHERE IdFecha = @IdFecha
          AND IdRegulador = @IdRegulador
          AND ISNULL(Activo, 0) = 0

    IF (@Tipo = 'Edición')
    BEGIN
        IF (@CountActivos > 1)
            SET @Mensaje = 'FECHA_CON_REGULADOR_ACTIVA';

        IF (@CountInactivos > 1)
            SET @Mensaje = 'FECHA_CON_REGULADOR_INACTIVA';
    END
    ELSE
    BEGIN
        IF (@CountActivos > 0)
            SET @Mensaje = 'FECHA_CON_REGULADOR_ACTIVA';

        IF (@CountInactivos > 0)
            SET @Mensaje = 'FECHA_CON_REGULADOR_INACTIVA';
    END

	SELECT @Mensaje AS 'MENSAJE';
END