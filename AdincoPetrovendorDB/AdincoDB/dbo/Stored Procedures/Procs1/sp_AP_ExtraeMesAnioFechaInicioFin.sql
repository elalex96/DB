CREATE PROCEDURE dbo.sp_AP_ExtraeMesAnioFechaInicioFin-- 3,10061
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;    
         SET LANGUAGE spanish;
         DECLARE @FechaEfectiva AS DATE

         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;

		SELECT CAST(C.PrimerDiaMes AS DATE) AS IdFechaInicio, 
            CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS FechaInicio,

			CAST(C.UltimoDiaMes AS DATE) AS IdFechaFin, 
            CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS FechaFin
        FROM AP_Calendario C
        WHERE C.Dia = 1
			AND 
			C.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND DATEADD(YEAR, 2,CURRENT_TIMESTAMP)
        ORDER BY c.IdFecha DESC;
END