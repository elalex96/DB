-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	CONSULTAR PERFIL DETALLE S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarPerfilEmpresa_S3] 
	-- Add the parameters for the stored procedure here
	---SP_PV_ConsultarPerfilEmpresa 420,
@IdProveedor int,
@IdUsuario int 
 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
 DECLARE @DocumentoCurriculum NVARCHAR(MAX)
 DECLARE @DocumentoOrganigrama NVARCHAR(MAX)
 DECLARE @AniosExperiencia int
 DECLARE @Disciplina int
 DECLARE @ExistePerfil int
 DECLARE @NombreEmpresa NVARCHAR(MAX)

 /*NUEVOS PARAMETROS*/
 DECLARE @CurriculumExtension NVARCHAR(MAX)
 DECLARE @CurriculumMime NVARCHAR(MAX)
 DECLARE @CurriculumCarpeta NVARCHAR(MAX)
 DECLARE @OrganigramaExtension NVARCHAR(MAX)
 DECLARE @OrganigramaMime NVARCHAR(MAX)
 DECLARE @OrganigramaCarpeta NVARCHAR(MAX)

    SELECT @DocumentoOrganigrama=D.Identificador, @OrganigramaCarpeta= D.Carpeta, @OrganigramaMime=D.Mime, @OrganigramaExtension=D.Extension
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = PE.IdDocumentoOrganigrama
	WHERE PE.IdProveedor = @IdProveedor  AND D.Activo=1

    SELECT @DocumentoCurriculum=D.Identificador, @CurriculumCarpeta= D.Carpeta,@CurriculumMime=D.Mime, @CurriculumExtension=D.Extension
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = PE.IdDocumentoCurriculum
	WHERE PE.IdProveedor = @IdProveedor AND D.Activo=1
	 
	SET @NombreEmpresa = (SELECT P.RazonSocial+' '+P.RegimenCapital
						   FROM S_Proveedor AS P
						   WHERE P.IdProveedor = @IdProveedor)

	SET @ExistePerfil = (SELECT  COUNT(IdPerfilEmpresa)
	FROM PV_PerfilEmpresa AS PE
	WHERE PE.IdProveedor =@IdProveedor)



	IF @ExistePerfil>0
		BEGIN 
			SELECT  
			[IdPerfilEmpresa],--0
			ISNULL([IdGiroEmpresaria],0),--1
			ISNULL([AniosExperiencia],0),--2
			ISNULL(@DocumentoOrganigrama,''),--3
			ISNULL(@DocumentoCurriculum,''),--4
			'Organigrama '+ @NombreEmpresa+'.pdf' AS Organigrama,--5
			'Curriculum '+ @NombreEmpresa+'.pdf' AS Curriculum,--6
			ISNULL(@OrganigramaCarpeta,''),--7
			ISNULL(@OrganigramaExtension,''),--8
			ISNULL(@OrganigramaMime,''),--9
			ISNULL(@CurriculumCarpeta,''),--10
			ISNULL(@OrganigramaExtension,''),--11
			ISNULL(@CurriculumMime,'')--12
			FROM PV_PerfilEmpresa AS PE
			WHERE PE.IdProveedor = @IdProveedor 
		END 
	ELSE
		BEGIN 

			INSERT INTO PV_PerfilEmpresa([CreadoPor],[CreadoEl],[IdProveedor],[Activo])
			VALUES(@IdUsuario, GETDATE(),@IdProveedor, 1)

			SELECT  [IdPerfilEmpresa],--0
			ISNULL([IdGiroEmpresaria],0),--1
			ISNULL([AniosExperiencia],0),--2
			ISNULL(@DocumentoOrganigrama,''),--3
			ISNULL(@DocumentoCurriculum,''),--4
			'Organigrama no cargado',--5
			'Curriculum no cargado',--6
			ISNULL(@OrganigramaCarpeta,''),--7
			ISNULL(@OrganigramaExtension,''),--8
			ISNULL(@OrganigramaMime,''),--9
			ISNULL(@CurriculumCarpeta,''),--10
			ISNULL(@OrganigramaExtension,''),--11
			ISNULL(@OrganigramaMime,'')--12
			FROM PV_PerfilEmpresa AS PE
			INNER JOIN S_Proveedor AS P ON P.IdProveedor = PE.IdProveedor
			WHERE PE.IdProveedor = @IdProveedor 

		END 
END