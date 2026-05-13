IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_OT_InsertarOrdenTrabajo'
)
    DROP PROCEDURE sp_OT_InsertarOrdenTrabajo
GO
CREATE Proc [dbo].[sp_OT_InsertarOrdenTrabajo]
@pIdOTSolicitud	INT OUT,
@pIdSubContrato	INT,
@pFolio	VARCHAR(30),
@pIdLineasPresupuesto VARCHAR(300),
@pIdInstalacion	VARCHAR(300),
@pFechaInicio	DATETIME,
@pFechaFin	DATETIME,
@pIdPresupuesto INT,
@pCreadoPor	INT,
@pObjeto VARCHAR(600),
@pIdCentroCosto INT,
@pProgIniPorProveedor BIT,
@pCapturaManual BIT = 0
AS
BEGIN
	DECLARE @IdMoneda INT,
			@error BIT = 0,
			@mError VARCHAR(150) = '',
			@IdContrato INT = 0,
			@filasSubcontrato INT = 0

	SELECT @filasSubcontrato = COUNT(DISTINCT IdSCMaterial)
	FROM dbo.SC_Materiales 
	WHERE IdSubContrato = @pIdSubContrato

	SELECT @IdContrato = IdContrato
	FROM SC_Subcontrato
	WHERE IdSubcontrato =  @pIdSubContrato

	SELECT * 
	INTO #tmpInstalaciones
	FROM dbo.fnSplitString(@pIdInstalacion,',')

	SELECT * 
	INTO #tmpPresupuesto
	FROM dbo.fnSplitString(@pIdLineasPresupuesto,',')

	SELECT @pIdOTSolicitud = ISNULL(MAX(IdOTSolicitud), 0) + 1
	FROM OT_Solicitud

	SELECT @IdMoneda = ISNULL(SC_Subcontrato.IdMoneda, MM_Maestro.IdMoneda)
	FROM SC_Subcontrato 
	INNER JOIN SC_Materiales ON SC_Subcontrato.IdSubcontrato = SC_Materiales.IdSubcontrato
	INNER JOIN Petrovendor..MM_Material ON SC_Materiales.IdMaestro = MM_Material.IdMaterial
	LEFT JOIN Petrovendor..MM_Maestro ON MM_Material.IdMaestro = MM_Maestro.IdMaestro
	WHERE SC_Subcontrato.IdSubcontrato = @pIdSubContrato

	SELECT AP_FlujoAprobacionEstatus.Descripcion, 
			feu.UsuarioId
	INTO #tmpUsuariosFlujo
	FROM AP_FlujoAprobacionEstatus	
	INNER JOIN AP_FlujoAprobacionContratos ON AP_FlujoAprobacionContratos.IdContrato = @IdContrato
	INNER JOIN AP_FlujoAprobacion ON AP_FlujoAprobacionContratos.FlujoAprobacionId = AP_FlujoAprobacion.FlujoAprobacionId AND
									AP_FlujoAprobacionEstatus.TipoFlujoAprobacionId = AP_FlujoAprobacion.TipoFlujoAprobacionId 
	INNER JOIN AP_FlujoAprobacionTipos ON AP_FlujoAprobacionEstatus.TipoFlujoAprobacionId = AP_FlujoAprobacionTipos.TipoFlujoAprobacionId 	
	LEFT JOIN (
				SELECT AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId, AP_FlujoAprobacionEstatusUsuarios.UsuarioId
				FROM AP_FlujoAprobacionEstatusUsuarios
				INNER JOIN AP_UsuarioCentroCosto ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario 
				WHERE AP_UsuarioCentroCosto.IdCentroCosto = @pIdCentroCosto
				GROUP BY AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId, AP_FlujoAprobacionEstatusUsuarios.UsuarioId
				)
				
				 feu on AP_FlujoAprobacionEstatus.FlujoAprobacionEstatusId = feu.FlujoAprobacionEstatusId 
	WHERE AP_FlujoAprobacionTipos.TipoFlujoAprobacionId = 1 --Control de Obra
	GROUP BY AP_FlujoAprobacionEstatus.Descripcion,feu.UsuarioId

	SELECT @mError = @mError + ','+ Descripcion
	FROM #tmpUsuariosFlujo
	WHERE UsuarioId is null

	IF @mError <> ''	
	BEGIN
		SET @mError = 'Falta definir los usuarios: '+ @mError +' por favor realice esta configuración';
		RAISERROR (15600, -1, -1, @mError); 
		RETURN
	END
	


	BEGIN TRY  

	BEGIN TRAN

	--Asegurarse de tener generados los materiales del operador y del proveedor
	EXEC [p_SC_Materiales_Gen] @pIdSubContrato, @error OUT

	if(@error = 1)
	BEGIN
		RAISERROR (15600, -1, -1, 'Ocurrió un error al intentar generar los materiales'); 
		RETURN
	END


	INSERT INTO OT_Solicitud(IdOTSolicitud,IdSubContrato,Folio,FechaInicio,
	FechaFin,PlazoEjecucion,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,IsActivo,IsEliminado,IdPresupuesto,
	Objeto,IdOTEstatus,IdCentroCosto,ProgIniPorProveedor,IdMoneda,CapturaManual)
	VALUES(@pIdOTSolicitud, @pIdSubContrato, @pFolio, @pFechaInicio,
	@pFechaFin, 0, @pCreadoPor, getdate(), null, null, 1, 0, @pIdPresupuesto, @pObjeto,1 /*registrada por contratista*/,
	@pIdCentroCosto, @pProgIniPorProveedor, @IdMoneda, 0)


	INSERT INTO [dbo].[OT_LineaPresupuesto](IdOTSolicitud, IdLineaPresupuestoMes, CreadoPor, CreadoEl)
	SELECT @pIdOTSolicitud, splitdata, @pCreadoPor, GETDATE()
	FROM  #tmpPresupuesto lp

	INSERT INTO OT_SolicitudInstalacion(IdOTSolicitud, IdInstalacion, CreadoPor, CreadoEl)
	SELECT @pIdOTSolicitud, CO_LineaPresupuestoMes.IdInstalacion, @pCreadoPor, GETDATE()
	FROM #tmpPresupuesto
	INNER JOIN CO_LineaPresupuestoMes on #tmpPresupuesto.splitdata = CO_LineaPresupuestoMes.IdLineaPresupuestoMes 
	WHERE CO_LineaPresupuestoMes.IdInstalacion IS NOT NULL
	GROUP BY CO_LineaPresupuestoMes.IdInstalacion

	/***************Actualizar plazo ejecución**************/
	UPDATE OT_Solicitud
	SET PlazoEjecucion = ISNULL(DATEDIFF(dd, FechaInicio, FechaFin), 0)
	WHERE IdOTSolicitud = @pIdOTSolicitud


	/************Insertar los materiales****************/

	DECLARE @IdOTSolicitudMaterial INT
    
	SELECT @IdOTSolicitudMaterial = ISNULL(MAX(IdOTSolicitudMaterial), 0)
	FROM OT_SolicitudMaterial

	--Si son mas de 50 filas, capturar manualmente
	IF ISNULL(@pCapturaManual,0)  = 0
	BEGIN

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
		IdSCMaterial,
		0,
		@pCreadoPor,
		GETDATE(),
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	FROM dbo.SC_Materiales 
	WHERE IdSubContrato = @pIdSubContrato

	END
	ELSE
	BEGIN
		UPDATE OT_Solicitud
		SET CapturaManual = @pCapturaManual
		WHERE IdOTSolicitud = @pIdOTSolicitud
	END

	
	EXEC p_OT_SolicitudBitacora_ins @pIdOTSolicitud, 1, 'Creación de OT', @pCreadoPor, null


	COMMIT TRAN
	END TRY  
	BEGIN CATCH  
		ROLLBACK TRAN
		
	END CATCH  
END










