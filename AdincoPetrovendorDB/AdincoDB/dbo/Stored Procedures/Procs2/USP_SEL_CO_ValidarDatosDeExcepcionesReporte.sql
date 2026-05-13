IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ValidarDatosDeExcepcionesReporte'
)
    DROP PROCEDURE USP_SEL_CO_ValidarDatosDeExcepcionesReporte;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_ValidarDatosDeExcepcionesReporte]
    @ContratoId INT,
    @UsuarioId INT,
    @Id INT,
    @IdContrato INT,
    @MesReporte VARCHAR(50),
    @FechaFin DATETIME,
    @IdTipoReporte INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @FechaHoy DATE = DATEADD(DD, -1, GETDATE()),
            @FechaFinDate DATE = CONVERT(DATE, @FechaFin),
            @DetalleBitacora VARCHAR(4000) = '',
            @CuentaRegistrosIguales INT = 1;

    IF (@FechaFinDate < @FechaHoy)
    BEGIN
        SET @DetalleBitacora = 'FECHAMAXIMA';
    END

    SELECT @CuentaRegistrosIguales = COUNT(1)
    FROM CO_ExcepcionesReporte (NOLOCK)
    WHERE Id <> @Id
          AND IdContrato = @IdContrato
          AND MesReporte = CONVERT(DATE, @MesReporte)
          AND IdTipoReporte = @IdTipoReporte

    IF (@CuentaRegistrosIguales > 0)
    BEGIN
        SET @DetalleBitacora = CONCAT(@DetalleBitacora, 'CONTRATOMESTIPO');
    END

    IF (LEN(@DetalleBitacora) = 0)
    BEGIN
        SET @DetalleBitacora = 'CORRECTO';
    END

    SELECT @DetalleBitacora AS MENSAJE
END;