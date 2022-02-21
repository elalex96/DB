USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Mobile_CambioEstatusAprobacion'
)
    DROP PROCEDURE Mobile_CambioEstatusAprobacion;
GO 
/****** Object:  StoredProcedure [dbo].[Mobile_CambioEstatusAprobacion]    Script Date: 15/02/2022 10:05:39 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Mobile_CambioEstatusAprobacion] @IdAprobacion INT, 
                                                       @Comentario   VARCHAR(250), 
                                                       @idStatus     INT, 
                                                       @ByMobileApp  INT          = 0
AS
     BEGIN
         DECLARE @correousuarioadinco VARCHAR(200), @IdUsuario INT, @FechaRegistro DATETIME, @IdContrato INT, @IdOperacion INT, @fecha DATETIME, @IdFirma NVARCHAR(MAX), @MensajeFinal VARCHAR(50), @EstatusPet INT, @Version INT, @EstatusPetrovendor INT, @IdTipoAprobacion INT, @SolicitudPedido INT
         ----------------
         , @Secuencia INT, @IdDocumento INT, @NoSecuenciaActual INT, @NoSecuenciaSiguiente INT, @SiguienteTarea INT, @UsuarioID INT;
         SET @fecha = GETDATE();

         --1 = Aprobada
         --2 = Rechazada
         --3 = El estatus ya fue modificada
         --4 = Error en la transacción
         IF @ByMobileApp = 1
             BEGIN
                 --                                            BEGIN TRY 
                 UPDATE dbo.AM_Aprobacion
                   SET 
                       ActualizadoByApp = 1
                 WHERE IdTareaOrigen = @IdAprobacion;
                 --END TRY  
                 --BEGIN CATCH  
                 --END CATCH  
             END;

         --se verifica si es aprobación de pedido o solicitud de pedido
         SET @IdTipoAprobacion =
         (
             SELECT TOP 1 IdTipoAprobacion
             FROM Adinco.dbo.AM_Aprobacion
             WHERE IdTareaOrigen = @IdAprobacion
             ORDER BY FechaCreacion DESC
         );

		 		--- HISTORIAL
		INSERT INTO Petrovendor..APP_BitacoraAprobacionesApp(IdTarea,IdTipoPedido,IdEstatus,Fecha,App)
	    VALUES (@IdAprobacion,@IdTipoAprobacion,@idStatus,GETDATE(),'V1')
         ----------------------------------------------------------------------------------------
         --------OPERACIONES GENERALES----------------
         SET @EstatusPet =
         (
             SELECT TOP 1 PTA.IdEstatus AS 'Estatus Petrovendor'
             FROM dbo.AM_Aprobacion AS MAP
                  JOIN Petrovendor.dbo.TA_Tarea AS PTA ON MAP.IdTareaOrigen = PTA.IdTarea
                  JOIN Petrovendor.dbo.TA_Operacion AS OP ON OP.IdOperacion = PTA.IdOperacion
             WHERE MAP.IdTareaOrigen = @IdAprobacion
                   AND PTA.IdTarea = @IdAprobacion
             ORDER BY MAP.FechaCreacion DESC
         );
         ----------------------------------------------------------------------------------------
         --------------SOLICITUD DE PEDIDO
         IF @IdTipoAprobacion = 2
             BEGIN
                 IF @EstatusPet = 1
                     BEGIN
                         --Se extrae la firma de la aprobación para mandarla al sp de petrovendor 
                         SELECT @IdFirma = idfirma, 
                                @IdOperacion = IdOperacion
                         FROM Petrovendor.dbo.TA_Tarea
                         WHERE IdTarea = @IdAprobacion;

                         --Extraer IdUsuarioAprobador

                         SELECT TOP 1 @IdContrato = IdContrato, 
                                      @UsuarioID = IdUsuario
                         FROM Adinco.dbo.AM_Aprobacion
                         WHERE IdTareaOrigen = @IdAprobacion
                         ORDER BY FechaCreacion DESC;

                         -- IDUSUARIO APROBADOR 
                         SET @IdUsuario =
                         (
                             SELECT TOP 1 IdUsuario
                             FROM Petrovendor.dbo.S_Usuario
                             WHERE IdUsuarioADINCO = @UsuarioID
                         );

                         --Begin PETROVENDOR 
                         IF EXISTS
                         (
                             SELECT 1
                             FROM Petrovendor.dbo.TA_Tarea
                             WHERE IdAprobador = @IdUsuario
                                   AND IdTarea = @IdAprobacion
                         )
                             BEGIN
                                 ----------------------------Comienza el bloque secuencia---------------
                                 ----------------------------------------------------------------------
                                 SET @Secuencia =
                                 (
                                     SELECT TOP 1 TipoFlujo
                                     FROM dbo.AM_Aprobacion
                                     WHERE IdTareaOrigen = @IdAprobacion
                                     ORDER BY FechaCreacion DESC
                                 ); --Secuencia = Tipo de Flujo

                                 IF @Secuencia = 1
                                     BEGIN
                                         --Se obtiene el Id del Documento y NoSecuencia
                                         SELECT TOP 1 @IdDocumento = IdDocumento, 
                                                      @NoSecuenciaActual = NoSecuencia
                                         FROM dbo.AM_Aprobacion
                                         WHERE IdTareaOrigen = @IdAprobacion
                                         ORDER BY FechaCreacion DESC;
                                         SET @NoSecuenciaSiguiente = (@NoSecuenciaActual + 1);
                                         IF EXISTS
                                         (
                                             SELECT IdTareaOrigen
                                             FROM dbo.AM_Aprobacion
                                             WHERE IdDocumento = @IdDocumento
                                                   AND NoSecuencia = @NoSecuenciaSiguiente
                                         )
                                            AND @idStatus = 2
                                             BEGIN
                                                 -- Siguiente tarea si existe 
                                                 SET @SiguienteTarea =
                                                 (
                                                     SELECT TOP 1 IdTareaOrigen
                                                     FROM dbo.AM_Aprobacion
                                                     WHERE IdDocumento = @IdDocumento
                                                           AND NoSecuencia = @NoSecuenciaSiguiente
                                                     ORDER BY FechaCreacion DESC
                                                 );

                                                 ----- Hacer visible siguiente aprobación
                                                 UPDATE dbo.AM_Aprobacion
                                                   SET 
                                                       EsVisible = 1
                                                 WHERE IdTareaOrigen = @SiguienteTarea;
                                                 ----- Enviar Push 
                                                 UPDATE AM_OneSignalNotificaciones
                                                   SET 
                                                       Enviar = 1
                                                 WHERE IdTareaOrigen = @SiguienteTarea;
                                             END;
                                         ----------------------------Ejecuta cambio de estatus ----------------
                                         ----------------------------------------------------------------------
                                         EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusTarea 
                                              @IdOperacion = @IdOperacion, -- int
                                              @IdEstatus = @idStatus, -- int
                                              @IdUsuario = @IdUsuario, -- int
                                              @Comentario = @Comentario, -- nvarchar(max)
                                              @IdFirma = @IdFirma, -- nvarchar(max)
                                              @IdContrato = @IdContrato, -- int
                                              @FechaRegistro = @fecha; -- datetime

                                         UPDATE dbo.AM_Aprobacion
                                           SET 
                                               IdStatusAprobacionM = @idStatus, 
                                               ComentarioAprobacionRechazo = @Comentario, 
                                               FechaModificacion = GETDATE()
                                         WHERE IdTareaOrigen = @IdAprobacion;
                                     END;
                                 IF @Secuencia = 2
                                     BEGIN
                                         EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusTarea 
                                              @IdOperacion = @IdOperacion, -- int
                                              @IdEstatus = @idStatus, -- int
                                              @IdUsuario = @IdUsuario, -- int
                                              @Comentario = @Comentario, -- nvarchar(max)
                                              @IdFirma = @IdFirma, -- nvarchar(max)
                                              @IdContrato = @IdContrato, -- int
                                              @FechaRegistro = @fecha; -- datetime

                                         UPDATE dbo.AM_Aprobacion
                                           SET 
                                               IdStatusAprobacionM = @idStatus, 
                                               ComentarioAprobacionRechazo = @Comentario, 
                                               FechaModificacion = GETDATE()
                                         WHERE IdTareaOrigen = @IdAprobacion;
                                     END;
                                 ----------------------------Termina el bloque secuencia---------------
                                 ----------------------------------------------------------------------
                                 IF @idStatus = 2
                                     BEGIN
                                         SET @MensajeFinal = 1;
                                         SELECT @MensajeFinal AS 'MENSAJE';
                                     END;
                                 IF @idStatus = 3
                                     BEGIN
                                         SET @MensajeFinal = 2;
                                         SELECT @MensajeFinal AS 'MENSAJE';
                                     END;
                             END;
                             ELSE
                             BEGIN
                                 SELECT '4';
                             END;
                                 --end PETROVENDOR
                     END;
                     ELSE
                     BEGIN
                         SET @MensajeFinal = 3;
                         SELECT @MensajeFinal AS 'MENSAJE';
                     END;
             END;

         --------------APROBACIÓN DE PEDIDO
         IF @IdTipoAprobacion = 9
             BEGIN
                 SET @EstatusPetrovendor =
                 (
                     SELECT TOP 1 TA.IdEstatus
                     FROM Petrovendor.dbo.TA_Tarea AS TA
                          JOIN Petrovendor.dbo.TA_Operacion AS TAO ON TAO.IdOperacion = TA.IdOperacion
                          INNER JOIN Petrovendor.dbo.MM_Pedido AS P ON TAO.IdDocumento = P.IdSolicitudPedido  AND TAO.NoVersion = P.Version
                     WHERE TAO.IdTipoOperacion = 9
                           AND TA.IdTarea = @IdAprobacion
                 );
                 IF @EstatusPetrovendor = 1
                     BEGIN
                         ------------------------
                         --Se extrae la solicitud de pedido y NoVersion

                         SELECT TOP 1 @SolicitudPedido = P.IdSolicitudPedido, 
                                      @Version = TAO.NoVersion, 
                                      @IdUsuario = TA.IdAprobador, 
                                      @IdFirma = TA.IdFirma
                         FROM Petrovendor.dbo.TA_Tarea AS TA
                              JOIN Petrovendor.dbo.TA_Operacion AS TAO ON TA.IdOperacion = TAO.IdOperacion 
                              INNER JOIN Petrovendor.dbo.MM_Pedido AS P ON TAO.IdDocumento = P.IdSolicitudPedido  AND TAO.NoVersion = P.Version
                         WHERE TAO.IdTipoOperacion = 9
                               AND TA.IdTarea = @IdAprobacion;

                         --------------------------------------------------------------
                         -------------------TIPO DE FLUJO------------------------------
                         --------------------------------------------------------------
                         SET @Secuencia =
                         (
                             SELECT TOP 1 TipoFlujo
                             FROM dbo.AM_Aprobacion
                             WHERE IdTareaOrigen = @IdAprobacion
                         ); --Secuencia = Tipo de Flujo

                         IF @Secuencia = 1
                             BEGIN
                                 --Se obtiene el Id del Documento
                                 -- Se obtiene numero de secuencia
                                 SELECT TOP 1 @IdDocumento = IdDocumento, 
                                              @NoSecuenciaActual = NoSecuencia, 
                                              @Version = NoVersion
                                 FROM dbo.AM_Aprobacion
                                 WHERE IdTareaOrigen = @IdAprobacion
                                 ORDER BY FechaCreacion DESC;
                                 SET @NoSecuenciaSiguiente = (@NoSecuenciaActual + 1);

                                 IF EXISTS
                                 (
                                     SELECT IdTareaOrigen
                                     FROM dbo.AM_Aprobacion
                                     WHERE IdDocumento = @IdDocumento
                                           AND NoSecuencia = @NoSecuenciaSiguiente
                                           AND NoVersion = @Version
                                 )
                                    AND @idStatus = 2
                                     BEGIN
                                         -- Siguiente tarea si existe 
                                         SET @SiguienteTarea =
                                         (
                                             SELECT TOP 1 IdTareaOrigen
                                             FROM dbo.AM_Aprobacion
                                             WHERE IdDocumento = @IdDocumento
                                                   AND NoSecuencia = @NoSecuenciaSiguiente
                                                   AND NoVersion = @Version
                                             ORDER BY FechaCreacion DESC
                                         );

                                         ----- Hacer visible siguiente aprobación
                                         UPDATE dbo.AM_Aprobacion
                                           SET 
                                               EsVisible = 1
                                         WHERE IdTareaOrigen = @SiguienteTarea;
                                         ----- Enviar Push 
                                         UPDATE AM_OneSignalNotificaciones
                                           SET 
                                               Enviar = 1
                                         WHERE IdTareaOrigen = @SiguienteTarea;
                                     END;

                                 ----------------------------Ejecuta cambio de estatus ----------------
                                 ----------------------------------------------------------------------
                                 EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusPedidoAprobacion 
                                      @IdEstatus = @idStatus, 
                                      @IdSoliciudPedido = @SolicitudPedido, 
                                      @IdAprobador = @IdUsuario, 
                                      @Comentario = @Comentario, 
                                      @Version = @Version, 
                                      @IdFirma = @IdFirma;


                                 UPDATE dbo.AM_Aprobacion
                                   SET 
                                       IdStatusAprobacionM = @idStatus, 
                                       ComentarioAprobacionRechazo = @Comentario, 
                                       FechaModificacion = GETDATE()
                                 WHERE IdTareaOrigen = @IdAprobacion;

                             END;
                         IF @Secuencia = 2
                             BEGIN
                                 EXEC Petrovendor.dbo.SP_TA_ActualizarEstatusPedidoAprobacion 
                                      @IdEstatus = @idStatus, 
                                      @IdSoliciudPedido = @SolicitudPedido, 
                                      @IdAprobador = @IdUsuario, 
                                      @Comentario = @Comentario, 
                                      @Version = @Version, 
                                      @IdFirma = @IdFirma;

                                 UPDATE dbo.AM_Aprobacion
                                   SET 
                                       IdStatusAprobacionM = @idStatus, 
                                       ComentarioAprobacionRechazo = @Comentario, 
                                       FechaModificacion = GETDATE()
                                 WHERE IdTareaOrigen = @IdAprobacion;
                             END;

						 
						 /*Se valida y envia CORREO de notificacion de aprobacion  de pedido al siguiente aprobador, si es Flujo de aprobación SERIAL*/
						 EXEC Petrovendor..Mobile_EnviarNotificacionAprobacionPedido  @IdTareaActual= @IdAprobacion,@Origen='Mobile_CambioEstatusAprobacion'   	

                         --IF @ByMobileApp = 1
                         --BEGIN
                         --            UPDATE dbo.AM_Aprobacion
                         --            SET ActualizadoByApp = 1 
                         --            WHERE IdTareaOrigen = @IdAprobacion
                         --         END
                         --------------------------------------------------------------
                         -------------------Termina el flujo---------------------------
                         --------------------------------------------------------------
                         IF @idStatus = 2
                             BEGIN
                                 SET @MensajeFinal = 1;
                                 SELECT @MensajeFinal AS 'MENSAJE';
                             END;
                         IF @idStatus = 3
                             BEGIN
                                 SET @MensajeFinal = 2;
                                 SELECT @MensajeFinal AS 'MENSAJE';
                             END;
                     END;
                     ELSE
                     BEGIN
                         SELECT '3' AS 'Mensaje';
                     END;

                         --Termina el "IF" de aprobación de pedido
             END;
     END;