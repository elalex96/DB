-- =============================================
-- Author:		Pedro Acuña
-- Create date: 20/09/2018
-- Description:	guardar los documentos en S3 
--1 Documentos por material SolPed
--2 Documentos Anexos SolPed 
--3 Fianza solOferta
--4 Bases solOferta
--5 Adj Directa Justificacion solOferta
--6 Mercadeo Justificacion solOferta
--7 Aceptacion de servicio
--8 Documentos por material Cotizacion/Oferta por Material
--9 Documentos Anexos Cotizacion/Oferta por Material 
--10 Documentos anexos Pedido
--11 Adjudicacion directa para PCM
-- =============================================
CREATE PROCEDURE SP_ADM_GuardarDocumentosS3 @TipoDocumento            INT, 
                                            @NombreDoc                NVARCHAR(100), 
                                            @IdSolicitudPedidoDetalle NVARCHAR(MAX), 
                                            @Carpeta                  NVARCHAR(150), 
                                            @Identificador            NVARCHAR(MAX), 
                                            @Extension                NVARCHAR(50), 
                                            @Mime                     NVARCHAR(50), 
                                            @IdUsuario                INT, 
                                            @IdProveedor              INT, 
                                            @IdSubcontratista         INT, 
                                            @IdSolicitudPedido        INT, 
                                            @IdAceptacionPedido       INT, 
                                            @IdPedido                 INT           = NULL, 
                                            @Version                  INT           = NULL
AS
    BEGIN
        DECLARE @IdOperacion INT, @IdPeticionOferta INT, @IdIdentityDocumento INT;
        IF(@TipoDocumento = 1)
            BEGIN
                INSERT INTO dbo.MM_SolPedArchivoAdjuntoMaterial
                (IdSolPedDetalle, 
                 NombreArchivoAdjunto, 
                 Carpeta, 
                 Identificador, 
                 Extension, 
                 Mime, 
                 Activo, 
                 CreadoPor, 
                 CreadoEl
                )
                       SELECT @IdSolicitudPedidoDetalle, 
                              @NombreDoc, 
                              @Carpeta, 
                              @Identificador, 
                              @Extension, 
                              @Mime, 
                              1, 
                              @IdUsuario, 
                              GETDATE();
        END;
        IF(@TipoDocumento = 2)
            BEGIN
                INSERT INTO dbo.MM_DocumentosSolPed
                (IdSolPed, 
                 NombreDoc, 
                 Carpeta, 
                 Identificador, 
                 Extension, 
                 Mime, 
                 Activo, 
                 CreadoPor, 
                 CreadoEl, 
                 Documento
                )
                       SELECT @IdSolicitudPedido, 
                              @NombreDoc, 
                              @Carpeta, 
                              @Identificador, 
                              @Extension, 
                              @Mime, 
                              1, 
                              @IdUsuario, 
                              GETDATE(), 
                              '';
        END;
        IF(@TipoDocumento = 3)
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM TA_DocFianzaOperacion doc
                         INNER JOIN dbo.TA_Operacion TAO ON TAO.IdOperacion = doc.IdOperacion
                         INNER JOIN dbo.MM_SolicitudPedido solPed ON TAO.IdDocumento = solPed.IdSolicitudPedido
                    WHERE doc.IdOperacion IN
                    (
                        SELECT IdOperacion
                        FROM dbo.TA_Operacion
                        WHERE IdDocumento = @IdSolicitudPedido
                              AND IdTipoOperacion = 6
                    )
                          AND doc.Activo = 1
                          AND TAO.IdTipoOperacion = 6
                )
                    BEGIN
                        RAISERROR('Este documento ya ah sido cargado', 16, 1);
                END;
                    ELSE
                    BEGIN
                        SELECT @IdOperacion = TAO.IdOperacion
                        FROM dbo.TA_Operacion TAO
                        WHERE TAO.IdTipoOperacion = 6
                              AND TAO.IdDocumento = @IdSolicitudPedido;
                        INSERT INTO dbo.TA_DocFianzaOperacion
                        (IdProveedor, 
                         NombreDoc, 
                         IdOperacion, 
                         Carpeta, 
                         Identificador, 
                         Extension, 
                         Mime, 
                         AMS3, 
                         Activo, 
                         CreadoPor, 
                         CreadoEl, 
                         Documento
                        )
                               SELECT @IdProveedor, 
                                      @NombreDoc, 
                                      @IdOperacion, 
                                      @Carpeta, 
                                      @Identificador, 
                                      @Extension, 
                                      @Mime, 
                                      1, 
                                      1, 
                                      @IdUsuario, 
                                      GETDATE(), 
                                      '';
                        UPDATE dbo.MM_SolicitudPedido
                          SET 
                              Fianza = 1
                        WHERE IdSolicitudPedido = @IdSolicitudPedido;
                END;
        END;
        IF(@TipoDocumento = 4)
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.TA_DocBasesOperacion doc
                         INNER JOIN dbo.TA_Operacion TAO ON TAO.IdOperacion = doc.IdOperacion
                         INNER JOIN dbo.MM_SolicitudPedido solPed ON TAO.IdDocumento = solPed.IdSolicitudPedido
                    WHERE doc.IdOperacion IN
                    (
                        SELECT IdOperacion
                        FROM dbo.TA_Operacion
                        WHERE IdDocumento = @IdSolicitudPedido
                              AND IdTipoOperacion = 6
                    )
                          AND doc.Activo = 1
                          AND TAO.IdTipoOperacion = 6
                )
                    BEGIN
                        RAISERROR('Este documento ya ah sido cargado', 16, 1);
                END;
                    ELSE
                    BEGIN
                        SELECT @IdOperacion = TAO.IdOperacion
                        FROM dbo.TA_Operacion TAO
                        WHERE TAO.IdTipoOperacion = 6
                              AND TAO.IdDocumento = @IdSolicitudPedido;
                        INSERT INTO dbo.TA_DocBasesOperacion
                        (IdProveedor, 
                         NombreDoc, 
                         IdOperacion, 
                         Carpeta, 
                         Identificador, 
                         Extension, 
                         Mime, 
                         AMS3, 
                         Activo, 
                         CreadoPor, 
                         CreadoEl
                        )
                               SELECT @IdProveedor, 
                                      @NombreDoc, 
                                      @IdOperacion, 
                                      @Carpeta, 
                                      @Identificador, 
                                      @Extension, 
                                      @Mime, 
                                      1, 
                                      1, 
                                      @IdUsuario, 
                                      GETDATE();
                END;
        END;
        IF(@TipoDocumento = 5)
            BEGIN
                INSERT INTO dbo.MM_PeticionOfertaADAdjunto
                (Carpeta, 
                 Identificador, 
                 Mime, 
                 Extension, 
                 NombreDocumento, 
                 Activo, 
                 CreadoPor, 
                 CreadoEl, 
                 IdSolicitudPedido
                )
                       SELECT @Carpeta, 
                              @Identificador, 
                              @Mime, 
                              @Extension, 
                              @NombreDoc, 
                              1, 
                              @IdUsuario, 
                              GETDATE(), 
                              @IdSolicitudPedido;
        END;
        IF(@TipoDocumento = 6)
            BEGIN
                INSERT INTO dbo.MM_PeticionOfertaMercadeoAdjunto
                (Carpeta, 
                 Identificador, 
                 Mime, 
                 Extension, 
                 NombreDocumento, 
                 Activo, 
                 CreadoPor, 
                 CreadoEl, 
                 IdSolicitudPedido
                )
                       SELECT @Carpeta, 
                              @Identificador, 
                              @Mime, 
                              @Extension, 
                              @NombreDoc, 
                              1, 
                              @IdUsuario, 
                              GETDATE(), 
                              @IdSolicitudPedido;
        END;

        --Revisar
        IF(@TipoDocumento = 7)
            BEGIN
                -- aki el tipo de documento se toma de S_TipoDocumento ya que ya estaba realizado esta parte y se tomaba de documentos3
                INSERT INTO dbo.S_Documento_S3
                (IdTipoDocumento, 
                 IdUsuario, 
                 IdProveedor, 
                 Activo, 
                 Documento, 
                 CreadoPor, 
                 CreadoEl, 
                 Carpeta, 
                 Identificador, 
                 Mime, 
                 Extension, 
                 NombreDocumento
                )
                       SELECT 12, 
                              @IdUsuario, 
                              @IdProveedor, 
                              1, 
                              '', 
                              @IdUsuario, 
                              GETDATE(), 
                              @Carpeta, 
                              @Identificador, 
                              @Mime, 
                              @Extension, 
                              @NombreDoc;
                SELECT @IdIdentityDocumento = SCOPE_IDENTITY();
                INSERT INTO dbo.MM_AceptacionDocumento
                (IdAceptacionDocumento, 
                 IdDocumento, 
                 Comentario, 
                 NombreDocumento, 
                 Activo
                )
                       SELECT @IdAceptacionPedido, 
                              @IdIdentityDocumento, 
                              '', 
                              @NombreDoc, 
                              1;
        END;
        IF(@TipoDocumento = 8)
            BEGIN
                DECLARE @IdPeticionOfertaDetalle INT;
                SELECT @IdPeticionOferta = POD.IdPeticionOferta, 
                       @IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
                FROM dbo.MM_SolicitudPedidoDetalle det
                     INNER JOIN dbo.MM_PeticionOfertaDetalle POD ON POD.IdSolicitudPedidoDetalle = det.IdSolicitudPedidoDetalle
                WHERE det.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
                      AND POD.IdProveedorVenta = @IdSubcontratista;
                INSERT INTO dbo.MM_DocumentosAnexos
                (IdPeticionOferta, 
                 IdPeticionOfertaDetalle, 
                 Nombre, 
                 Carpeta, 
                 Identificador, 
                 Extension, 
                 Mime, 
                 AMS3, 
                 Activo, 
                 CreadoPor, 
                 CreadoEl, 
                 Documento
                )
                       SELECT @IdPeticionOferta, 
                              @IdPeticionOfertaDetalle, 
                              @NombreDoc, 
                              @Carpeta, 
                              @Identificador, 
                              @Extension, 
                              @Mime, 
                              1, 
                              1, 
                              @IdUsuario, 
                              GETDATE(), 
                              '';
        END;
        IF(@TipoDocumento = 9)
            BEGIN
                SELECT TOP 1 @IdPeticionOferta = POD.IdPeticionOferta
                FROM dbo.MM_SolicitudPedidoDetalle det
                     INNER JOIN dbo.MM_PeticionOfertaDetalle POD ON POD.IdSolicitudPedidoDetalle = det.IdSolicitudPedidoDetalle
                WHERE POD.IdProveedorVenta = @IdSubcontratista
                      AND det.IdSolicitudPedido = @IdSolicitudPedido;
                INSERT INTO dbo.MM_DocAnexosPeticionOferta
                (IdPeticionOferta, 
                 NomDocumento, 
                 SubidoPor, 
                 SubidoEl, 
                 Carpeta, 
                 Identificador, 
                 Extension, 
                 Mime, 
                 AMS3, 
                 Eliminado, 
                 Documento
                )
                       SELECT @IdPeticionOferta, 
                              @NombreDoc, 
                              @IdUsuario, 
                              GETDATE(), 
                              @Carpeta, 
                              @Identificador, 
                              @Extension, 
                              @Mime, 
                              1, 
                              0, 
                              '';
        END;
        IF(@TipoDocumento = 10)
            BEGIN
                -- aki el tipo de documento se toma de S_TipoDocumento para que este igual que el tipo 7
                INSERT INTO dbo.DocumentosPedido
                (IdPedido, 
                 Version, 
                 Carpeta, 
                 Identificador, 
                 Mime, 
                 Extension, 
                 NombreDocumento, 
                 CreadoPor, 
                 CreadoEl, 
                 Activo
                )
                       SELECT @IdPedido, 
                              @Version, 
                              @Carpeta, 
                              @Identificador, 
                              @Mime, 
                              @Extension, 
                              @NombreDoc, 
                              @IdUsuario, 
                              GETDATE(), 
                              1;
        END;
        IF(@TipoDocumento = 11)
            BEGIN
                IF NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.PCMDocumentoAdjunto
                    WHERE IdSolicitucPedido = @IdSolicitudPedido
                          AND Activo = 1
                          AND IdTipoDocumento = 28
                          AND IdProveedor = @IdProveedor
                )
                    BEGIN
                        INSERT INTO dbo.PCMDocumentoAdjunto
                        (IdSolicitucPedido, 
                         IdTipoDocumento, 
                         IdProveedor, 
                         Activo, 
                         CreadoPor, 
                         CreadoEl, 
                         Descripcion, 
                         Carpeta, 
                         Identificador, 
                         Mime, 
                         Extension, 
                         NombreDocumento
                        )
                               SELECT @IdSolicitudPedido, 
                                      28, 
                                      @IdProveedor, 
                                      1, 
                                      @IdUsuario, 
                                      GETDATE(), 
                                      '', 
                                      @Carpeta, 
                                      @Identificador, 
                                      @Mime, 
                                      @Extension, 
                                      @NombreDoc;
                END;
        END;
    END;
