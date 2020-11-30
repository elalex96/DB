-- =============================================
-- Author:	Luis David De La Cruz 
-- Create date: 11/11/19
-- Description:	<Consulta para los documentos de soporte de recepcion de nota de credito.>
-- =============================================
CREATE PROCEDURE p_NC_ConsultaDocAnexosNotaCredito
    @IdNotaCredito INT,
    @IdProveedor INT,
    @IdUsuario INT,
    @IdDocumento INT,
    @Accion NVARCHAR(MAX)
AS
BEGIN
    IF @Accion = 'VER_LISTA'
    BEGIN
        SELECT D.IdDocumento,
               D.NombreDocumento
        FROM dbo.S_Documento_S3 D
            INNER JOIN dbo.MPY_MM_AceptacionNotaCredito NC
                ON NC.IdAceptacionNotaCredito = D.IdDocumentoTabla
        WHERE D.IdTipoDocumento = 27
		AND NC.IdAceptacionNotaCredito=@IdNotaCredito

    END;

    IF @Accion = 'DESCARGAR'
    BEGIN
        SELECT  D.NombreDocumento,
				D.Extension,
				D.Mime,				             
				D.Carpeta,
				D.Identificador,
				D.IdDocumento
        FROM dbo.S_Documento_S3 D
            LEFT JOIN dbo.MPY_MM_AceptacionNotaCredito NC
                ON NC.IdAceptacionNotaCredito = D.IdDocumentoTabla
        WHERE D.IdTipoDocumento = 27
		AND NC.IdAceptacionNotaCredito=@IdNotaCredito
		AND D.IdDocumento=@IdDocumento
    END;

END;