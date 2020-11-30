-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <07/10/2020>
-- Description:	<Actualizacion del archivo de Pedimento/Comprobante en el S3>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarArchivoPedimentoComprobante_S3_CD] 
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
	@IdentificadorDoc NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@NombreDocumento NVARCHAR(MAX),
	@IdUsuario INT,
	@IdProveedor INT,
	@Archivo IMAGE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	--SE INACTIVA EL DOCUMENTO ANTERIORMENTE CARGADO
	UPDATE dbo.S_Documento_S3
	SET Activo = 0,--INACTIVO
		IdTipoValidacionDocumento = 6--ELIMINADO
	WHERE IdDocumentoTabla = @IdPedimentoComprobante

	DELETE FROM dbo.FI_Documento WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

	IF @Extension = '.pdf'
	BEGIN
	    
		INSERT INTO dbo.FI_Documento
		(
		    Documento,
		    IdTipoDocumento,
		    IdFactura,
		    IdPedimentoComprobante,
		    IdDocFacturacionSIPAC,
		    NombreExtensionArchivo,
		    IdUsuario,
		    FechaCarga,
		    IsEliminado,
		    DocumentoByte
		)
		VALUES
		(   NULL,       -- Documento - nvarchar(max)
		    4,         -- IdTipoDocumento - int
		    NULL,         -- IdFactura - int
		    @IdPedimentoComprobante,         -- IdPedimentoComprobante - int
		    NULL,       -- IdDocFacturacionSIPAC - nvarchar(50)
		    'PE_' + @IdPedimentoComprobante + '.pdf',       -- NombreExtensionArchivo - nvarchar(150)
		    @IdUsuario,         -- IdUsuario - int
		    GETDATE(), -- FechaCarga - datetime
		    NULL,      -- IsEliminado - bit
		    @Archivo       -- DocumentoByte - image
		    )

	END
	
	--SE GUARDA EL NUEVO DOCUMENTO CARGADO
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
	(   54,         -- IdTipoDocumento - int Pedimento/Comprobante - Compra Directa
	    @IdUsuario,         -- IdUsuario - int
	    1003,         -- IdTipoValidacionDocumento - int
	    @IdProveedor,         -- IdProveedor - int
	    1,      -- Activo - bit
	    NULL,       -- Documento - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    NULL,         -- ModificadoPor - int
	    NULL, -- ModificadoEl - datetime
	    NULL,       -- Descripcion - nvarchar(max)
	    'PEDIMENTO_COMPROBANTE_CD/',       -- Carpeta - nvarchar(max)
	    @IdentificadorDoc,       -- Identificador - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @NombreDocumento,       -- NombreDocumento - nvarchar(max)
	    NULL,       -- Duplicado - nvarchar(40)
	    NULL,       -- SizeDocumento - float
	    @IdPedimentoComprobante,         -- IdDocumentoTabla - int
	    NULL        -- Bucket - nvarchar(200)
	  );

	  SELECT SCOPE_IDENTITY() AS IdPedimentoS3
END
