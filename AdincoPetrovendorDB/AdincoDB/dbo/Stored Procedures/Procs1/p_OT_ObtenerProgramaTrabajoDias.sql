
-- p_OT_ObtenerProgramaTrabajoDias 1,'20171101-20171105'
CREATE PROC p_OT_ObtenerProgramaTrabajoDias
@pIdOTSolicitud INT,
@pSemana VARCHAR(21)
AS


	DECLARE @IdOTSolicitudMaterial INT,
		@fechaProgramaIni DATETIME,
		@fechaProgramaFin DATETIME,
		@fechaIndice DATETIME,
		@fechaIniFiltro DATETIME=null,
		@fechaFinFiltro DATETIME=null

	CREATE TABLE #tmpSemana(
		Fecha VARCHAR(10)
	)

	INSERT INTO #tmpSemana
	SELECT *
	FROM [dbo].[fnSplitString](@pSemana,'-')

	IF exists(
		SELECT 1
		FROM #tmpSemana
	)
	BEGIN 
		SELECT @fechaIniFiltro = MIN(Fecha),
			@fechaFinFiltro = MAX(fecha)
			FROM #tmpSemana
	END

        
	CREATE TABLE #tmpServiciosDias
	(
		IdOTSolicitudMaterial int,
		Fecha DATETIME,
		IdAnioMesDia INT,
		FormatoFechaColumna VARCHAR(20)	
	)

	SELECT sol.Folio,
		solm.IdSCMaterial,
		mat.TextoCorto,		
		solmb.IdOTSolicitudMaterial,
		solm.FechaProgramaInicio,
		solm.FechaProgramaFin
		INTO #tmpSolicitudMaterial
	FROM OT_Solicitud sol
	
	INNER JOIN OT_SolicitudMaterial solm ON solm.IdOTSolicitud = SOL.IdOTSolicitud
	INNER JOIN OT_SolicitudPrograma solmb ON solmb.IdOTSolicitudMaterial = solm.IdOTSolicitudMaterial
	INNER JOIN SC_Materiales scMat ON scMat.IdSCMaterial = solm.IdSCMaterial
	INNER JOIN Petrovendor.dbo.MM_Maestro mat ON mat.IdMaestro = scMat.IdMaestro
	WHERE sol.IdOTSolicitud = @pIdOTSolicitud
	GROUP BY sol.Folio,
		solm.IdSCMaterial,
		mat.TextoCorto,		
		solmb.IdOTSolicitudMaterial,
		solm.FechaProgramaInicio,
		solm.FechaProgramaFin
	ORDER BY solmb.IdOTSolicitudMaterial

	SELECT @IdOTSolicitudMaterial=MIN(IdOTSolicitudMaterial)
	FROM #tmpSolicitudMaterial

	/*********Recorre cada solicitud material para obtener los dias que se tienen que capturar*****/
	WHILE @IdOTSolicitudMaterial IS NOT NULL
    BEGIN

		SELECT @fechaProgramaIni = FechaProgramaInicio,
			@fechaProgramaFin = FechaProgramaFin,
			@fechaIndice = FechaProgramaInicio
		FROM #tmpSolicitudMaterial
		WHERE IdOTSolicitudMaterial = @IdOTSolicitudMaterial

		WHILE @fechaIndice <= @fechaProgramaFin
		BEGIN 

			INSERT INTO #tmpServiciosDias (IdOTSolicitudMaterial,Fecha,IdAnioMesDia,FormatoFechaColumna) 
			SELECT @IdOTSolicitudMaterial,
					@fechaIndice,
					(DATEPART(yy,@fechaIndice)*10000) +
					(DATEPART(mm,@fechaIndice)*100) +
					DATEPART(dd,@fechaIndice)
					,
					CAST(DATEPART(dd,@fechaIndice) AS varchar) + '-'+
					UPPER(SUBSTRING(DATENAME(MONTH, @fechaIndice) ,1,3))+ '-'+
					SUBSTRING(CAST(DATEPART(yy,@fechaIndice) AS varchar),3,2)

			SET @fechaIndice=DATEADD(dd,1,@fechaIndice)

		end


		SELECT @IdOTSolicitudMaterial=MIN(IdOTSolicitudMaterial)
	FROM #tmpSolicitudMaterial
	WHERE IdOTSolicitudMaterial > @IdOTSolicitudMaterial

    END
    

	--SELECT * FROM #tmpSolicitudMaterial
	SELECT * FROM #tmpServiciosDias
	WHERE (fecha BETWEEN @fechaIniFiltro AND @fechaFinFiltro)
	OR
	(@fechaIniFiltro IS NULL AND @fechaFinFiltro IS null)




