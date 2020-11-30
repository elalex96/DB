-- =============================================
-- Author:	Daniel AC
-- Create date: 08/10/2019
-- Description:	Actualizar PO
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_GuardarReemplazoDocPO]
    -- Add the parameters for the stored procedure here
    @IdRelacionPO INT,
    @IdAdjuntoPO INT,
    @Comentario NVARCHAR(MAX),
    @Mime NVARCHAR(MAX),
    @Carpeta NVARCHAR(MAX),
    @Extension NVARCHAR(MAX),
    @Identificador NVARCHAR(MAX),
    @NombreDocumento NVARCHAR(MAX),
    @Descripcion NVARCHAR(MAX),
    @SizeDocumento NVARCHAR(MAX),
    @CargadoPorUsuarioID INT,
    @CargadaManualmente BIT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF @CargadaManualmente = 0
        SET @CargadoPorUsuarioID = NULL;
    -- Insert statements for procedure here
    DECLARE @IdDocumento INT;

    SELECT @IdDocumento=IdDocumento
    FROM dbo.DEA_AdjuntoPO
    WHERE IdAdjuntoPO = @IdAdjuntoPO;

	--PASAR DOCUEMNTO A TABLA DE HISTORIAL DE DOCUMENTOS 

	INSERT INTO [dbo].[DEA_DocumentoHistorial_S3]
	(
		[IdDocumento],
	    [IdTipoDocumento], 	
		[IdProveedor],
		[Activo], 
		[CreadoPor],
		[CreadoEl],
		[Descripcion],
		[Carpeta],
		[Identificador],
		[Mime],
		[Extension],
		[NombreDocumento],
		[SizeDocumento],		
	    [IdDocumentoTabla]
	)	

	SELECT 
		IdDocumento,
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
        NombreDocumento,
        SizeDocumento,
		IdDocumentoTabla
	 FROM dbo.DEA_Documento_S3 
	 WHERE IdDocumento=@IdDocumento

	--ACTUALZAR PO EN EL DOCUMENTO
    UPDATE dbo.DEA_Documento_S3
    SET IdTipoDocumento = 2,
        IdProveedor = NULL,
        Activo = 1,
        CreadoPor = @CargadoPorUsuarioID,
        CreadoEl = GETDATE(),
        Descripcion = '',
        Carpeta = @Carpeta,
        Identificador = @Identificador,
        Mime = @Mime,
        Extension = @Extension,
        NombreDocumento = @NombreDocumento,
        SizeDocumento = @SizeDocumento,
		ModificadoPor=@CargadoPorUsuarioID,
		ModificadoEl=GETDATE()
    WHERE IdDocumento = @IdDocumento;
	
	SELECT 'SUCCESS' AS Response , @IdDocumento AS IdDocumentoPO
    FROM dbo.DEA_AdjuntoPO
    WHERE IdAdjuntoPO = @IdAdjuntoPO;

END;



