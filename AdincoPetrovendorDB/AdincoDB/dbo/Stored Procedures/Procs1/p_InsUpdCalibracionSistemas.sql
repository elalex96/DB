Create Proc p_InsUpdCalibracionSistemas
@pIdCalibracion	int out,
@pIdContrato	int,
@pIdSistema	int,
@pCertificado	varchar(250),
@pFecha	datetime,
@pFechaProxima	datetime,
@pIntervaloCalibracion	varchar(250),
@pInvervaloVerificacion	varchar(250),
@pIncertidumbreMagnitud	varchar(250),
@pLaboratorio	varchar(250),
@pEsAcreditado	bit,
@pPuertoDisponible	varchar(250),
@pConfiguracionPuerto	varchar(250),
@pProtocoloComunicacion	varchar(250),
@pAreaRestringida	bit,
@pObservaciones	varchar(2000),
@pVigente	bit,
@pCreadoPor	int
as



	if not exists (
		select 1
		from PR_CalibracionSistemas
		where IdCalibracion = @pIdCalibracion
	)
	begin

		insert into PR_CalibracionSistemas(

			IdContrato,				IdSistema,			Certificado,			Fecha,
			FechaProxima,		IntervaloCalibracion,InvervaloVerificacion,	IncertidumbreMagnitud,
			Laboratorio,		EsAcreditado,			PuertoDisponible,	ConfiguracionPuerto,
			ProtocoloComunicacion,AreaRestringida,		Observaciones,		Vigente,
			CreadoPor,			CreadoEl,				ModificadoPor,		ModificadoEl
		)
		values(
			@pIdContrato,				@pIdSistema,			@pCertificado,			@pFecha,
			@pFechaProxima,		@pIntervaloCalibracion,@pInvervaloVerificacion,	@pIncertidumbreMagnitud,
			@pLaboratorio,		@pEsAcreditado,			@pPuertoDisponible,	@pConfiguracionPuerto,
			@pProtocoloComunicacion,@pAreaRestringida,		@pObservaciones,		@pVigente,
			@pCreadoPor,			getdate(),				null,		null
		)
	End
	Else
	Begin
		update PR_CalibracionSistemas
		set 			
			IdSistema=@pIdSistema,
			Certificado = @pCertificado,
			Fecha = @pFecha,
			FechaProxima = @pFechaProxima,
			IntervaloCalibracion = @pIntervaloCalibracion,
			InvervaloVerificacion = @pInvervaloVerificacion,
			IncertidumbreMagnitud =@pIncertidumbreMagnitud ,
			Laboratorio = @pLaboratorio,
			EsAcreditado = @pEsAcreditado,
			PuertoDisponible = @pPuertoDisponible,
			ConfiguracionPuerto = @pConfiguracionPuerto,
			ProtocoloComunicacion = @pProtocoloComunicacion,
			AreaRestringida = @pAreaRestringida,
			Observaciones = @pObservaciones,
			Vigente = @pVigente,
			ModificadoPor = @pCreadoPor,
			ModificadoEl = getdate()
		Where IdCalibracion = @pIdCalibracion

	End

