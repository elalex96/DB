USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ActualizarEstatusTarea'
)
    DROP PROCEDURE SP_TA_ActualizarEstatusTarea;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Daniel A Cruz  
-- Create date: 04-01-17  
-- Description:  Actualiza el Estatus de la Tarea y   
-- Regresa la información del flujo de Tarea junto con todos los aprobadores involucrados  
-- =============================================  
--**************************************************************  
-- Modified:      <Alexander Gomez>           
-- Updated date: <08/03/2018>           
-- Description: <Se modifico la variable de las palabras del estatus>  
--**************************************************************  
--**************************************************************  
-- Modified:    Daniel AC     
-- Updated date: 04/11/2019       
-- Description: Se agrego sp para cambiar estatus DEA de las aprobaciones de Requisición
--**************************************************************  
--**************************************************************  
-- Modified:    Daniel AC     
-- Updated date: 21/11/2019       
-- Description: Se agrego validación para agregar asignación de compradores en la requisición por centro de costo
--************************************************************** 
--**************************************************************  
-- Modified:    Alexander Gomez   
-- Updated date: 14/08/2020
-- Description: Se agrego la validacion para verificar el sig aprobador
--************************************************************** 
-- Modified:    LUIS DAVID
-- Updated date: 22/02/2022
-- Description: Se agrega el idusuarioAdinco para notificaciones push
--************************************************************** 
-- Modified:		Alexander Gomez
-- Create date: 16-08-2023
-- Description:	se agrega la actualizacion del campo updateByApp para localizacion de actualizaciones desde la app
--**************************************************************
CREATE PROCEDURE [dbo].[SP_TA_ActualizarEstatusTarea]
-- Add the parameters for the stored procedure here  
@IdOperacion INT,
@IdEstatus INT,
@IdUsuario INT,
@Comentario NVARCHAR(MAX),
@IdFirma NVARCHAR(MAX),
@IdContrato INT = NULL,
@FechaRegistro DATETIME = NULL,
@updateByApp BIT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;

    DECLARE @IdTarea INT;
    --DECLARE @IdFlujoTarea INT;
    DECLARE @IdOperacionR INT;
    DECLARE @DescripcionH NVARCHAR(MAX)
    DECLARE @Mensaje NVARCHAR(MAX)
    DECLARE @IdEstatusOperacionAntesUpdate INT,
            @IdEstatusOperacionDespuesUpdate INT,
            @IdTipoOperacionAux INT
    SET @IdOperacionR = @IdOperacion;

	--SE OBTIENE EL FLUJO DE LA OPERACION
	DECLARE @IDFLUJOTAREA INT = (SELECT IdFlujoTarea 
								FROM dbo.TA_Operacion (NOLOCK)
								WHERE IdOperacion = @IdOperacion);
	--SE OBTIENE EL TIPO DE FLUJO(SERIAL O PARALELO)
	DECLARE @IDTIPOFLUJO INT = (SELECT IdTipoFlujo 
								FROM dbo.TA_FlujoTarea (NOLOCK)
								WHERE IdFlujoTarea = @IDFLUJOTAREA);
	DECLARE @IDSIGAPROBADOR INT;
	
	--SE VALIDA EL TIPO DE FLUJO
	IF @IDTIPOFLUJO = 1 -- SERIAL
	BEGIN
		--SE OBTIENE EL SIG APROBADOR EN EL FLUJO
		SET @IDSIGAPROBADOR = (SELECT TOP 1 IdAprobador 
								FROM dbo.TA_Tarea (NOLOCK)
								WHERE IdEstatus = 1 
									AND IdOperacion = @IdOperacion 
								ORDER BY NoSecuencia ASC);

	END
	ELSE
	BEGIN--PARALELO
	    --SE SETEA AL APROBADOR QUE REQUIERE APROBAR
		SET @IDSIGAPROBADOR = (@IdUsuario);
	END


    SET @IdTarea =
    (   SELECT T.IdTarea
        FROM TA_Tarea AS T
            INNER JOIN TA_TareaOperacion AS TA (NOLOCK)
                ON T.IdTarea = TA.IdTarea
        WHERE IdAprobador = @IdUsuario
              AND TA.IdOperacion = @IdOperacion)

    SELECT @IdEstatusOperacionAntesUpdate = IdEstatusOperacion,
           @IdTipoOperacionAux = IdTipoOperacion
    FROM dbo.TA_Operacion (NOLOCK)
    WHERE IdOperacion = @IdOperacion

	--SE VALIDA QUE EL SIGUIENTE APROBADOR SE LE MISMO AL QUE DESEA APROBAR
	IF @IdUsuario = @IDSIGAPROBADOR
	BEGIN
    ---Validar que la Tarea Tenga un Estatus Pendiente para poder actualizar   
    IF (SELECT IdEstatus FROM TA_Tarea (NOLOCK) WHERE IdTarea = @IdTarea) = 1
    BEGIN

 -- Actualizar Estatus de Tarea ---  
        UPDATE TA_Tarea
        SET IdEstatus = @IdEstatus,
            FechaCambioEstatus = GETDATE(),
            TA_Tarea.Comentario = @Comentario,
           IdFirma = @IdFirma,
		   updateByApp = @updateByApp
        WHERE IdTarea = @IdTarea



        ----Agregar Evento al Historial  ---  
        DECLARE @ESTATUSTA NVARCHAR(MAX)
            =   (SELECT Nombre FROM TA_Estatus (NOLOCK) WHERE IdEstatus = @IdEstatus)

        IF @ESTATUSTA = 'Aprobada'
        BEGIN
            SET @ESTATUSTA = N'Aprobado'
        END

        IF @ESTATUSTA = 'Rechazada'
        BEGIN
            SET @ESTATUSTA = N'Rechazado'
        END

        SET @DescripcionH
            = N'El Usuario ' + (SELECT Nombre FROM S_Usuario (NOLOCK) WHERE IdUsuario = @IdUsuario)
              + N' ha ' + @ESTATUSTA + N' la Tarea'

        INSERT INTO TA_HistorialFlujoTarea (IdOperacion, Fecha, Descripcion, IdEstadoFlujo)
        VALUES
        (@IdOperacion, GETDATE(), @DescripcionH, 2)


        --- Ejecutar el Cambio de Estatus General de la Operacion  -----  

        EXEC SP_TA_CambiarEstatusFlujo @IdOperacionR


        --- Obtener la información del flujo ---   

        SELECT DISTINCT
               TOO.IdOperacion,
               FT.IdFlujoTarea,
               FT.IdTipoFlujo,
               TOO.IdEstatusOperacion,
               TAE.Nombre,
               TOO.IdEstadoFlujo,
               TOO.IdTipoOperacion,
               TTO.NombreOperacion,
               U.IdUsuario,
               T.NoSecuencia,
               U.Nombre,
               U.Correo,
               T.IdEstatus,
               TOO.IdDocumento,
               TOO.IdAsignador,
               TOO.IdProveedor,
               ISNULL(T.Comentario, '') AS Comentario,
               TAE.Name,
			   U.IdUsuarioADINCO,
			   UA.IdUsuarioADINCO as 'AsignadorId'
        FROM TA_Tarea AS T (NOLOCK) 
            LEFT JOIN TA_Operacion AS TOO (NOLOCK)
                ON T.IdOperacion = TOO.IdOperacion
            LEFT JOIN TA_FlujoTarea AS FT (NOLOCK)
                ON TOO.IdFlujoTarea = FT.IdFlujoTarea
            LEFT JOIN S_Usuario AS U (NOLOCK)
                ON T.IdAprobador = U.IdUsuario
            LEFT JOIN TA_TipoOperacion AS TTO (NOLOCK)
                ON TOO.IdTipoOperacion = TTO.IdTipoOperacion
            LEFT JOIN TA_Estatus AS TAE (NOLOCK)
                ON TOO.IdEstatusOperacion = TAE.IdEstatus
			LEFT JOIN S_Usuario UA (NOLOCK)
				ON UA.IdUsuario = TOO.IdAsignador 
        WHERE TOO.IdOperacion = @IdOperacion
        ORDER BY NoSecuencia ASC


    END
    ELSE
    BEGIN
        SET @Mensaje = N'ERROR DOBLE APROBACION'
        SELECT @Mensaje AS MENSAJE
    END

    -- ASIGNAR COMPRADORES A LA SOL OFERTA POR CENTRO DE COSTO 
    -- APLICA PARA TODAS LAS EMPRESAS 
    --BEGIN

        DECLARE @IdTipoOperacion_SO INT
        DECLARE @IdSolicutPedido_SO INT
        DECLARE @EstatusOperacion INT

        --OBTENER DATOS 
        SELECT @IdSolicutPedido_SO = IdDocumento,
               @IdTipoOperacion_SO = IdTipoOperacion,
               @EstatusOperacion = IdEstatusOperacion
        FROM dbo.TA_Operacion
        WHERE IdOperacion = @IdOperacion

        --VALIDAR 
        IF ISNULL(@EstatusOperacion, 0) = 2 --> OPERACION APROBADA
           AND ISNULL(@IdTipoOperacion_SO, 0) = 2 --> OPERACIÓN DE TIPO SOL PED
        BEGIN
            CREATE TABLE #CentrosCostos (Id INT IDENTITY(1, 1), IdCentroCosto INT, IdProveedor INT)

            INSERT INTO #CentrosCostos (IdCentroCosto, IdProveedor)
            SELECT SPDL.IdCentroCosto,
                   SP.IdProveedor
            FROM dbo.MM_SolicitudPedido SP (NOLOCK)
                INNER JOIN dbo.MM_SolicitudPedidoDetalle SPD (NOLOCK)
                    ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
                INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL (NOLOCK)
                    ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle
            WHERE SP.IdSolicitudPedido = @IdSolicutPedido_SO
            GROUP BY SPDL.IdCentroCosto,
                     SP.IdProveedor

            INSERT INTO dbo.MM_SolicitudPedidoComprador
            (
                IdSolicitudPedido,
                IdAsignadoA,
                IdAsignadorPor,
                CreadoPor,
                CreadoEl,
                Activo
            )
            SELECT @IdSolicutPedido_SO,
                   CG.IdUsuario,
                   NULL,
                   @IdUsuario,
                   GETDATE(),
                   1
            FROM dbo.CC_CentroCostoGrupoCompras CG (NOLOCK)
                INNER JOIN #CentrosCostos CC (NOLOCK)
                    ON CG.IdCentroCosto = CC.IdCentroCosto
                INNER JOIN dbo.S_Usuario U (NOLOCK)
                    ON CG.IdUsuario = U.IdUsuario
            WHERE CG.Activo = 1 --> RELACIÓN ACTIVA 
                  AND U.Activo = 1 --> USUARIO ACTIVO
            GROUP BY CG.IdUsuario

        END
    --END
    --Actualizar en versión móvil  

    IF EXISTS (SELECT 1 FROM Adinco.dbo.AM_Aprobacion (NOLOCK) WHERE IdTareaOrigen = @IdTarea)
    BEGIN
        --1 Pendiente  
        --2 Aprobada  
        --3 Rechazada  
        IF @IdEstatus = 1
        BEGIN
            UPDATE Adinco.dbo.AM_Aprobacion
            SET IdStatusAprobacionM = @IdEstatus,
                FechaModificacion = NULL
            WHERE IdTareaOrigen = @IdTarea
        END
        IF @IdEstatus <> 1
        BEGIN
            UPDATE Adinco.dbo.AM_Aprobacion
            SET IdStatusAprobacionM = @IdEstatus,
                FechaModificacion = GETDATE(),
                ComentarioAprobacionRechazo = @Comentario
            WHERE IdTareaOrigen = @IdTarea
        END

        IF ISNULL(@Mensaje, '') != 'ERROR DOBLE APROBACION'
        BEGIN
            ---> SI EXISTE ESTA TAREA EN ADINCO APP VALIDAR CAMBIO DE ESTATUS DE LA OPERACIÓN, 
            --VALIDAR PROVEEDOR DEA, 
            --VALIDAR OPERACIÓN DE TIPO REQUISICIÓN Y QUE LA TAREA ACTUAL FUE REALIZADA EN LA APP

            EXEC dbo.Mobile_CambioEstatusAprobacionDEA @IdOperacion = @IdOperacion, -- int
                                                       @IdAprobador = @IdUsuario,   -- int
                                                       @IdTarea = @IdTarea          -- int

        END

    END

    SELECT @IdEstatusOperacionDespuesUpdate = IdEstatusOperacion
    FROM dbo.TA_Operacion
    WHERE IdOperacion = @IdOperacion

    IF ((@IdEstatusOperacionAntesUpdate <> @IdEstatusOperacionDespuesUpdate)
        AND @IdEstatusOperacionDespuesUpdate IN ( 2, 3 )
        AND @IdTipoOperacionAux = 14)
    BEGIN
        --Se envia correos si es un cambio de estatus de compra directa
        DECLARE @Asunto NVARCHAR(MAX),
                @Html NVARCHAR(MAX),
                @De NVARCHAR(MAX),
                @CreadorCompra INT,
                @NombreCreadorCompraDirecta NVARCHAR(MAX),
                @Num_Factura NVARCHAR(MAX),
                @IdContratoAux INT,
                @AreaContractual NVARCHAR(MAX),
                @IdProveedor INT,
                @Justificacion NVARCHAR(MAX),
                @IdDocumento INT,
                @Estatus NVARCHAR(MAX),
                @NumCompraDirecta INT,
                @Url NVARCHAR(MAX),
                @Para NVARCHAR(MAX),
				@Primero NVARCHAR(MAX),
				@Segundo NVARCHAR(MAX),
				@EstatusEnglish NVARCHAR(MAX),
				@TipoUsuario NVARCHAR(100)
		
		SELECT @Primero = dbo.Fn_generarValorQueryStringIncognito(), @Segundo = dbo.Fn_generarValorQueryStringIncognito()


        SELECT @CreadorCompra = tao.IdAsignador,
               @Num_Factura = tao.IdDocumento,
               @IdProveedor = tao.IdProveedor,
               @Estatus = t.Nombre,
			   @EstatusEnglish = t.Name,
               @IdDocumento = tao.IdDocumento
        FROM dbo.TA_Operacion tao (NOLOCK)
            INNER JOIN dbo.TA_Estatus t (NOLOCK)
                ON tao.IdEstatusOperacion = t.IdEstatus
        WHERE tao.IdOperacion = @IdOperacion
             AND tao.IdTipoOperacion = 14

        SELECT @IdContratoAux = f.IdContrato,
               @Justificacion = r.Comentarios
        FROM dbo.FI_Factura f (NOLOCK)
            INNER JOIN dbo.CO_Registro r (NOLOCK)
        ON f.IdFactura = r.IdFactura
        WHERE f.IdFactura = @Num_Factura

        SELECT @AreaContractual = a.NombreAreaContractual
        FROM Adinco.dbo.CO_Contrato c (NOLOCK)
            INNER JOIN Adinco.dbo.CO_AreaContractual a (NOLOCK)
                ON c.IdAreaContractual = a.IdAreaContractual
        WHERE c.IdContrato = @IdContratoAux

        SELECT @NumCompraDirecta = ps.IdPedido
        FROM dbo.MM_Pedidos ps (NOLOCK)
        WHERE ps.IdProveedorCliente = @IdProveedor
              AND ps.IdTipoPedido = 1
              AND ps.IdIdentificador = @Num_Factura

        SELECT @Asunto = C.Asunto,
               @Html = C.HTML,
               @De = S.CuentaRegistro
        FROM dbo.TA_Correo AS C (NOLOCK)
            INNER JOIN dbo.TA_CorreoServidor AS S (NOLOCK)
                ON C.IdServidor = S.IdServidor
        WHERE C.IdCorreo = 2

        SELECT @NombreCreadorCompraDirecta = Nombre,
               @Para = Correo,
			   @TipoUsuario = LTRIM(IdTipoUsuario)
        FROM dbo.S_Usuario (NOLOCK)
        WHERE IdUsuario = @CreadorCompra

        SELECT @Url = Url
        FROM dbo.TA_Dominios (NOLOCK)
        WHERE IdDominio = 2

        SELECT @Url += CONCAT(
                       '02Proveedores/DetalleCompraDirecta.aspx?num_operacion=',
                       @Primero,
                       @IdOperacion,
                       @Primero,
                       '&compra=',
                       @Segundo,
                       @IdDocumento,
                       @Primero,
                       '&creado=',
                       @Primero,
                       @CreadorCompra,
                       @Segundo,
					   '&origin=t&tp_user=',
					   @Segundo,
					   @TipoUsuario,
					   @Segundo)
        SELECT @Asunto = REPLACE(@Asunto, '##TIPO_OPERACION##', 'Compra Directa ')
        SELECT @Asunto = REPLACE(@Asunto, '##NO##', @NumCompraDirecta)
        SELECT @Html = REPLACE(@Html, '##NOMBRE_USUARIO##', @NombreCreadorCompraDirecta)
        SELECT @Html = REPLACE(@Html, '##TIPO_OPERACION##', 'Compra Directa ')
        SELECT @Html = REPLACE(@Html, '##NUMERO_OPERACION##', @NumCompraDirecta)
        SELECT @Html = REPLACE(@Html, '##AREA_CONTRACTUAL##', @AreaContractual)
        SELECT @Html = REPLACE(@Html, '##JUSTIFICACION##', @Justificacion)
        SELECT @Html = REPLACE(@Html, '##ESTATUS##', @Estatus)
		SELECT @Html = REPLACE(@Html, '##STATUS##', @EstatusEnglish)
        SELECT @Html = REPLACE(@Html, '##ANIO_ACTUAL##', YEAR(GETDATE()))
        SELECT @Html = REPLACE(@Html, '##URL_TAREA##', @Url)

        DECLARE @Max INT

        SELECT @Max = MAX(IdNotificacion) + 1
        FROM Adinco.dbo.S_Notificacion

        INSERT INTO Adinco.dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            CreadoPor,
            CreadoEl,
            De
        )
        VALUES
        (   @Max,      -- IdNotificacion - bigint
            @Para,     -- Para - varchar(1000)
            @Asunto,   -- Asunto - varchar(250)
            @Html,     -- Mensaje - text
            GETDATE(), -- FechaProgramadaEnvio - datetime
            0,         -- Enviada - bit
            3,         -- CreadoPor - int
            GETDATE(), -- CreadoEl - datetime
            @De        -- De - varchar(100)
        )

        INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)
        SELECT @Max,
               2,
               'Fin de Aprobación de Compra Directa ' + LTRIM(@NumCompraDirecta),
               @IdUsuario,
               GETDATE()
    END
	END
	ELSE
    BEGIN
        SET @Mensaje = N'ERROR DOBLE APROBACION'
SELECT @Mensaje AS MENSAJE
    END

END