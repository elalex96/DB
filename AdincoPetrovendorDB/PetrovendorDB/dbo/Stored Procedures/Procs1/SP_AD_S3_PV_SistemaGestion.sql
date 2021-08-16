if exists (select * from sys.procedures where name = 'SP_AD_S3_PV_SistemaGestion')
begin
	drop proc SP_AD_S3_PV_SistemaGestion
end

go
-- =============================================
-- Author:		Daniel AC
-- Create date: 26/09/2019
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE  PROCEDURE[dbo].[SP_AD_S3_PV_SistemaGestion] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),

	@IdDocumento INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL,	
	@NombreDocumento NVARCHAR(MAX)=NULL,
	@Bucket nvarchar(max)
AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN
		
		  SELECT TOP 50 IdSistemaGestion,	      
		  		 ISNULL(NombreCertificacion,(CONCAT('Documento',IdSistemaGestion)))
		  FROM dbo.PV_SistemaGestion
		  WHERE Identificador IS NULL AND LEN(Documento)>0
		  ORDER BY IdSistemaGestion ASC		   
		
		END 

		IF @ACCION ='CONSULTAR_DOCUMENTO'
		BEGIN

	     SELECT Documento 
		 FROM dbo.PV_SistemaGestion
		 WHERE IdSistemaGestion = @IdDocumento 

		END 
				
		 		
		IF @ACCION ='ACTUALIZAR'
		BEGIN 
			BEGIN TRAN tran1;
			BEGIN TRY
			
			  UPDATE dbo.PV_SistemaGestion
			  SET 
			  Mime=@Mime,
			  Extension=@Extension,
			  Identificador=@IdentificadorS3,
			  Carpeta=@Carpeta,
			  AMS3=1,
			  Bucket = @Bucket 
			  WHERE IdSistemaGestion=@IdDocumento

		    COMMIT TRAN tran1;
			END TRY
			BEGIN CATCH
				ROLLBACK TRAN tran1;					
				SELECT 'ERROR_PROCESO',
					   ERROR_NUMBER() AS ErrorNumber,
					   ERROR_SEVERITY() AS ErrorSeverity,
					   ERROR_STATE() AS ErrorState,
					   ERROR_PROCEDURE() AS ErrorProcedure,
					   ERROR_LINE() AS ErrorLine,
					   ERROR_MESSAGE() AS ErrorMessage;
			END CATCH;
	    END  

END
