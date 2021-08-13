if exists (select * from sys.procedures where name = 'SP_AD_S3_MM_SolPedArchivoAdjuntoMaterial')
begin
	drop proc SP_AD_S3_MM_SolPedArchivoAdjuntoMaterial
end

go
-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE PROCEDURE[dbo].[SP_AD_S3_MM_SolPedArchivoAdjuntoMaterial] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),
	@IdSolPedMaterialDocumentoAdj INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL,
	@bucket	nvarchar(max) = null
AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN

		  SELECT TOP 50 IdSolPedMaterialDocumentoAdj,ISNULL(ArchivoAdjuntoMaterial,''), ISNULL(NombreArchivoAdjunto,'')  
		  FROM dbo.MM_SolPedArchivoAdjuntoMaterial WHERE Identificador IS NULL
		  ORDER BY IdSolPedMaterialDocumentoAdj DESC
		 
		END 

		IF @ACCION ='ACTUALIZAR'
		BEGIN
			UPDATE MM_SolPedArchivoAdjuntoMaterial
			SET Mime =@Mime,
			Carpeta=@Carpeta,
			Identificador=@IdentificadorS3,
			Extension=@Extension,
			Bucket=@bucket
			WHERE IdSolPedMaterialDocumentoAdj= @IdSolPedMaterialDocumentoAdj

			SELECT 'SUCCES' 
		END 
END

