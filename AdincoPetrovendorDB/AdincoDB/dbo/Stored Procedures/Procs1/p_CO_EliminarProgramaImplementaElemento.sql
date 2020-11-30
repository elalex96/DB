
Create Proc p_CO_EliminarProgramaImplementaElemento
@pIdProgramaImplementaElemento int,
@pError varchar(250) out
as


	if exists(
		select 1
		from [dbo].[CO_ProgramaImplementaProgramacion] p
		inner join [CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaAccion = p.IdProgramaImplementaAccion
		inner join [CO_ProgramaImplementaElemento] ie on ie.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
		where ie.IdProgramaImplementaElemento = @pIdProgramaImplementaElemento and 
		(FechaInicioImplementa is not null OR FechaFinImplementa is not null)
	)
	begin
		set @pError = 'Ya existe una revisión en la programación de estas acciones, no es posible eliminar'
		return
	end



	begin tran

	delete [CO_ProgramaImplementaProgramacion]
	from [CO_ProgramaImplementaProgramacion] p
	inner join [CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaAccion = p.IdProgramaImplementaAccion
	inner join [CO_ProgramaImplementaElemento] ie on ie.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
	where ie.IdProgramaImplementaElemento = @pIdProgramaImplementaElemento

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[CO_ProgramaImplementaAcciones]
	where IdProgramaImplementaElemento = @pIdProgramaImplementaElemento

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[CO_ProgramaImplementaElemento]
	where IdProgramaImplementaElemento = @pIdProgramaImplementaElemento


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin: