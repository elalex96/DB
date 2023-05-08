--=======================================
-- Modificador: Neri del Angel
-- Fecha: 13 de Septiembre del 2022
-- Detalle: Se elimina codigo comentado, se ajusta orden de joins y en los ON de los joins
--=======================================
CREATE Proc [dbo].[p_OT_GuardarEstimacion]
    @pIdOTEstimacion int out,
    @pIdOTSolicitud int,
    @pFechaEstimacionIni datetime,
    @pFechaEstimacionFin datetime,
    @pCreadoPor int,
    @pTotalEstimacion money,
    @pError varchar(250) out
as
BEGIN
    SET @pError = ''
    declare @consecutivo int,
            @folioEstimacion varchar(50),
            @IdProveedorOperador int,
            @IdUsuarioSolicitante int,
            @AdjudicableParcialmente bit,
            @FolioOT varchar(50),
            @MotivoUrgenciaSolPed varchar(200),
            @fechaActual DateTime = getdate(),
            @IdPeriodo int,
            @IdPresupuesto int,
            @IdInstalacion int,
            @EntregaUnicoDomicilio int,
            @IdDomiclioEntrega int,
            @IdContrato int,
            @IdLineaPresupuesto int,
            @IdMaterialProveedor int,
            @precioUnitario money,
            @IdMaterialOperador int,
            @idMoneda int,
            @IdProveedorPetrovendor int,
            @IdSolicitudPedidoActual int,
            @IdPedidoActual int,
            @IdPedidoGeneral int,
            @IdCentroCosto int,
            @IdActividad int,
            @nombreActividad varchar(250),
            @IdPedidoSC int,
            @IdOTEstimacionDetalle int = 0,
            @IdSubcontrato int = 0,
            @descripcionBita varchar(150)

    create table #tmpEstimacionDetalle
    (
        IdOTSolicitud int null,
        IdOTEstimacion int null,
        FolioEstimacion varchar(100) null,
        Consecutivo smallint null,
        FolioOT varchar(30) null,
        FolioSC varchar(30) null,
        FechaIniCorte datetime null,
        FechaFinCorte datetime null,
        Instalacion varchar(500) null,
        Actividad varchar(500) null,
        Presupuesto varchar(500) null,
        Subcontratista varchar(500) null,
        AreaContractual varchar(500) null,
        AceptaOperador varchar(500) null,
        AceptaSubcontratista varchar(500) null,
        IdSCMaterial int null,
        COncepto varchar(500) null,
        Descripcion varchar(8000) null,
        Unidad varchar(500) null,
        Cantidad float null,
        PrecioUnitario decimal(19, 4) null,
        Importe decimal(19, 4) null,
        IdOTSolicitudMaterial int null,
        Moneda varchar(20) null,
        IdMoneda int null
    )

    select @consecutivo = isnull(max(Consecutivo), 0) + 1
    from OT_Estimacion (NOLOCK)
    where IdOTSolicitud = @pIdOTSolicitud

    select @folioEstimacion = isnull(Folio, '') + '-E' + cast(@consecutivo as varchar),
           @IdSubcontrato = IdSubContrato
    from OT_Solicitud (NOLOCK)
    where IdOTSolicitud = @pIdOTSolicitud

    if (isnull(@pTotalEstimacion, 0) = 0)
    begin
        set @pError = 'No es posible generar una estimación en cero'
        return
    end

    BEGIN TRY


        begin tran

        declare @pErrorMatGen bit = 0

        exec [p_SC_Materiales_Gen] @IdSubcontrato, @pErrorMatGen out

        if @pErrorMatGen <> 0
        begin
            set @pError = 'Error al generar materiales del contratista'
            RAISERROR(15600, -1, -1, @pError);
            return
        end

        insert into #tmpEstimacionDetalle
        exec p_OT_ObtenerEstimacion @pIdOTSolicitud,
                                    @pIdOTEstimacion,
                                    @pFechaEstimacionIni,
                                    @pFechaEstimacionFin

        select @pTotalEstimacion = sum(Cantidad * PrecioUnitario)
        from #tmpEstimacionDetalle

        select @pIdOTEstimacion = isnull(max(IdOTEstimacion), 0) + 1
        from OT_Estimacion (NOLOCK)

        /****Asegurarse de no duplicar estimacion******/
        IF exists
        (
            select 1
            from OT_Estimacion (NOLOCK)
            where IdOTSolicitud = @pIdOTSolicitud
                  and (
                          (
                              convert(varchar, FechaCorteInicio, 112) = convert(varchar, @pFechaEstimacionIni, 112)
                              and convert(varchar, FechaCorteFin, 112) = convert(varchar, @pFechaEstimacionFin, 112)
                          )
                          OR convert(varchar, FechaCorteInicio, 112)
                  between @pFechaEstimacionIni and @pFechaEstimacionFin
                          OR convert(varchar, FechaCorteFin, 112)
                  between @pFechaEstimacionIni and @pFechaEstimacionFin
                      )
                  and isnull(cancelada, 0) = 0
        )
        begin
            set @pError = 'Se está intentando generar una estimación duplicada'
            RAISERROR(15600, -1, -1, @pError);
            return
        end

        insert into OT_Estimacion
        (
            IdOTEstimacion,
            IdOTSolicitud,
            FolioEstimacion,
            Consecutivo,
            FechaCorteInicio,
            FechaCorteFin,
            CreadoEl,
            CreadoPor,
            Total,
            Cancelada
        )
        select @pIdOTEstimacion,
               @pIdOTSolicitud,
               @folioEstimacion,
               @consecutivo,
               @pFechaEstimacionIni,
               @pFechaEstimacionFin,
               getdate(),
               @pCreadoPor,
               @pTotalEstimacion,
               0

        /***GENERAR DETALL ESTIMACIÓN***/
        if not exists (select 1 from #tmpEstimacionDetalle)
        begin

            set @pError = 'Error al calcular la estimación'
            RAISERROR(15600, -1, -1, @pError);
            return
        end

        select @IdOTEstimacionDetalle = isnull(max(IdOTEstimacionDetalle), 0) + 1
        from OT_EstimacionDetalle (NOLOCK)

        insert into OT_EstimacionDetalle
        (
            IdOTEstimacionDetalle,
            IdOTEstimacion,
            IdOTSolicitudMaterial,
            Cantidad,
            PrecioUnitario,
            Importe,
            CreadoEl
        )
        select ROW_NUMBER() OVER (ORDER BY COncepto ASC) + @IdOTEstimacionDetalle,
               @pIdOTEstimacion,
               IdOTSolicitudMaterial,
               Cantidad,
               PrecioUnitario,
               Importe = Cantidad * PrecioUnitario,
               getdate()
        from #tmpEstimacionDetalle

        if (isnull(@IdPedidoSC, 0) = 0)
            select @IdProveedorOperador = ptista.IdProveedor,
                   @IdUsuarioSolicitante = conf.IdUsuarioTaskPetro,
                   @AdjudicableParcialmente = 1,
                   @FolioOT = Folio,
                   @IdPeriodo = pa.IdPeriodoContrato,
                   @IdPresupuesto = p.IdPresupuesto,
                   @IdLineaPresupuesto = lpm.IdLineaPresupuestoMes,
                   @IdInstalacion = si.IdInstalacion,
                   @EntregaUnicoDomicilio = null,
                   @IdDomiclioEntrega = null,
                   @IdContrato = sc.IdContrato,
                   @IdMaterialOperador = ot.IdMatContratista,
                   @IdMaterialProveedor = ot.IdMatSubcontratista,
                   @IdProveedorPetrovendor = prov.IdProveedor,
                   @idMoneda = ot.IdMoneda,
                   @IdActividad = 5,
                   @nombreActividad = act.NombreActividad,
                   @IdCentroCosto = ot.IdCentroCosto
            from OT_Solicitud ot (NOLOCK)
                inner join SC_Subcontrato sc  (NOLOCK)
                    on ot.IdSubcontrato = sc.IdSubcontrato
                inner join OT_LineaPresupuesto lp (NOLOCK)
                    on ot.IdOTSolicitud = lp.IdOTSolicitud
                inner join CO_Contratista ctista (NOLOCK)
                    on sc.IdContratista = ctista.IdContratista
                inner join petrovendor..S_Proveedor ptista (NOLOCK)
                    on ctista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ptista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                inner join OT_Configurador conf (NOLOCK)
                    on sc.IdContrato = conf.IdContrato
                inner join [dbo].[CO_LineaPresupuestoMes] lpm (NOLOCK)
                    on lp.IdLineaPresupuestoMes = lpm.IdLineaPresupuestoMes
                inner join CO_Presupuesto p (NOLOCK)
                    on lpm.IdPresupuesto = p.IdPresupuesto
                inner join [dbo].[CO_ProgramaActividad] pa (NOLOCK)
                    on p.IdProgramaActividad = pa.IdProgramaActividad
                inner join PV_Subcontratista subcon (NOLOCK)
                    on sc.IdSubContratista = subcon.IdSubcontratista
                inner join Petrovendor.dbo.S_Proveedor prov (NOLOCK)
                    on subcon.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                inner join [dbo].[CO_ActividadCIEP] ACT (NOLOCK)
                    ON lpm.IdActividad = ACT.IdActividad
                inner join [dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK)
                    on ucc.IdCentroCosto in ( ot.IdCentroCosto )
                inner join [dbo].[AP_FlujoAprobacionEstatusUsuarios] ue (NOLOCK)
                    on ucc.IdUsuario = ue.UsuarioId
                       and ue.FlujoAprobacionEstatusId = 4
                left join [dbo].[OT_SolicitudInstalacion] si (NOLOCK)
                    on ot.IdOTSolicitud = si.IdOTSolicitud
            where ot.IdOTSolicitud = @pIdOTSolicitud
        set @MotivoUrgenciaSolPed = 'Estimación Completa para OT:' + @FolioOT

        select @precioUnitario = Total
        from OT_Estimacion (NOLOCK)
        where IdOTEstimacion = @pIdOTEstimacion

        if isnull(@IdUsuarioSolicitante, 0) = 0
        begin

            set @pError
                = 'No fue posible obtener el usuario solicitante. Revise que haya un usuario Solicitante configurado dentro del Configurador de Ordenes de trabajo '

            RAISERROR(15600, -1, -1, @pError);
        end

        if isnull(@IdCentroCosto, 0) = 0
        begin
            set @pError = 'No fue posible obtener el centro de costo'

            RAISERROR(15600, -1, -1, @pError);
        end

        /************vALIDAR INSTALACI�N************************************/
        if (isnull(@IdInstalacion, 0) = 0)
        begin
            select @IdInstalacion = IdInstalacion
            from co_instalacion (NOLOCK)
            where idactividad = @IdActividad
        end

        if isnull(@IdInstalacion, 0) = 0
        begin
            set @pError
                = 'No fue posible obtener la instalación,asegurese que exista una instalación tipo bolsa para la actividad:'
                  + isnull(@nombreActividad, '')
            RAISERROR(15600, -1, -1, @pError);
        end

        select @IdDomiclioEntrega = min(spd.IdDomicilioEntrega)
        from OT_Solicitud ot (NOLOCK)
            inner join SC_Subcontrato sc (NOLOCK)
                on ot.IdSubContrato = sc.IdSubcontrato
            inner join Petrovendor..MM_Pedido ped (NOLOCK)
                on sc.IdPedido = ped.IdPedido
            inner join Petrovendor..[MM_SolicitudPedidoDetalle] spd (NOLOCK)
                on ped.IdSolicitudPedido = spd.IdSolicitudPedido
        where ot.IdOTSolicitud = @pIdOTSolicitud

        exec Petrovendor.dbo.SP_OT_GenerarHistorialPedido @IdOTSolicitud = @pIdOTSolicitud,
                                                          @IdOTEstimacion = @pIdOTEstimacion,
                                                          @IdTipoSolicitudPedido = 10001,
                                                          @IdProveedorOperador = @IdProveedorOperador,
                                                          @IdUsuarioSolicitante = @IdUsuarioSolicitante,
                                                          @AdjudicableParcialmente = @AdjudicableParcialmente,
                                                          @MotivoUrgenciaSolPed = @MotivoUrgenciaSolPed,
                                                          @VisitaRequerida = 0,
                                                          @JuntaAclaracionesRequerida = 0,
                                                          @UnaSolaEntregaRequerida = 0,
                                                          @Activo = 1,
                                                          @FechaEntregaRequerida = @fechaActual,
                                                          @FechaEntregaFinRequerida = @fechaActual,
                                                          @EntregasParciales = 0,
                                                          @IdPeriodo = @IdPeriodo,
                                                          @IdPresupuesto = @IdPresupuesto,
                                                          @IdLineaPresupuesto = @IdLineaPresupuesto,
                                                          @IdCentroCosto = @IdCentroCosto,
                                                          @IdTipoGasto = 1,
                                                          @IdInstalacion = @IdInstalacion,
                                                          @IdTerminosInternacionales = 0,
                                                          @EntregaUnicoDomicilio = 0,
                                                          @IdDomiclioEntrega = @IdDomiclioEntrega,
                                                          @IdContrato = @IdContrato,
                                                          @Fianza = 0,
                                                          @Controlados = 0,
                                                          @IdMaterialProveedor = @IdMaterialProveedor,
                                                          @IdMaterialOperador = @IdMaterialOperador,
                                                          @Cantidad = 1,
                                                          @ObservacionCotizacion = @MotivoUrgenciaSolPed,
                                                          @IdUnidad = 10011,
                                                          @IdUnidadProveedor = 10011,
                                                          @PrecioUnitario = @precioUnitario,
                                                          @SubTotal = @precioUnitario,
                                                          @IdProveedorPetrovendor = @IdProveedorPetrovendor,
                                                          @IdMonedaFactura = @idMoneda,
                                                          @IdTerminosCondiciones = 0,
                                                          @pIdSolicitudPedidoActual = @IdSolicitudPedidoActual out,
                                                          @pIdPedidoActual = @IdPedidoActual out,
                                                          @pIdPedidoGeneral = @IdPedidoGeneral out

        if (
               isnull(@IdSolicitudPedidoActual, 0) = 0
               OR isnull(@IdPedidoActual, 0) = 0
               OR isnull(@IdPedidoGeneral, 0) = 0
           )
        Begin
            set @pError = 'Ocurrió un error al generar la aprobación'
            RAISERROR(15600, -1, -1, @pError);
        End
        /**********Actualizar la estimaci�n*************/
        UPDATE OT_Estimacion
        SET IdSolicitudPedido = @IdSolicitudPedidoActual,
            IdPedido = @IdPedidoActual,
            IdPedidoGeneral = @IdPedidoGeneral
        WHERE IdOTEstimacion = @pIdOTEstimacion

        exec p_OT_CalcularAvance @pIdOTEstimacion
        exec p_OT_Estimacion_Notificacion @pIdOTEstimacion, 1, @pCreadoPor
        exec p_OT_Estimacion_Notificacion @pIdOTEstimacion, 2, @pCreadoPor

        set @descripcionBita
            = 'Generación de Estimación para fechas ' + convert(varchar, @pFechaEstimacionIni, 103) + ' al '
              + convert(varchar, @pFechaEstimacionFin, 103)

        exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,
                                        null,
                                        @descripcionBita,
                                        @pCreadoPor,
                                        null
        commit tran
    END TRY
    BEGIN CATCH
        set @pError = error_message() + ERROR_PROCEDURE() + ' ERROR LINE:' + cast(ERROR_LINE() as varchar)
        rollback tran
    END CATCH
END