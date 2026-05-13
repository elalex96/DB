
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018097
-- Description:	Aprueba o rechaza un calculo
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_ApruebaRechazaCalculo] --10010,'20181101',10090,1,'',2
    @idContrato    INT,
    @MesReporte    DATE,
    @idUsuario     INT,
    @Aprobado      INT,
    @Comentario    NVARCHAR(MAX),
    @TipoAprobador INT, --1= Representante PEP, 2= SCOC, 9=liquidos, 10=gas,
    @IdPermiso     INT
AS
    BEGIN
        DECLARE
            @error                  NVARCHAR(MAX) = '',
            @IsPC                   INT,
            @CountComercializadores INT,
            @DatetimeAprobPEP       DATETIME,
            @bitGas                 BIT,
            @bitPetroleo            BIT,
            @HidrocarburosContrato  INT;

        SELECT
                @IsPC = CASE CO_Contrato.IdTipoContrato
                            WHEN 2
                                THEN CO_Contrato.IdTipoContrato
                            WHEN 3
                                THEN CASE IsConsorcio
                                         WHEN 0
                                             THEN IsConsorcio
                                         ELSE
                                             3
                                     END
                        END
        FROM
                dbo.CO_Contrato
            JOIN
                dbo.CO_TipoContrato
                    ON CO_TipoContrato.IdTipoContrato = CO_Contrato.IdTipoContrato
        WHERE
                IdContrato = @idContrato;

        SET NOCOUNT ON;
        IF (@TipoAprobador = 1) --PEP
            BEGIN
                IF @IsPC <> 2 --LICENCIA o NO CONSORCIO
                    BEGIN
                        UPDATE
                            SCOC_EnvioNotificacion
                        SET
                            AprobadoRepPEP = @Aprobado,
                            FechaAprobacionRepPEP = GETDATE(),
                            IdUsuarioAprobadoRepPEP = @idUsuario,
                            Comentarios = @Comentario,
                            EnviadoContratista = @Aprobado
                        WHERE
                            idContrato = @idContrato
                            AND MesReporte = @MesReporte;

                        IF (@Aprobado = 0)
                            BEGIN
                                UPDATE
                                    SCOC_EnvioNotificacion
                                SET
                                    idEstatus = 10000 -- en licencia se finaliza y se avisa a contratista y a SCOC
                                WHERE
                                    idContrato = @idContrato
                                    AND MesReporte = @MesReporte;
                                EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                    @idContrato,
                                    @MesReporte,
                                    @IdPermiso,
                                    @idUsuario,
                                    @Comentario,
                                    1;
                                EXECUTE sp_SCOC_EnviaCorreos
                                    @idContrato,
                                    @MesReporte,
                                    @idUsuario,
                                    '',
                                    5,
                                    @Comentario;
                            END;
                        ELSE IF (@Aprobado = 1)
                                 BEGIN
                                     UPDATE
                                         SCOC_EnvioNotificacion
                                     SET
                                         idEstatus = 10005 -- en licencia se finaliza y se avisa a contratista y a SCOC
                                     WHERE
                                         idContrato = @idContrato
                                         AND MesReporte = @MesReporte;
                                     EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                         @idContrato,
                                         @MesReporte,
                                         @IdPermiso,
                                         @idUsuario,
                                         'Completamente aprobado por el usuario PEP, Sera visualizado por el usuario SCOC',
                                         0;
                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato,
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         12,
                                         '';

                                     EXEC SP_SCOC_RegistraVolumenesTotales
                                         @idContrato, -- SE EJEUTA PROCEDIMIENTO QUE TRASPASA LOS VOLUMENES A LAS TABLAS PARA LA GENRACION DE COMERCIALIZACIONES
                                         @MesReporte,
                                         @idUsuario,
                                         1;
                                 END;
                    END;

                ELSE IF @IsPC = 2
                         BEGIN
                             UPDATE
                                 SCOC_EnvioNotificacion
                             SET
                                 AprobadoRepPEP = @Aprobado,
                                 FechaAprobacionRepPEP = GETDATE(),
                                 IdUsuarioAprobadoRepPEP = @idUsuario,
                                 Comentarios = @Comentario,
                                 EnviadoContratista = @Aprobado
                             WHERE
                                 idContrato = @idContrato
                                 AND MesReporte = @MesReporte;

                             IF (@Aprobado = 0)
                                 BEGIN
                                     UPDATE
                                         SCOC_EnvioNotificacion
                                     SET
                                         idEstatus = 10000
                                     WHERE
                                         idContrato = @idContrato
                                         AND MesReporte = @MesReporte;
                                     EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                         @idContrato,
                                         @MesReporte,
                                         @IdPermiso,
                                         @idUsuario,
                                         @Comentario,
                                         1;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato,
                                         @MesReporte,
                                         @idUsuario,
                                         '',
                                         5,
                                         @Comentario;
                                 END;
                             ELSE IF (@Aprobado = 1)
                                      BEGIN
                                          UPDATE
                                              SCOC_EnvioNotificacion
                                          SET
                                              idEstatus = 10006
                                          WHERE
                                              idContrato = @idContrato
                                              AND MesReporte = @MesReporte;

                                          EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                              @idContrato,
                                              @MesReporte,
                                              @IdPermiso,
                                              @idUsuario,
                                              'Completamente aprobado por el usuario PEP, Se envia notificación a usuarios comercializadores del estado',
                                              0;
                                          EXECUTE sp_SCOC_EnviaCorreos
                                              @idContrato,
                                              @MesReporte,
                                              @idUsuario,
                                              @Comentario,
                                              8,
                                              @Comentario;
                                      END;
                         END;


            END;
        IF (@TipoAprobador = 2) --SCOC Pemex
            BEGIN
                UPDATE
                    SCOC_EnvioNotificacion
                SET
                    AprobadoSCOC = @Aprobado,
                    FechaAprobacion = GETDATE(),
                    IdUsuarioAprobadoSCOC = @idUsuario,
                    AprobadoRepPEP = @Aprobado,
                   -- FechaAprobacionRepPEP = GETDATE(),
                   -- IdUsuarioAprobadoRepPEP = @idUsuario,
                    Comentarios = @Comentario,
                    EnviadoContratista = @Aprobado
                WHERE
                    idContrato = @idContrato
                    AND MesReporte = @MesReporte;

                IF (@Aprobado = 0)
                    BEGIN
                        UPDATE
                            SCOC_EnvioNotificacion
                        SET
                            idEstatus = 10000
                        WHERE
                            idContrato = @idContrato
                            AND MesReporte = @MesReporte;
                        EXECUTE sp_SCOC_EnviaCorreos
                            @idContrato,
                            @MesReporte,
                            @idUsuario,
                            '',
                            3,
                            @Comentario;
                        EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                            @idContrato,
                            @MesReporte,
                            @IdPermiso,
                            @idUsuario,
                            @Comentario,
                            1;
                    END;
                ELSE IF (@Aprobado = 1)
                         BEGIN
                             UPDATE
                                 SCOC_EnvioNotificacion
                             SET
                                 idEstatus = 10005
                             WHERE
                                 idContrato = @idContrato
                                 AND MesReporte = @MesReporte;

                             -- SE EJEUTA PROCEDIMIENTO QUE TRASPASA LOS VOLUMENES A LAS TABLAS PARA LA GENRACION DE COMERCIALIZACIONES
                             EXEC SP_SCOC_RegistraVolumenesTotales
                                 @idContrato,
                                 @MesReporte,
                                 @idUsuario,
                                 1;

                             EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                 @idContrato,
                                 @MesReporte,
                                 @IdPermiso,
                                 @idUsuario,
                                 'Completamente aprobado por el usuario SCOC, Se envia notificación a todos los usuarios',
                                 0;
                             EXECUTE sp_SCOC_EnviaCorreos
                                 @idContrato,
                                 @MesReporte,
                                 @idUsuario,
                                 '',
                                 2,
                                 @Comentario;
                         END;
            END;
        ---------------------------------------------------------------------------
        IF (@TipoAprobador = 9) --Comercializador Edo Liquidos)
            BEGIN
                UPDATE
                    SCOC_EnvioNotificacion
                SET
                    AprobadoRepPEP = @Aprobado,
                  --  FechaAprobacionRepPEP = GETDATE(),
                   -- IdUsuarioAprobadoRepPEP = @idUsuario,
                    Comentarios = @Comentario,
                    EnviadoContratista = @Aprobado
                WHERE
                    idContrato = @idContrato
                    AND MesReporte = @MesReporte;

                IF (@Aprobado = 0)
                    BEGIN
                        UPDATE
                            SCOC_EnvioNotificacion
                        SET
                            idEstatus = 10000
                        WHERE
                            idContrato = @idContrato
                            AND MesReporte = @MesReporte;
                        EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                            @idContrato,
                            @MesReporte,
                            @IdPermiso,
                            @idUsuario,
                            @Comentario,
                            1;
                        EXECUTE sp_SCOC_EnviaCorreos
                            @idContrato,
                            @MesReporte,
                            @idUsuario,
                            '',
                            6,
                            @Comentario;
                    END;
                ELSE IF (@Aprobado = 1)
                         BEGIN
                             EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                 @idContrato,
                                 @MesReporte,
                                 @IdPermiso,
                                 @idUsuario,
                                 'Completamente aprobado por el usuario comenrcializador de liquidos',
                                 0;
                             SELECT
                                 @DatetimeAprobPEP =MAX(FecMovto)
                             FROM
                                 dbo.SCOC_HistorialAprobaciones
                             WHERE
                                 Rechazado = 0
                                 AND IdPermiso = 8
                                 AND MesReporte = @MesReporte
                                 AND IdContrato = @idContrato
							
                             

                             SELECT
                                 @CountComercializadores = COUNT(IdAprobacion)
                             FROM
                                 dbo.SCOC_HistorialAprobaciones
                             WHERE
                                 IdPermiso IN (
                                                  9, 10
                                              )
                                 AND MesReporte = @MesReporte
                                 AND IdContrato = @idContrato
                                 AND FecMovto > @DatetimeAprobPEP;
                             SELECT
                                 @bitGas      = ISNULL(BitGas, 0),
                                 @bitPetroleo = ISNULL(BitPetroleo, 0)
                             FROM
                                 SCOC_Contrato
                             WHERE
                                 IdContrato = @idContrato;
                             IF (
                                    @bitGas = 1
                                    AND @bitPetroleo = 1
                                )
                                 BEGIN
                                     SET @HidrocarburosContrato = 2;
                                 END;
                             ELSE
                                 BEGIN
                                     SET @HidrocarburosContrato = 1;
                                 END;

                             IF (@CountComercializadores >= @HidrocarburosContrato)
                                 BEGIN
                                     UPDATE
                                         SCOC_EnvioNotificacion
                                     SET
                                         idEstatus = 10004 --SCOC
                                     WHERE
                                         idContrato = @idContrato
                                         AND MesReporte = @MesReporte;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato, --Notifica que ya fue aprobado por liquidos
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         10,
                                         @Comentario;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato, --Para SCOC para que pase a aprobar
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         1,
                                         @Comentario;

                                 END;
                             ELSE
                                 BEGIN
                                     UPDATE
                                         SCOC_EnvioNotificacion
                                     SET
                                         idEstatus = 10003
                                     WHERE
                                         idContrato = @idContrato
                                         AND MesReporte = @MesReporte;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato, --Aprobado liquidos
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         10,
                                         @Comentario;
                                 END;


                         END;
            END;
        ---------------------------------------------------------------------------
        IF (@TipoAprobador = 10) --Comercializador Edo Gas
            BEGIN
                UPDATE
                    SCOC_EnvioNotificacion
                SET
                    AprobadoRepPEP = @Aprobado,
                 --   FechaAprobacionRepPEP = GETDATE(),
                  --  IdUsuarioAprobadoRepPEP = @idUsuario,
                    Comentarios = @Comentario,
                    EnviadoContratista = @Aprobado
                WHERE
                    idContrato = @idContrato
                    AND MesReporte = @MesReporte;

                IF (@Aprobado = 0)
                    BEGIN
                        UPDATE
                            SCOC_EnvioNotificacion
                        SET
                            idEstatus = 10000
                        WHERE
                            idContrato = @idContrato
                            AND MesReporte = @MesReporte;
                        EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                            @idContrato,
                            @MesReporte,
                            @IdPermiso,
                            @idUsuario,
                            @Comentario,
                            1;
                        EXECUTE sp_SCOC_EnviaCorreos
                            @idContrato,
                            @MesReporte,
                            @idUsuario,
                            '',
                            7,
                            @Comentario;
                    END;
                ELSE IF (@Aprobado = 1)
                         BEGIN
                             UPDATE
                                 SCOC_EnvioNotificacion
                             SET
                                 idEstatus = 10004
                             WHERE
                                 idContrato = @idContrato
                                 AND MesReporte = @MesReporte;
                             EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                                 @idContrato,
                                 @MesReporte,
                                 @IdPermiso,
                                 @idUsuario,
                                 'Completamente aprobado por el usuario comenrcializador de Gas',
                                 0;
                             SELECT
                                 @DatetimeAprobPEP = MAX(FecMovto)
                             FROM
                                 dbo.SCOC_HistorialAprobaciones
                             WHERE
                                 Rechazado = 0
                                 AND IdPermiso = 8 --PEP
                                 AND MesReporte = @MesReporte
                                 AND IdContrato = @idContrato
								 	
                            

                             SELECT
                                 @CountComercializadores = COUNT(IdAprobacion)
                             FROM
                                 dbo.SCOC_HistorialAprobaciones
                             WHERE
                                 IdPermiso IN (
                                                  9, 10
                                              )
                                 AND MesReporte = @MesReporte
                                 AND IdContrato = @idContrato
                                 AND FecMovto > @DatetimeAprobPEP;
                             SELECT
                                 @bitGas      = ISNULL(BitGas, 0),
                                 @bitPetroleo = ISNULL(BitPetroleo, 0)
                             FROM
                                 SCOC_Contrato
                             WHERE
                                 IdContrato = @idContrato;
                             IF (
                                    @bitGas = 1
                                    AND @bitPetroleo = 1
                                )
                                 BEGIN
                                     SET @HidrocarburosContrato = 2;
                                 END;
                             ELSE
                                 BEGIN
                                     SET @HidrocarburosContrato = 1;
                                 END;

                             IF (@CountComercializadores >=  @HidrocarburosContrato)
                                 BEGIN
                                     UPDATE
                                         SCOC_EnvioNotificacion
                                     SET
                                         idEstatus = 10004 --SCOC
                                     WHERE
                                         idContrato = @idContrato
                                         AND MesReporte = @MesReporte;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato, --Notifica que ya fue aprobado por Gas
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         11,
                                         @Comentario;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato, --Para SCOC para que pase a aprobar
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         1,
                                         @Comentario;

                                 END;
                             ELSE
                                 BEGIN
                                     UPDATE
                                         SCOC_EnvioNotificacion
                                     SET
                                         idEstatus = 10002
                                     WHERE
                                         idContrato = @idContrato
                                         AND MesReporte = @MesReporte;

                                     EXECUTE sp_SCOC_EnviaCorreos
                                         @idContrato, --Aprobado Gas
                                         @MesReporte,
                                         @idUsuario,
                                         @Comentario,
                                         11,
                                         @Comentario;
                                 END;


                         END;
            END;

        SELECT
            @error AS error;
    END;
