IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_GastosAmatitlan2020'
)
    DROP PROCEDURE USP_SEL_GastosAmatitlan2020;
GO

CREATE PROCEDURE [USP_SEL_GastosAmatitlan2020]
    @ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    DECLARE @DiaActual DATE = GETDATE(),
            @MesPresentacionDisponible DATE;

    IF EXISTS
    (
        SELECT *
        FROM AP_Usuario (NOLOCK)
        WHERE Usuario LIKE '%@pemex%'
              AND UsuarioID = @UsuarioId
    )
    BEGIN
        IF (@DiaActual >= DATEFROMPARTS(YEAR(@DiaActual), MONTH(@DiaActual), 6))
        BEGIN
            SELECT DISTINCT
                @MesPresentacionDisponible = UltimoDiaMes --'YA SE PUEDEN VER LOS GASTOS DEL MES ANTERIOR'
            FROM AP_Calendario (NOLOCK)
            WHERE PrimerDiaMes = DATEFROMPARTS(
                                                  YEAR(DATEADD(MONTH, -1, @DiaActual)),
                                                  MONTH(DATEADD(MONTH, -1, @DiaActual)),
                                                  1
                                              )
            ORDER BY UltimoDiaMes DESC;
        END
        ELSE
        BEGIN
            SELECT DISTINCT
                @MesPresentacionDisponible = UltimoDiaMes --'SOLO SE PUEDEN VER LOS GASTOS DEL DOS MESES ANTES';
            FROM AP_Calendario (NOLOCK)
            WHERE PrimerDiaMes = DATEFROMPARTS(
                                                  YEAR(DATEADD(MONTH, -2, @DiaActual)),
                                                  MONTH(DATEADD(MONTH, -2, @DiaActual)),
                                                  1
                                              )
            ORDER BY UltimoDiaMes DESC;
        END

        SELECT GastosAmatitlan2020.*,
               CASE
                   WHEN ISNULL(CO_RegistroMarkup.TipoCambio, '') <> '' THEN
                       'Si'
                   ELSE
                       'No'
               END AS [Tipo Cambio Homologado]
        FROM GastosAmatitlan2020 (NOLOCK)
            LEFT JOIN CO_RegistroMarkup (NOLOCK)
                ON GastosAmatitlan2020.IdRegistro = CO_RegistroMarkup.GastoId
        WHERE MesPresentacion <= @MesPresentacionDisponible;
    END
    ELSE
    BEGIN
        SELECT GastosAmatitlan2020.*,
               CASE
                   WHEN ISNULL(CO_RegistroMarkup.TipoCambio, '') <> '' THEN
                       'Si'
                   ELSE
                       'No'
               END AS [Tipo Cambio Homologado]
        FROM GastosAmatitlan2020 (NOLOCK)
            LEFT JOIN CO_RegistroMarkup (NOLOCK)
                ON GastosAmatitlan2020.IdRegistro = CO_RegistroMarkup.GastoId
    END
END