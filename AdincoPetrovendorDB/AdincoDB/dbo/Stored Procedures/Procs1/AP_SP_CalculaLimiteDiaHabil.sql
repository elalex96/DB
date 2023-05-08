
CREATE PROCEDURE dbo.AP_SP_CalculaLimiteDiaHabil-- 3,10,'20230101',10
    @IdContrato      INT,
	@IdUsuario      INT,
    @Fecha DATE,
    @DiaHabilSolicitado    INT= 0
AS
    BEGIN

        CREATE TABLE #DiasHabiles
            (
                Fecha       DATETIME,
                Anio        INT,
                Mes         INT,
                Dia         INT,
                NumDiaHabil INT
            )
        INSERT INTO #DiasHabiles
            (
                Fecha,
                Anio,
                Mes,
                Dia,
                NumDiaHabil
            )
                    SELECT
                        IdFecha,
                        Anio,
                        Mes,
                        Dia,
                        ROW_NUMBER() OVER (ORDER BY
                                               Dia
                                          ) AS NumDiaHabil
                    FROM
                        dbo.AP_Calendario (NOLOCK)
                    WHERE
                        PrimerDiaMes = @Fecha
                        AND NombreDia NOT IN (
                                                 'Sábado', 'Domingo'
                                             )
                        AND DiaFeriado <> 1
                    ORDER BY
                        Dia

        SELECT
             DATEADD(MINUTE, 59, DATEADD(HOUR, 23, Fecha))
        FROM
            #DiasHabiles
        WHERE
            NumDiaHabil = @DiaHabilSolicitado
    END