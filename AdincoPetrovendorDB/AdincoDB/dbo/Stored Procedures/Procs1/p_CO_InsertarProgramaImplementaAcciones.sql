CREATE Proc p_CO_InsertarProgramaImplementaAcciones
@pIdProgramaImplementaAccion	int OUT,
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


		select @pIdProgramaImplementaAccion = isnull(max(IdProgramaImplementaAccion),0) + 1
		from [CO_ProgramaImplementaAcciones]


		insert into [dbo].[CO_ProgramaImplementaAcciones](
			IdProgramaImplementaAccion,IdProgramaImplementaElemento,Descripcion,IdProgramaImplementaDepartamento,
			FechaInicioPrimeraAccion,FechaFinPrimeraAccion,Anexo3,ElementosNumerales,IdPeriodicidad,
			CreadoEl,CreadoPor,ModificadoEl,ModificadoPor,Periodicidad	,Porcentaje		
		)
		values(
			@pIdProgramaImplementaAccion,@pIdProgramaImplementaElemento,@pDescripcion,@pIdProgramaImplementaDepartamento,
			@pFechaInicioPrimeraAccion,
			dateadd(minute,59,dateadd(hour,23,@pFechaFinPrimeraAccion)),@pAnexo3,@pElementosNumerales,@pIdPeriodicidad,
			getdate(),@pCreadoPor,null,null,@pPeriodicidadExtra	,@pPorcentaje	
		)


		EXEC p_CO_GenerarProgramacionProgramaImplementa @pIdProgramaImplementaAccion,@pCreadoPor