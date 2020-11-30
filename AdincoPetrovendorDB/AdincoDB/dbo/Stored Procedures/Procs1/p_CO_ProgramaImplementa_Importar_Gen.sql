

create proc p_CO_ProgramaImplementa_Importar_Gen
@pIdContrato int,
@pError varchar(250) out

as
	set @pError = ''

	declare @IdTipoPrograma int,
			@IdProgramaImplementa int,
			@IdProgramaImplementaDepartamento int,
			@IdProgramaImplementaPolitica int,
			@IdProgramaImplementaElemento int,
			@IdProgramaImplementaAccion int,
			@IdProgramaImplementaProgramacion int

	select @IdTipoPrograma = isnull(max(Id),0)
	from [dbo].[CO_ProgramaImplementacionTipo]
	where IdContrato = @pIdContrato


	BEGIN TRY  
     begin tran

		--Si no existe tipo de programa, crearlo
		if isnull(@IdTipoPrograma,0) = 0
		begin

			select @IdTipoPrograma = isnull(max(Id),0) + 1
			from [CO_ProgramaImplementacionTipo]

			insert into [CO_ProgramaImplementacionTipo](Id,Descripcion,IsEliminado,IdContratista,IdContrato)
			select @IdTipoPrograma,'Programa SASISOPA ' + NumeroContrato,0,IdContratista,IdContrato
			from CO_Contrato
			where IdContrato = @pIdContrato
		end	

		--Crear el encabezado del programa SASISOPA
		select @IdProgramaImplementa = isnull(max(IdProgramaImplementa),0) + 1
		from CO_ProgramaImplementa

		insert into [dbo].[CO_ProgramaImplementa](
			IdProgramaImplementa,IdContrato,IdTipoPrograma,FechaInicio,FechaFin,CreadoEl,CreadoPor,ModificadoEl,ModificadoPor,Activo
		)
		select @IdProgramaImplementa,@pIdContrato,@IdTipoPrograma,MIn(IniciaPrimerAccion),max(TerminaPrimerAccion),getdate(),1,null,null,1
		from CO_ProgramaImplementa_Importar i
		where i.IdContrato = @pIdContrato
		group by IdContrato

		


		--Crear los departamentos	
		select @IdProgramaImplementaDepartamento = isnull(max(IdProgramaImplementaDepartamento),0) + 1
		from 	[CO_ProgramaImplementaDepartamentos]


		insert into [dbo].[CO_ProgramaImplementaDepartamentos](
			IdProgramaImplementaDepartamento,IdContrato,Descripcion,CreadoEl,CreadoPor,Activo
		)
		select ROW_NUMBER() OVER(ORDER BY IdContrato ASC) + @IdProgramaImplementaDepartamento,IdContrato,Categoria,getdate(),IdUsuario,1
		from [dbo].[CO_ProgramaImplementa_ImportarDep] t1
		where IdContrato = @pIdContrato 
		and not exists (
			select 1
			from CO_ProgramaImplementaDepartamentos s1
			where s1.Descripcion = t1.Categoria and
			s1.IdContrato = t1.IdContrato
		)-- Solo crear los que no existan

		

		--Crear las Politicas
		select @IdProgramaImplementaPolitica = isnull(max(IdProgramaImplementaPolitica),0)
		from [CO_ProgramaImplementaPoliticas]

		insert into [dbo].[CO_ProgramaImplementaPoliticas](
			IdProgramaImplementaPolitica,IdProgramaImplementa,Descripcion,CreadoEl,CreadoPor
		)
		select ROW_NUMBER() OVER(ORDER BY DescripcionPolitica ASC) + @IdProgramaImplementaPolitica,
		@IdProgramaImplementa,DescripcionPolitica,getdate(),t1.IdUsuario
		from [dbo].[CO_ProgramaImplementa_Importar] t1
		where IdContrato = @pidContrato		
		group by  t1.DescripcionPolitica,t1.IdUsuario

		

		--Crear las Elementos

		select @IdProgramaImplementaElemento = isnull(max(IdProgramaImplementaElemento),0) 
		from [CO_ProgramaImplementaElemento]

		insert into [dbo].[CO_ProgramaImplementaElemento](
			IdProgramaImplementaElemento,		IdProgramaImplementaPolitica,		IdProgramaImplementa,		Descripcion,
			CreadoEl,							CreadoPor,							ModificadoEl,				ModificadoPor
		)
		select ROW_NUMBER() OVER(ORDER BY t1.DescripcionElemento ASC) +@IdProgramaImplementaElemento,pol.IdProgramaImplementaPolitica,		pol.IdProgramaImplementa,		t1.DescripcionElemento,
		getdate(),								t1.IdUsuario,						null,						null						
		from [CO_ProgramaImplementa_Importar] t1
		inner join [CO_ProgramaImplementaPoliticas] pol on pol.Descripcion = t1.DescripcionPolitica and
														pol.IdProgramaImplementa = @IdProgramaImplementa

		where IdContrato = @pidContrato	 and rtrim(ltrim(t1.DescripcionElemento)) <> ''
		group by t1.DescripcionElemento,t1.IdUsuario,pol.IdProgramaImplementa,pol.IdProgramaImplementaPolitica


		

		--Crear las acciones
		select @IdProgramaImplementaAccion = isnull(max(IdProgramaImplementaAccion),0) 
		from [CO_ProgramaImplementaAcciones]


		
		insert into [dbo].[CO_ProgramaImplementaAcciones](
			IdProgramaImplementaAccion,		IdProgramaImplementaElemento,		Descripcion,		IdProgramaImplementaDepartamento,
			FechaInicioPrimeraAccion,		FechaFinPrimeraAccion,				Anexo3,				ElementosNumerales,
			IdPeriodicidad,					CreadoEl,							CreadoPor,			ModificadoEl,
			ModificadoPor,					Periodicidad,						Porcentaje
		)
		select  ROW_NUMBER() OVER(ORDER BY t1.DescripcionAccion ASC) + @IdProgramaImplementaAccion,el.IdProgramaImplementaElemento,
		cast(t1.DescripcionAccion as varchar(250)),dep.IdProgramaImplementaDepartamento,
		min(t1.IniciaPrimerAccion),				min(t1.TerminaPrimerAccion),					cast(t1.Anexo3 as varchar(500)),		cast(t1.Numerales as varchar(500)),
		isnull(per.IdFrecuenciaEntregable,10019),			getdate(),							t1.IdUsuario,		null,
		null,								case when per.IdFrecuenciaEntregable is null then 'SIN DEFINIR' else '' end ,									t1.Porcentaje								

					
		from [CO_ProgramaImplementa_Importar] t1
		inner join [CO_ProgramaImplementaElemento] el on el.Descripcion = t1.DescripcionElemento 
		inner join [CO_ProgramaImplementaPoliticas] pol on 	pol.IdProgramaImplementaPolitica = el.IdProgramaImplementaPolitica and
														pol.IdProgramaImplementa = 	@IdProgramaImplementa		
		inner join 	[dbo].[CO_ProgramaImplementaDepartamentos] dep on dep.Descripcion = t1.Departamento and
														dep.IdContrato = t1.IdContrato
		left join EN_FrecuenciaEntregable per on per.FrecuenciaEntregable = t1.Periodicidad
		where t1.IdContrato = @pIdContrato
		group by t1.DescripcionAccion,el.IdProgramaImplementaElemento,dep.IdProgramaImplementaDepartamento,
		/*t1.IniciaPrimerAccion,				t1.TerminaPrimerAccion,*/	t1.Anexo3, t1.Numerales,
		per.IdFrecuenciaEntregable,			t1.IdUsuario,	t1.Porcentaje	

		declare @IdAccion_i int = 0,
				@IdUsuario_i int

		select @IdAccion_i = min(a.IdProgramaImplementaAccion),
			@IdUsuario_i = min(a.CreadoPor)
		from [CO_ProgramaImplementaAcciones] a
		inner join [CO_ProgramaImplementaElemento] e on e.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
		inner join [CO_ProgramaImplementaPoliticas] p on p.IdProgramaImplementaPolitica = e.IdProgramaImplementaPolitica and
													p.IdProgramaImplementa = @IdProgramaImplementa
		where a.IdPeriodicidad <> 10019--NO SE 'OTRO'

		--Generar la programación
		select @IdProgramaImplementaProgramacion = isnull(max(IdProgramaImplementaProgramacion),0) 
		from [CO_ProgramaImplementaProgramacion]

		insert into [dbo].[CO_ProgramaImplementaProgramacion](IdProgramaImplementaProgramacion,IdProgramaImplementaAccion,FechaInicioProgramada,
		FechaFinProgramada,FechaInicioImplementa,FechaFinImplementa,
		RevisadoPor,CreadoEl,CreadoPor
		)
		select ROW_NUMBER() OVER(ORDER BY ac.IdProgramaImplementaAccion ASC) + @IdProgramaImplementaProgramacion,ac.IdProgramaImplementaAccion,IniciaPrimerAccion,
		TerminaPrimerAccion,null,null,null,getdate(),IdUsuario
		from [CO_ProgramaImplementa_Importar] t1
		inner join [CO_ProgramaImplementaElemento] el on el.Descripcion = t1.DescripcionElemento 
		inner join [CO_ProgramaImplementaPoliticas] pol on 	pol.IdProgramaImplementaPolitica = el.IdProgramaImplementaPolitica and
														pol.IdProgramaImplementa = 	@IdProgramaImplementa		
		inner join 	[dbo].[CO_ProgramaImplementaDepartamentos] dep on dep.Descripcion = t1.Departamento and
														dep.IdContrato = t1.IdContrato
		inner join [CO_ProgramaImplementaAcciones] ac on cast(ac.Descripcion as varchar(250)) = cast(t1.DescripcionAccion as varchar(250)) and
													ac.IdProgramaImplementaElemento = el.IdProgramaImplementaElemento
		where t1.IdContrato = @pIdContrato
		group by ac.IdProgramaImplementaAccion,IniciaPrimerAccion,TerminaPrimerAccion,IdUsuario


		--WHILE @IdAccion_i IS NOT NULL
		--BEGIN
		--	EXEC p_CO_GenerarProgramacionProgramaImplementa @IdAccion_i,@IdUsuario_i



		--	select @IdAccion_i = min(IdProgramaImplementaAccion)
		--	from [CO_ProgramaImplementaAcciones] a
		--	inner join [CO_ProgramaImplementaElemento] e on e.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
		--	inner join [CO_ProgramaImplementaPoliticas] p on p.IdProgramaImplementaPolitica = e.IdProgramaImplementaPolitica and
		--												p.IdProgramaImplementa = @IdProgramaImplementa
		--	where a.IdPeriodicidad <> 10019--NO SE 'OTRO' AND
		--	and a.IdProgramaImplementaAccion > @IdAccion_i
		--END

		
		



		fin:

	 commit tran
	END TRY  
	BEGIN CATCH 
		rollback tran 
		set @pError = error_message()
	END CATCH  


	
	