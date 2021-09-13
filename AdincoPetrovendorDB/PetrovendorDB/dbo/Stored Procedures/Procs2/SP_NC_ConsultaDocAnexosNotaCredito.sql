DROP PROCEDURE IF EXISTS SP_NC_ConsultaDocAnexosNotaCredito
GO
-- =============================================
-- Author:	Daniel AC
-- Create date:08/09/2019
-- Description:	<Consulta para los documentos de soporte de recepcion de nota de credito.>
-- =============================================
-- =============================================
-- Author:	Luis David De La Cruz 
-- Create date: 07/09/2021
-- Description:	Se agrega el bucket en la descarga para la estandarización de descarga amazon s3
-- =============================================
create PROCEDURE SP_NC_ConsultaDocAnexosNotaCredito
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
            INNER JOIN dbo.MM_AceptacionNotaCredito NC
                ON NC.IdAceptacionNotaCredito = D.IdDocumentoTabla
        WHERE D.IdTipoDocumento = 27
		AND NC.IdAceptacionNotaCredito=@IdNotaCredito
		union 
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
				D.IdDocumento,
				D.Bucket
        FROM dbo.S_Documento_S3 D
            LEFT JOIN dbo.MM_AceptacionNotaCredito NC
                ON NC.IdAceptacionNotaCredito = D.IdDocumentoTabla
        WHERE D.IdTipoDocumento = 27
		AND NC.IdAceptacionNotaCredito=@IdNotaCredito
		AND D.IdDocumento=@IdDocumento
		union 
		SELECT  D.NombreDocumento,
				D.Extension,
				D.Mime,				             
				D.Carpeta,
				D.Identificador,
				D.IdDocumento,
				D.Bucket
        FROM dbo.S_Documento_S3 D
            LEFT JOIN dbo.MPY_MM_AceptacionNotaCredito NC
                ON NC.IdAceptacionNotaCredito = D.IdDocumentoTabla
        WHERE D.IdTipoDocumento = 27
		AND NC.IdAceptacionNotaCredito=@IdNotaCredito
		AND D.IdDocumento=@IdDocumento
    END;

END;
