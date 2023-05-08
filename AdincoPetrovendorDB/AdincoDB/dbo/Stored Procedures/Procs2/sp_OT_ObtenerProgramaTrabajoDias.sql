
-- sp_OT_ObtenerProgramaTrabajoDias 1
CREATE PROC sp_OT_ObtenerProgramaTrabajoDias
@pIdOTSolicitud INT
AS


	DECLARE @IdOTSolicitudMaterial INT,
		@fechaProgramaIni DATETIME,
		@fechaProgramaFin DATETIME,
		@fechaIndice DATETIME
        
	CREATE TABLE #tmpServiciosDias
	(
		IdOTSolicitudMaterial int,
		Fecha DATETIME,
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

			INSERT INTO #tmpServiciosDias (IdOTSolicitudMaterial,Fecha,FormatoFechaColumna) 
			SELECT @IdOTSolicitudMaterial,
					@fechaIndice,
					CAST(DATEPART(dd,@fechaIndice) AS varchar) + '-'+
					UPPER(SUBSTRING(DATENAME(MONTH, @fechaIndice) ,1,3))+ '-'+
					SUBSTRING(CAST(DATEPART(yy,@fechaIndice) AS varchar),3,2)

			SET @fechaIndice=DATEADD(dd,1,@fechaIndice)

		end


		SELECT @IdOTSolicitudMaterial=MIN(IdOTSolicitudMaterial)
	FROM #tmpSolicitudMaterial
	WHERE IdOTSolicitudMaterial > @IdOTSolicitudMaterial

    END
    

	SELECT * FROM #tmpSolicitudMaterial
	SELECT * FROM #tmpServiciosDias





