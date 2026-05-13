-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/02/2023
-- Description:	Guardar reporte(archivo) a s3
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_GuardarReporteS3]
	-- Add the parameters for the stored procedure here
	@IdSolicitud INT,
	@IdContrato INT,
	@Folder NVARCHAR(1000),
	@UUID NVARCHAR(1000),
	@NombreArchivo NVARCHAR(1000),
	@Size FLOAT,
	@Meta NVARCHAR(1000),
	@IdUsuario INT,
	@IdProveedor INT,
	@Extension NVARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO S_Documento_S3(
		IdTipoDocumento,
		IdUsuario,
		IdProveedor,
		Activo,
		CreadoPor,
		CreadoEl,
		Carpeta,
		Identificador,
		Mime,
		Extension,
		NombreDocumento,
		SizeDocumento,
		IdDocumentoTabla,
		Bucket
	)
	VALUES
	(
		(SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'Reporte'),
		@IdUsuario,
		@IdProveedor,
		1,
		@IdUsuario,
		GETDATE(),
		@Folder,
		@UUID,
		@Meta,
		@Extension,
		@NombreArchivo,
		@Size,
		@IdSolicitud,
		'petrovendor'
	);

	SELECT SCOPE_IDENTITY();

END
