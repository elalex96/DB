CREATE FUNCTION FN_EN_SumaDiasHabiles ( @Fecha DATETIME, @dias int )
RETURNS DATE
AS
BEGIN
	DECLARE @FechaRetorno DATETIME

	declare @DiasHabiles table (Id INT IDENTITY(1, 1),
                        IdFecha DATE);

    INSERT INTO @DiasHabiles
    (
        IdFecha
    )
    SELECT IdFecha
    FROM dbo.AP_Calendario
    WHERE IdFecha > @Fecha
        AND DATEADD(year, 3, @Fecha) >= IdFecha
        AND FinDeSemana = 0
        AND DiaLaborable = 1
    ORDER BY IdFecha ASC;

	SELECT
            @FechaRetorno =	    DH.IdFecha
    FROM @DiasHabiles DH
    WHERE
        @dias  = DH.Id

    RETURN @FechaRetorno
END