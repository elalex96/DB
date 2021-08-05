USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_DEA_Documento_AgregarReferencia
GO

-- =============================================
-- Author:		Daniel AC
-- Create date: 27/04/2018
-- Description:	Agregar referencia a  documentos 
-- =============================================
-- Author:		LUIS DAVID DE LA CRUZ
-- Update date: 02/08/2021
-- Description:	SE AGREGA LA COLUMNA BUCKET
-- =============================================
CREATE  PROCEDURE[dbo].[SP_DEA_Documento_AgregarReferencia] 
	-- Add the parameters for the stored procedure here
	
	@IdTipoDocumento INT, 
	@IdProveedor INT,
	@IdUsuario INT,
	

	@Mime NVARCHAR(MAX),
	@Carpeta NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),	
	@NombreDocumento NVARCHAR(MAX),
	@Descripcion NVARCHAR(MAX),
	@SizeDocumento FLOAT,
	@IdDocumentoTabla INT ,
	@Bucket VARCHAR(200) = NULL

AS
	
BEGIN				
	
   INSERT INTO dbo.DEA_Documento_S3   
   (
       IdTipoDocumento,         
       IdProveedor,
       Activo,       
       CreadoPor,
       CreadoEl,     
       Descripcion,
       Carpeta,
       Identificador,
       Mime,
       Extension,
       NombreDocumento,
       SizeDocumento,
	   IdDocumentoTabla,
	   Bucket
   )
   VALUES
   (   @IdTipoDocumento,         -- IdTipoDocumento - int      
       @IdProveedor,         -- IdProveedor - int
       1,      -- Activo - bit    
       @IdUsuario,         -- CreadoPor - int
       GETDATE(), -- CreadoEl - datetime      
       @Descripcion,       -- Descripcion - nvarchar(max)
       @Carpeta,       -- Carpeta - nvarchar(max)
       @Identificador,       -- Identificador - nvarchar(max)
       @Mime,       -- Mime - nvarchar(max)
       @Extension,       -- Extension - nvarchar(max)
       @NombreDocumento,       -- NombreDocumento - nvarchar(max)
       @SizeDocumento,        
	   @IdDocumentoTabla,  -- IdDocumentoIdTabla - int
	   @Bucket
      )

	  SELECT @@IDENTITY AS IdDocumento

END
