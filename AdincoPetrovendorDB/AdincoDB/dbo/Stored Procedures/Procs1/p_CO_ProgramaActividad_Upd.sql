Create Proc p_CO_ProgramaActividad_Upd
@pIdProgramaActividad int,
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
		@IdAnioContractual int,
		@IdPresupuesto int


	select @IdPeriodoContrato = IdPeriodoContrato,
		@IdAnioContractual = pre.IdAnioContractual,
		@IdPresupuesto = IdPresupuesto
	from CO_ProgramaActividad pa
	inner join CO_Presupuesto pre on pre.IdProgramaActividad = pa.IdProgramaActividad
	where pa.IdProgramaActividad = @pIdProgramaActividad

	begin tran

	update CO_PeriodoContrato
	set Inicio = @pFechaInicio,
		Fin = @pFechaFin,
		NombrePeriodo = @pNombrePrograma
	where IdPeriodo = @IdPeriodoContrato

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update CO_ProgramaActividad
	set IdTipoProgramaActividad = @pIdTipoProgramaActividad,
		NombrePrograma = @pNombrePrograma,
		FechaPresentacion = @pFechaPresentacion,
		NumeroRegistroContenidoNacional  = @pNumeroRegistroContenidoNacional,
		ModificadoPor = @pCreadoPor,
		ModificadoEl = getdate()
	where IdProgramaActividad = @pIdProgramaActividad

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update CO_AnioContractual
	set Anio = datepart(year,@pFechaInicio),
		Inicio = @pFechaInicio,
		Termino = @pFechaFin
	where IdAnioContractual = @IdAnioContractual

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	update CO_Presupuesto
	set Nombre = @pNombrePrograma,		
		ModificadoPor = @pCreadoPor,
		ModificadoEl = getdate()
	where IdPresupuesto = @IdPresupuesto

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end



	commit tran

	fin:
	