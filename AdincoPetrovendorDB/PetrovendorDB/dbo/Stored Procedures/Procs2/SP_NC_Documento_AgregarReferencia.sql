-- =============================================  
-- Author:  Daniel AC  
-- Create date: 27/04/2018  
-- Description: Agregar referencia a  documentos   
-- =============================================  
-- Author:		Daniel Cruz
-- Create date: 28-07-2021
-- Description:	Se agrega parametro de bucket
-- ============================================= 
CREATE  PROCEDURE[dbo].[SP_NC_Documento_AgregarReferencia]   
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
 @IdDocumentoTabla INT,   
 @Bucket NVARCHAR(MAX)
  
AS  
   
BEGIN      
   
   INSERT INTO dbo.S_Documento_S3  
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
	   IdDocumentoTabla ,
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
  