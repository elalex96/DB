Create Proc p_CO_ProgramaActividad_Del
@pIdProgramaActividad int
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

	update CO_ProgramaActividad
	set activo = 0
	where IdProgramaActividad = @pIdProgramaActividad

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	update CO_Presupuesto
	set activo = 0
	where IdPresupuesto = @IdPresupuesto


	commit tran

	fin:

	--delete CO_LineaPresupuestoMes
	--from CO_LineaPresupuestoMes t1
	
	--where t1.IdPresupuesto = @IdPresupuesto 

	
	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--delete [dbo].[CO_LineaProgramaActividadMes]	
	--where IdProgramaActividad = @pIdProgramaActividad

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	

	

	--delete CO_Presupuesto
	--where IdPresupuesto = @IdPresupuesto

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--delete CO_AnioContractual
	--where IdAnioContractual = @IdAnioContractual

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	

	--delete CO_ProgramaActividad
	--where IdProgramaActividad = @pIdProgramaActividad


	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--delete CO_PeriodoContrato
	--where IdPeriodo = @IdPeriodoContrato

	--if @@error <> 0
	--begin
	--	rollback tran
	--	goto fin
	--end

	--commit tran

	--fin:
