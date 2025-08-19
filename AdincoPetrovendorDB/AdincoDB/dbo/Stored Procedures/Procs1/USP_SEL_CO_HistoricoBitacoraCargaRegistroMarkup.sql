IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_HistoricoBitacoraCargaRegistroMarkup'
    )
    DROP PROCEDURE USP_SEL_CO_HistoricoBitacoraCargaRegistroMarkup;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_HistoricoBitacoraCargaRegistroMarkup]
    @IdUsuario              INT,
    @IdContrato             INT,
    @IdContratoSeleccionado INT = 0
AS
    BEGIN
        SELECT
            CO_BitacoraCargaRegistroMarkup.Id,
            CO_BitacoraCargaRegistroMarkup.IdArchivoAWS,
            CO_BitacoraCargaRegistroMarkup.IdContrato,
            CO_BitacoraCargaRegistroMarkup.CreadoEl,
            CO_BitacoraCargaRegistroMarkup.CreadoPor,
            CO_BitacoraCargaRegistroMarkup.Mensaje,
            CO_BitacoraCargaRegistroMarkup.DetalleAnalisis,
            CO_BitacoraCargaRegistroMarkup.DetalleInsercion,
            CO_BitacoraCargaRegistroMarkup.MarkupRegistrado,
            AP_Usuario.Nombre             AS UsuarioCreadoPor,
            CO_Contrato.NumeroContrato    AS NumeroContrato,
            AWS_Documentos.Bucket,
            AWS_Documentos.Folder,
            AWS_Documentos.UUIDAmazon,
            AWS_Documentos.NombreArchivo
        FROM
            CO_BitacoraCargaRegistroMarkup (NOLOCK)
            JOIN
                AP_Usuario (NOLOCK)
                    ON CO_BitacoraCargaRegistroMarkup.CreadoPor = AP_Usuario.UsuarioID
            JOIN
                CO_Contrato (NOLOCK)
                    ON CO_BitacoraCargaRegistroMarkup.IdContrato = CO_Contrato.IdContrato
            LEFT JOIN
                AWS_Documentos (NOLOCK)
                    ON CO_BitacoraCargaRegistroMarkup.IdArchivoAWS = AWS_Documentos.AWSDocumentoId;
    END