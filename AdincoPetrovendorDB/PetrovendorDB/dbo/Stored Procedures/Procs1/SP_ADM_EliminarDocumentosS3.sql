-- =============================================
-- Author:		Pedro Acuña
-- Create date: 17/09/2018
-- Description:	eliminado logico de los documentos cargados en procura Tipo Documento (ADM_TipoDocumentosS3 )
--1 Documentos por material SolPed
--2 Documentos Anexos SolPed 
--3 Fianza solOferta
--4 Bases solOferta
--5 Adj Directa Justificacion solOferta
--6 Mercadeo Justificacion solOferta
--7 Aceptacion de servicio
--10 Anexo pedido Se agrego por Daniel AC
--11 adjudicacion directa solo para PCM
-- =============================================

CREATE PROCEDURE [dbo].[SP_ADM_EliminarDocumentosS3] @TipoDocumento INT, 
                                                     @IdDocumento   INT, 
                                                     @IdAceptacion  INT
AS
    BEGIN

        --1 Documentos por material SolPed
        IF(@TipoDocumento = 1)
            BEGIN
                UPDATE MM_SolPedArchivoAdjuntoMaterial
                  SET 
                      Activo = 0
                WHERE IdSolPedMaterialDocumentoAdj = @IdDocumento;
        END;

        --2 Documentos Anexos SolPed 
        IF(@TipoDocumento = 2)
            BEGIN
                UPDATE MM_DocumentosSolPed
                  SET 
                      Activo = 0
                WHERE IdDocumento = @IdDocumento;
        END;

        --3 Fianza solOferta
        IF(@TipoDocumento = 3)
            BEGIN
                DECLARE @IdOperacion INT, @IdSolicitudPedido INT;
                UPDATE dbo.TA_DocFianzaOperacion
                  SET 
                      Activo = 0
                WHERE IdDocFianza = @IdDocumento;
                SELECT @IdOperacion = IdOperacion
                FROM dbo.TA_DocFianzaOperacion
                WHERE IdDocFianza = @IdDocumento;
                SELECT @IdSolicitudPedido = IdDocumento
                FROM dbo.TA_Operacion
                WHERE IdOperacion = @IdOperacion;
                UPDATE dbo.MM_SolicitudPedido
                  SET 
                      Fianza = 0
                WHERE IdSolicitudPedido = ISNULL(@IdSolicitudPedido, 0);
        END;

        --4 Bases solOferta
        IF(@TipoDocumento = 4)
            BEGIN
                UPDATE TA_DocBasesOperacion
                  SET 
                      Activo = 0
                WHERE IdDocBases = @IdDocumento;
        END;

        --5 Adj Directa Justificacion solOferta
        IF(@TipoDocumento = 5)
            BEGIN
                UPDATE MM_PeticionOfertaADAdjunto
                  SET 
                      Activo = 0
                WHERE IdDocumento = @IdDocumento;
        END;

        --6 Mercadeo Justificacion solOferta
        IF(@TipoDocumento = 6)
            BEGIN
                UPDATE MM_PeticionOfertaMercadeoAdjunto
                  SET 
                      Activo = 0
                WHERE Id = @IdDocumento;
        END;

        --7 Aceptacion de servicio
        IF(@TipoDocumento = 7)
            BEGIN
                UPDATE dbo.S_Documento_S3
                  SET 
                      Activo = 0
                WHERE IdDocumento = @IdDocumento
                      AND IdTipoDocumento = 12;
                UPDATE MM_AceptacionDocumento
                  SET 
                      Activo = 0
                WHERE IdDocumento = @IdDocumento
                      AND IdAceptacionDocumento = @IdAceptacion;
        END;

        --8 Cotizacion/Oferta por Material
        IF(@TipoDocumento = 8)
            BEGIN
                UPDATE MM_DocumentosAnexos
                  SET 
                      Activo = 0
                WHERE IdDocumentoAnexo = @IdDocumento;
        END;

        --9 Cotizacion/Oferta Anexos
        IF(@TipoDocumento = 9)
            BEGIN
                UPDATE MM_DocAnexosPeticionOferta
                  SET 
                      Eliminado = 1
                WHERE IdDocAnexoPeticionOferta = @IdDocumento;
        END;

        --10 Anexos de Pedido
        IF(@TipoDocumento = 10)
            BEGIN
                UPDATE dbo.DocumentosPedido
                  SET 
                      Activo = 0
                WHERE Id = @IdDocumento;
        END;

        -- 11 Adjudicacion directa PCM
        IF(@TipoDocumento = 11)
            BEGIN
                UPDATE dbo.PCMDocumentoAdjunto
                  SET 
                      Activo = 0
                WHERE IdDocumento = @IdDocumento;
        END;
        SELECT 1;	--retorno
    END;
