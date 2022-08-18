USE Adinco;
GO
-- =============================================
-- Author:	Reyna Olvera
--  date: 17/08/2022
-- Description:	detecta los meses faltantes de verificar por SDK
-- =============================================
CREATE PROCEDURE [dbo].SP_AP_RangoTipoCambioMensualSinSDK 
	@IdContrato INT, 
	@IdUsuario  INT,
	@IdMoneda INT
AS
BEGIN
	CREATE TABLE #AnioMes(id int identity(1,1), Anio int, IdMes int);
	DECLARE @UltimoDiaMes DATETIME,
		@FechaActual DATETIME;

	SELECT @FechaActual = GETDATE();

	SELECT @UltimoDiaMes = EOMONTH(@FechaActual);

	INSERT INTO #AnioMes(Anio, IdMes)
	SELECT ANIO, IdMes 
	FROM 
		CO_TipoCambioMensual 
	WHERE	IdMoneda	=	@IdMoneda 
	AND		ISNULL(ObtenidoSDK,0)	=	0;


	INSERT INTO #AnioMes(Anio, IdMes) -- meses y años que no estan  en la tabla de tipo cambio mensual
	SELECT YEAR( AP_Calendario.PrimerDiaMes),MONTH( AP_Calendario.PrimerDiaMes)
	FROM 
		AP_Calendario
	LEFT JOIN 
		CO_TipoCambioMensual
	ON	AP_Calendario.PrimerDiaMes	=	
		DATEFROMPARTS(CO_TipoCambioMensual.Anio, CO_TipoCambioMensual.IdMes,1)
		AND CO_TipoCambioMensual.IdMoneda = @IdMoneda
	 WHERE AP_Calendario.IdFecha < GETDATE() AND  CO_TipoCambioMensual.IdTipoCambioMensual IS NULL
	GROUP BY  AP_Calendario.PrimerDiaMes,CO_TipoCambioMensual.Anio, CO_TipoCambioMensual.IdMes
	order by  AP_Calendario.PrimerDiaMes DESC;


	IF((SELECT COUNT(id) FROM #AnioMes) > 0)
	BEGIN
		SELECT MIN(DATEFROMPARTS(ANIO, IdMes,1)) AS Inicio ,MAX(EOMONTH(DATEFROMPARTS(ANIO, IdMes,1))) AS Fin
		FROM #AnioMes
	END
END ;