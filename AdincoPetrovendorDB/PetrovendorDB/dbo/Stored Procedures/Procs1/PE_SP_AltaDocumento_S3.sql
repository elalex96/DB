-- ============================================= 
-- Author:        Daniel Cruz
-- Create date:	  26-07-21
-- Description:   Se agrega columna de Bucket
-- ============================================= 
CREATE procedure [dbo].[PE_SP_AltaDocumento_S3]

	@IdProveedor INT,
	@IdDistribuidorAutorizadoDe INT,
	@DocumentoAutorizacion NVARCHAR(max),
	@IdUsuario INT,
    
	/*NUEVOS PARAMETROS*/
	@MIME NVARCHAR(MAX),
	@EXTENSION NVARCHAR(MAX),
	@NOMBRE_DOCUMENTO NVARCHAR(MAX),
	@IDENTIFICADOR NVARCHAR(MAX),
	@CARPETA NVARCHAR(MAX),
	@BUCKET NVARCHAR(MAX)

AS
BEGIN
	DECLARE @existe INT,
			@IdDocumento int

	SET @existe = (SELECT IdDocumento FROM dbo.PV_DistribuidorAutorizado WHERE IdDistribuidorAutorizado = @IdDistribuidorAutorizadoDe)

	IF(@existe IS NULL)
	begin
		INSERT INTO [dbo].[S_Documento_S3]
							([IdTipoDocumento],
							[IdProveedor],
							[Activo],
							[Documento],
							[Mime],
							[Extension],
							[Carpeta],
							[Identificador],
							[CreadoPor],
							CreadoEl,
							[NombreDocumento],
							[Bucket])
		VALUES(21,--->TIPO DISTRIBUIDOR AUTORIZADO DE ...
				@IdProveedor,
				1,
				@DocumentoAutorizacion,
				@MIME,
				@EXTENSION,
				@CARPETA,
				@IDENTIFICADOR,	
				@IdUsuario,
				GETDATE(),
				@NOMBRE_DOCUMENTO,
				@BUCKET
				)

		set @IdDocumento = (SELECT @@Identity)

		UPDATE [PV_DistribuidorAutorizado]
		SET [IdDocumento]=@IdDocumento
		WHERE [IdDistribuidorAutorizado]=@IdDistribuidorAutorizadoDe
	END
    ELSE
    BEGIN
		UPDATE [S_Documento_S3]
			SET [Documento]=@DocumentoAutorizacion,
			[ModificadoPor]=@IdUsuario,
			[NombreDocumento]=@NOMBRE_DOCUMENTO,
			[Mime]=@MIME,
			[Extension]=@EXTENSION,
			[Carpeta]=@Carpeta,
			[Identificador]=@IDENTIFICADOR,
			[ModificadoEl]=GETDATE(),
			[Bucket] = @BUCKET
			WHERE [IdDocumento]=@existe 
	end
END