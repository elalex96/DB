
Create Proc p_CO_InertarLineaPresupuestoMes
@pIdLineaPresupuestoMes int out,
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




	insert into CO_LineaPresupuestoMes(
								IdPresupuesto,		IdTipoServicio,		IdActividad,				IdSubactividad,
		IdClasificacion,		IdSubactividad002,	AC_TERMINADO,		IdInstalacion,				AC_PRESUP_MES,
		IdServicio,				AC_FEC_INI,			AC_FEC_FIN,			IdActvidadHidrocarburo,		ID_PADRE,
		IdArea,					IdRubro,			Volumetria,			PrecioUnitario,				Monto,
		IdUsuario,				FecMovto,			IdExcel,			IdAnexo4,					IdRubroInterno,
		CPXOPX,					Actividad,			MesActividadIni,	MesActividadFin,			IdActividadPetrolera,
		IdSubactividadPetrolera,IdTareaPetrolera,	IdCatalogoCuentasSH,MOExt,						MOCNac,
		BSExt,					BSCNac,				SExt,				SNac,						CExt,
		CNac,					TTec,				ISoc,				CreadoPor,					IdLineaProgramaActividadMes,
		CAPEX,					AC_DESCRIPCION
	)
	select						@IdPresupuesto,		NULL,				NULL,						NULL,
	NULL,						NULL,				0,					@pIdInstalacion,			@AC_PRESUP_MES,
	@IdServicio,				@pFechaIni,			@pFechaFin,			null,						null,
	null,						null,				1,					@pPrecioUnitario,			@pPrecioMonto,
	@pCreadoPor,				getdate(),			null,				null,						null,
	null,						null,				null,				null,							@IdActividadPetrolera,
	@IdSubactividadPetrolera,	@IdTareaPetrolera,	@pIdCatalogoCuentasSH,@pMOExt,					@pMOCNac,
	@pBSExt,					@pBSCNac,			@pSExt,				@pSNac,						@pCExt,
	@pCNac,						@pTTec,				@pISoc,				@pCreadoPor,				@pIdLineaProgramaActividadMes,
		NULL,					NULL