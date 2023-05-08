-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 13-11-2019
-- Description:	 Se agrega validación DEA para aprobaciones desde la APP
--**************************************************************
-- Modified:      <Alexander Gomez>									
-- Updated date: <24/04/2018>									
-- Description: <Se agrega el guardado de firma electronica>
--**************************************************************

CREATE PROCEDURE [dbo].[SP_TA_ActualizarEstatusPedidoAprobacion] 
-- Add the parameters for the stored procedure here
----execute  SP_TA_ActualizarEstatusPedidoAprobacion 2,12417, 2221, '',2
@IdEstatus        INT, 
@IdSoliciudPedido INT, 
@IdAprobador      INT, 
@Comentario       NVARCHAR(MAX), 
@Version          INT, 
@IdFirma          VARCHAR(50)
---@Comentario NVARCHAR(MAX)

AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @IdTarea INT;
        DECLARE @IdFlujoTarea INT;
        DECLARE @IdOperacion INT;
        DECLARE @DescripcionH NVARCHAR(MAX);
        DECLARE @IdAprobacionMobile INT;
        DECLARE @Mensaje NVARCHAR(MAX);
        SET @IdOperacion =
        (
            SELECT TOP 1 O.IdOperacion
            FROM TA_Operacion AS O
                 INNER JOIN MM_Pedido AS P ON P.IdSolicitudPedido = O.IdDocumento
                 INNER JOIN TA_Tarea AS TA ON TA.IdOperacion = O.IdOperacion
            WHERE TA.IdAprobador = @IdAprobador
                  AND P.IdSolicitudPedido = @IdSoliciudPedido
                  AND P.Version = O.NoVersion
                  AND P.Version = @Version
                  AND O.IdTipoOperacion = 9
            GROUP BY O.IdOperacion
        );
        SET @IdTarea =
        (
            SELECT T.IdTarea
            FROM TA_Tarea AS T
            WHERE T.IdAprobador = @IdAprobador
                  AND T.IdOperacion = @IdOperacion
                  AND T.Activo = 1
        );

        ---Validar que la Tarea Tenga un Estatus Pendiente para poder actualizar 

        IF
        (
            SELECT IdEstatus
            FROM TA_Tarea
            WHERE IdTarea = @IdTarea
        ) = 1
            BEGIN 
                -- Actualizar Estatus de Tarea ---

                UPDATE TA_Tarea
                  SET 
                      IdEstatus = @IdEstatus, 
                      FechaCambioEstatus = GETDATE(), 
                      Comentario = @Comentario, 
                      IdFirma = @IdFirma
                WHERE IdTarea = @IdTarea;
                IF @IdEstatus = 3 ---AGREGAR COMENTARIO DE CANCELACIÓN DE PEDIDO
                    BEGIN
                        INSERT INTO [dbo].[TA_ComentariosTareaCancelada]
                        ([Descripcion], 
                         [IdOperacion], 
                         [IdUsuario]
                        )
                        VALUES
                        (@Comentario, 
                         @IdOperacion, 
                         @IdAprobador
                        );
                END;

                ----Agregar Evento al Historial  ---
                DECLARE @ESTATUSTA NVARCHAR(MAX)=
                (
                    SELECT Nombre
                    FROM TA_Estatus
                    WHERE IdEstatus = @IdEstatus
                );
                IF @ESTATUSTA = 'Aprobada'
                    BEGIN
                        SET @ESTATUSTA = 'Aprobado';
                END;
                IF @ESTATUSTA = 'Rechazada'
                    BEGIN
                        SET @ESTATUSTA = 'Rechazado';
                END;
                SET @DescripcionH = 'El Usuario ' +
                (
                    SELECT Nombre
                    FROM S_Usuario
                    WHERE IdUsuario = @IdAprobador
                ) + ' ha ' + @ESTATUSTA + ' el pedido';
                INSERT INTO TA_HistorialFlujoTarea
                (IdOperacion, 
                 Fecha, 
                 Descripcion, 
                 IdEstadoFlujo
                )
                VALUES
                (@IdOperacion, 
                 GETDATE(), 
                 @DescripcionH, 
                 2
                );

                --- Ejecutar el Cambio de Estatus General de la Operacion  -----

                EXEC SP_TA_CambiarEstatusOperacionAprobacionPedido 
                     @IdOperacion, 
                     @Version;
                ------------------CAMBIO ESTATUS MOBILE
                SET @IdAprobacionMobile =
                (
                    SELECT TOP 1 TA.IdTarea
                    FROM dbo.TA_Tarea AS TA
                         JOIN dbo.TA_Operacion AS TAO ON TAO.IdOperacion = TA.IdOperacion
                         INNER JOIN MM_Pedido AS P ON P.IdSolicitudPedido = TAO.IdDocumento
                    WHERE TAO.IdTipoOperacion = 9
                          AND P.IdSolicitudPedido = @IdSoliciudPedido
                );
                IF EXISTS
                (
                    SELECT 1
                    FROM Adinco.dbo.AM_Aprobacion
                    WHERE IdTareaOrigen = @IdTarea
                )
                    BEGIN
                        --1 Pendiente
                        --2 Aprobada
                        --3 Rechazada
                        IF @IdEstatus = 1
                            BEGIN
                                UPDATE Adinco.dbo.AM_Aprobacion
                                  SET 
                                      IdStatusAprobacionM = @IdEstatus, 
                                      FechaModificacion = NULL, 
                                      ComentarioAprobacionRechazo = ''
                                WHERE IdTareaOrigen = @IdTarea;
                        END;
                        IF @IdEstatus <> 1
                            BEGIN
                                UPDATE Adinco.dbo.AM_Aprobacion
                                  SET 
                                      IdStatusAprobacionM = @IdEstatus, 
                                      FechaModificacion = GETDATE(), 
                                      ComentarioAprobacionRechazo = @Comentario
                                WHERE IdTareaOrigen = @IdTarea;
                        END;
                END;
                ------------------TERMINA CAMBIO ESTATUS MOBILE
                --- Obtener la información del flujo --- 

                SELECT O.IdOperacion, 
                       FT.IdTipoFlujo, 
                       O.IdEstatusOperacion, 
                       E.Nombre, 
                       O.IdAsignador, 
                       T.IdAprobador, 
                       U.Nombre, 
                       U.Correo, 
                       T.NoSecuencia, 
                       T.IdEstatus, 
                       E.Name
                FROM TA_Operacion AS O
                     INNER JOIN MM_Pedido AS P ON P.IdSolicitudPedido = O.IdDocumento
                     INNER JOIN TA_Tarea AS T ON T.IdOperacion = O.IdOperacion
                     INNER JOIN S_Usuario AS U ON U.IdUsuario = T.IdAprobador
                     INNER JOIN TA_FlujoTarea AS FT ON FT.IdFlujoTarea = O.IdFlujoTarea
                     INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                WHERE O.IdOperacion = @IdOperacion
                      AND P.Version = @Version
                GROUP BY O.IdOperacion, 
                         FT.IdTipoFlujo, 
                         O.IdEstatusOperacion, 
                         E.Nombre, 
                         O.IdAsignador, 
                         T.IdAprobador, 
                         U.Nombre, 
                         U.Correo, 
                         T.NoSecuencia, 
                         T.IdEstatus, 
                         E.Name
                ORDER BY T.NoSecuencia ASC;
        END;
            ELSE
            BEGIN
                SET @Mensaje = 'ERROR DOBLE APROBACION';
                SELECT @Mensaje AS MENSAJE;
        END;

        ---VALIDACIÓN DE APROBACIÓN DESDE LA APP PARA FLUJO DEA 
        IF EXISTS
        (
            SELECT 1
            FROM Adinco.dbo.AM_Aprobacion
            WHERE IdTareaOrigen = @IdTarea
        )
            BEGIN
                IF ISNULL(@Mensaje, '') != 'ERROR DOBLE APROBACION'
                    BEGIN 
                        ---> SI EXISTE ESTA TAREA EN ADINCO APP VALIDAR CAMBIO DE ESTATUS DE LA OPERACIÓN, 
                        --VALIDAR PROVEEDOR DEA, 
                        --VALIDAR OPERACIÓN DE TIPO REQUISICIÓN Y QUE LA TAREA ACTUAL FUE REALIZADA EN LA APP

                        EXEC dbo.Mobile_CambioEstatusAprobacionPedidoDEA 
                             @IdOperacion = @IdOperacion, -- int
                             @IdAprobador = @IdAprobador, -- int
                             @IdTarea = @IdTarea, -- int
                             @NoVersion = @Version;
                END;
        END;
    END;