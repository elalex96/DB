CREATE FUNCTION FN_EN_RestaDiasHabiles ( @Fecha DATETIME,@dias int )
RETURNS DATE
AS
    BEGIN
		DECLARE @FechaRetorno DATETIME
		IF OBJECT_ID('tempdb..#DiasHabiles', 'U') IS NOT NULL
declare @DiasHabiles table (Id INT IDENTITY(1, 1),
                           IdFecha DATE);

            INSERT INTO @DiasHabiles
            (
                IdFecha
            )
            SELECT IdFecha
            FROM dbo.AP_Calendario
            WHERE IdFecha < @Fecha
                  AND DATEADD(year, -1, @Fecha) <= IdFecha
                  AND FinDeSemana = 0
                  AND DiaLaborable = 1
            ORDER BY IdFecha DESC;

		  SELECT TOP 1
              @FechaRetorno =
			    DH.IdFecha
                From @DiasHabiles DH
                     LEFT JOIN dbo.AP_Calendario C2
                    ON @Fecha >= C2.IdFecha
                       AND C2.IdFecha >DATEADD(MONTH, -6, @Fecha) 
                       AND C2.FinDeSemana = 0
                       AND C2.DiaLaborable = 1
					   where
					   @Fecha >= DH.IdFecha
                       AND @dias  = DH.Id

        RETURN @FechaRetorno
    END