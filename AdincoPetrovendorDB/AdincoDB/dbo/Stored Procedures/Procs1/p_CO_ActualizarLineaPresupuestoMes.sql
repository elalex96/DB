
Create Proc p_CO_ActualizarLineaPresupuestoMes
@pIdLineaPresupuestoMes int,
@pIdLineaProgramaActividadMes int,
@pIdInstalacion int,
@pFechaIni datetime,
@pFechaFin datetime,
@pPrecioUnitario money,
@pPrecioMonto money,
@pCreadoPor int,
@pIdCatalogoCuentasSH int,
@pMOExt decimal(18,4),
@pMOCNac decimal(18,4),
@pBSExt decimal(18,4),
@pBSCNac decimal(18,4),
@pSExt decimal(18,4),
@pSNac decimal(18,4),
@pCExt decimal(18,4),
@pCNac decimal(18,4),
@pTTec decimal(18,4),
@pISoc decimal(18,4)

as

	declare @IdPresupuesto int,
			@AC_PRESUP_MES datetime,
			@IdServicio int,
			@IdActividadPetrolera int,
			@IdSubactividadPetrolera int,
			@IdTareaPetrolera int


	select @IdPresupuesto = IdPresupuesto,	
		@AC_PRESUP_MES = Fecha,
		@IdServicio = lp.IdSubTareaPetrolera,
		@IdActividadPetrolera = IdActividadPetrolera,
		@IdSubactividadPetrolera = IdSubactividadPetrolera,
		@IdTareaPetrolera = IdTareaPetrolera
	from [CO_LineaProgramaActividadMes] lp
	inner join CO_ProgramaActividad pa on pa.IdProgramaActividad = lp.IdProgramaActividad
	inner join CO_Presupuesto pre on pre.IdProgramaActividad = pa.IdProgramaActividad
	where lp.IdProgramaActividad = @pIdLineaProgramaActividadMes




	update CO_LineaPresupuestoMes
	set
		
		IdInstalacion = @pIdInstalacion,						
		AC_FEC_INI = @pFechaIni,			
		AC_FEC_FIN = @pFechaFin,			
				
		PrecioUnitario = @pPrecioUnitario,				
		Monto = @pPrecioMonto,
		MOExt=@pMOExt,						
		MOCNac=@pMOCNac,
		BSExt=@pBSExt,					
		BSCNac=@pBSCNac,				
		SExt=@pSExt,				
		SNac=@pSNac,						
		CExt=@pCExt,
		CNac=@pCNac,					
		TTec=@pTTec,				
		ISoc=@pISoc
	where IdLineaPresupuestoMes = @pIdLineaPresupuestoMes			
		