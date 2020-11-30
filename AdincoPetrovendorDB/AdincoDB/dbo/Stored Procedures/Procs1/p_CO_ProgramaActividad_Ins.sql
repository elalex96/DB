Create Proc p_CO_ProgramaActividad_Ins
@pIdProgramaActividad int out,
@pIdContrato int,
@pIdTipoProgramaActividad int,
@pNombrePrograma varchar(200),
@pNumeroRegistroContenidoNacional varchar(300),
@pFechaPresentacion datetime,
@pFechaInicio datetime,
@pFechaFin datetime,
@pCreadoPor int
as


	declare @IdPeriodoContrato int,		
		@IdAnioContractual int

	begin tran


	insert into CO_PeriodoContrato(
			IdContrato,		NombrePeriodo,		Inicio,			Fin,
		CreadoPor,		CreadoEl,		ModificadoPor,		ModificadoEl,	Activo
	)
	select @pIdContrato,@pNombrePrograma,@pFechaInicio,@pFechaFin,
	@pCreadoPor,	getdate(),		null,					null,			1

	

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	select @IdPeriodoContrato = scope_identity();

	insert into CO_ProgramaActividad(
		IdPeriodoContrato,	IdTipoProgramaActividad,NombrePrograma,FechaPresentacion,
		NumeroRegistroContenidoNacional,CreadoPor,			CreadoEl,				ModificadoPor,	ModificadoEl,
		Activo
	)
	select @IdPeriodoContrato,@pIdTipoProgramaActividad,@pNombrePrograma,@pFechaPresentacion,
	@pNumeroRegistroContenidoNacional,@pCreadoPor,			getdate(),				null,			null,
	1

	
	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	select @pIdProgramaActividad = scope_identity();


	insert into CO_AnioContractual(
		Anio,Inicio,Termino,IdContrato,CreadoPor
	)
	select datepart(year,@pFechaInicio),@pFechaInicio,@pFechaFin,@pIdContrato,@pCreadoPor


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	select @IdAnioContractual = scope_identity();



	insert into CO_Presupuesto(
		IdAnioContractual,	IdProgramaActividad,	Version,
		Nombre,			Comentario,			FechaAprobacionPEP,		CreadoPor,
		CreadoEl,		ModificadoPor,		ModificadoEl,			Activo,
		IdPresupuestoCNH,Actual,CIEP
	)
	select @IdAnioContractual,@pIdProgramaActividad,1,
	@pNombrePrograma,null,					null,					@pCreadoPor,
	getdate(),			null,				null,					1,
	null,1,1
	

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran


	fin:

