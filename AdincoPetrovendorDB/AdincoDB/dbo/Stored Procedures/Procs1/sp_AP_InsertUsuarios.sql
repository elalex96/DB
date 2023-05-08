-- =============================================  
-- Author:  Oscar Mtz  
-- Create date: 30/06/2017  
-- Description: Inserta en la tabla AP_Usuario.  
-- =============================================  
CREATE PROCEDURE [dbo].[sp_AP_InsertUsuarios]  
@Usuario as varchar(150),  
@Contraseña as varchar(200),  
@Nombre as varchar(200),  
@IsActivo as bit,  
@IsEliminado as bit,  
@imgsrc as varchar(200),  
@image as varbinary(max) = null,  
@Idioma as int,  
@CreadoPor as int,  
@Sello varchar(20)  
AS  
BEGIN   
DECLARE @RowAffected as int;  
SET NOCOUNT ON;  
 BEGIN TRY  
  
  INSERT INTO [dbo].[AP_Usuario]  
   ([Usuario]  
   ,[Contraseña]  
   ,[Nombre]  
   ,[IsActivo]  
   ,[fchRegistro]  
   ,[IsEliminado]  
   ,[imgsrc]  
   ,[image]  
   ,[UltimoAcceso]  
   ,[Idioma]  
   ,[CreadoPor]  
   ,[Sello],
   [IsGrupo] 
   )  
  VALUES       
   (@Usuario  
   ,@Contraseña  
   ,@Nombre  
   ,@IsActivo  
   ,GETDATE()  
   ,@IsEliminado  
   ,@imgsrc  
   ,@image  
   ,GETDATE()  
   ,@Idioma  
   ,@CreadoPor  
   ,@Sello,
   0 
   )     
   
   --Filas afectadas.  
   SELECT @RowAffected = @@ROWCOUNT  
   SELECT @RowAffected as FilasAfectadas;  
 END TRY  
  BEGIN CATCH  
   SELECT     
    ERROR_NUMBER() AS NumeroError    
    --,ERROR_SEVERITY() AS ErrorSeverity    
    --,ERROR_STATE() AS ErrorState    
    ,ERROR_PROCEDURE() AS ProcedimientoError    
    ,ERROR_LINE() AS LineaError    
    ,ERROR_MESSAGE() AS MensajeError;     
  END CATCH  
END