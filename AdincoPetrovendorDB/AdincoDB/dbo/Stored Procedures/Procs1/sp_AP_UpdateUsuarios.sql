-- =============================================  
-- Author:  Oscar Mtz  
-- Create date: 30/06/2017  
-- Description: Actualiza la tabla AP_Usuario.  
-- =============================================  
CREATE PROCEDURE dbo.sp_AP_UpdateUsuarios  
@UsuarioID as int,  
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
  
  UPDATE [dbo].[AP_Usuario]  
     SET   
      [Usuario] = @Usuario  
     ,[Contraseña] = @Contraseña  
     ,[Nombre] = @Nombre  
     ,[IsActivo] = @IsActivo  
     --,[fchRegistro] = @fchRegistro  
     ,[IsEliminado] = @IsEliminado  
     ,[imgsrc] = @imgsrc  
     ,[image] = @image  
     --,[UltimoAcceso] = @UltimoAcceso  
     ,[Idioma] = @Idioma  
     ,[CreadoPor] = @CreadoPor  
     ,[Sello] = @Sello  
   WHERE [dbo].[AP_Usuario].UsuarioID = @UsuarioID AND ISNULL(IsGrupo,0)=0; 
   
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