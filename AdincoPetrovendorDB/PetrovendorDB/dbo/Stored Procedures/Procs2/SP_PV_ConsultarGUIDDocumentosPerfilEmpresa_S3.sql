-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	CONSULTAR GUID DE DOCUMENTOS DE PERFIL DETALLE S3
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PV_ConsultarGUIDDocumentosPerfilEmpresa_S3] 
	-- Add the parameters for the stored procedure here
	---SP_PV_ConsultarPerfilEmpresa 420,
@IdProveedor int
 
---SP_PV_ConsultarDistribuidorAutorizadoDe 2
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
	 DECLARE @DocumentoCurriculum NVARCHAR(MAX)
	 DECLARE @DocumentoOrganigrama NVARCHAR(MAX)



    SELECT @DocumentoCurriculum=D.Identificador
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = PE.IdDocumentoCurriculum
	WHERE PE.IdProveedor = @IdProveedor  AND D.Activo=1

    SELECT @DocumentoOrganigrama=D.Identificador
	FROM PV_PerfilEmpresa AS PE
	INNER JOIN dbo.S_Documento_S3 AS D ON D.IdDocumento = PE.IdDocumentoOrganigrama
	WHERE PE.IdProveedor = @IdProveedor AND D.Activo=1

	
	SELECT ISNULL(@DocumentoCurriculum,'')AS GUID_CURRICULUM, ISNULL(@DocumentoOrganigrama,'') AS GUID_ORGANIGRAMA

END