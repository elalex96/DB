CREATE proc p_s_notificacion_ins
@pIdNotificacion int out,
@pPara varchar(1000),
@pAsunto varchar(500),
@pMensaje text,
@pFechaProgramadaEnvio DateTime,
@pEnviada bit,
@pCreadoPor int,
@pDe varchar(100)
as

	--Quitar duplicados en para

	select distinct Para =splitdata
	into #tmpPara
	from [dbo].[fnSplitString](@pPara,';')
	where isnull(splitdata,'') <> ''
	order by splitdata

	set @pPara = ''

	select @pPara = @pPara + isnull(Para,'') + ';'
	from #tmpPara


	SELECT @pIdNotificacion = ISNULL(MAX(IdNotificacion),0) + 1
	FROM S_Notificacion

	if isnull(@pPara,'') <> '' and isnull(cast(@pMensaje as varchar(8000)),'') <> ''
	begin

	INSERT INTO dbo.S_Notificacion
	(
	    IdNotificacion,
	    Para,
	    Asunto,
	    Mensaje,
	    FechaProgramadaEnvio,
	    Enviada,
	    FechaEnvio,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    De
	)
	VALUES
	(   @pIdNotificacion,         -- IdNotificacion - bigint
	    @ppara,        -- Para - varchar(500)
	    isnull(@pasunto,''),        -- Asunto - varchar(250)
	    isnull(@pmensaje,''),        -- Mensaje - text
	    dateadd(minute,1,GETDATE()), -- FechaProgramadaEnvio - datetime
	    @pEnviada,      -- Enviada - bit
	    GETDATE(), -- FechaEnvio - datetime
	    @pCreadoPor,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    null,         -- ModificadoPor - int
		null, -- ModificadoEl - datetime
	    @pDe         -- De - varchar(100)
	    )

	end


	fin: