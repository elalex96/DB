CREATE PROCEDURE [dbo].[EN_SHELL_GuardarDocumentoGeneral]    
	@ContratoId INT,
	@NivelPadre INT,
	@EtapaId INT,
	@ReceptorId INT,
	@InstalacionId INT,
	@EtapaPozoId	INT,
	@MarcoLegalId INT,
	@Frecuencia  NVARCHAR(max),
	@FechaEntregaAnioMes  NVARCHAR(max),
	@EntregableId INT,
	@Bucket NVARCHAR(max),
	@Folder NVARCHAR(max),
	@UUIDAmazon uniqueidentifier,
	@NombreArchivo NVARCHAR(max),
	@Meta nvarchar(max),
	@CreadoPor INT,	
	@TipoArchivo NVARCHAR(100),
	@SizeBytes DECIMAL,
	@Comentarios NVARCHAR(max)  
AS
BEGIN
		
		SET @NombreArchivo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@NombreArchivo, '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','');  

		INSERT INTO [dbo].[EN_DocumentoGeneral]
           (NivelPadre,
			ContratoId,
			EtapaId,
			ReceptorId,
			InstalacionId,
			EtapaPozoId,
			MarcoLegalId,
			Frecuencia,
			FechaEntregaAnioMes,
			EntregableId,
			Bucket,
			Folder,
			UUIDAmazon,
			NombreArchivo,
			Meta,
			CreadoPor,
			CreadoEl,
			Activo,
			TipoArchivo,
			SizeBytes,
			Comentarios)
     VALUES
           (
		    @NivelPadre,
			@ContratoId,
			CASE WHEN @EtapaId = 0 THEN NULL ELSE @EtapaId END,
			CASE WHEN @ReceptorId = 0 THEN NULL ELSE @ReceptorId END,
			CASE WHEN @InstalacionId = 0 THEN NULL ELSE @InstalacionId END, --> SI LA INSTALACION ES DIFERENTE DE CERO ENTONCES LA CARPETA ES GENERAL DE UN POZO
			CASE WHEN @EtapaPozoId = 0 THEN NULL ELSE @EtapaPozoId END,
			CASE WHEN @MarcoLegalId = 0 THEN NULL ELSE @MarcoLegalId END,
			@Frecuencia,
			@FechaEntregaAnioMes,
			CASE WHEN @EntregableId = 0 THEN NULL ELSE @EntregableId END,
			@Bucket,
			@Folder,
			UPPER(@UUIDAmazon),
			@NombreArchivo,
			@Meta,
			@CreadoPor,
			GETDATE(),			
			1,
			@TipoArchivo,
			@SizeBytes,
			@Comentarios)

		SELECT @@IDENTITY AS DocumentoId

 END