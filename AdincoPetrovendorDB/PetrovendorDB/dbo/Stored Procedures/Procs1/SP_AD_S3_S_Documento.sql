-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x 
create PROCEDURE[dbo].[SP_AD_S3_S_Documento] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),

	@IdDocumento INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL,	
	@NombreDocumento NVARCHAR(MAX)=NULL
	
AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN

		  SELECT  TOP 40
		  D.IdDocumento, --0
		  '' AS Documento, --1
		  CONCAT(TD.NombreTipoDocumento, ' ',D.IdDocumento,'.pdf') AS NombreTipoDocumento, --2
		  D.IdTipoDocumento --3
		  FROM dbo.S_Documento D	
		  INNER JOIN dbo.S_TipoDocumento TD ON TD.IdTipoDocumento = D.IdTipoDocumento		  		
	      WHERE IdDocumentoS3 IS NULL 
		  ORDER BY D.IdDocumento ASC


		END 

		IF @ACCION ='CONSULTAR_DOCUMENTO'
		BEGIN

		  SELECT  D.Documento AS Documento		 
		  FROM dbo.S_Documento D
		  WHERE D.IdDocumento = @IdDocumento	 		


		END 

		IF @ACCION ='CONSULTAR_ELIMINAR'
		BEGIN

		  SELECT  		   		
		  D.Identificador, 
		  D.Duplicado 
		  FROM dbo.S_Documento_S3 D	
		  INNER JOIN dbo.S_TipoDocumento TD ON TD.IdTipoDocumento = D.IdTipoDocumento		  		
	      WHERE D.Duplicado IS NOT NULL AND D.IdDocumento NOT IN (1338,1362)
		  ORDER BY D.IdDocumento ASC


		END 
		 		
		IF @ACCION ='ACTUALIZAR'
		BEGIN 
			BEGIN TRAN tran1;
			BEGIN TRY

			 /*DESACTIVAR EL IDENTITY */
			 SET IDENTITY_INSERT dbo.S_Documento_S3 ON


				INSERT INTO dbo.S_Documento_S3
				(   IdDocumento,IdTipoDocumento,IdUsuario,IdTipoValidacionDocumento,IdProveedor,Activo,Documento,CreadoPor,CreadoEl,ModificadoPor,
				    ModificadoEl,Descripcion,Carpeta,Identificador,Mime,Extension,NombreDocumento,Duplicado)
				
				SELECT IdDocumento, IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, '', CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, Descripcion,
				@Carpeta, @IdentificadorS3, @Mime, @Extension, @NombreDocumento, CAST(@IdDocumento AS NVARCHAR(40))
				FROM dbo.S_Documento 
				WHERE IdDocumento=@IdDocumento

				DECLARE @NUEVO_IdDocumentoS3 INT = (SELECT @@IDENTITY)

				UPDATE dbo.S_Documento
				SET IdDocumentoS3 =@NUEVO_IdDocumentoS3			
				WHERE IdDocumento= @IdDocumento


				COMMIT TRAN tran1;
				/*ACTIVAR EL IDENTITY*/
				SET IDENTITY_INSERT dbo.S_Documento_S3  OFF
				SELECT 'SUCCESS'

			END TRY
			BEGIN CATCH
				ROLLBACK TRAN tran1;
				/*ACTIVAR EL IDENTITY*/
				SET IDENTITY_INSERT dbo.S_Documento_S3  OFF
				SELECT 'ERROR_PROCESO',
					   ERROR_NUMBER() AS ErrorNumber,
					   ERROR_SEVERITY() AS ErrorSeverity,
					   ERROR_STATE() AS ErrorState,
					   ERROR_PROCEDURE() AS ErrorProcedure,
					   ERROR_LINE() AS ErrorLine,
					   ERROR_MESSAGE() AS ErrorMessage;
			END CATCH;
	    END  


	IF @ACCION ='CONSULTAR_NOMBRE_AP'
	BEGIN 
		
		 SELECT D.IdDocumento,
		 CASE WHEN AD.NombreDocumento IS NULL THEN 
			CONCAT(TD.NombreTipoDocumento,CAST(D.IdDocumento AS NVARCHAR(MAX)), '.pdf')
			ELSE
			AD.NombreDocumento
		 END AS NombreDocumento
		 FROM dbo.S_Documento D	
		 INNER JOIN dbo.S_TipoDocumento TD ON TD.IdTipoDocumento = D.IdTipoDocumento	
		 LEFT JOIN dbo.MM_AceptacionDocumento AD ON AD.IdDocumento = D.IdDocumento	  		
	     WHERE D.IdDocumento = @IdDocumento AND D.IdTipoDocumento =12 --> ACEPTACION PEDIDO 
			
	END 
	
	
END