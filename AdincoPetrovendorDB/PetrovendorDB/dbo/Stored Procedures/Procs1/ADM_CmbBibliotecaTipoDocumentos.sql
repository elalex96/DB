-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <23-10-2018>
-- Description:	<llenar el combo de tipo documento, 0 para publico y 1 para privado>
-- =============================================

CREATE PROCEDURE ADM_CmbBibliotecaTipoDocumentos @PublicoPrivado    INT, 
                                                 @IdSolicitudPedido INT, 
                                                 @DocumentosRemover NVARCHAR(500) = NULL
AS
    BEGIN
        DECLARE @RFC_PCM NVARCHAR(MAX);
        SELECT TOP 1 @RFC_PCM = RFC
        FROM dbo.PCM_RFC;
        DECLARE @TablaOpcionesAMostrar TABLE(TipoDocumentoBiblioteca INT);
        -- si es privado entonces muestra estos documentos
        IF(@PublicoPrivado = 1)
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_SolicitudPedido
                    WHERE IdSolicitudPedido = @IdSolicitudPedido
                          AND IdTipoProceso = 4 -- adj directa
                )
                    BEGIN
                        INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                               SELECT 5;
                END;
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_SolicitudPedido
                    WHERE IdSolicitudPedido = @IdSolicitudPedido
                          AND IdTipoProceso = 2 -- mercadeo
                )
                    BEGIN
                        INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                               SELECT 6;
                END;
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_AceptacionPedido ap
                         INNER JOIN dbo.MM_Pedido p ON p.IdPedido = ap.IdPedido
                    WHERE p.IdSolicitudPedido = @IdSolicitudPedido
                )
                    BEGIN
                        INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                               SELECT 7;
                END;
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_Pedido
                    WHERE IdSolicitudPedido = @IdSolicitudPedido
                )
                    BEGIN
                        INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                               SELECT 10;
                END;

                --si  la solped pertenece a PCM entonces se muestra
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_SolicitudPedido sp
                         INNER JOIN dbo.S_Proveedor p ON p.IdProveedor = sp.IdProveedor
                    WHERE sp.IdSolicitudPedido = @IdSolicitudPedido
                          AND UPPER(p.RFC) = @RFC_PCM
                )
                    BEGIN
                        IF NOT EXISTS
                        (
                            SELECT 1
                            FROM dbo.PCMDocumentoAdjunto
                            WHERE IdSolicitucPedido = @IdSolicitudPedido
                                  AND Activo = 1
                        )
                            BEGIN
                                INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                                       SELECT 11;	--justificacion de adjudicacion directa para PCM
                        END;
                END;
        END;
        IF(@PublicoPrivado = 0)
            BEGIN
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_SolicitudPedido
                    WHERE IdSolicitudPedido = @IdSolicitudPedido
                )
                    BEGIN
                        INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                               SELECT 1
                               UNION
                               SELECT 2;
                END;
                IF EXISTS
                (
                    SELECT 1
                    FROM dbo.MM_PeticionOferta
                    WHERE IdSolicitudPedido = @IdSolicitudPedido
                )
                    BEGIN
                        IF NOT EXISTS
                        (
                            SELECT 1
                            FROM TA_DocFianzaOperacion doc
                                 INNER JOIN dbo.TA_Operacion TAO ON TAO.IdOperacion = doc.IdOperacion
                                 INNER JOIN dbo.MM_SolicitudPedido solPed ON TAO.IdDocumento = solPed.IdSolicitudPedido
                            WHERE solPed.IdSolicitudPedido = @IdSolicitudPedido
                                  AND doc.Activo = 1
                        )
                            BEGIN
                                INSERT INTO @TablaOpcionesAMostrar
                                       SELECT 3;
                        END;
                        IF NOT EXISTS
                        (
                            SELECT 1
                            FROM dbo.TA_DocBasesOperacion doc
                                 INNER JOIN dbo.TA_Operacion TAO ON TAO.IdOperacion = doc.IdOperacion
                                 INNER JOIN dbo.MM_SolicitudPedido solPed ON TAO.IdDocumento = solPed.IdSolicitudPedido
                            WHERE solPed.IdSolicitudPedido = @IdSolicitudPedido
                                  AND doc.Activo = 1
                        )
                            BEGIN
                                INSERT INTO @TablaOpcionesAMostrar
                                       SELECT 4;
                        END;
                        INSERT INTO @TablaOpcionesAMostrar(TipoDocumentoBiblioteca)
                               SELECT 8
                               UNION
                               SELECT 9;
                END;
        END;

        -- retorno a la vista
        SELECT doc.IdDocumento, 
               doc.Descripcion
        FROM @TablaOpcionesAMostrar t
             INNER JOIN dbo.ADM_TipoDocumentosS3 doc ON doc.IdDocumento = t.TipoDocumentoBiblioteca
        WHERE doc.IdDocumento NOT IN
        (
            SELECT splitdata
            FROM dbo.fnSplitString(@DocumentosRemover, ',')
        );
    END;
