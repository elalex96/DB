

-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarPerfilEmpresa] 
	-- Add the parameters for the stored procedure here
	---SP_PV_ConsultarPerfilEmpresa 420,
@IdProveedor int,
@IdUsuario int 
 
---SP_PV_ConsultarDistribuidorAutorizadoDe 2
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
 DECLARE @DocumentoCurriculum NVARCHAR(MAX)
 DECLARE @DocumentoOrganigrama NVARCHAR(MAX)
 DECLARE @AniosExperiencia int
 DECLARE @Disciplina int
 DECLARE @ExistePerfil int
 DECLARE @NombreEmpresa NVARCHAR(MAX)
	   
SET @DocumentoOrganigrama =(SELECT Documento
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN S_Documento AS D ON D.IdDocumento = PE.IdDocumentoOrganigrama
	WHERE PE.IdProveedor = @IdProveedor  AND D.Activo=1)

SET @DocumentoCurriculum =(SELECT Documento
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN S_Documento AS D ON D.IdDocumento = PE.IdDocumentoCurriculum
	WHERE PE.IdProveedor = @IdProveedor AND D.Activo=1)
	 
	SET @NombreEmpresa = (SELECT P.RazonSocial+' '+P.RegimenCapital
						   FROM S_Proveedor AS P
						   WHERE P.IdProveedor = @IdProveedor)

	SET @ExistePerfil = (SELECT  COUNT(IdPerfilEmpresa)
	FROM PV_PerfilEmpresa AS PE
	WHERE PE.IdProveedor =@IdProveedor)



	IF @ExistePerfil>0
		BEGIN 
			SELECT  
			[IdPerfilEmpresa],
			ISNULL([IdGiroEmpresaria],0),
			ISNULL([AniosExperiencia],0),
			ISNULL(@DocumentoOrganigrama,''),
			ISNULL(@DocumentoCurriculum,''),
			'Organigrama '+ @NombreEmpresa+'.pdf' AS Organigrama,
			'Curriculum '+ @NombreEmpresa+'.pdf' AS Curriculum
			FROM PV_PerfilEmpresa AS PE
			WHERE PE.IdProveedor = @IdProveedor 
		END 
	ELSE
		BEGIN 

			INSERT INTO PV_PerfilEmpresa([CreadoPor],[CreadoEl],[IdProveedor],[Activo])
			VALUES(@IdUsuario, GETDATE(),@IdProveedor, 1)

			SELECT  [IdPerfilEmpresa],
			ISNULL([IdGiroEmpresaria],0),
			ISNULL([AniosExperiencia],0),
			ISNULL(@DocumentoOrganigrama,''),
			ISNULL(@DocumentoCurriculum,''),
			'Organigrama no cargado',
			'Curriculum no cargado'
			FROM PV_PerfilEmpresa AS PE
			INNER JOIN S_Proveedor AS P ON P.IdProveedor = PE.IdProveedor
			WHERE PE.IdProveedor = @IdProveedor 

		END 
END
 
