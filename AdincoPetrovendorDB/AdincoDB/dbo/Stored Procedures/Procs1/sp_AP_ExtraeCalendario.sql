CREATE PROCEDURE [dbo].[sp_AP_ExtraeCalendario]--3,10061,1
@idContrato INT,
@idUsuario INT,
@IdRegulador INT
AS
BEGIN
    SET NOCOUNT ON;

	IF(@IdRegulador=0)
	BEGIN
		SELECT  IdFecha,
				Anio,
				Mes,
				Dia,
				DiaDeSemana,
				NombreDia,
				DayName,
				CONCAT (Mes,'-',NombreMes) AS NombreMes,
				MonthName,
				DiaDeAño as DiaDeAnio,
				Cuarto,
				PrimerDiaMes,
				UltimoDiaMes,
				InicioDia,
				TerminoDia,
				DiaLaborable,
				FinDeSemana,
				DiaFeriado,
				Descripcion from AP_Calendario
				WHERE ANIO   >= YEAR(GETDATE())
				AND   IdFecha <= DATEADD(YEAR,5,GETDATE())
	END
	ELSE
	BEGIN
			SELECT  C.IdFecha,
					Anio,
					Mes,
					Dia,
					C.DiaDeSemana,
					NombreDia,
					DayName,
					CONCAT (Mes,'-',NombreMes) AS NombreMes,
					MonthName,
					DiaDeAño as DiaDeAnio,
					Cuarto,
					PrimerDiaMes,
					UltimoDiaMes,
					InicioDia,
					TerminoDia,
					DiaLaborable,
					FinDeSemana,
					DiaFeriado,
					CASE 
					  WHEN ISNULL(LEN(C.Descripcion),0) <> 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CONCAT(C.Descripcion ,',',CE.Descripcion)
					  WHEN  ISNULL(LEN(C.Descripcion),0) <> 0  AND ISNULL(LEN(CE.Descripcion),0) = 0
						THEN  C.Descripcion
					  WHEN ISNULL(LEN(C.Descripcion),0) = 0 AND ISNULL(LEN(CE.Descripcion),0)<> 0
						THEN  CE.Descripcion
					 ELSE ' '
					END  AS Descripcion
				    FROM  AP_Calendario C
					LEFT JOIN AP_CalendarioExcepciones CE 
						ON C.IdFecha= CE.IdFecha AND CE.IdRegulador=@IdRegulador
						AND CE.Activo = 1
					WHERE ANIO   >= YEAR(GETDATE())
					AND   C.IdFecha <= DATEADD(YEAR,5,GETDATE())
	END
END;
