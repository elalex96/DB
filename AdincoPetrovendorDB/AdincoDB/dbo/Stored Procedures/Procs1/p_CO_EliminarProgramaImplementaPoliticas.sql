
Create proc p_CO_EliminarProgramaImplementaPoliticas
@pIdProgramaImplementaPolitica int,
@pError varchar(250) out
as


	if exists (
		select 1
		from [CO_ProgramaImplementaProgramacion] p
		inner join [dbo].[CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaAccion = p.IdProgramaImplementaAccion
		inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
		where e.IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica and
		(p.FechaInicioImplementa is not null OR p.FechaFinImplementa is not null)

	)
	begin
		set @pError = 'Ya existen fechas de implementación capturadas para las acciones y elementos de está pólitica. No es posible eliminar'
		return
	end

	begin tran

	delete [dbo].[CO_ProgramaImplementaProgramacion]
	from [CO_ProgramaImplementaProgramacion] p
	inner join [dbo].[CO_ProgramaImplementaAcciones] a on a.IdProgramaImplementaAccion = p.IdProgramaImplementaAccion
	inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
	where e.IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[CO_ProgramaImplementaAcciones]
	from [dbo].[CO_ProgramaImplementaAcciones] a 
	inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
	where e.IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica

		if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	delete [dbo].[CO_ProgramaImplementaElemento]
	from  [dbo].[CO_ProgramaImplementaElemento] e 
	where e.IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end


	delete CO_ProgramaImplementaPoliticas
	where IdProgramaImplementaPolitica = @pIdProgramaImplementaPolitica


	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin: