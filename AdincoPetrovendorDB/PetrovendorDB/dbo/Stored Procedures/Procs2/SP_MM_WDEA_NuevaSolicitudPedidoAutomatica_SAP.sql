USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_WDEA_NuevaSolicitudPedidoAutomatica_SAP]    Script Date: 19/10/2022 01:44:34 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/09/2021
-- Description:	Creacion de solicitud de pedido automatica
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/10/2022
-- Description:	correcciones en validaciones de lineas de presupuesto
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_WDEA_NuevaSolicitudPedidoAutomatica_SAP] --'4500564101',3315
	-- Add the parameters for the stored procedure here
	@Purchasing NVARCHAR(100),
	@IdContrato INT,
	@IdBitacoraLectura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdSolicitudPedido int,
		@IdTipoSolicitudPedido int,
        @IdProveedor int, 
        @IdUsuarioSolicitante int,
        @AdjudicableParcialmente bit, 
        @IdPrioridad int,
        @MotivoUrgencia nvarchar(max),
        @VisitaRequerida bit,
        @JuntaAclaracionesRequerida bit,
        @UnaSolaEntregaRequerida bit,
        @Activo bit,
        @FechaEntregaRequerida nvarchar(max), 
        @FechaEntregaFinRequerida nvarchar(max),
        @EntregasParciales bit,
        @IdPeriodo int,
        @IdPresupuesto int,
        @IdLineaPresupuesto int, 
        @IdCentroCosto int, --
        @IdTipoGasto int, 
        @IdTerminosInternacionales int, 
        @EntregaUnicoDomicilio bit, 
        @IdDomiclioEntrega int, --
        @Fianza bit,
        @Controlados bit,
		@Solicitante INT,
		@CONTTOTAL INT,
		@CONTPARTIDAS INT = 1,
		@IdInstalacion INT,
		@WBS NVARCHAR(100),
		@IdFlujoTarea INT,
		@IdOperacion INT,
		@IdOperadora INT,
		@RESPUESTASOLPED INT,
		@RESPUESTASOLPEDDETALLE INT,
		@RESPUESTASOLPEDLINEAPRESUPUESTO INT,
		@RESPUESTAOPERACION INT,
		@RESPUESTATAREA INT,
		@MENSAJEFINAL NVARCHAR(1000);	
		
IF @IdContrato = 10145
BEGIN
	
	SET @IdInstalacion = (SELECT TOP 1
								i.IdInstalacion
							FROM Adinco.dbo.CO_Instalacion AS i (NOLOCK)
							 JOIN adinco.dbo.CO_Contrato AS c (NOLOCK) ON c.IdAreaContractual = i.IdAreaContractual and c.IdContrato = @IdContrato
							WHERE ISNULL(i.Activo,0) = 1
							ORDER BY i.CreadoEn DESC);

END
ELSE
BEGIN

	--SE OBTIENE DEL WBS EL CENTRO DE COSTO DEL CATALOGO
	SET @WBS = (SELECT TOP 1 
					RIGHT(WBS_ELEMENT, LEN(WBS_ELEMENT) - 11)
				FROM dbo.WDEA_PurchasingDocumentsImportados
				WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato);

	SET @WBS = (SELECT LEFT(@WBS, LEN(@WBS) - 10));

	--SE ASIGNA EL CENTRO DE COSTO
	SET @IdInstalacion = (SELECT TOP 1 
								IdInstalacionAdinco 
							FROM PozosSAP 
							WHERE IdPozoSAP = CAST(@WBS AS INT));

END




--SE ASIGNA LAS VARIABLES NECESARIAS PARA LA CREACION DEL PROCESO DE PROCURA
SELECT TOP 1
	@IdTipoSolicitudPedido = 10002,--BIENES/SERVICIOS
	@IdProveedor = IDPROVEEDOR,
	@IdUsuarioSolicitante = IDUSUARIOSOLICITANTE,
	@AdjudicableParcialmente = 0,
	@IdPrioridad = 10001, --ALTA (ESTE DATO YA NO SE MUESTRA)
	@MotivoUrgencia = JUSTIFICACION,
	@VisitaRequerida = 0,
	@JuntaAclaracionesRequerida = 0,
	@UnaSolaEntregaRequerida = 1,
	@Activo = 1,
	@FechaEntregaRequerida = VALIDITY_PER_START,
	@FechaEntregaFinRequerida = VALIDITY_PER_END,
	@EntregasParciales = 0,
	@IdTipoGasto = 0,
	@IdTerminosInternacionales = 0,
	@EntregaUnicoDomicilio = 1,
	@IdContrato = IDCONTRATO,
	@IdLineaPresupuesto = IDLINEAPRESUPUESTOMES,
	@Fianza = 0,
	@Controlados = 0,
	@Solicitante = IDUSUARIOSOLICITANTE
FROM dbo.WDEA_PurchasingDocumentsImportados
WHERE PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato;

--CONTRATO DE PRUEBAS- COMENTAR PARA PRODUCTIVO
-- SET @IdContrato = 10038;

--SE BUSCA LA OPERADORA SEGUN EL CONTRATO
SET @IdOperadora = (SELECT TOP 1
						PR.IdProveedor
					FROM Adinco.dbo.CO_Contrato AS C
						JOIN Adinco.dbo.CO_Contratista AS CI ON C.IdContratista = CI.IdContratista
						JOIN Petrovendor.dbo.S_Proveedor AS PR ON CI.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = PR.RFC
					WHERE C.IdContrato = @IdContrato AND C.Activo = 1);

SET @IdCentroCosto = (SELECT TOP 1 IdCentroCosto FROM dbo.CC_CentroCosto WHERE IdProveedor = @IdOperadora);

SET @IdDomiclioEntrega = (SELECT TOP 1 IdDomicilio FROM dbo.DG_Domicilio WHERE IdProveedor = @IdOperadora);

--BUSQUEDA Y ASIGNACION DE PRESUPUESTO Y PERIODO
SELECT TOP 1
	@IdPresupuesto = COP.IdPresupuesto,
	@IdPeriodo = COPC.IdPeriodo
FROM Adinco.dbo.CO_PeriodoContrato  AS COPC
      JOIN Adinco.dbo.CO_ProgramaActividad AS COPA 
		ON COPC.IdPeriodo = COPA.IdPeriodoContrato
      JOIN Adinco.dbo.CO_Presupuesto AS COP 
		ON COPA.IdProgramaActividad = COP.IdProgramaActividad AND COP.Actual = 1
	  JOIN Adinco.dbo.CO_LineaPresupuestoMes AS LPM 
		ON LPM.IdPresupuesto = COP.IdPresupuesto 
		AND LPM.IdLineaPresupuestoMes = @IdLineaPresupuesto;

--CREACION DE LA SOLPED
INSERT INTO [dbo].[MM_SolicitudPedido]
           ([IdTipoSolicitudPedido]
           ,[IdUsuarioSolicitante]
           ,[AdjudicableParcialmente]
           ,[IdPrioridadSolicitudPedido]
           ,[MotivoUrgencia]
           ,[VisitaRequerida]
           ,[JuntaAclaracionesRequerida]
           ,[UnaSolaEntregaRequerida]
           ,[Activo]
           ,[FechaEntregaRequerida]
           ,[FechaEntregaFinRequerida]
           ,[IdProveedor]
           ,[FechaAlta]
           ,[EntregasParciales]
           ,[IdContrato]
           ,[IdPeriodo]
           ,[IdPresupuesto]
           ,[IdLineaPresupuesto]
           ,[IdTipoGasto]
           ,[IdTerminoInternacionales]
           ,[UnicoDomicilioEntrega]
           ,[IdDomicilioEntrega]
           ,[IdCentroCosto]
           ,[Fianza]
           ,[Controlados]
		   ,Solicitante
           )
     VALUES
           (
            @IdTipoSolicitudPedido,
            @IdUsuarioSolicitante,
            @AdjudicableParcialmente, 
            @IdPrioridad,
            @MotivoUrgencia,
            @VisitaRequerida,
            @JuntaAclaracionesRequerida,
            @UnaSolaEntregaRequerida,
            @Activo,
            @FechaEntregaRequerida,
            @FechaEntregaFinRequerida,
            @IdOperadora,
            GETDATE(),
            @EntregasParciales
            ,@IdContrato
            ,@IdPeriodo
            ,@IdPresupuesto
            ,@IdLineaPresupuesto
            ,0 --@IdTipoGasto
            ,@IdTerminosInternacionales
            ,@EntregaUnicoDomicilio
            ,@IdDomiclioEntrega
            ,@IdCentroCosto
            ,@Fianza
            ,@Controlados
			,@Solicitante
            )
    
    SET @IdSolicitudPedido = (SCOPE_IDENTITY());

	--CREACION DE LOS DETALLES DE LA SOLPED
	INSERT INTO MM_SolicitudPedidoDetalle
	(
		IdSolicitudPedido,
		IdMaterial,
		Fecha,
		Cantidad,
		observaciones,
		CreadoPor,
		IdUnidad,
		IdCentroCosto,
		IdDomicilioEntrega,
		IDMONEDA_WS,
		NET_PRICE,
		TERMINOS_PAGO
	)
	SELECT
		@IdSolicitudPedido,
		PDI.IDMATERIAL,
		GETDATE(),
		PDI.ORDER_QUANTITY,
		NULL,
		NULL,
		IDUNIDAD,
		@IdCentroCosto,
		@IdDomiclioEntrega,
		PDI.IDMONEDA,
		PDI.NET_PRICE,
		PDI.TERMINOS_DE_PAGO
	FROM WDEA_PurchasingDocumentsImportados AS PDI
	WHERE PDI.PURCHASING_DOCUMENT = @Purchasing AND IDCONTRATO = @IdContrato
	GROUP BY PDI.IDMATERIAL,
			PDI.ORDER_QUANTITY,
			PDI.IDUNIDAD,
			PDI.IDMONEDA,
			PDI.NET_PRICE,
			PDI.TERMINOS_DE_PAGO;

	--CREACION DE LAS LINEAS DE PRESUPUESTO POR DETALLE
	INSERT INTO dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
	(
		IdSolicitudPedidoDetalle,
		IdCentroCosto,
		IdInstalacion,
		IdLineaPresupuesto
	)
	SELECT
		IdSolicitudPedidoDetalle,
		@IdCentroCosto,
		@IdInstalacion,
		@IdLineaPresupuesto
	FROM MM_SolicitudPedidoDetalle
	WHERE IdSolicitudPedido = @IdSolicitudPedido;

	--BUSQUEDA DEL FLUJO DEFAULT DE APROBACION AUTOMATICA
	SET @IdFlujoTarea = (SELECT TOP 1 IdFlujoTarea FROM TA_FlujoTarea WHERE Nombre = 'FLUJO APROBACION AUTOMATICA - SOLICITUD DE PEDIDO');

	IF ISNULL(@IdFlujoTarea,0) = 0
	BEGIN

		--CREACION DE UN NUEVO FLUJO AUTOMATICO
		INSERT INTO TA_FlujoTarea
		(
			Nombre,
			Descripcion,
			IdTipoFlujo,
			IdTipoOperacion,
			Condicion,
			FechaCreacion,
			CreadorPor,
			IdProveedor,
			Activo,
			Eliminado
		)
		VALUES
		(
			'FLUJO APROBACION AUTOMATICA - SOLICITUD DE PEDIDO',
			'FLUJO APROBACION AUTOMATICA - SOLICITUD DE PEDIDO',
			1,
			2,
			0,
			GETDATE(),
			@Solicitante,
			@IdOperadora,
			1,
			0
		);

		SET @IdFlujoTarea = (SCOPE_IDENTITY());

		--CREACION DE LOS APROBADORES PARA EL FLUJO (SOLO 1)
		INSERT INTO TA_Aprobador
		(
			IdFlujoTarea,
			IdUsuario,
			NoSecuencia
		)
		VALUES
		(
			@IdFlujoTarea,
			@Solicitante,
			1
		);

	END

	--CREACION DE LA OPERACION PARA LA APROBACION DE LA SOLPED
	INSERT INTO TA_Operacion
	(
		IdDocumento,
		IdTipoOperacion,
		IdFlujoTarea,
		IdEstatusOperacion,
		IdEstadoFlujo,
		IdProveedor,
		IdAsignador,
		FechaRegistro,
		Descripcion, 
		IdVigencia, 
		IdPrioridad
	)
	VALUES
	(
		@IdSolicitudPedido,
		2,--APROBACION DE SOLICITUD DE PEDIDO
		@IdFlujoTarea,
		2,--APROBADA
		3,--TAREA APROBADA
		@IdOperadora,
		@Solicitante,
		GETDATE(),
		'FLUJO APROBACION AUTOMATICA - SOLICITUD DE PEDIDO',
		1,
		2
	);

	SET @IdOperacion = (SCOPE_IDENTITY());

	--CREACION DE LAS TAREAS
	INSERT INTO TA_Tarea
	(
		NombreTarea,
		FechaRegistro,
		IdEstatus,
		Activo, 
		IdAprobador,
		NoSecuencia,
		IdOperacion,
		Comentario,
		FechaCambioEstatus
	)
	values
	(
		'Requisición',
		GETDATE(),
		2,--APROBADA
		1,
		@Solicitante,
		1,
		@IdOperacion,
		'APROBACION AUTOMATICA - SOLICITUD DE PEDIDO',
		GETDATE()
	);

	INSERT INTO TA_TareaOperacion
	(
		IdTarea,
		IdOperacion
	)
	SELECT
		IdTarea,
		IdOperacion
	FROM TA_Tarea
	WHERE IdOperacion = @IdOperacion;

	--VALIDACION PARA LA CANTIDAD DE DATOS INSERTADOS
	--INSERCION EN MM_SolicitudPedido
	SET @RESPUESTASOLPED = (SELECT COUNT(1) FROM MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido);
	--INSERCION EN MM_SolicitudPedidoDetalle
	SET @RESPUESTASOLPEDDETALLE = (SELECT COUNT(1) FROM MM_SolicitudPedidoDetalle WHERE IdSolicitudPedido = @IdSolicitudPedido);
	--INSERCION EN MM_SolicitudPedidoDetalleLineaPresupuesto
	SET @RESPUESTASOLPEDLINEAPRESUPUESTO = (SELECT COUNT(1) FROM MM_SolicitudPedidoDetalleLineaPresupuesto WHERE IdSolicitudPedidoDetalle IN (SELECT IdSolicitudPedidoDetalle FROM MM_SolicitudPedidoDetalle WHERE IdSolicitudPedido = @IdSolicitudPedido));
	--INSERCION EN TA_Operacion
	SET @RESPUESTAOPERACION = (SELECT COUNT(1) FROM TA_Operacion WHERE IdOperacion = @IdOperacion);
	--INSERCION EN TA_Tarea
	SET @RESPUESTATAREA = (SELECT COUNT(1) FROM TA_Tarea WHERE IdOperacion = @IdOperacion);


	IF @RESPUESTASOLPED > 0 AND 
		@RESPUESTASOLPEDDETALLE > 0 AND 
		@RESPUESTASOLPEDLINEAPRESUPUESTO > 0 AND 
		@RESPUESTAOPERACION > 0 AND 
		@RESPUESTATAREA > 0
	BEGIN 
		--SE GAURDO EXITOSAMENTE LA SOLPED
		SET @MENSAJEFINAL = 'PURCHASING_DOCUMENT ' + @Purchasing + ' PROCESADO EN PROCURA CON LA SOLICITUD DE PEDIDO #' + CAST(@IdSolicitudPedido AS NVARCHAR) + ' CORRECTAMENTE';

		INSERT INTO WDEA_Bitacora_AdincoSAP
		(
			Fecha,
			Mensaje,
			NoConsecutivoProcesamiento,
			IdBitacoraLectura
		)
		VALUES
		(
			GETDATE(),
			@MENSAJEFINAL,
			NULL,
			@IdBitacoraLectura
		);

		--SE EJECUTA LA CREACION DE LA PETICION OFERTA (SIGUIENTE PASO EN EL PROCESO)
		EXEC SP_MM_WDEA_NuevaPeticionOfertaAutomatica_SAP @IdSolicitudPedido,
															@Purchasing,
															@IdOperadora,
															@IdContrato,
															@IdBitacoraLectura;

	END
	ELSE
	BEGIN
		--OCURRIO ALGUN ERROR EN LA INCERSION
		SET @MENSAJEFINAL = 'ERROR AL PROCESAR EL PURCHASING_DOCUMENT ' + @Purchasing + ' EN LA SOLICITUD DE PEDIDO DE PROCURA, FALTO DE PROCESAR LA PETICION OFERTA, COTIZACION Y PEDIDO';

		IF @RESPUESTASOLPED = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN MM_SolicitudPedido'

		END

		IF @RESPUESTASOLPEDDETALLE = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN MM_SolicitudPedidoDetalle'

		END

		IF @RESPUESTASOLPEDLINEAPRESUPUESTO = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN MM_SolicitudPedidoDetalleLineaPresupuesto'

		END

		IF @RESPUESTAOPERACION = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN TA_Operacion'

		END

		IF @RESPUESTATAREA = 0
		BEGIN

			SET @MENSAJEFINAL = @MENSAJEFINAL + ', ERROR AL REGISTRAR EN TA_Tarea'

		END

		INSERT INTO WDEA_Bitacora_AdincoSAP
		(
			Fecha,
			Mensaje,
			NoConsecutivoProcesamiento,
			IdBitacoraLectura
		)
		VALUES
		(
			GETDATE(),
			@MENSAJEFINAL,
			NULL,
			@IdBitacoraLectura
		);

	END

END