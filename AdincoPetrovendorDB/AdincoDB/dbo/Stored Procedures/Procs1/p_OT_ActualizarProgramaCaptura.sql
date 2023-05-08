CREATE PROC [dbo].[p_OT_ActualizarProgramaCaptura]
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
			@decimales int,
			@pDiaSemana2 TINYINT = @pDiaSemana

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
        set @pErrorOut = case when @pDiaSemana2 = 1 then 'El Domingo no es válido para la semana seleccionada'
                            when @pDiaSemana2 = 2 then 'El Lunes no es válido para la semana seleccionada'
                            when @pDiaSemana2 = 3 then 'El Martes no es válido para la semana seleccionada'
                            when @pDiaSemana2 = 4 then 'El Miercoles no es válido para la semana seleccionada'
                            when @pDiaSemana2 = 5 then 'El Jueves no es válido para la semana seleccionada'
                            when @pDiaSemana2 = 6 then 'El Viernes no es válido para la semana seleccionada'
                            when @pDiaSemana2 = 7 then 'El Sábado no es válido para la semana seleccionada'
                        end
        return
    end

	/***Validar si existe un VoBo. para el dia****/
	DECLARE @VoBoContratista  BIT, @VoBoSubcontratista  BIT, @CapturaDia DECIMAL = 0.0
	CREATE TABLE #tmpResult ( 
			IdOTSolicitudMaterial int,
			Material varchar(200),
			IdOTSolicitud int,
			Folio Varchar(max),
			Disponible INT,
			LunesCaptura decimal,
			MartesCaptura decimal,
			MiercolesCaptura decimal,
			JuevesCaptura decimal,
			ViernesCaptura decimal,
			SabadoCaptura decimal,
			DomingoCaptura decimal,
			TotalSemana decimal,
			IdEstatus bit,
	        LunesVoBoC BIT,
			MartesVoBoC BIT,
			MiercolesVoBoC BIT,
			JuevesVoBoC BIT,
			ViernesVoBoC BIT,
			SabadoVoBoC BIT,
			DomingoVoBoC BIT,
			---------------------------------
			LunesVoBoSC BIT,
			MartesVoBoSC BIT,
			MiercolesVoBoSC BIT,
			JuevesVoBoSC BIT,
			ViernesVoBoSC BIT,
			SabadoVoBoSC BIT,
			DomingoVoBoSC BIT,
			---------------------------------
			LunesCerrado BIT,
			MartesCerrado BIT,
			MiercolesCerrado BIT,
			JuevesCerrado BIT,
			ViernesCerrado BIT,
			SabadoCerrado BIT,
			DomingoCerrado BIT,
			UploadFile varchar(max),
			TieneArchivos BIT)

	insert  INTO #tmpResult  
    exec [dbo].[p_OT_ConsultaSolicitudProgramaCaptura]@IdOTSolicitud, @pSemana, 0

	if(@pDiaSemana2 = 1)
	begin
		SET @VoBoContratista = (SELECt DomingoVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt DomingoVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(DomingoCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end
	if(@pDiaSemana2 = 2)
	begin
		SET @VoBoContratista = (SELECt LunesVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt LunesVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(LunesCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end
	if(@pDiaSemana2 = 3)
	begin
		SET @VoBoContratista = (SELECt MartesVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt MartesVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(MartesCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end
	if(@pDiaSemana2 = 4)
	begin
		SET @VoBoContratista = (SELECt MiercolesVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt MiercolesVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(MiercolesCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end
	if(@pDiaSemana2 = 5)
	begin
		SET @VoBoContratista = (SELECt JuevesVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt JuevesVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(JuevesCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end
	if(@pDiaSemana2 = 6)
	begin
		SET @VoBoContratista = (SELECt ViernesVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt ViernesVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(ViernesCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end
	if(@pDiaSemana2 = 7)
	begin
		SET @VoBoContratista = (SELECt SabadoVoBoC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @VoBoSubcontratista = (SELECt SabadoVoBoSC from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
		SET @CapturaDia = (SELECt ISNULL(SabadoCaptura, 0) from #tmpResult where IdOTSolicitudMaterial = @pIdOTSolicitudMaterial)
	end

	SET @VoBoContratista = ISNULL(@VoBoContratista,0)
	SET @VoBoSubcontratista = ISNULL(@VoBoSubcontratista,0)

	IF(@CapturaDia <> @pCaptura)
		begin 		
		if ( (@VoBoContratista = 1 or @VoBoSubcontratista = 1))
			begin 
				SET @pErrorOut = 'Hay un VoBo activado para el día, no es posible actualizar'
					GOTO fin
			end		
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