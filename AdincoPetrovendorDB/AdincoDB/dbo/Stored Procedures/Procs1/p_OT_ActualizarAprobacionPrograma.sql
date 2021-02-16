CREATE PROC p_OT_ActualizarAprobacionPrograma
@pIdOTSolicitud INT,
@pSemana VARCHAR(21),
@pTipoUsuario INT ,--1 contratista , 2 subcontratista
@pLunesAprob BIT,
@pMartesAprob BIT,
@pMiercolesAprob BIT,
@pJuevesAprob BIT,
@pViernesAprob BIT,
@pSabadoAprob BIT,
@pDomingoAprob BIT,
@pCreadoPor VARCHAR(100),
@pUsuarioId int=0
AS

	DECLARE @fechaIni DATETIME,
			@fechaFin DATETIME,
			@error varchar(250)='',
			@descripcionBitacora varchar(150)

			

	CREATE TABLE #tmpSemana(
		Fecha VARCHAR(10)
	)

	INSERT INTO #tmpSemana
	SELECT *
	FROM [dbo].[fnSplitString](@pSemana,'-')


	IF exists(
		SELECT 1
		FROM OT_Solicitud
		WHERE IdOTSolicitud=@pIdOTSolicitud AND
        rtrim(isnull(SAPPR,'')) = ''  and
		@pTipoUsuario = 1
	)
	BEGIN

		exec p_OT_CorreoProgramacion_Flujo @pIdOTSolicitud,10,'',104


		RAISERROR (15600,-1,-1, '[ALERTA]:Falta la captura de PR, la información no se guardó. Ya se notificó al area correspondiente ');  
		RETURN
    end


	IF exists(
		SELECT 1
		FROM OT_ProgramaSemanaCerrada
		WHERE IdOTSolicitud=@pIdOTSolicitud AND
        SemanaID = @pSemana and
		isactivo = 1
	)
	BEGIN
		RAISERROR (15600,-1,-1, '[ALERTA]:La semana está cerrada, no es posible realizar cambios');  
		RETURN
    end

	
	IF exists(
		SELECT 1
		FROM #tmpSemana
	)
	BEGIN 
		SELECT @fechaIni = MIN(Fecha),			
			@fechaFin = MAX(fecha)
			FROM #tmpSemana
	END



	--CONTRATISTA
	IF(
		@pTipoUsuario =1 
	)
	BEGIN
		update dbo.OT_SolicitudProgramaCaptura
		SET VoBoContratista = CASE WHEN DATEPART(WEEKDAY,Fecha) = 1 THEN @pDomingoAprob 
									WHEN DATEPART(WEEKDAY,Fecha) = 2 THEN @pLunesAprob 
									WHEN DATEPART(WEEKDAY,Fecha) = 3 THEN @pMartesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 4 THEN @pMiercolesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 5 THEN @pJuevesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 6 THEN @pViernesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 7 THEN @pSabadoAprob
									ELSE VoBoContratista
								END,
			FechaVoBoContratista = GETDATE() ,
			QuienVoBoContratista = @pCreadoPor
		FROM OT_SolicitudProgramaCaptura sp
		INNER JOIN dbo.OT_SolicitudMaterial sm ON sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
		WHERE sm.IdOTSolicitud = @pIdOTSolicitud AND
        convert(varchar,sp.Fecha,112) BETWEEN convert(VARCHAR,@fechaIni,112) AND convert(VARCHAR,@fechaFin,112)

		set @descripcionBitacora = 'Modificación VoBo para semana:'+@pSemana


		
		exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcionBitacora,@pUsuarioId,null	
			

		exec  p_OT_CorreoProgramacion_flujo @pIdOTSolicitud,1,'',101
		
    END
    ELSE
	BEGIN
		update dbo.OT_SolicitudProgramaCaptura
		SET VoBoSubContratista = CASE WHEN DATEPART(WEEKDAY,Fecha) = 1 THEN @pDomingoAprob 
									WHEN DATEPART(WEEKDAY,Fecha) = 2 THEN @pLunesAprob 
									WHEN DATEPART(WEEKDAY,Fecha) = 3 THEN @pMartesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 4 THEN @pMiercolesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 5 THEN @pJuevesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 6 THEN @pViernesAprob
									WHEN DATEPART(WEEKDAY,Fecha) = 7 THEN @pSabadoAprob
									ELSE VoBoContratista
								END,
			FechaVoBoSubContratista = GETDATE() ,
			QuienVoBoSubontratista = @pCreadoPor
		FROM OT_SolicitudProgramaCaptura sp
		INNER JOIN dbo.OT_SolicitudMaterial sm ON sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
		WHERE sm.IdOTSolicitud = @pIdOTSolicitud AND
        convert(varchar,sp.Fecha,112) BETWEEN convert(VARCHAR,@fechaIni,112) AND convert(VARCHAR,@fechaFin,112)		
	
		set @descripcionBitacora = 'Modificación VoBo para semana:'+@pSemana		
		
		exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,@descripcionBitacora,null,@pUsuarioId
			
		exec  p_OT_CorreoProgramacion_flujo @pIdOTSolicitud,1,'',100
		

		
		
	END



