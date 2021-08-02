USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PV_EditarPerfilEmpresa_S3'
)
    DROP PROCEDURE SP_PV_EditarPerfilEmpresa_S3;
/****** Object:  StoredProcedure [dbo].[SP_PV_EditarPerfilEmpresa_S3]    Script Date: 26/07/2021 05:06:29 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	Actualización de Documentos de S3
-- =============================================
-- ============================================= 
-- Author:        Daniel Cruz
-- Create date:	  26-07-21
-- Description:   Se agrega columna de Bucket
-- ============================================= 
CREATE  PROCEDURE [dbo].[SP_PV_EditarPerfilEmpresa_S3] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdUsuario int, 
@DocumentoCurriculum nvarchar(max),
@DocumentoOrganigrama nvarchar(max), 
@IdGiroEmpresarial int,
@NumeroExperiencia int,
@IdPerfilEmpresa INT,

/*PARAMETROS DE DOCUMENTOS*/
@Curriculum_NOMBREDOCUMENTO nvarchar(max),
@Curriculum_MIME nvarchar(max),
@Curriculum_EXTENSION nvarchar(max),
@Curriculum_CARPETA nvarchar(max),
@Curriculum_IDENTIFICADOR nvarchar(max),
@Curriculum_BUCKET nvarchar(max),
@Organigrama_NOMBREDOCUMENTO nvarchar(max),
@Organigrama_MIME nvarchar(max),
@Organigrama_EXTENSION nvarchar(max),
@Organigrama_CARPETA nvarchar(max),
@Organigrama_IDENTIFICADOR nvarchar(max),
@Organigrama_BUCKET nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
	 DECLARE @IdCurriculum int
     DECLARE @IdOrganigrama int

	 
	 SET @IdOrganigrama =  (SELECT [IdDocumentoOrganigrama]
						  FROM [dbo].[PV_PerfilEmpresa] 
						  WHERE [IdPerfilEmpresa]=@IdPerfilEmpresa)

	SET @IdCurriculum =  (SELECT [IdDocumentoCurriculum]
						  FROM [dbo].[PV_PerfilEmpresa] 
						  WHERE [IdPerfilEmpresa]=@IdPerfilEmpresa)

	IF @IdOrganigrama IS NULL
	BEGIN 
		INSERT INTO S_Documento_S3(
		[IdTipoDocumento],
		[IdProveedor],[Activo],
		[Documento],
		[CreadoPor],
		[Mime],
		[Carpeta],
		[Extension],
		[Identificador],
		[NombreDocumento],
		[CreadoEl],
		[Bucket])
		VALUES (
		20, ---> ORGANIGRAMA S_TipoDocumento
		@IdProveedor,
		1, 
		@DocumentoOrganigrama,
		@IdUsuario,
		@Organigrama_MIME,
		@Organigrama_CARPETA,
		@Organigrama_EXTENSION,
		@Organigrama_IDENTIFICADOR,
		@Organigrama_NOMBREDOCUMENTO,
		GETDATE(),
		@Organigrama_BUCKET
		)
		SET @IdOrganigrama = (SELECT @@IDENTITY)
	END 
	ELSE
	BEGIN
		UPDATE S_Documento_S3
		SET [Documento]=@DocumentoOrganigrama,
		[ModificadoPor] = @IdUsuario,
		[ModificadoEl] = GETDATE(),
		[Mime]=@Organigrama_MIME,
		[Carpeta]=@Organigrama_CARPETA,
		[Extension]=@Organigrama_EXTENSION,
		[Identificador]=@Organigrama_IDENTIFICADOR,
		[NombreDocumento]=@Organigrama_NOMBREDOCUMENTO,
		[Bucket] = @Organigrama_BUCKET
		WHERE [IdDocumento]=@IdOrganigrama

		
	END 


	IF @IdCurriculum IS NULL
	BEGIN 
		INSERT INTO S_Documento_S3(
		[IdTipoDocumento],
		[IdProveedor],
		[Activo], 
		[Documento],
		[CreadoPor],
		[Mime],
		[Carpeta],
		[Extension],
		[Identificador],
		[NombreDocumento],
		[Bucket])
		VALUES (
		19, --> S_TipoDocumento / curriculum
		@IdProveedor,
		1,
		@DocumentoCurriculum,
		@IdUsuario,
		@Curriculum_MIME,
		@Curriculum_CARPETA,
		@Curriculum_EXTENSION,
		@Curriculum_IDENTIFICADOR,
		@Curriculum_NOMBREDOCUMENTO,
		@Curriculum_BUCKET)

		SET @IdCurriculum = (SELECT @@IDENTITY)
	END 
	ELSE
	BEGIN
		UPDATE S_Documento_S3 
		SET [Documento]=@DocumentoCurriculum,
		[ModificadoPor] = @IdUsuario,
		[ModificadoEl] = GETDATE(),
		[Mime]=@Curriculum_MIME,
		[Carpeta]=@Curriculum_CARPETA,
		[Extension]=@Curriculum_EXTENSION,
		[Identificador]=@Curriculum_IDENTIFICADOR,
		[NombreDocumento]=@Curriculum_NOMBREDOCUMENTO,
		[Bucket] = @Curriculum_BUCKET
		WHERE [IdDocumento]=@IdCurriculum

		
	END 


	UPDATE [dbo].[PV_PerfilEmpresa]
	SET [IdGiroEmpresaria]=@IdGiroEmpresarial ,
	[AniosExperiencia]=@NumeroExperiencia,
	[IdDocumentoOrganigrama]=@IdOrganigrama,
	[IdDocumentoCurriculum]=@IdCurriculum,
	[EditadoPor]=@IdUsuario,
	[EditadoEl]=GETDATE()
	WHERE [IdPerfilEmpresa]=@IdPerfilEmpresa


	SELECT 'UPDATE SUCCESS'
END