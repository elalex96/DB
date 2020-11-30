
Create Proc p_CO_EliminarProgramaImplementaAcciones
@pIdProgramaImplementaAccion	int,
@pError varchar(250) out
as


	if exists (
		select 1
		from [CO_ProgramaImplementaProgramacion] p
		inner join [CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaAccion = p.IdProgramaImplementaAccion
		where a.IdProgramaImplementaAccion = @pIdProgramaImplementaAccion
		and (p.FechaInicioImplementa is not null OR p.FechaFinImplementa is not null)
	)
	begin
		set @pError = 'Ya existen fechas de implementación capturadas para esta acción. No es posible eliminar'
		RETURN
	end


	BEGIN TRAN

	delete [dbo].[CO_ProgramaImplementaProgramacion]
	from [CO_ProgramaImplementaProgramacion] p
	inner join [CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaAccion = p.IdProgramaImplementaAccion
	where a.IdProgramaImplementaAccion = @pIdProgramaImplementaAccion

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end


	delete [CO_ProgramaImplementaAcciones]
	where IdProgramaImplementaAccion = @pIdProgramaImplementaAccion

	if @@error <> 0
	begin 
		rollback tran
		goto fin
	end

	commit tran

	fin:

	