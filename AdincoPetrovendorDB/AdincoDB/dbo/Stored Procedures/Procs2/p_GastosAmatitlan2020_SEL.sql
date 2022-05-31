CREATE PROC [dbo].[p_GastosAmatitlan2020_SEL]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM [dbo].[AP_Usuario]
        WHERE Usuario Like '%@pemex%'
              AND UsuarioID = @IdUsuario
    )
    BEGIN
        DECLARE @DiaActual DATE = GETDATE(),
                @MesPresentacionDisponible DATE;

        IF (@DiaActual >= DATEFROMPARTS(YEAR(@DiaActual), MONTH(@DiaActual), 6))
        BEGIN
            SELECT DISTINCT
                @MesPresentacionDisponible = UltimoDiaMes --'YA SE PUEDEN VER LOS GASTOS DEL MES ANTERIOR'
            FROM AP_Calendario
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
            FROM AP_Calendario
            WHERE PrimerDiaMes = DATEFROMPARTS(
                                                  YEAR(DATEADD(MONTH, -2, @DiaActual)),
                                                  MONTH(DATEADD(MONTH, -2, @DiaActual)),
                                                  1
                                              )
            ORDER BY UltimoDiaMes DESC;
        END

        SELECT *
        FROM GastosAmatitlan2020
        WHERE MesPresentacion <= @MesPresentacionDisponible;
    END
    ELSE
    BEGIN
        SELECT *
        FROM GastosAmatitlan2020
    END
END