-- Stored Procedure  
-- =============================================  
-- Author:  Miguel Gomez  
-- Create date:   
-- Description:   
-- =============================================  
-- Author:  Marcos Garcia  
-- Alter date: 17-02-2020  
-- Description: Modificar Para solo UsuarioID   
-- =============================================  
CREATE PROCEDURE [dbo].[sp_AP_ValidaUsuario]   
 -- Add the parameters for the stored procedure here  
@UsuarioID    INT=0  
--@Contrasena NVARCHAR(MAX) = 0  
AS  
         BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
             SET NOCOUNT ON;  
  
    -- Insert statements for procedure here  
             SELECT usuarioid,  
                    Usuario,  
                    Contraseña,  
                    Nombre,  
                    IsActivo,  
                    fchRegistro,  
                    IsEliminado,  
                    imgsrc,  
                    UltimoAcceso,  
                    Idioma,  
                    CreadoPor,  
                    IdTipoUsuario,  
                    Sello,  
                    image,  
                    Foto,  
                    ModificadoPor,  
                    ModificadoEl,  
                    TFAuthentication,  
                    NumeroCelular,  
                    P.CodigoPais AS CodigoPais  
             FROM AP_Usuario U  
                  LEFT JOIN dbo.AP_Paises P ON U.CodigoPais = p.idPais  
             --WHERE(U.usuario = RTRIM(@Usuario))  
                  --AND (u.Contraseña = RTRIM(@Contrasena))  
     WHERE U.UsuarioID = @UsuarioID  
                  AND u.IsActivo = 1
				  AND ISNULL(IsGrupo,0)=0
         END;  