-- p_CO_GenerarProgramacionProgramaImplementa 1,1
Create Proc p_CO_GenerarProgramacionProgramaImplementa
@pIdProgramaImplementaAccion int,
@pCreadoPor int
as


	declare @IdPeriodicidad int,
			@fechaFinPrograma datetime,
			@fechaProgramacionIniAux datetime,
			@fechaProgramacionFinAux datetime,
			@IdProgramaImplementaProgramacion int

	select @IdPeriodicidad = IdPeriodicidad,
		@fechaFinPrograma = convert(varchar,pi.FechaFin,112),
		@fechaProgramacionIniAux = convert(varchar,FechaInicioPrimeraAccion,112),
		@fechaProgramacionFinAux =convert(varchar,FechaFinPrimeraAccion,112)
	from [dbo].[CO_ProgramaImplementaAcciones] a
	inner join [dbo].[CO_ProgramaImplementaElemento] e on e.IdProgramaImplementaElemento = a.IdProgramaImplementaElemento
	inner join [dbo].[CO_ProgramaImplementa] pi on pi.IdProgramaImplementa = e.IdProgramaImplementa
	where [IdProgramaImplementaAccion] = @pIdProgramaImplementaAccion




	if not exists (
		select 1
		from [dbo].[CO_ProgramaImplementaProgramacion]
		where IdProgramaImplementaAccion = @pIdProgramaImplementaAccion
		AND (FechaInicioImplementa IS NOT NULL or FechaFinImplementa IS NOT NULL)
	)
	begin

		DELETE  [dbo].[CO_ProgramaImplementaProgramacion]
		where IdProgramaImplementaAccion = @pIdProgramaImplementaAccion

		select @IdProgramaImplementaProgramacion = isnull(max(IdProgramaImplementaProgramacion),0) + 1
		from [CO_ProgramaImplementaProgramacion]

		insert into [dbo].[CO_ProgramaImplementaProgramacion](
		IdProgramaImplementaProgramacion,	IdProgramaImplementaAccion,	FechaInicioProgramada,
		FechaFinProgramada,					FechaInicioImplementa,		FechaFinImplementa,
		RevisadoPor,						CreadoEl,					CreadoPor
		)
		select @IdProgramaImplementaProgramacion,@pIdProgramaImplementaAccion,@fechaProgramacionIniAux,
		@fechaProgramacionFinAux,null,									null,
		null,								getdate(),					@pCreadoPor	


		/**************Avanzar a la siguiente programación**********************/


		SELECT @fechaProgramacionIniAux = CASE WHEN @IdPeriodicidad = 10001 ---ANUAL
												THEN DATEADD(YEAR,1,@fechaProgramacionIniAux)
												WHEN @IdPeriodicidad = 10009 --MENSUAL
												THEN DATEADD(MONTH,1,@fechaProgramacionIniAux)
												WHEN @IdPeriodicidad = 10012 --SEMESTRAL
												THEN DATEADD(MONTH,6,@fechaProgramacionIniAux)
												WHEN @IdPeriodicidad = 10012 --TRIMESTRAL
												THEN DATEADD(MONTH,3,@fechaProgramacionIniAux)
										END,
			@fechaProgramacionFinAux = CASE WHEN @IdPeriodicidad = 10001 ---ANUAL
												THEN DATEADD(YEAR,1,@fechaProgramacionFinAux)
												WHEN @IdPeriodicidad = 10009 --MENSUAL
												THEN DATEADD(MONTH,1,@fechaProgramacionFinAux)
												WHEN @IdPeriodicidad = 10012 --SEMESTRAL
												THEN DATEADD(MONTH,6,@fechaProgramacionFinAux)
												WHEN @IdPeriodicidad = 10012 --TRIMESTRAL
												THEN DATEADD(MONTH,3,@fechaProgramacionFinAux)
										END

	/*******Recorrer hasta acabar la programación*************/
		while @fechaProgramacionFinAux <= @fechaFinPrograma
		begin

				select @IdProgramaImplementaProgramacion = isnull(max(IdProgramaImplementaProgramacion),0) + 1
				from [CO_ProgramaImplementaProgramacion]

				insert into [dbo].[CO_ProgramaImplementaProgramacion](
				IdProgramaImplementaProgramacion,	IdProgramaImplementaAccion,	FechaInicioProgramada,
				FechaFinProgramada,					FechaInicioImplementa,		FechaFinImplementa,
				RevisadoPor,						CreadoEl,					CreadoPor
				)
				select @IdProgramaImplementaProgramacion,@pIdProgramaImplementaAccion,@fechaProgramacionIniAux,
				@fechaProgramacionFinAux,null,									null,
				null,								getdate(),					@pCreadoPor	


				SELECT @fechaProgramacionIniAux = CASE WHEN @IdPeriodicidad = 10001 ---ANUAL
												THEN DATEADD(YEAR,1,@fechaProgramacionIniAux)
												WHEN @IdPeriodicidad = 10009 --MENSUAL
												THEN DATEADD(MONTH,1,@fechaProgramacionIniAux)
												WHEN @IdPeriodicidad = 10012 --SEMESTRAL
												THEN DATEADD(MONTH,6,@fechaProgramacionIniAux)
												WHEN @IdPeriodicidad = 10012 --TRIMESTRAL
												THEN DATEADD(MONTH,3,@fechaProgramacionIniAux)
										END,
						@fechaProgramacionFinAux = CASE WHEN @IdPeriodicidad = 10001 ---ANUAL
												THEN DATEADD(YEAR,1,@fechaProgramacionFinAux)
												WHEN @IdPeriodicidad = 10009 --MENSUAL
												THEN DATEADD(MONTH,1,@fechaProgramacionFinAux)
												WHEN @IdPeriodicidad = 10012 --SEMESTRAL
												THEN DATEADD(MONTH,6,@fechaProgramacionFinAux)
												WHEN @IdPeriodicidad = 10012 --TRIMESTRAL
												THEN DATEADD(MONTH,3,@fechaProgramacionFinAux)
										END
		end
	end




	