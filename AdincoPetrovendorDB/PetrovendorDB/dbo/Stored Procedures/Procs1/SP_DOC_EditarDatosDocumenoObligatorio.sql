-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21-07-2020>
-- Description:	<Editado y eliminado de documentos obligatorios por operadora>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_EditarDatosDocumenoObligatorio]
	-- Add the parameters for the stored procedure here
	@IdDocumentoPlantilla INT,
	@NombreDocumentoObligatorio NVARCHAR(1000) = NULL,
	@DescripcionDocumento NVARCHAR(1000) = NULL,
	@Obligatorio BIT = NULL,
	@IdProveedor INT,
	@IdUsuario INT = NULL,
	@Activo BIT,
	@Carpeta NVARCHAR(1000) = NULL,
	@Identificador NVARCHAR(MAX) = NULL,
	@Mime NVARCHAR(1000) = NULL,
	@Extension NVARCHAR(1000) = NULL,
	@NombreDocumento NVARCHAR(1000) = NULL,
	@Size FLOAT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDDOCUMENTOS3_UPD INT;
	DECLARE @IDDOCUMENTOSPLAN INT = (SELECT TOP 1 IdDocumentoPlantilla
										FROM dbo.S_DocumentoPlantillaOperadora
										WHERE IdDocumentoS3 = @IdDocumentoPlantilla)

    -- Insert statements for procedure here
	IF @Activo = 0
	BEGIN

		UPDATE dbo.S_Documento_S3
		SET Activo = 0
		WHERE IdDocumento = @IdDocumentoPlantilla
			AND IdProveedor = @IdProveedor;
	    
		UPDATE dbo.S_DocumentoPlantillaOperadora
		SET Activo = 0
		WHERE IdDocumentoPlantilla = @IDDOCUMENTOSPLAN
			AND IdProveedor = @IdProveedor;

		SELECT 'REG ELIMINADO'

	END
	ELSE
	BEGIN

		UPDATE dbo.S_DocumentoPlantillaOperadora
		SET NombreDocumentoObligatorio = @NombreDocumentoObligatorio,
			DescripcionDocumento = @DescripcionDocumento,
			Obligatorio = @Obligatorio
		WHERE IdDocumentoPlantilla = @IDDOCUMENTOSPLAN
			AND IdProveedor = @IdProveedor;

		IF ISNULL(@Identificador,'') <> ''
		BEGIN
		    
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

				SET @IDDOCUMENTOS3_UPD = (SCOPE_IDENTITY());

				UPDATE dbo.S_DocumentoPlantillaOperadora
				SET IdDocumentoS3 = @IDDOCUMENTOS3_UPD
				WHERE IdDocumentoPlantilla = @IDDOCUMENTOSPLAN
					AND IdProveedor = @IdProveedor;

				UPDATE dbo.S_Documento_S3
				SET Activo = 0
				WHERE IdDocumento = @IdDocumentoPlantilla
					AND IdProveedor = @IdProveedor;

		END

		SELECT 'REG ACTUALIZADO'

	END

	

END
