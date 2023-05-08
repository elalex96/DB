
Create Proc p_CO_InsertarLineaProgramaActividadMes
@pIdLineaProgramaActividadMes	int out,
@pIdProgramaActividad	int,
@pIdActividadPetrolera	int,
@pIdSubactividadPetrolera	int,
@pIdTareaPetrolera	int,
@pIdSubTareaPetrolera	int,
@pActividades	float,
@pFecha	date,
@pError varchar(250) out
as


	declare @fechaInicio datetime,
			@fechaFin datetime,
			@numeroAnio int
		

	select @fechaInicio = Inicio,
			@fechaFin = termino
	from CO_Presupuesto pre
	inner join CO_AnioContractual ac on ac.IdAnioContractual = pre.IdAnioContractual
	where pre.IdProgramaActividad = @pIdProgramaActividad

	if (convert(varchar,@pFecha,112) NOT between  convert(varchar,@fechaInicio,112) and convert(varchar,@fechaFin,112))
	begin
		set @pError = 'La fecha del registro no esta entre las fechas del presupuesto'
		return
	end


	select @numeroAnio = (datepart(year,@pFecha) - datepart(year,@fechaInicio)) + 1

	insert into [CO_LineaProgramaActividadMes](
		IdProgramaActividad,	IdActividadPetrolera,
		IdSubactividadPetrolera,		IdTareaPetrolera,		IdSubTareaPetrolera,
		NumeroAnio,						NumeroMes,				Actividades,
		Fecha
	)
	values(
		@pIdProgramaActividad,@pIdActividadPetrolera,
		@pIdSubactividadPetrolera,		@pIdTareaPetrolera,	@pIdSubTareaPetrolera,
		@numeroAnio,					datepart(month,@pFecha),			@pActividades,
		@pFecha
	)

	select @pIdLineaProgramaActividadMes = scope_identity();