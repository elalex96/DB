-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	CONSULTAR LOS DOCUMENTOS DE LA TABLA x MM_DocumentosSolPed
CREATE PROCEDURE[dbo].[SP_AD_S3_MM_DocumentosSolPed] 
	-- Add the parameters for the stored procedure here
	@ACCION NVARCHAR(MAX),
	@IdDocumento INT = NULL,
	@Mime NVARCHAR(MAX)=NULL,
	@Carpeta NVARCHAR(MAX)=NULL,
	@Extension NVARCHAR(MAX)=NULL,
	@IdentificadorS3 NVARCHAR(MAX)=NULL

AS
	
BEGIN				

		
		IF @ACCION ='CONSULTAR'
		BEGIN		  

		  SELECT TOP 50 IdDocumento, ISNULL(Documento,''), ISNULL(NombreDoc,'')
		  FROM dbo.MM_DocumentosSolPed WHERE Identificador IS NULL
		  ORDER BY IdDocumento DESC
		 
		END 

		IF @ACCION ='ACTUALIZAR'
		BEGIN
			UPDATE MM_DocumentosSolPed
			SET Mime =@Mime,
			Carpeta=@Carpeta,
			Identificador=@IdentificadorS3,
			Extension=@Extension
			WHERE IdDocumento= @IdDocumento

			SELECT 'SUCCES' 
		END 
END