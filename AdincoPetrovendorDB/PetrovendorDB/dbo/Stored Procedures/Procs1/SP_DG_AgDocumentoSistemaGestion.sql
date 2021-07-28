if exists (select * from sys.procedures where name = 'SP_DG_AgDocumentoSistemaGestion')
begin
	drop proc SP_DG_AgDocumentoSistemaGestion
end

go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <30/052017>
-- Description:	<Procedimiento para insertar un documento en especidico(INE, RCF, ACTA CONSTITUTIVA) en la tabla S_Documento>
-- =============================================
-- =============================================
-- Author: Daniel AC
-- Create date: 26-09-2019
-- Description: Add refencias s3 
-- =============================================
CREATE PROCEDURE[dbo].[SP_DG_AgDocumentoSistemaGestion] 

	-- Insertar Documento nuevo---
	@IdProveedor                 int,
	@IdTipoDocSG                 int,
	@Documento                   nvarchar(MAX),
	@NombreCertificacion		 nvarchar(MAX),
	@CasaCerficadora             nvarchar(200),
    @NoDeCertificado             NVARCHAR(MAX),
	@FechaEmisionCertificado     datetime,
	@FechaVigenciaInicio         datetime,
    @FechaVigenciaTermino        datetime,
    @MetodosProcesosCertificados nvarchar(500),
    @Carpeta						NVARCHAR(MAX),
	@Mime							NVARCHAR(MAX),
	@Extension						NVARCHAR(MAX),
	@Identificador					NVARCHAR(MAX),
	@bucket							NVARCHAR(MAX)
AS

BEGIN

	INSERT INTO [dbo].[PV_SistemaGestion]
         (
			IdProveedor,
			IdTipoDocSG,
			Documento,
			Activo,
			NombreCertificacion,
			CasaCertificadora,
			NoDeCertificado,
			FechaEmisionCertificado,
			FechaVigenciaInicio,
			FechaVigenciaTermino,
			MetodosProcesosCertificados,
			Carpeta,
			Mime,
			Extension,
			Identificador,
			Bucket
         )
         VALUES
         (
			 @IdProveedor,
			 @IdTipoDocSG,
			 @Documento,
			 1,
			 @NombreCertificacion,
			 @CasaCerficadora,            
			 @NoDeCertificado,           
			 @FechaEmisionCertificado,    
			 @FechaVigenciaInicio,         
			 @FechaVigenciaTermino,        
			 @MetodosProcesosCertificados,
			 @Carpeta,
			 @Mime,
			 @Extension,
			 @Identificador,
			 @bucket
         )
		 IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
END