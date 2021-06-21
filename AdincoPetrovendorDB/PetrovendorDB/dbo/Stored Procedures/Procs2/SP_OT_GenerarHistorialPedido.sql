----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 06-02-2018
-- Description:	SP Historico de un Pedido de Orden de Trabajo
-- =============================================
CREATE PROCEDURE [dbo].[SP_OT_GenerarHistorialPedido]
    @IdOTSolicitud INT,
    @IdOTEstimacion INT,
    --- PARAMETROS SOLPED ---
    @IdTipoSolicitudPedido INT,
    @IdProveedorOperador INT,
    @IdUsuarioSolicitante INT,
    @AdjudicableParcialmente BIT = 0,
    @MotivoUrgenciaSolPed NVARCHAR(MAX),
    @VisitaRequerida BIT = 0,
    @JuntaAclaracionesRequerida BIT = 0,
    @UnaSolaEntregaRequerida BIT = 1,
    @Activo BIT = 1,
    @FechaEntregaRequerida NVARCHAR(MAX),
    @FechaEntregaFinRequerida NVARCHAR(MAX),
    @EntregasParciales BIT = 0,
    @IdPeriodo INT,
    @IdPresupuesto INT,
    @IdLineaPresupuesto INT,
    @IdCentroCosto INT,
    @IdTipoGasto INT,
    @IdInstalacion INT,
    @IdTerminosInternacionales INT,
    @EntregaUnicoDomicilio BIT,
    @IdDomiclioEntrega INT,
    @IdContrato INT,
    @Fianza BIT,
    @Controlados BIT = 0,

    ---FIN  PARAMETROS SOLPED ---
    --- PARAMETROS DE SOLICITUD DE PEDIDO DETALLE ---		    
    @IdMaterialProveedor INT,
    @IdMaterialOperador INT,
    @Cantidad FLOAT,
    @ObservacionCotizacion NVARCHAR(MAX),
    @IdUnidad INT,
    @IdUnidadProveedor INT,
    @PrecioUnitario DECIMAL,
    @SubTotal DECIMAL,
    @IdProveedorPetrovendor INT,
    @IdMonedaFactura INT,
    @IdTerminosCondiciones INT,

    /**********RESULT************/
    @pIdSolicitudPedidoActual INT OUT,
    @pIdPedidoActual INT OUT,
    @pIdPedidoGeneral INT OUT


--- FIN PARAMETROS DE PETICION OFERTA DETALLE ---
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IdSolicitudPedidoActual INT;
    DECLARE @IdSolicitudPedidoDetalleActual INT;
    DECLARE @IdPeticionOfertaActual INT;
    DECLARE @IdPeticionOfertaDetalleActual INT;
    DECLARE @IdPedidoActual INT;
    DECLARE @IdPedidoDetalleActual INT;
    DECLARE @IdOperacionAprobacionPedido INT;
    DECLARE @IdDomiclioEntregaF INT;
    DECLARE @IdTerminosInternacionalesF INT;
    DECLARE @FechaEntregaFinRequeridaF NVARCHAR(MAX);
    DECLARE @IdTipoProcesoActual INT = 6; ---> ORDEN DE TRABAJO  --> MM_TipoPedido
    DECLARE @DescripcionH NVARCHAR(MAX); --> PARA DETALLE HISTORIAL DE APROBACION 
    DECLARE @IdPrioridadSolicitudPedido INT = 10002; ---->ALTA  --->  MM_PrioridadSolicitudPedido
    DECLARE @IdFlujo INT;
    DECLARE @creadorOT VARCHAR(MAX);
    DECLARE @FolioOT VARCHAR(30),
            @SAPPR VARCHAR(50),
            @FolioEstimacion VARCHAR(50),
            @ObjetoOT VARCHAR(600),
            @permitirAceptacionAut BIT = 0,
            @error VARCHAR(250);


    SET NOCOUNT ON;

    SELECT @FolioOT = o.Folio,
           @SAPPR = o.SAPPR,
           @FolioEstimacion = e.FolioEstimacion,
           @ObjetoOT = o.Objeto,
           @creadorOT = CONCAT(u.Usuario, ' - ', u.Nombre),
           @permitirAceptacionAut = ISNULL(cf.PermitirAceptacionAut, 0)
    FROM Adinco..OT_Solicitud o
        INNER JOIN Adinco..OT_Estimacion e
            ON e.IdOTSolicitud = o.IdOTSolicitud
               AND e.IdOTEstimacion = @IdOTEstimacion
        INNER JOIN Adinco..AP_Usuario u
            ON u.usuarioId = o.CreadoPor
        INNER JOIN Adinco..SC_Subcontrato sc
            ON sc.IdSubcontrato = o.IdSubcontrato
        INNER JOIN Adinco..OT_Configurador cf
ON cf.IdContrato = sc.IdContrato
    WHERE o.IdOTSolicitud = @IdOTSolicitud;



    --#### 1.-AGREGAR SOLICITUD DE PEDIDO ####----		
    BEGIN
        SELECT @IdDomiclioEntrega = ISNULL(MAX(IdDomicilio), 0)
        FROM petrovendor..DG_Domicilio
        WHERE IdProveedor = @IdProveedorOperador;



        IF @IdDomiclioEntrega = 0
        BEGIN
            SET @IdDomiclioEntregaF = NULL;

            SELECT @IdDomiclioEntrega = MIN(IdDomicilio)
            FROM petrovendor..DG_Domicilio;
            --where IdProveedor = @IdProveedorOperador


            SET @IdDomiclioEntregaF = @IdDomiclioEntrega;
        END;
        ELSE
        BEGIN
            SET @IdDomiclioEntregaF = @IdDomiclioEntrega;
        END;


        --- Validar EntregasParciales ----

        IF @EntregasParciales = 0
        BEGIN
            SET @FechaEntregaFinRequeridaF = NULL;
        END;
        ELSE
        BEGIN
            SET @FechaEntregaFinRequeridaF = @FechaEntregaFinRequerida;
        END;


        INSERT INTO [dbo].[MM_SolicitudPedido]
        (
            [IdTipoSolicitudPedido],
            [IdUsuarioSolicitante],
            [AdjudicableParcialmente],
            [IdPrioridadSolicitudPedido],
            [MotivoUrgencia],
            [VisitaRequerida],
            [JuntaAclaracionesRequerida],
            [UnaSolaEntregaRequerida],
            [Activo],
            [FechaEntregaRequerida],
            [FechaEntregaFinRequerida],
            [IdProveedor],
            [FechaAlta],
            [EntregasParciales],
            [IdContrato],
            [IdPeriodo],
            [IdPresupuesto],
            [IdLineaPresupuesto],
            [IdTipoGasto],
            [IdTerminoInternacionales],
            [UnicoDomicilioEntrega],
            [IdDomicilioEntrega],
            [IdCentroCosto],
            [Fianza],
            [Controlados],
            [IdTipoProceso],
            [PeticionEnviada],
            [IdFirma],
            [Visible]
        )
        VALUES
        (   @IdTipoSolicitudPedido, @IdUsuarioSolicitante, @AdjudicableParcialmente, @IdPrioridadSolicitudPedido,
            @MotivoUrgenciaSolPed, @VisitaRequerida, @JuntaAclaracionesRequerida, @UnaSolaEntregaRequerida, @Activo,
            @FechaEntregaRequerida, @FechaEntregaFinRequeridaF, @IdProveedorOperador, ----@IdProveedor,
            GETDATE(), @EntregasParciales, @IdContrato, @IdPeriodo, @IdPresupuesto, @IdLineaPresupuesto, 0, 0,
            @EntregaUnicoDomicilio, @IdDomiclioEntregaF, @IdCentroCosto, @Fianza, @Controlados, @IdTipoProcesoActual,
            1, '', 0                                                                  ---> Enviado
            );


        SELECT @IdSolicitudPedidoActual = SCOPE_IDENTITY();



        PRINT @IdSolicitudPedidoActual;
    END;

    --#### 2.-AGREGAR SOLICITUD DE PEDIDO DETALLE ####----
    BEGIN
        PRINT 'Solicitud pedido';

        INSERT INTO [dbo].[MM_SolicitudPedidoDetalle]
        (
            [IdSolicitudPedido],
            [IdMaterial],
            [Fecha],
            [Cantidad],
            [observaciones],
            [CreadoPor],
            [IdUnidad],
            [IdCentroCosto],
            [IdDomicilioEntrega]
        )
        SELECT @IdSolicitudPedidoActual,
               mat.IdMaterialContratista,
               GETDATE(),
               ed.Cantidad,
               '',
               @IdUsuarioSolicitante,
               mat.IdUnidad,
               ot.IdCentroCosto,
               @IdDomiclioEntrega
        FROM Adinco..OT_EstimacionDetalle ed
            INNER JOIN Adinco..OT_Estimacion e
                ON e.IdOTEstimacion = ed.IdOTEstimacion
            INNER JOIN Adinco..OT_SolicitudMaterial sm
                ON sm.IdOTSolicitudMaterial = ed.IdOTSolicitudMaterial
            INNER JOIN Adinco..SC_Materiales mat
                ON mat.IdSCMaterial = sm.IdSCMaterial
 INNER JOIN Adinco..OT_Solicitud ot
                ON ot.IdOTSolicitud = e.IdOTSolicitud
        WHERE e.IdOTEstimacion = @IdOTEstimacion
        GROUP BY mat.IdMaterialContratista,
                 ed.Cantidad,
                 mat.IdUnidad,
                 ot.IdCentroCosto;

        PRINT 'PEDIDO DETALLE';

        exec p_OT_EstimacionLineasPresupuesto @IdOTEstimacion,@IdSolicitudPedidoActual,@error out

		IF ISNULL(@error, '') <> ''
        BEGIN
                SET @error = 'Error al generar líenas:' + @error;
                RAISERROR(15600, -1, -1, @error);
				return
        END;

        PRINT 'Linea Presupuesto';

    END;

    --#### 2.- AGREGAR PR SAP
    BEGIN
        IF ISNULL(@SAPPR, '') <> ''
        BEGIN

            INSERT INTO DEA_AdjuntoPR
            (/*IdAjuntoPr,*/
                IdSolicitudPedido,
                IdDocumento,
                IdProveedor,
                Comentario,
                CreadoPor,
                CreadoEl,
                EditadoEl,
                EditadoPor,
                EliminadoEl,
                EliminadoPor,
                Activo,
                IsEliminado,
                ID_PR
            )
            SELECT @IdSolicitudPedidoActual,
                   NULL,
                   @IdProveedorOperador,
                   'SAP-PR ' + @FolioOT,
                   @IdUsuarioSolicitante,
                   GETDATE(),
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   1,
                   0,
                   @SAPPR;

            PRINT 'PR SAP';

        END;
    END;

    --#### 2.1.-AGREGAR FLUJO APROBACION DE SOLICITUD DE PEDIDO ####----

    BEGIN

        DECLARE @IdDocumento INT = @IdSolicitudPedidoActual;
        DECLARE @IdTipoOperacion INT = 2; --> Solictud de Pedido --> MM_TipoOperacion
        DECLARE @IdFlujoTarea INT =
                (
                    SELECT IdFlujo
                    FROM dbo.MM_FlujoEstatico
                    WHERE Detalle = 'FLUJO_SOLICITUD_PEDIDO_SISTEMA'
                );
        DECLARE @IdProveedor INT = @IdProveedorOperador;
        DECLARE @IdEstatusOperacion INT = 2; ---> Aprobada --> TA_Estatus
        DECLARE @IdEstadoFlujo INT = 7; ---> Estatus Tarea Finalizada --> TA_EstadoFlujoTarea 
        DECLARE @IdAsignador INT = @IdUsuarioSolicitante;
        DECLARE @Descripcion NVARCHAR(MAX) = N'';
        DECLARE @IdVigencia INT = 1; ---> DEFAULT 5 DÍAS  -->  TA_Vencimiento
        DECLARE @IdPrioridad INT = 1; ---> DEFAULT URGENTE -->TA_Prioridad


        INSERT INTO TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdEstatusOperacion,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad,
            IdFlujoTarea,
       IdEstadoFlujo,
            IdFirma
        )
        VALUES
        (@IdDocumento, @IdTipoOperacion, @IdEstatusOperacion, @IdProveedor, @IdAsignador, GETDATE(), @Descripcion,
         @IdVigencia, @IdPrioridad, @IdFlujoTarea, @IdEstadoFlujo, '');

        PRINT 'Operación';

		DECLARE @IdOperacionActual INT
        SELECT @IdOperacionActual = SCOPE_IDENTITY();


        ---GENERAR HISTORIAL

        SELECT @DescripcionH = CONCAT('Aprobación Automática ', NombreOperacion, ' de Control de Obra')
        FROM TA_TipoOperacion
        WHERE IdTipoOperacion = 2;


        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacionActual, GETDATE(), @DescripcionH, 1);

    END;

    --#### 2.2.-AGREGAR FLUJO APROBACION DETALLAR SOLICITUD DE PEDIDO (ALTA APROBADORES)####----
    BEGIN
        DECLARE @NombreTarea NVARCHAR(MAX) = N'SP/ OT';
        DECLARE @IdEstatus INT = 2; ---> APROBADO --> TA_Estatus


        SELECT @IdFlujoTarea = IdFlujo
        FROM dbo.MM_FlujoEstatico
        WHERE Detalle = 'FLUJO_SOLICITUD_PEDIDO_SISTEMA';


        DECLARE @IdAprobador INT =
                (
                    SELECT IdUsuario
                    FROM dbo.TA_Aprobador
                        INNER JOIN dbo.TA_FlujoTarea FT
                            ON FT.IdFlujoTarea = TA_Aprobador.IdFlujoTarea
                    WHERE FT.IdFlujoTarea = @IdFlujoTarea
                );
        DECLARE @Visto BIT = 1;
        DECLARE @NoSecuencia INT =
                (
                    SELECT NoSecuencia
                    FROM dbo.TA_Aprobador
                        INNER JOIN dbo.TA_FlujoTarea FT
                            ON FT.IdFlujoTarea = TA_Aprobador.IdFlujoTarea
                    WHERE FT.IdFlujoTarea = @IdFlujoTarea
                );

        DECLARE @IdOperacion INT = @IdOperacionActual;


        -- Insert statements for procedure here
        INSERT INTO TA_Tarea
        (
            NombreTarea,
            FechaRegistro,
            IdEstatus,
            Activo,
            Visto,
            IdAprobador,
            NoSecuencia,
            IdOperacion,
            IdFirma,
            Comentario,
            FechaCambioEstatus
        )
        VALUES
        (@NombreTarea, GETDATE(), @IdEstatus, 1, @Visto, @IdAprobador, @NoSecuencia, @IdOperacion, '', '', GETDATE());

        PRINT 'TA_Tarea';

		DECLARE @IdTarea INT
        SELECT @IdTarea = SCOPE_IDENTITY();


        INSERT INTO TA_TareaOperacion
        (
            IdTarea,
            IdOperacion
        )
        VALUES
        (@IdTarea, @IdOperacion);

        PRINT 'TA_TareaOperacion';

        ---GENERAR HISTORIAL DE APROBACIÓN AUTOMATICA

        SET @DescripcionH
            = N'Aprobación Automática ' +
              (
                  SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion = 2
              ) + N' de Control de Obra por (Usuario del Sistema)';

        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacionActual, GETDATE(), @DescripcionH, 3);

        SET @DescripcionH
            = N'Aprobación Automática ' +
              (
                  SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion = 2
              ) + N' de Control de Obra';

        PRINT 'TA_HistorialFlujoTarea';


        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacionActual, GETDATE(), @DescripcionH, 7);

        PRINT 'TA_HistorialFlujoTarea';

    END;



    --#### 3.-AGREGAR PETICION OFERTA ####----
BEGIN

        DECLARE @IdSolicitudPedido INT = @IdSolicitudPedidoActual;
        SET @IdProveedor = @IdProveedorPetrovendor;
        DECLARE @IdUsuario INT = @IdUsuarioSolicitante;
        DECLARE @IdTipoProceso INT = @IdTipoProcesoActual;
        DECLARE @JustificacionAdjDirecta NVARCHAR(MAX) = NULL;
        DECLARE @DocAdjDirecta NVARCHAR(MAX) = NULL;

        INSERT INTO MM_PeticionOferta
        (
            IdSolicitudPedido,
            IdSubcontratista,
            CreadoPor,
            CreadoEl,
            Activo,
            Visto,
            Iniciada,
            IdTipoProceso,
            Cotizado,
            NoCotizar,
            Visible,
            AceptoTerminosCondiciones,
            Verificable,
            FechaFinalizado,
            IdEstatus
        )
        VALUES
        (@IdSolicitudPedido, @IdProveedor, @IdUsuario, GETDATE(), 1, 1, 0, @IdTipoProceso, 1, 0, 0, 1, 1, GETDATE(), 2);


        PRINT 'MM_PeticionOferta';

        SELECT @IdPeticionOfertaActual = SCOPE_IDENTITY();

    END;

    --#### 4.-AGREGAR PETICION OFERTA DETALLE ####----
    BEGIN
        DECLARE @NoOFerta INT;

        DECLARE @IdPeticionOferta INT = @IdPeticionOfertaActual;
        DECLARE @IdMaterial INT = @IdMaterialOperador;
        DECLARE @ComentarioComprador NVARCHAR(MAX) = N'';
        DECLARE @NoMaterialesRequeridos FLOAT = @Cantidad;
        SET @IdUsuario = @IdUsuarioSolicitante;
        SET @IdProveedor = @IdProveedorPetrovendor;
        DECLARE @IdSolicitudPedidoDetalle INT = @IdSolicitudPedidoDetalleActual;


        DECLARE @UnidadProveedor NVARCHAR(300) =
                (
                    SELECT Unidad
                    FROM dbo.PV_MM_MaterialUnidad
                    WHERE IdUnidad = @IdUnidadProveedor
                );
        DECLARE @MaterialCotizadoTextoC NVARCHAR(MAX) =
                (
                    SELECT DescripcionCorta
                    FROM dbo.MM_Material
                    WHERE IdMaterial = @IdMaterialProveedor
                );
        DECLARE @MaterialCotizadoTextoL NVARCHAR(MAX) =
                (
                    SELECT DescripcionLarga
                    FROM dbo.MM_Material
                    WHERE IdMaterial = @IdMaterialProveedor
                );

        INSERT INTO MM_PeticionOfertaDetalle
        (
            IdPeticionOferta,
            IdSolicitudPedidoDetalle,
            IdMaterial,
            ComentariosComprador,
            CreadoEl,
            CreadoPor,
            Activo,
            NoMaterialesRequeridos,
            IdProveedorVenta,
            Cotizado,
            NoCotizar,
            IdUnidad,
            IdMaterialVendedor,
            SubTotal,
            PrecioUnitario,
            Disponibilidad,
            IdMoneda,
            FechaVigencia,
            UnidadProveedor,
            MaterialCotizadoTextoC,
            MaterialCotizadoTextoL,
            IdUnidadProveedor
        )
        SELECT @IdPeticionOferta,
               spd.IdSolicitudPedidoDetalle,
               mat.IdMaterialContratista,
               @ComentarioComprador,
               GETDATE(),
               @IdUsuario,
               1,
               spd.Cantidad,
               @IdProveedor,
               1,
               0,
               spd.IdUnidad,
               mat.IdMaestro,
               ed.Cantidad * ed.PrecioUnitario,
               ed.PrecioUnitario,
               spd.Cantidad,
               @IdMonedaFactura,
               GETDATE(),
               uni.Unidad,
               mat.DescripcionCorta,
               mat.Descripcion,
               spd.IdUnidad
        FROM Adinco..OT_EstimacionDetalle ed
            INNER JOIN Adinco..OT_Estimacion e
                ON e.IdOTEstimacion = ed.IdOTEstimacion
            INNER JOIN Adinco..OT_SolicitudMaterial sm
                ON sm.IdOTSolicitudMaterial = ed.IdOTSolicitudMaterial
            INNER JOIN Adinco..SC_Materiales mat
                ON mat.IdSCMaterial = sm.IdSCMaterial
            INNER JOIN Adinco..OT_Solicitud ot
                ON ot.IdOTSolicitud = e.IdOTSolicitud
            INNER JOIN MM_SolicitudPedidoDetalle spd
                ON spd.IdSolicitudPedido = @IdSolicitudPedido
                   AND spd.IdMaterial = mat.IdMaterialContratista
				   LEFT JOIN dbo.PV_MM_MaterialUnidad uni ON spd.IdUnidad = uni.IdUnidad

        WHERE e.IdOTEstimacion = @IdOTEstimacion
        GROUP BY spd.IdSolicitudPedidoDetalle,
                 mat.IdMaterialContratista,
                 spd.Cantidad,
                 spd.IdUnidad,
                 mat.IdMaestro,
                 ed.Cantidad,
                 ed.PrecioUnitario,
                 spd.Cantidad,
                 spd.IdUnidad,
                 mat.DescripcionCorta,
                 mat.Descripcion,
                 spd.IdUnidad,
				 uni.Unidad
        PRINT 'MM_PeticionOfertaDetalle';


    END;
    ----### 5. AGREGAR OPERARACIÓN DE COTIZACIÓN ###---
    BEGIN

        SET @IdDocumento = @IdSolicitudPedidoActual;
        SET @IdTipoOperacion = 6; --> Cotización --> MM_TipoOperacion		
        SET @IdProveedor = @IdProveedorOperador;
        SET @IdEstatusOperacion = 2; ---> Aprobada --> TA_Estatus
        SET @IdEstadoFlujo = 7; ---> Estatus Tarea Finalizada --> TA_EstadoFlujoTarea 
        SET @IdAsignador = @IdUsuarioSolicitante;
        SET @Descripcion = @ObservacionCotizacion;
        SET @IdVigencia = 1; ---> DEFAULT 5 DÍAS  -->  TA_Vencimiento
        SET @IdPrioridad = 1; ---> DEFAULT URGENTE -->TA_Prioridad
        DECLARE @FechaLimiteCotizacion DATETIME = GETDATE();


        INSERT INTO TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdEstatusOperacion,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad,
            FechaFinalizacion
        )
        VALUES
        (@IdDocumento, @IdTipoOperacion, @IdEstatusOperacion, @IdProveedor, @IdAsignador, GETDATE(), @Descripcion,
         @IdVigencia, @IdPrioridad, @FechaLimiteCotizacion);

        PRINT 'TA_Operacion';

        DECLARE @IdOperacionCotizacion INT;
        SET @IdOperacionCotizacion =
        (
            SELECT SCOPE_IDENTITY()
        );

        ---AGREGAR TERMINOS Y CONDICIONES DE OT PARA MOSTRARLO EN EL REPORTE DE PEDIDO---
        INSERT INTO dbo.TA_TerminosCondicionesOperacion
        (
            IdOperacion,
            IdTerminosYCondiciones
        )
        VALUES
        (   @IdOperacionCotizacion, -- IdOperacion - int
            @IdTerminosCondiciones  -- IdTerminosYCondiciones - int
            );

        PRINT 'TA_TerminosCondicionesOperacion';

    ---### ESTE OPERACIÓN NO LLEVA DETALLE EN TA_Tarea ###--

    END;

    ----### CREACIÓN DE APROBACIÓN PEDIDO Y APROBACIÓN DE PEDIDO  ###----

    BEGIN
        SET @IdSolicitudPedido = @IdSolicitudPedidoActual;
        DECLARE @Mensaje NVARCHAR(MAX) = N'Aprobación de Orden de Trabajo';
        SET @IdPrioridad = 1;
        SET @IdVigencia = 1;
        DECLARE @IdUsuarioCompras INT = @IdUsuarioSolicitante;
        DECLARE @IdProveedorCompras INT = @IdProveedorOperador;
        DECLARE @HorasVigencia INT = 24;
        DECLARE @ID_MONEDA_ACTUAL INT = @IdMonedaFactura;
        DECLARE @ID_PROVEEDOR_VENTAS INT = @IdProveedorPetrovendor;

        SET @IdTipoOperacion = 9; ---Aprobación de pedido --> TA_TipoOperacion
        DECLARE @TotalSumaPedidos FLOAT;
        DECLARE @VERSION INT;
        DECLARE @IdMonedaDLS INT = 2;


        SET @VERSION =
        (
            SELECT ISNULL(
                   (
                       SELECT TOP 1
                              P.Version
                       FROM MM_Pedido AS P
                       WHERE IdSolicitudPedido = @IdSolicitudPedidoActual
                       ORDER BY Version DESC
                   ),
                   1
                         )
        );


        INSERT INTO MM_Pedido
        (
            IdPeticionOferta,
            Comentarios,
            IdSolicitudPedido,
            IdSubcontratista,
            IdContrato,
            Editado,
            CreadoEl,
            CreadoPor,
            IdProveedorCompras,
            Version,
            IdMoneda,
            IdFirma,
            RecepcionServicio,
            ComentariosAsignado,
			FechaRecepcionServicio,
			IdUsuarioRecepcionServicio
        )
        SELECT PO.IdPeticionOferta,
               'Estimacion:' + ISNULL(@FolioEstimacion, ''),
               SP.IdSolicitudPedido,
               PO.IdSubcontratista,
               SP.IdContrato,
               0 AS editado,
               GETDATE(),
               @IdUsuarioCompras,
               @IdProveedorCompras,
               @VERSION,
               @ID_MONEDA_ACTUAL,
               '',
               1,
               ISNULL(@FolioOT, '') + ' [Creada por: ' + ISNULL(@creadorOT, '') + '] Objeto:' + ISNULL(@ObjetoOT, ''),
			   GETDATE(),
			   @IdUsuarioCompras
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
              AND PO.IdSubcontratista = @ID_PROVEEDOR_VENTAS -----AND POD.AddValidado = 1 AND POD.cOTIZADO= 1 AND POD.AddPedidoTemp= 1 
        GROUP BY PO.IdPeticionOferta,
                 SP.IdSolicitudPedido,
                 PO.IdSubcontratista,
                 SP.IdContrato;

        SELECT @IdPedidoActual = SCOPE_IDENTITY();

        INSERT INTO dbo.MM_HorasVigenciaPedido
        (
            IdPedido,
            HorasVigencia,
            FechaVigencia
        )
        VALUES
        (   @IdPedidoActual, -- IdPedido - int
            @HorasVigencia,  -- HorasVigencia - int
            NULL             -- FechaCreacionPedido - smalldatetime
            );

        PRINT 'MM_HorasVigenciaPedido';

        ---#Agregar al pedido detalle
        INSERT INTO MM_PedidoDetalle
        (
            IdPedido,
            IdMaterial,
            IdMaterialVendedor,
            IdPeticionOfertaDetalle,
            PrecioUnitario,
            Cantidad,
            IdMoneda,
            Subtotal,
            Activo,
            ComentariosCompras,
            CreadoPor,
            CreadoEl,
            IdUnidad,
            IdUnidadProveedor,
            RecepcionPedido,
            FechaRecepcionPedido,
            IdUsuarioRecepcionServicio
        )
        SELECT @IdPedidoActual AS IdPedido,
               POD.IdMaterial,
               POD.IdMaterialVendedor,
               POD.IdPeticionOfertaDetalle,
               POD.PrecioUnitario,
               SPD.cantidad,
               POD.IdMoneda,
               SPD.cantidad * POD.PrecioUnitario,
               1,
               '',
               @IdUsuarioCompras AS CreadoPor,
               GETDATE() AS CreadoEl,
               POD.IdUnidad,
               POD.IdUnidadProveedor,
               1,
               GETDATE(),
               @IdUsuarioSolicitante
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_PeticionOfertaDetalle AS POD
                ON POD.IdPeticionOferta = PO.IdPeticionOferta
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN MM_SolicitudPedidoDetalle AS SPD
                ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
        WHERE PO.IdSolicitudPedido = @IdSolicitudPedidoActual
   AND PO.IdSubcontratista = @ID_PROVEEDOR_VENTAS
        GROUP BY POD.IdMaterial,
                 POD.IdMaterialVendedor,
                 POD.IdPeticionOfertaDetalle,
                 POD.PrecioUnitario,
                 SPD.cantidad,
                 POD.IdMoneda,
                 SPD.cantidad,
                 POD.IdMoneda,
                 POD.IdUnidad,
                 POD.IdUnidadProveedor;


        PRINT 'MM_PedidoDetalle';

        --#Generar el IdPedidoGeneral   
        DECLARE @IdPedidoGeneral INT;
        DECLARE @FECHA_ACTUAL DATETIME =
                (
                    SELECT GETDATE()
                );
        EXEC dbo.SP_MM_GenerarIdPedidoGeneral @IdTipoPedido = 6,                        -- int 6 = ORDEN DE TRABAJO
                                              @IdPrimaryKey = @IdPedidoActual,          -- int
                                              @CreadoPor = @IdUsuarioCompras,           -- int
                                              @CreadoEl = @FECHA_ACTUAL,                -- datetime
                                              @IdProveedorActual = @IdProveedorCompras, -- int
                                              @IdPedidoGeneral = @IdPedidoGeneral OUTPUT,
                                              @CuentaBancaria = '';                     -- int
        PRINT 'SP_MM_GenerarIdPedidoGeneral';


        SET @IdFlujo =
        (
            SELECT IdFlujo
            FROM dbo.MM_FlujoEstatico
            WHERE Detalle = 'FLUJO_PEDIDO_SISTEMA'
        );

        INSERT INTO TA_Operacion
        (
            IdDocumento,
            IdTipoOperacion,
            IdFlujoTarea,
            IdEstadoFlujo,
            IdEstatusOperacion,
            IdProveedor,
            IdAsignador,
            FechaRegistro,
            Descripcion,
            IdVigencia,
            IdPrioridad,
            NoVersion,
            IdFirma
        )
        VALUES
        (@IdSolicitudPedido, @IdTipoOperacion, @IdFlujo, 3, 2, @IdProveedorCompras, @IdUsuarioCompras, GETDATE(),
         @Mensaje, @IdVigencia, @IdPrioridad, @VERSION, '');

        PRINT 'TA_Operacion 694';

        SELECT @IdOperacionAprobacionPedido = SCOPE_IDENTITY();


        SET @DescripcionH = N'Se ha registrado la operación ' +
                            (
                                SELECT ISNULL(NombreOperacion, 'APROBACIÓN DE PEDIDO DE ORDEN DE TRABAJO')
                                FROM TA_TipoOperacion
                                WHERE IdTipoOperacion = @IdTipoOperacion
                            );

        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacionAprobacionPedido, GETDATE(), @DescripcionH, 1);

        PRINT 'TA_HistorialFlujoTarea';

        ----#AGREGAR RELACION OPERACION PEDIDO APROBACION 
        INSERT INTO TA_Tarea
        (
            IdAprobador,
            IdEstatus,
            NombreTarea,
            Visto,
            FechaRegistro,
            Activo,
            NoSecuencia,
            IdOperacion,
            FechaCambioEstatus,
            Comentario,
            IdFirma
        )
        SELECT A.IdUsuario,
               2 AS Estatus,
               'Aprobación de pedido',
               1 AS Visto,
               GETDATE() AS FechaRegistro,
               2,
               A.NoSecuencia,
               @IdOperacionAprobacionPedido AS IdOperacion,
               GETDATE(),
               '',
               ''
        FROM TA_Aprobador AS A
            INNER JOIN TA_FlujoTarea AS FT
                ON FT.IdFlujoTarea = A.IdFlujoTarea
            INNER JOIN S_Usuario AS U
                ON U.IdUsuario = A.IdUsuario
        WHERE A.IdFlujoTarea = @IdFlujo
        ORDER BY NoSecuencia ASC;

        SET @DescripcionH = N'Se ha aprobado ' +
                            (
                                SELECT ISNULL(NombreOperacion, ' APROBACIÓN DE PEDIDO DE ORDEN DE TRABAJO')
                                FROM TA_TipoOperacion
                                WHERE IdTipoOperacion = @IdTipoOperacion
                            );

        INSERT INTO TA_HistorialFlujoTarea
        (
            IdOperacion,
            Fecha,
            Descripcion,
            IdEstadoFlujo
        )
        VALUES
        (@IdOperacionAprobacionPedido, GETDATE(), @DescripcionH, 7);

        PRINT 'TA_HistorialFlujoTarea 721';


        UPDATE HV
        SET FechaVigencia = DATEADD(HOUR, ISNULL(HV.HorasVigencia, 0), GETDATE())
        FROM MM_HorasVigenciaPedido AS HV
            INNER JOIN MM_Pedido AS P
                ON P.IdPedido = HV.IdPedido
        WHERE P.IdSolicitudPedido = @IdSolicitudPedidoActual
              AND P.Version = @VERSION;


        UPDATE dbo.MM_Pedido
        SET FechaEnvioPedido = GETDATE()
        WHERE IdPedido = @IdPedidoActual;

        --	

        /*****GENERAR ACEPTACIÓN***/

        IF (@permitirAceptacionAut = 1)
        BEGIN

            INSERT INTO MM_AceptacionPedido
            (
                IdProveedor,
                IdPedido,
                Comentario,
                NombreUsuarioEntrega,
                Activo,
                Creado,
                IdDomicilioEntrega,
                CreadorPor,
                Modificado,
                ModificadoPor,
                RecibidoPor,
                NombreRecibidoPor,
                EntregadoPor,
                FacturaSolicitada,
                RecepcionServicio,
                PCN_Agregado,
                DocumentoDescargado,
                NoSecuencia,
                IdNacionalidadProveedor,
                IdRegimenProveedor,
                IdPaisProveedor,
                IdEstatusEliminado,
                IdEliminado,
                IdOcCarso,
                BtnCartaCarso,
                Asiento
            )
            SELECT IdProveedorCompras,
                   IdPedido,
                   ComentariosAsignado,
                   prov.RazonSocial,
                   1,
                   GETDATE(),
                   @IdDomiclioEntregaF,
                   p.IdUsuarioRecepcionServicio,
                   NULL,
                   NULL,
                   p.IdUsuarioRecepcionServicio,
                   u.Nombre,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   prov.IdNacionalidad,
                   prov.IdTipoRegimen,
                   prov.IdPais,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL
            FROM MM_Pedido p
                INNER JOIN S_Proveedor prov
                    ON prov.IdProveedor = p.IdSubcontratista
                LEFT JOIN S_Usuario u
                    ON u.IdUsuario = p.IdUsuarioRecepcionServicio
            WHERE IdPedido = @IdPedidoActual;

            PRINT 'TA_HistorialFlujoTarea 758';

            DECLARE @IdAceptacionPedido INT;

            SELECT @IdAceptacionPedido = MAX(IdAceptacionPedido)
            FROM MM_AceptacionPedido
            WHERE IdPedido = @IdPedidoActual;

            PRINT '@IdAceptacionPedido' + CAST(@IdAceptacionPedido AS VARCHAR);


            INSERT INTO MM_AceptacionPedidoDetalle
            (
                IdAceptacionPedido,
                IdPedidoDetalle,
                Cantidad,
                Detalle,
                CreadoPor,
                Creado,
                Excedente,
                PCN,
                PCN_Agregado,
                EditadoPor,
                EditadoEl,
                ClasificacionCN,
                IdEstatusEliminado,
              IdEliminado,
                RecId
            )
            SELECT @IdAceptacionPedido,
                   pd.IdPedidoDetalle,
                   pd.Cantidad,
                   mat.DescripcionCorta,
                   pd.CreadoPor,
                   GETDATE(),
                   0,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   0,
                   NULL
            FROM MM_PedidoDetalle pd
                INNER JOIN MM_Material mat
                    ON mat.IdMaterial = pd.IdMaterial
            WHERE pd.IdPedido = @IdPedidoActual;

		

            PRINT 'TA_HistorialFlujoTarea 779';

			/**Obtener líneas de presupuesto por material**/
			select pd.IdMaterial,
					spdl.IdSolicitudPedidoDetalle,
					NLineas = count(distinct spdl.IdLineaPresupuesto)
			into #tmpNLineas
			FROM MM_AceptacionPedidoDetalle s2
                INNER JOIN MM_AceptacionPedido s1
                    ON s1.IdAceptacionPedido = s2.IdAceptacionPedido
                INNER JOIN MM_Pedido p
                    ON p.IdPedido = s1.IdPedido
                INNER JOIN MM_PedidoDetalle pd
                    ON pd.IdPedidoDetalle = s2.IdPedidoDetalle
				inner join MM_SolicitudPedidoDetalle spd on spd.IdSolicitudPedido = p.IdSolicitudPedido and
																spd.IdMaterial = pd.IdMaterial
				inner join MM_SolicitudPedidoDetalleLineaPresupuesto spdl on spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
            WHERE s2.IdAceptacionPedido = @IdAceptacionPedido
			group by pd.IdMaterial,spdl.IdSolicitudPedidoDetalle

            INSERT INTO [dbo].[MM_AceptacionPedidoDetalleInstalacion]
            (
                IdAceptacionPedido,
                IdAceptacionPedidoDetalle,
                IdPedidoDetalle,
                IdProveedor,
                IdMaterial,
                Cantidad,
                IdInstalacion,
                IdLineaPresupuesto
            )
            SELECT s2.IdAceptacionPedido,
                   s2.IdAceptacionPedidoDetalle,
                   max(s2.IdPedidoDetalle),
                   max(s1.IdProveedor),
                   max(pd.IdMaterial),
                   max(s2.Cantidad),
                   max(spdl.IdInstalacion),
                   max(spdl.IdLineaPresupuesto)
            FROM MM_AceptacionPedidoDetalle s2
                INNER JOIN MM_AceptacionPedido s1
                    ON s1.IdAceptacionPedido = s2.IdAceptacionPedido
                INNER JOIN MM_Pedido p
                    ON p.IdPedido = s1.IdPedido
                INNER JOIN MM_PedidoDetalle pd
                    ON pd.IdPedidoDetalle = s2.IdPedidoDetalle
				inner join MM_SolicitudPedidoDetalle spd on spd.IdSolicitudPedido = p.IdSolicitudPedido and
																spd.IdMaterial = pd.IdMaterial
				inner join MM_SolicitudPedidoDetalleLineaPresupuesto spdl on spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
				inner join #tmpNLineas tmpN on tmpN.IdMaterial = spd.IdMaterial and
											tmpN.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle
            WHERE s2.IdAceptacionPedido = @IdAceptacionPedido
            GROUP BY s2.IdAceptacionPedido,
                     s2.IdAceptacionPedidoDetalle
                     /*s2.IdPedidoDetalle,
                     s1.IdProveedor,
                     pd.IdMaterial,
                     spdl.IdInstalacion,
					 spdl.IdLineaPresupuesto,
					 s2.Cantidad,
					 tmpN.Nlineas*/


            INSERT INTO RelacionCartaCNPedido
            (
                IdPedido,
                IdAceptacionPedido,
                PedirCarta,
                CreadoPor,
                FechaCreacion
            )
            SELECT @IdPedidoActual,
                   @IdAceptacionPedido,
                   1,
                   @IdUsuarioCompras,
                   GETDATE();


            --IMPORTAR DOCUMENTOS HACIA LA ACEPTACION

            EXEC Adinco..p_OT_Estimacion_Aceptacion_Docs @IdOTEstimacion,
                                                         @IdAceptacionPedido,
                                                         @error OUT;

            IF ISNULL(@error, '') <> ''
            BEGIN
                SET @error = 'Error al importar documentos:' + @error;
                RAISERROR(15600, -1, -1, @error);
            END;

            SET @error = '';

            --CERRAR SEMANAS ABIERTAS DE MANERA AUTOMÁTICA

            EXEC Adinco..p_OT_Estimacion_Cerrar_Semana @IdOTEstimacion, @error OUT;

            IF ISNULL(@error, '') <> ''
            BEGIN
                SET @error = 'Error al cerrar semanas:' + @error;
                RAISERROR(15600, -1, -1, @error);
            END;

        --Asegurarse de haber generado el encabezado de la aceptacion
        --if(
        --	@@ROWCOUNT =0  OR
        --	@IdAceptacionPedido = 0
        --)
        --begin

        --	RAISERROR('No fue posible generar la aceptación',0,1)
        --end

        END;
    END;


 SELECT @pIdSolicitudPedidoActual = @IdSolicitudPedidoActual,
           @pIdPedidoActual = @IdPedidoActual,
           @pIdPedidoGeneral = @IdPedidoGeneral;
--- VALIDACION ERRROR ---

END;


