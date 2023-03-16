USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_AgregarSolicitudPedido_V2'
)
    DROP PROCEDURE SP_MM_AgregarSolicitudPedido_V2;
GO
-- =============================================
-- Author:  Alexander Gomez
-- Create date: 16/03/2023
-- Description: Generacion de la solicitud de pedido, junto con su operacion y tareas
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarSolicitudPedido_V2]
        
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
        @IdCentroCosto int,
        @IdTipoGasto int, 
        @IdTerminosInternacionales int, 
        @EntregaUnicoDomicilio bit, 
        @IdDomiclioEntrega int, 
        @IdContrato int,
        @Fianza bit,
        @Controlados bit,
		@IdSolicitante INT,
		@IdFlujoTarea INT,
		@IdVigencia INT,
		@Descripcion VARCHAR(MAX),
		@IdsNuevosAprobadores VARCHAR(MAX)
AS
BEGIN
    DECLARE @IdSolicitudPedido int
    DECLARE @IdDomiclioEntregaF int 
    DECLARE @IdTerminosInternacionalesF int
    DECLARE @FechaEntregaFinRequeridaF nvarchar(max)
    DECLARE @RFC NVARCHAR(100)
	DECLARE @DescripcionH nvarchar(MAX)
	DECLARE @IdOperacion INT
	CREATE TABLE #APROBADORES (IdRow INT IDENTITY(1,1),IdAprobador INT, NoSecuencia INT);
	CREATE TABLE #TAREAS_CREADAS (IdRow INT IDENTITY(1,1),IdTarea INT);
	DECLARE @CONT_TAREAS INT = 1;
	DECLARE @CONT_TAREAS_TOTAL INT;
	DECLARE @ID_TAREA INT;
	DECLARE @ID_TIPOFLUJO INT;
	DECLARE @VALIDAR_FLUJO INT = (SELECT IdFlujoTarea FROM TA_FlujoTarea WHERE IdFlujoTarea = @IdFlujoTarea AND IdTipoOperacion = 2);--Requisición
    SET NOCOUNT ON;
    --VALIDAR SI REALMENTE EXISTE EL FLUJO A SU TIPO DE OPERACION
	IF ISNULL(@VALIDAR_FLUJO,0) = 0
	BEGIN
		SELECT 'ERROR' AS Error,'TIPO DE FLUJO NO CORRESPONDIENTE A REQUISICIÓN' AS Descripcion
	END
	ELSE
	BEGIN
    --- Validar Domicilios Entrega
    IF @IdDomiclioEntrega = 0 
        BEGIN
            SET @IdDomiclioEntregaF = NULL
        END  
    ELSE 
        BEGIN
            SET @IdDomiclioEntregaF = @IdDomiclioEntrega
        END 
     
     --- Validar Tipo de Intercom
     IF @IdTerminosInternacionales = 0 
        BEGIN
            SET @IdTerminosInternacionalesF = NULL
        END  
    ELSE 
        BEGIN
            SET @IdTerminosInternacionalesF = @IdTerminosInternacionales
        END 
    --- Validar EntregasParciales ----
    IF @EntregasParciales =  0
        BEGIN
            SET @FechaEntregaFinRequeridaF = NULL
        END  
    ELSE 
        BEGIN
            SET @FechaEntregaFinRequeridaF = @FechaEntregaFinRequerida
        END 
    --VALIDACION DE CONTRATO VACIO
    IF ISNULL(@IdContrato,0) = 0
    BEGIN
        /*OBTENER EL CONTRATO POR MEDIO DEL PERIODO SELECCIONADO*/
		SELECT   @IdContrato=IdContrato 
		FROM      Adinco..CO_PeriodoContrato  
		WHERE    (IdPeriodo = @IdPeriodo)    

		IF ISNULL(@IdContrato,0) = 0
		BEGIN
		/*SI NO SE ENCONTRO EL CONTRATO POR MEDIO DEL PERIODO, BUSCARLO POR MEDIO DEL PROVEEDOR*/
        SET @RFC = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);
        SET @IdContrato = (SELECT TOP 1
                                IdContrato 
                            FROM Adinco.dbo.CO_Contratista AS CON
                            JOIN Adinco.dbo.CO_Contrato AS CO
                                ON CON.IdContratista = CO.IdContratista
                            WHERE CON.RFC = @RFC);
		END 
    END

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
		   ,[Solicitante]
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
            @FechaEntregaFinRequeridaF,
            @IdProveedor,
            GETDATE(),
            @EntregasParciales
            ,@IdContrato
            ,@IdPeriodo
            ,@IdPresupuesto
            ,@IdLineaPresupuesto
            ,0 --@IdTipoGasto
            ,@IdTerminosInternacionalesF
            ,@EntregaUnicoDomicilio
            ,@IdDomiclioEntregaF
            ,@IdCentroCosto
            ,@Fianza
            ,@Controlados
			,@IdSolicitante
            )
    
    set @IdSolicitudPedido= (select @@IDENTITY);

	--GENERACION DE LA OPERACION
	--SE OBTIENE EL IDOPERACION SI ES QUE EXISTE CON LOS MISMOS DATOS
	SET @IdOperacion = (SELECT TOP 1 
							IdOperacion
						FROM dbo.TA_Operacion 
						WHERE IdDocumento = @IdSolicitudPedido 
							AND IdTipoOperacion = 2
							AND IdProveedor = @IdProveedor
							);

	IF ISNULL(@IdOperacion,0) = 0
	BEGIN
			
		INSERT INTO TA_Operacion
		(IdDocumento,
			IdTipoOperacion,
			IdFlujoTarea,
			IdEstatusOperacion,
			IdEstadoFlujo,
			IdProveedor,
			IdAsignador,
			FechaRegistro,
			Descripcion, 
			IdVigencia, 
			IdPrioridad)
		VALUES(@IdSolicitudPedido,
				2, --Requisición
				@IdFlujoTarea,
				1,--En Aprobacion
				2,--Tarea En Aprobacion
				@IdProveedor,
				@IdUsuarioSolicitante,
				GETDATE(), 
				@Descripcion,
				@IdVigencia,
				@IdPrioridad)

		SET @IdOperacion = (SCOPE_IDENTITY());

	END

	----Agregar Evento al Historial del Flujo de Tarea----
	SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdUsuarioSolicitante)+ ' ha registrado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion=2)
	INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
	VALUES(@IdOperacion,GETDATE(),@DescripcionH,1);

	--GENERACION DE LAS TAREAS DE LOS APROBADORES
	--SE OBTIENEN LOS APROBADORES DEL FLUJO
	INSERT INTO #APROBADORES (IdAprobador, NoSecuencia)
	SELECT usuario.IdUsuario,
           aprobador.NoSecuencia
    FROM dbo.TA_FlujoTarea flujo (NOLOCK)
        INNER JOIN dbo.TA_Aprobador aprobador (NOLOCK)
            ON flujo.IdFlujoTarea = aprobador.IdFlujoTarea
        INNER JOIN dbo.S_Usuario usuario (NOLOCK)
            ON aprobador.IdUsuario = usuario.IdUsuario
			AND usuario.Activo = 1
    WHERE flujo.Activo = 1
          AND (
                  flujo.IdTipoOperacion = 14
                  OR flujo.IdTipoOperacion = 2
              )
          AND (
                  flujo.Eliminado = 0
                  OR flujo.Eliminado IS NULL
              )
          AND flujo.IdFlujoTarea = @IdFlujoTarea;

	--SE AGREGAN LOS APROBADORES ADICIONALES AL FLUJO
	INSERT INTO #APROBADORES (IdAprobador)
	SELECT CAST(splitdata AS INT) FROM dbo.fnSplitString (@IdsNuevosAprobadores, '|');
	
	--SE AGREGAN LAS TAREAS DE LOS APROBADORES
	INSERT INTO TA_Tarea(NombreTarea,
						FechaRegistro,
						IdEstatus,
						Activo, 
						Visto,
						IdAprobador,
						NoSecuencia,
						IdOperacion)
	SELECT
		'Requisición',
		GETDATE(),
		1,--En Aprobacion
		1,
		0,
		IdAprobador,
		IdRow,
		@IdOperacion
	FROM #APROBADORES;

	--SE AGREGA LA RELACION DE LA TAREA Y LA OPERACION
	INSERT INTO TA_TareaOperacion(IdTarea,IdOperacion)
	SELECT
		IdTarea,
		IdOperacion
	FROM TA_Tarea
	WHERE IdOperacion = @IdOperacion;

	INSERT INTO #TAREAS_CREADAS (IdTarea)
	SELECT
		IdTarea
	FROM TA_Tarea
	WHERE IdOperacion = @IdOperacion;

	SET @CONT_TAREAS_TOTAL = (SELECT COUNT(IdRow) FROM #TAREAS_CREADAS);

	--SE NOTIFICA EN MOBIL A TODOS LOS APROBADORES
	WHILE @CONT_TAREAS_TOTAL >= @CONT_TAREAS
	BEGIN
		SET @ID_TAREA = (SELECT IdTarea FROM #TAREAS_CREADAS WHERE IdRow = @CONT_TAREAS);
		EXEC dbo.Mobile_NotificacionPetrovendor @IdtareaIdentity = @ID_TAREA;
		SET @CONT_TAREAS = @CONT_TAREAS + 1;
	END

	SET @ID_TIPOFLUJO = (SELECT IdTipoFlujo FROM TA_FlujoTarea WHERE IdFlujoTarea = @IdFlujoTarea);

	SELECT
		'Requisición',
		@IdSolicitudPedido,
		T.IdAprobador,
		@IdFlujoTarea,
		T.NoSecuencia,
		T.IdOperacion,
		T.IdTarea,
		US.IdUsuario,
		US.Nombre,
		US.Correo,
		@Descripcion,
		@ID_TIPOFLUJO
	FROM TA_Tarea AS T
		JOIN S_Usuario AS US
			ON T.IdAprobador = US.IdUsuario
			AND US.Activo = 1
	WHERE IdOperacion = @IdOperacion;

	END

END