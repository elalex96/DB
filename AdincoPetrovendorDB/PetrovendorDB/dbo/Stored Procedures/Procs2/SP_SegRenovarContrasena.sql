
-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================       
ALTER PROCEDURE [dbo].[SP_SegRenovarContrasena]    
-- Add the parameters for the stored procedure here    
@idusuario  INT            = NULL, 
@Pass       VARBINARY(MAX) = NULL, 
@Salt       VARBINARY(MAX) = NULL, 
@contrasena VARCHAR(50)    = NULL
AS
    BEGIN
        DECLARE @respuesta BIT= 1;    
        -- SET NOCOUNT ON added to prevent extra result sets from    
        -- interfering with SELECT statements.    
        SET NOCOUNT ON;
        IF @contrasena IS NULL
            BEGIN
                UPDATE dbo.AP_Usuario
                  SET 
                      Pass = @Pass, 
                      Salt = @Salt
                WHERE UsuarioID = @idusuario
                      AND ISNULL(IsGrupo, 0) = 0;   
                --    
                SELECT Usuario
                FROM AP_Usuario
                WHERE UsuarioID = @idusuario
                      AND IsActivo = 1
                      AND ISNULL(IsGrupo, 0) = 0;
        END;
            ELSE
            BEGIN
                UPDATE dbo.S_Usuario
                  SET 
                      Contrasena = @contrasena
                WHERE IdUsuario = @idusuario;
                SELECT Correo
                FROM S_Usuario
                WHERE IdUsuario = @idusuario
                      AND Activo = 1;
        END;
    END;
