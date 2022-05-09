CREATE PROC p_GastosAmatitlan2020_SEL 
 AS
 BEGIN
		DECLARE @DiaActual DATE = GETDATE(), @MesPresentacionDisponible DATE;
		if(@DiaActual  >= DATEFROMPARTS(YEAR(@DiaActual),MONTH(@DiaActual),6))
		BEGIN
			 SELECT DISTINCT @MesPresentacionDisponible = UltimoDiaMes--'YA SE PUEDEN VER LOS GASTOS DEL MES ANTERIOR'
			 FROM AP_Calendario 
			 WHERE PrimerDiaMes = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, @DiaActual)),MONTH(DATEADD(MONTH, -1, @DiaActual)),1)
			 ORDER BY UltimoDiaMes	DESC;
		END
		ELSE
		BEGIN
			 SELECT DISTINCT @MesPresentacionDisponible = UltimoDiaMes --'SOLO SE PUEDEN VER LOS GASTOS DEL DOS MESES ANTES';
			 FROM AP_Calendario 
			 WHERE PrimerDiaMes = DATEFROMPARTS(YEAR(DATEADD(MONTH, -2, @DiaActual)),MONTH(DATEADD(MONTH, -2, @DiaActual)),1)
			 ORDER BY UltimoDiaMes	DESC;
		END

	SELECT *
	FROM GastosAmatitlan2020
	WHERE MesPresentacion <= @MesPresentacionDisponible;
END

	