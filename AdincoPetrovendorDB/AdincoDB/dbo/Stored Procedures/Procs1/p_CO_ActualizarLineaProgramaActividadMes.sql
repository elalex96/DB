
Create Proc p_CO_ActualizarLineaProgramaActividadMes
@pIdLineaProgramaActividadMes	int ,
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


	update [CO_LineaProgramaActividadMes]
	set 
		
		IdActividadPetrolera = @pIdActividadPetrolera,
		IdSubactividadPetrolera = @pIdSubactividadPetrolera,
		IdTareaPetrolera= @pIdTareaPetrolera,
		IdSubTareaPetrolera = @pIdSubTareaPetrolera,
		NumeroAnio = @numeroAnio,
		NumeroMes = datepart(month,@pFecha),
		Actividades = @pActividades,
		Fecha = @pFecha
	where IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes

	