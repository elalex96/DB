USE Petrovendor
GO
DROP PROC IF EXISTS SP_PC_GuardarArchivoCN
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<guardado de los archivos de s3 de carta cn de PEDIMENTOS/COMPROBANTES>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<guardado de los archivos de s3 de carta cn de PEDIMENTOS/COMPROBANTES>
-- =============================================
-- Author:		<David de la cruz>
-- Create date: <28/11/2025>
-- Description:	<Se eliminan los documentos de comprobante para edición de comprobante CN>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_GuardarArchivoCN]
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
	@nombreArchivo NVARCHAR(MAX),
	@Carpeta NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@IdUsuario INT,
	@IdProveedor INT,
	@Bucket varchar(500) = null
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------------
    -- VALIDACIÓN 1: ELIMINAR SI YA EXISTE EN S_Documento_S3
    ----------------------------------------------------------
    IF EXISTS (
        SELECT 1 FROM dbo.S_Documento_S3
        WHERE Carpeta = 'CARTACONTENIDONACIONALCOMPRADIRECTA/'
        AND IdDocumentoTabla = @IdPedimentoComprobante
    )
    BEGIN
        DELETE FROM dbo.S_Documento_S3
        WHERE Carpeta = 'CARTACONTENIDONACIONALCOMPRADIRECTA/'
        AND IdDocumentoTabla = @IdPedimentoComprobante;
    END

    ----------------------------------------------------------
    -- VALIDACIÓN 2: ELIMINAR SI YA EXISTE EN CN_ArchivoCartaCompraDirecta
    ----------------------------------------------------------
    IF EXISTS (
        SELECT 1 FROM dbo.CN_ArchivoCartaCompraDirecta
        WHERE Carpeta = 'CARTACONTENIDONACIONALCOMPRADIRECTA/'
        AND IdPedimentoComprobante = 3104
    )
    BEGIN
        DELETE FROM dbo.CN_ArchivoCartaCompraDirecta
        WHERE Carpeta = 'CARTACONTENIDONACIONALCOMPRADIRECTA/'
        AND IdPedimentoComprobante = 3104;
    END

    ----------------------------------------------------------
    -- INSERT EN S_Documento_S3
    ----------------------------------------------------------
    INSERT INTO dbo.S_Documento_S3
	(
	    IdTipoDocumento,
	    IdUsuario,
	    IdTipoValidacionDocumento,
	    IdProveedor,
	    Activo,
	    Documento,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    Descripcion,
	    Carpeta,
	    Identificador,
	    Mime,
	    Extension,
	    NombreDocumento,
	    Duplicado,
	    SizeDocumento,
	    IdDocumentoTabla,
	    Bucket
	)
	VALUES
	(   
	    53,
	    @IdUsuario,
	    1003,
	    @IdProveedor,
	    1,
	    NULL,
	    @IdUsuario,
	    GETDATE(),
	    NULL,
	    NULL,
	    NULL,
	    @Carpeta,
	    @Identificador,
	    @Mime,
	    @Extension,
	    @nombreArchivo,
	    NULL,
	    NULL,
	    @IdPedimentoComprobante,
	    @Bucket
	);

    ----------------------------------------------------------
    -- INSERT EN CN_ArchivoCartaCompraDirecta
    ----------------------------------------------------------
    INSERT INTO dbo.CN_ArchivoCartaCompraDirecta
	(
	    nombreArchivo,
	    Carpeta,
	    Mime,
	    Extension,
	    Identificador,
	    CreadoPor,
	    CreadoEl,
	    IdProveedor,
		Activo,
		IdPedimentoComprobante,
		Bucket
	)
	VALUES
	(   
	    @nombreArchivo,
	    @Carpeta,
	    @Mime,
	    @Extension,
	    @Identificador,
	    @IdUsuario,
	    GETDATE(),
	    @IdProveedor,
		1,
		@IdPedimentoComprobante,
		@Bucket
	);

    SELECT SCOPE_IDENTITY() AS id

END
GO
