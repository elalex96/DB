if exists(select * from sys.procedures where name = 'SP_AD_S3_Pv_DocSoporte_CompraDirecta')
begin
	drop proc SP_AD_S3_Pv_DocSoporte_CompraDirecta
end

go
-- =============================================
-- Author:		Daniel AC
-- Create date: 26/09/2019
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
CREATE  PROCEDURE[dbo].[SP_AD_S3_Pv_DocSoporte_CompraDirecta] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),

	@IdDocumento INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL,	
	@NombreDocumento NVARCHAR(MAX)=NULL,
	@Bucket NVARCHAR(MAX)=NULL
AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN
		
		  SELECT TOP 50 id,		        
		  		 ISNULL(nombreArchivo,(CONCAT('Documento',id)))
		  FROM dbo.Pv_DocSoporte_CompraDirecta
		  WHERE Identificador IS NULL AND LEN(documento)>0
		  ORDER BY id ASC		   
		
		END 

		IF @ACCION ='CONSULTAR_DOCUMENTO'
		BEGIN

	     SELECT documento 
		 FROM dbo.Pv_DocSoporte_CompraDirecta
		 WHERE id =@IdDocumento 

		END 
				
		 		
		IF @ACCION ='ACTUALIZAR'
		BEGIN 
			BEGIN TRAN tran1;
			BEGIN TRY
			
			  UPDATE dbo.Pv_DocSoporte_CompraDirecta
			  SET 
			  Mime=@Mime,
			  Extension=@Extension,
			  Identificador=@IdentificadorS3,
			  Carpeta=@Carpeta,
			  AMS3=1,
			  Bucket = @Bucket
			  WHERE id=@IdDocumento

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


