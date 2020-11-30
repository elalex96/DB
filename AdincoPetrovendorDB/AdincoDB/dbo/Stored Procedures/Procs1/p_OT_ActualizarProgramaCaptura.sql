
CREATE PROC p_OT_ActualizarProgramaCaptura
@pIdOTSolicitudProgramaCaptura INT,
@pIdOTSolicitudMaterial INT,
@pSemana VARCHAR(21),
@pCaptura DECIMAL(14,5),
@pDiaSemana TINYINT,
@pCreadoPor VARCHAR(50),
@pCreadlEl DATETIME,
@pVoBoContratista BIT = null,
@pVoBoSubcontratista bit = NULL,
@pErrorOut VARCHAR(250) out
AS

    DECLARE @IdOTSolicitudProgramaCaptura INT,
            @fechaIni DATETIME,
            @fechaFin DATETIME,
            @fechaIndex DATETIME,
            @fechaCaptura DATETIME,
            @anioMesDia int,
            @IdOTSolicitud int,
			@decimales int

    select @IdOTSolicitud=IdOTSolicitud
    from OT_SolicitudMaterial
    where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial        
	
	/***Obtener la cantidad de decimales que se pude capturar***/
	select @decimales = c.Decimales
	from OT_Configurador c
	inner join OT_Solicitud ot on ot.IdOTSolicitud = @IdOTSolicitud
	inner join SC_SubContrato sc on sc.IdSubContrato = ot.IdSubContrato and
								c.IdContrato = sc.IdContrato

	/****Validar decimales, no debe de exceder el límite configurado***/
	if(isnull(@decimales,0) =0 )
	begin
		SET @pErrorOut = 'No está configurado el límite de decimales, por favor revisar'
		GOTO fin
		
	end
            
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
        SELECT @fechaIni = MIN(Fecha),
            @fechaIndex =MIN(Fecha),
            @fechaFin = MAX(fecha)
            FROM #tmpSemana
    END
	

    /**********Recorrer las fechas hasta encontrar la fecha que corresponde al día capturado*****/
    WHILE @fechaIndex <= @fechaFin
    BEGIN
        IF(
            datepart(WEEKDAY,@fechaIndex) = @pDiaSemana
        )
        BEGIN 
            SET @fechaCaptura  = @fechaIndex
            SET @fechaIndex = dateadd(dd,1,@fechaFin)
        END
        ELSE
        BEGIN
            SET @fechaIndex = DATEADD(dd,1,@fechaIndex)
        end     
    end
    
    IF(@fechaCaptura IS NOT null)
    BEGIN 
        SET @anioMesDia = (DATEPART(yy,@fechaCaptura) * 10000) +
                            (DATEPART(mm,@fechaCaptura) * 100) + 
                            DATEPART(dd,@fechaCaptura)
    END
    if @fechaCaptura is null and  isnull(@pCaptura,0) > 0
    begin
        set @pErrorOut = case when @pDiaSemana = 1 then 'El Domingo no es válido para la semana seleccionada'
                            when @pDiaSemana = 2 then 'El Lunes no es válido para la semana seleccionada'
                            when @pDiaSemana = 3 then 'El Martes no es válido para la semana seleccionada'
                            when @pDiaSemana = 4 then 'El Miercoles no es válido para la semana seleccionada'
                            when @pDiaSemana = 5 then 'El Jueves no es válido para la semana seleccionada'
                            when @pDiaSemana = 6 then 'El Viernes no es válido para la semana seleccionada'
                            when @pDiaSemana = 7 then 'El Sábado no es válido para la semana seleccionada'
                        end
        return
    end

	/***Validar si existe un VoBo. para el dia****/
	if exists(
		select 1		
		froM [dbo].[OT_SolicitudProgramaCaptura] pc
		inner join OT_SolicitudMaterial sm on sm.IdOTSolicitudMaterial = pc.IdOTSolicitudMaterial
		where convert(varchar,pc.Fecha,112) = convert(varchar,@fechaCaptura,112) and
		sm.IdOTSolicitud = @IdOTSolicitud and
		(VoBoContratista = 1 OR VoBoSubcontratista = 1) and
		IdAnioMesDia = @anioMesDia
	)
	/***CAMBIó VALOR?****/
	AND
	not EXISTS
	(
			select 1
			from OT_SolicitudProgramaCaptura           
            WHERE 
            IdAnioMesDia = @anioMesDia AND
            IdOTSolicitudMaterial = @pIdOTSolicitudMaterial and
			Captura = @pCaptura
	)
	begin 
		SET @pErrorOut = 'Hay un VoBo activado para el día, no es posible actualizar'
        GOTO fin
	end

    /**********Asegurarse que el dia de la semana no este en una semana cerrada******************/
    if exists (
        select 1
        from OT_ProgramaSemanaCerrada 
        where isActivo = 1 and
        IdOTSolicitud = @IdOTSolicitud and
        @fechaCaptura between FechaSemanaIni and FechaSemanaFin
    )
    --OR
    --exists (
    --  select 1 from  OT_SolicitudProgramaCaptura
    --  WHERE 
 --           IdAnioMesDia = @anioMesDia AND
 --           IdOTSolicitudMaterial = @pIdOTSolicitudMaterial AND
    --      VoBoSubcontratista = 1 AND
    --      VoBoContratista = 1
    --)
    begin
        SET @pErrorOut = 'Se está intentando modificar un dia que ya está cerrado o que ya está dado el Vobo por Operador y Subcontratista'
        GOTO fin
    end
    
    IF(@fechaCaptura IS NULL OR @anioMesDia IS null)
    BEGIN
        --SET @pErrorOut = 'Se encontró un error al calcular las fechas'
        GOTO fin
    END
    
    ELSE
    BEGIN
    
        if not EXISTS (
            SELECT 1
            FROM OT_SolicitudProgramaCaptura
            WHERE IdAnioMesDia = @anioMesDia AND
            IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
        )
        BEGIN
            SELECT @pIdOTSolicitudProgramaCaptura =ISNULL(MAX(IdOTSolicitudProgramaCaptura),0)+1
            FROM OT_SolicitudProgramaCaptura
            IF(@pCaptura > 0)
            BEGIN
                INSERT INTO OT_SolicitudProgramaCaptura(
                IdOTSolicitudProgramaCaptura,   IdOTSolicitudMaterial,  IdAnioMesDia,
                Fecha,      Captura,            CreadoPor,              CreadoEl,
                ModificadoPor,                  ModificadoEl/*,         VoBoContratista,
                FechaVoBoContratista,           QuienVoBoContratista,   VoBoSubcontratista,
                FechaVoBoSubcontratista,        QuienVoBoSubontratista*/)
                VALUES(
                    @pIdOTSolicitudProgramaCaptura,@pIdOTSolicitudMaterial,@anioMesDia,
                    @fechaCaptura,@pCaptura,@pCreadoPor,GETDATE(),
                    NULL,                           NULL/*,                 @pVoBoContratista,
                    CASE WHEN @pVoBoContratista = 1 THEN GETDATE() ELSE NULL END,
                    CASE WHEN @pVoBoContratista = 1 THEN @pCreadoPor ELSE NULL END, @pVoBoSubcontratista,
                    CASE WHEN @pVoBoSubcontratista = 1 THEN GETDATE() ELSE NULL END,
                    CASE WHEN @pVoBoSubcontratista = 1 THEN @pCreadoPor ELSE NULL end*/
                )       
            END
            
        END
        ELSE
        begin
    
            UPDATE OT_SolicitudProgramaCaptura
            SET captura = @pCaptura,
                ModificadoPor =     @pCreadoPor,
                ModificadoEl = getdate()/*,
                VoBoContratista = CASE WHEN @pVoBoContratista = 1 THEN @pVoBoContratista 
                                        WHEN @pVoBoContratista IS null THEN VoBoContratista                                     
                                    END,
                FechaVoBoContratista = CASE WHEN @pVoBoContratista = 1 and FechaVoBoContratista IS NULL   THEN GETDATE() 
                                        ELSE FechaVoBoContratista                   
                                        END,
                QuienVoBoContratista = CASE WHEN @pVoBoContratista = 1 and QuienVoBoContratista IS NULL   THEN @pCreadoPor
                                        ELSE QuienVoBoContratista                   
                                        END,
                VoBoSubcontratista = CASE WHEN @pVoBoSubcontratista = 1 THEN @pVoBoSubcontratista 
                                        WHEN @pVoBoSubcontratista IS null THEN VoBoSubcontratista                                       
                                    END,
                FechaVoBoSubcontratista = CASE WHEN @pVoBoSubcontratista = 1 and FechaVoBoSubcontratista IS NULL   THEN GETDATE() 
                                            ELSE FechaVoBoSubcontratista                    
                                        END,
                QuienVoBoSubontratista  = CASE WHEN @pVoBoSubcontratista = 1 and QuienVoBoSubontratista IS NULL   THEN @pCreadoPor
                                        ELSE QuienVoBoSubontratista                 
                                        END */
            WHERE 
            IdAnioMesDia = @anioMesDia AND
            IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
        End
    
    End 
    
    fin:    


