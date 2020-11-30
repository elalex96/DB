CREATE Proc [dbo].[sp_OT_InsertarOrdenTrabajo]
@pIdOTSolicitud	int OUT,
@pIdSubContrato	int,
@pFolio	varchar(30),
@pIdLineasPresupuesto varchar(300),
@pIdInstalacion	varchar(300),
@pFechaInicio	datetime,
@pFechaFin	datetime,
--@pPlazoEjecucion	int,
@pIdPresupuesto int,
@pCreadoPor	INT,
@pObjeto VARCHAR(600),
@pIdCentroCosto int,
@pProgIniPorProveedor bit,
@pCapturaManual bit=0
as

	declare @IdMoneda int,
		@error bit=0,
		@mError varchar(150)='',
		@IdContrato int=0,
		@filasSubcontrato int=0

	SELECT @filasSubcontrato = count(distinct IdSCMaterial)
	FROM dbo.SC_Materiales MAT 
	WHERE MAT.IdSubContrato = @pIdSubContrato

	select @IdContrato = IdContrato
	from SC_Subcontrato
	where IdSubcontrato =  @pIdSubContrato

	SELECT * 
	INTO #tmpInstalaciones
	FROM dbo.fnSplitString(@pIdInstalacion,',')

	SELECT * 
	INTO #tmpPresupuesto
	FROM dbo.fnSplitString(@pIdLineasPresupuesto,',')

	select @pIdOTSolicitud = isnull(max(IdOTSolicitud),0)+1
	from OT_Solicitud

	select @IdMoneda = isnull(sc.IdMoneda,mae.IdMoneda)
	from SC_Subcontrato sc 
	inner join SC_Materiales scMat on scMat.IdSubcontrato = sc.IdSubcontrato
	inner join Petrovendor..MM_Material mat on mat.IdMaterial = scMat.IdMaestro
	left join Petrovendor..MM_Maestro mae on mae.IdMaestro = mat.IdMaestro
	where sc.IdSubcontrato = @pIdSubContrato

	select fe.Descripcion,feu.UsuarioId
	into #tmpUsuariosFlujo
	from [dbo].[AP_FlujoAprobacionEstatus] fe
	
	inner join [dbo].[AP_FlujoAprobacionContratos] fac on /*fac.FlujoAprobacionId = fa.FlujoAprobacionId and */
												fac.IdContrato = @IdContrato

	inner join [dbo].[AP_FlujoAprobacion] fa on fa.FlujoAprobacionId = fac.FlujoAprobacionId and
												fa.TipoFlujoAprobacionId = fe.TipoFlujoAprobacionId


	inner join [dbo].[AP_FlujoAprobacionTipos] ft on ft.TipoFlujoAprobacionId = fe.TipoFlujoAprobacionId	
	left join (
				select st1.FlujoAprobacionEstatusId,st1.UsuarioId
				from [dbo].[AP_FlujoAprobacionEstatusUsuarios] st1
				inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = st1.UsuarioId
				where ucc.IdCentroCosto = @pIdCentroCosto
				group by st1.FlujoAprobacionEstatusId,st1.UsuarioId
				)
				
				 feu on feu.FlujoAprobacionEstatusId = fe.FlujoAprobacionEstatusId
	where ft.TipoFlujoAprobacionId = 1 --Control de Obra
	group by fe.Descripcion,feu.UsuarioId

	select @mError = @mError + ','+ Descripcion
	from #tmpUsuariosFlujo tmp
	where UsuarioId is null



	if @mError <> ''	
	begin
		set @mError = 'Falta definir los usuarios: '+@mError +' por favor realice esta configuración';
		RAISERROR (15600,-1,-1, @mError); 
		return
	end
	


	BEGIN TRY  

	BEGIN TRAN

	--Asegurarse de tener generados los materiales del operador y del proveedor
	exec [p_SC_Materiales_Gen] @pIdSubContrato,@error out

	if(@error = 1)
	begin
		RAISERROR (15600,-1,-1, 'Ocurrió un error al intentar generar los materiales'); 
		return
	end


	insert into OT_Solicitud(IdOTSolicitud,IdSubContrato,Folio,FechaInicio,
	FechaFin,PlazoEjecucion,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,IsActivo,IsEliminado,IdPresupuesto,
	Objeto,IdOTEstatus,IdCentroCosto,ProgIniPorProveedor,IdMoneda,CapturaManual)
	values(@pIdOTSolicitud,@pIdSubContrato,@pFolio,@pFechaInicio,
	@pFechaFin,0,@pCreadoPor,getdate(),null,null,1,0,@pIdPresupuesto,@pObjeto,1 /*registrada por contratista*/,@pIdCentroCosto,@pProgIniPorProveedor,@IdMoneda,0)


	INSERT INTO [dbo].[OT_LineaPresupuesto](IdOTSolicitud,IdLineaPresupuestoMes,CreadoPor,CreadoEl)
	select @pIdOTSolicitud,splitdata,@pCreadoPor,GETDATE()
	from  #tmpPresupuesto lp



	INSERT INTO OT_SolicitudInstalacion(IdOTSolicitud,IdInstalacion,CreadoPor,CreadoEl)
	SELECT @pIdOTSolicitud,lp2.IdInstalacion,@pCreadoPor,GETDATE()
	FROM #tmpPresupuesto lp
	inner join CO_LineaPresupuestoMes lp2 on lp2.IdLineaPresupuestoMes = splitdata
	where lp2.IdInstalacion is not null
	group by lp2.IdInstalacion

	/***************Actualizar plazo ejecución**************/
	update OT_Solicitud
	set PlazoEjecucion = isnull(Datediff(dd,FechaInicio,FechaFin),0)
	where IdOTSolicitud = @pIdOTSolicitud


	/************Insertar los materiales****************/

	DECLARE @IdOTSolicitudMaterial INT
    
	SELECT @IdOTSolicitudMaterial = ISNULL(MAX(IdOTSolicitudMaterial),0)
	FROM OT_SolicitudMaterial

	--Si son mas de 50 filas, capturar manualmente
	if isnull(@pCapturaManual,0)  = 0
	begin

		INSERT INTO dbo.OT_SolicitudMaterial
	(
	    IdOTSolicitudMaterial,
	    IdOTSolicitud,
	    IdSCMaterial,
	    Cantidad,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    IdServicio,
	    FechaProgramaInicio,
	    FechaProgramaFin
	)
	SELECT  ROW_NUMBER() OVER( ORDER BY IdSCMaterial ASC) + @IdOTSolicitudMaterial,
		@pIdOTSolicitud,
		MAT.IdSCMaterial,
		0,
		@pCreadoPor,
		GETDATE(),
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	FROM dbo.SC_Materiales MAT 
	WHERE MAT.IdSubContrato = @pIdSubContrato

	end
	else
	begin
		update OT_Solicitud
		set CapturaManual = @pCapturaManual
		where IdOTSolicitud = @pIdOTSolicitud
	end

	
	exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,1,'Creación de OT',@pCreadoPor,null


	COMMIT TRAN
	END TRY  
	BEGIN CATCH  
		ROLLBACK TRAN
		
	END CATCH  











