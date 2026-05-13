-- =============================================
-- Author:		Daniel AC
-- Create date: 26/09/2019
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE  PROCEDURE[dbo].[SP_AD_S3_CF_EdoCuentaDocumentos] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),
	@IdDocumento INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL,	
	@NombreDocumento NVARCHAR(MAX)=NULL,
	@Bucket nvarchar(MAX)=NULL
AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN
		
		  SELECT TOP 50 IdEdoCuenta,		        
		  		 ISNULL(NombreDoc,(CONCAT('Documento',IdEdoCuenta)))
		  FROM dbo.CF_EdoCuentaDocumentos
		  WHERE Identificador IS NULL AND LEN(EdoCuenta)>0
		  ORDER BY IdEdoCuenta ASC		   
		
		END 

		IF @ACCION ='CONSULTAR_DOCUMENTO'
		BEGIN

	     SELECT EdoCuenta 
		 FROM dbo.CF_EdoCuentaDocumentos
		 WHERE IdEdoCuenta =@IdDocumento 

		END 
				
		 		
		IF @ACCION ='ACTUALIZAR'
		BEGIN 
			BEGIN TRAN tran1;
			BEGIN TRY
			
			  UPDATE dbo.CF_EdoCuentaDocumentos
			  SET 
			  Mime=@Mime,
			  Extension=@Extension,
			  Identificador=@IdentificadorS3,
			  Carpeta=@Carpeta,
			  AMS3=1,
			  Bucket = @Bucket
			  WHERE IdEdoCuenta=@IdDocumento

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
