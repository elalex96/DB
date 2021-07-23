-- =============================================
-- Author:		DANIEL AC 
-- Update date: 08/05/2018
-- Description:	Cambio de refrencia de s_documento a s_documento_s3
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_PerfilEmpresaReport] --573
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 DECLARE @DocumentoCurriculum NVARCHAR(MAX)
 DECLARE @DocumentoOrganigrama NVARCHAR(MAX)
 DECLARE @NombreEmpresa NVARCHAR(MAX)
	   
SET @DocumentoOrganigrama =(SELECT '1'
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = PE.IdDocumentoOrganigrama
	WHERE PE.IdProveedor = @IdProveedor  AND D.Activo=1)

SET @DocumentoCurriculum =(SELECT '1'
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = PE.IdDocumentoCurriculum
	WHERE PE.IdProveedor = @IdProveedor AND D.Activo=1)
	 
	SET @NombreEmpresa = (SELECT P.RazonSocial+' '+P.RegimenCapital
						   FROM S_Proveedor AS P
						   WHERE P.IdProveedor = @IdProveedor)

	--SET @ExistePerfil = (SELECT  COUNT(IdPerfilEmpresa)
	--FROM PV_PerfilEmpresa AS PE
	--WHERE PE.IdProveedor =@IdProveedor)


			SELECT  
			[IdPerfilEmpresa],
			ISNULL([IdGiroEmpresaria],0) AS IdGiroEmpresa,
		    GE.GiroProveedor AS GiroEmpresa,
			GCP.GiroProovedor AS TipoActividad,
			GCH.GiroProovedor AS ActividadEspecifica,
			ISNULL([AniosExperiencia],0) AS AñosExperiencia,
			ISNULL(@DocumentoOrganigrama,'Sin documento') AS DocumentoOrganigrama,
			ISNULL(@DocumentoCurriculum,'Sin documento') AS DocumentoCurriculum,
			'Organigrama '+ @NombreEmpresa+'.pdf' AS Organigrama,
			'Curriculum '+ @NombreEmpresa+'.pdf' AS Curriculum
			FROM PV_PerfilEmpresa AS PE
			LEFT JOIN PV_GiroEmpresarial GE
			ON PE.IdGiroEmpresaria = GE.IdGiroProveedor
			LEFT JOIN PV_GiroComercialHijo GCH
			ON GE.PV_GiroComercialHijo = GCH.IdGiroProveedorHijo
			LEFT JOIN PV_GiroComercialPadre GCP
			ON GCH.IdGiroProveedorPadre = GCP.IdGiroProveedorPadre
			WHERE PE.IdProveedor = @IdProveedor 

END
