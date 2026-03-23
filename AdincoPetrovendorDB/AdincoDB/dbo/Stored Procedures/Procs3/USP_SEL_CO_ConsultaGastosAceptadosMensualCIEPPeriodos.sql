IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ConsultaGastosAceptadosMensualCIEPPeriodos'
    )
    DROP PROCEDURE USP_SEL_CO_ConsultaGastosAceptadosMensualCIEPPeriodos;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ConsultaGastosAceptadosMensualCIEPPeriodos]
    @IdUsuario   INT = 0,
    @IdContrato   INT,
    @FechaInicio DATETIME,
    @FechaFin    DATETIME
AS
    BEGIN
        SET NOCOUNT ON;
        set language spanish;

        SELECT
            [IdGEAceptadoMes],
            [IdContrato],
            [GEAprobados]                                                                    as Monto,
            [Mes],
            [CreadoPor],
            [CreadoEl],
            [ModificadoPor],
            [ModificadoEl],
            [Activo]                                                                         Activo,
            RIGHT('00' + CAST(month([Mes]) AS VARCHAR(2)), 2) + ' ' + DATENAME(month, [Mes]) as NombreMes,
            DATENAME(YEAR, [Mes])                                                            as Anio
        FROM
            CO_GEAceptadosMes (NOLOCK)
        WHERE
            IdContrato = @IdContrato
            AND Mes BETWEEN @FechaInicio AND @FechaFin
    END
