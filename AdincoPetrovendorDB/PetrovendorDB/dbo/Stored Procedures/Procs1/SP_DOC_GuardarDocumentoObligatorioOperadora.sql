-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21-07-2020>
-- Description:	<Guardado del documento obligatorio por operadora>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_GuardarDocumentoObligatorioOperadora]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@NombreDocumentoObligatorio NVARCHAR(1000),
	@DescripcionDocumento NVARCHAR(MAX),
	@Obligatorio BIT,
	@Carpeta NVARCHAR(1000),
	@Identificador NVARCHAR(MAX),
	@Mime NVARCHAR(1000),
	@Extension NVARCHAR(1000),
	@NombreDocumento NVARCHAR(1000),
	@Size FLOAT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDDOCUMENTOS3 INT;

    -- Insert statements for procedure here

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
	    IdDocumentoTabla
	)
	VALUES
	(   51,         -- IdTipoDocumento - int Plantilla Documento Obligatorio Operadora
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
	    @NombreDocumento,       -- NombreDocumento - nvarchar(max)
	    NULL,       -- Duplicado - nvarchar(40)
	    @Size,       -- SizeDocumento - float
	    NULL          -- IdDocumentoTabla - int
	    );


		SET @IDDOCUMENTOS3 = (SCOPE_IDENTITY());
	
	INSERT INTO dbo.S_DocumentoPlantillaOperadora
	(
	    NombreDocumentoObligatorio,
	    DescripcionDocumento,
	    Obligatorio,
	    IdDocumentoS3,
	    IdProveedor,
	    CreadoPor,
	    CreadoEl,
	    Activo,
	    EliminadoPor,
	    EliminadoEl
	)
	VALUES
	(   @NombreDocumentoObligatorio,       -- NombreDocumentoObligatorio - nvarchar(1000)
	    @DescripcionDocumento,       -- DescripcionDocumento - nvarchar(max)
	    @Obligatorio,      -- Obligatorio - bit
	    @IDDOCUMENTOS3,         -- IdDocumentoS3 - int
	    @IdProveedor,         -- IdProveedor - int
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE(), -- CreadoEl - datetime
	    1,      -- Activo - bit
	    NULL,         -- EliminadoPor - int
	    NULL  -- EliminadoEl - datetime
	    );


	SELECT ISNULL(SCOPE_IDENTITY(),0);

END
