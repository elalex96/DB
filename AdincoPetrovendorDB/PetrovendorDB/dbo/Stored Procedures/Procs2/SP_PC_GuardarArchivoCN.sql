DROP PROCEDURE IF EXISTS SP_PC_GuardarArchivoCN
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/04/2020>
-- Description:	<guardado de los archivos de s3 de carta cn de PEDIMENTOS/COMPROBANTES>
-- =============================================
-- Author:		<LUIS DAVID>
-- Create date: <20/04/2020>
-- Description:	<guardado de los archivos de s3 de carta cn de PEDIMENTOS/COMPROBANTES>
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
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
	(   53,         -- IdTipoDocumento - int Pedimento/Comprobante - Compra Directa
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
		@Carpeta,       -- Carpeta - nvarchar(max)
	    @Identificador,       -- Identificador - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @nombreArchivo,       -- NombreDocumento - nvarchar(max)
	    NULL,       -- Duplicado - nvarchar(40)
	    NULL,       -- SizeDocumento - float
	    @IdPedimentoComprobante,         -- IdDocumentoTabla - int
	    @Bucket        -- Bucket - nvarchar(200)
	    );

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
	    @nombreArchivo,         -- nombreArchivo - int
	    @Carpeta,       -- Carpeta - nvarchar(max)
	    @Mime,       -- Mime - nvarchar(max)
	    @Extension,       -- Extension - nvarchar(max)
	    @Identificador,       -- Identificador - nvarchar(max)
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    @IdProveedor,          -- IdProveedor - int
		1,
		@IdPedimentoComprobante,
		@Bucket
	  );

	  SELECT SCOPE_IDENTITY() AS id
	
	

END