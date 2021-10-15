USE [Adinco]
GO

/****** Object:  StoredProcedure [dbo].[EN_SHELL_GuardarDocumentoPersonalizado]    Script Date: 15/10/2021 09:44:02 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[EN_SHELL_GuardarDocumentoPersonalizado]    
	@ContratoId INT,
	@NivelPadre INT,
	@EtapaId INT,
	@ReceptorId INT,
	@InstalacionId INT,
	@EtapaPozoId	INT,
	@MarcoLegalId INT,
	@Frecuencia  NVARCHAR(max),
	@EntregableId INT,
	@Bucket NVARCHAR(max),
	@Folder NVARCHAR(max),
	@UUIDAmazon uniqueidentifier,
	@NombreArchivo NVARCHAR(max),
	@Meta nvarchar(max),
	@CreadoPor INT,	
	@SizeBytes DECIMAL,
	@IdPadre INT
AS
BEGIN
		
		SET @NombreArchivo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@NombreArchivo, '$',''),'%',''),',',''),'*',''),'<',''),'>',''),'|',''),':',''),'?','');  

		INSERT INTO CarpetasDocumentosEntregables
           ([IDPadre]
      ,[Titulo]
      ,[EtapaId]
      ,[ReceptorEntregableId]
      ,[PozoInstalacionId]
      ,[MarcoLegalId]
      ,[EtapaPozoId]
      ,[EntregableId]
      ,[FrecuenciaId]
      ,[Frecuencia]
      ,[Detalle]
      ,[Icono]
      ,[Acciones]
      ,[Mime]
      ,[Nivel]
      ,[TipoArchivo]
      ,[FechaCarga]
      ,[CargadoPor]
      ,[Bucket]
      ,[Folder]
      ,[UUIDAmazon]
      ,[NombreArchivo]
      ,[Meta]
      ,[SizeBytes]
      ,[IdContrato]
      ,[Activo])
     VALUES
           (
		    @IdPadre,
			@NombreArchivo,
			CASE WHEN @EtapaId = 0 THEN NULL ELSE @EtapaId END,
			CASE WHEN @ReceptorId = 0 THEN NULL ELSE @ReceptorId END,
			CASE WHEN @InstalacionId = 0 THEN NULL ELSE @InstalacionId END, --> SI LA INSTALACION ES DIFERENTE DE CERO ENTONCES LA CARPETA ES GENERAL DE UN POZO
			CASE WHEN @MarcoLegalId = 0 THEN NULL ELSE @MarcoLegalId END,
			CASE WHEN @EtapaPozoId = 0 THEN NULL ELSE @EtapaPozoId END,
			CASE WHEN @EntregableId = 0 THEN NULL ELSE @EntregableId END,
			@Frecuencia,
			@Frecuencia,
			'Archivo',
			 N'<span style="color:green;" title="Archivo"><i class="glyph-icon icon-file"></i></span>',
			 '##ACCION##',
			(CASE WHEN @Meta IN('application/pdf') THEN 'PDF' 
                     WHEN @Meta IN ('application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spre',
                     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') THEN 'EXCEL'
                     WHEN @Meta IN ('application/msword',
                                    'application/vnd.openxmlformats-officedocument.word', 'application/vnd.openxmlformats-officedocument.spre',
                                    'text/plain','text/html') THEN 'WORD'
                    WHEN @Meta IN ('image/jpeg','image/png','image/gif','image/bmp') THEN 'IMAGEN'
                    ELSE 'ARCHIVO' END),
			@NivelPadre,
			'Archivo general',
			GETDATE(),
			@CreadoPor,
			@Bucket,
			@Folder,
			UPPER(@UUIDAmazon),
			@NombreArchivo,
			@Meta,
			@SizeBytes,
			@ContratoId,
			1)

		SELECT SCOPE_IDENTITY() AS DocumentoId

 END
GO


