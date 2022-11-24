-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE  PROCEDURE[dbo].[SP_AD_S3_MM_DocumentosAnexos] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),

	@IdDocumento INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL,	
	@NombreDocumento NVARCHAR(MAX)=NULL,
	@bucket	 NVARCHAR(MAX)=NULL
AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN
		
		  SELECT TOP 50 IdDocumentoAnexo,		        
		  		 ISNULL(Nombre,(CONCAT('Documento',IdDocumentoAnexo)))
		  FROM dbo.MM_DocumentosAnexos
		  WHERE Identificador IS NULL 
		  ORDER BY IdDocumentoAnexo ASC		   
		
		END 

		IF @ACCION ='CONSULTAR_DOCUMENTO'
		BEGIN

	     SELECT Documento 
		 FROM dbo.MM_DocumentosAnexos
		 WHERE IdDocumentoAnexo = @IdDocumento 

		END 
				
		 		
		IF @ACCION ='ACTUALIZAR'
		BEGIN 
			BEGIN TRAN tran1;
			BEGIN TRY
			
			  UPDATE dbo.MM_DocumentosAnexos
			  SET 
			  Mime=@Mime,
			  Extension=@Extension,
			  Identificador=@IdentificadorS3,
			  Carpeta=@Carpeta,
			  AMS3=1,
			  bucket = @bucket
			  WHERE IdDocumentoAnexo=@IdDocumento

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