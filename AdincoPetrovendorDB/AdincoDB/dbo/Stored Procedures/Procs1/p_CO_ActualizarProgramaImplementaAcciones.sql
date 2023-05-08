CREATE Proc p_CO_ActualizarProgramaImplementaAcciones
@pIdProgramaImplementaAccion	int out,
@pIdProgramaImplementaElemento	int,
@pDescripcion	varchar(250),
@pIdProgramaImplementaDepartamento	smallint,
@pFechaInicioPrimeraAccion	datetime,
@pFechaFinPrimeraAccion	datetime,
@pAnexo3	varchar(500),
@pElementosNumerales	varchar(500),
@pIdPeriodicidad	int,
@pCreadoPor	int,
@pPeriodicidadExtra varchar(250),
@pPorcentaje float
as


		 update [CO_ProgramaImplementaAcciones]
		 set Descripcion = @pDescripcion,
			IdProgramaImplementaDepartamento = @pIdProgramaImplementaDepartamento,
			FechaInicioPrimeraAccion = @pFechaInicioPrimeraAccion,
			FechaFinPrimeraAccion =  dateadd(minute,59,dateadd(hour,23,@pFechaFinPrimeraAccion)),
			Anexo3 = @pAnexo3,
			ElementosNumerales = @pElementosNumerales,
			IdPeriodicidad = @pIdPeriodicidad,
			Periodicidad = @pPeriodicidadExtra,
			Porcentaje = @pPorcentaje
		where IdProgramaImplementaAccion = @pIdProgramaImplementaAccion

		EXEC p_CO_GenerarProgramacionProgramaImplementa @pIdProgramaImplementaAccion,@pCreadoPor

