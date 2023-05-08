-- =============================================  
-- Author:  Oscar Mtz  
-- Create date: 03/07/2017  
-- Description: Obtiene la cadena sello del usuario.  
-- =============================================  
-- [sp_AP_ObtenerUsuario] 4,4  
CREATE PROCEDURE [dbo].[sp_AP_ObtenerUsuario] -- '10061',10061
--  
@pUsuarioID     VARCHAR(200),   
@pUsuarioSesion INT          = @pUsuarioID  
--  
AS  
     BEGIN  
         SELECT TOP 1 u.[Usuario],   
                      [Contrasenia] = '', --u.Contraseña,  
                      [Nombre] = u.[Nombre],   
                      [IsActivo] = u.[IsActivo],   
                      [fchRegistro] = u.[fchRegistro],   
                      [IsEliminado] = u.[IsEliminado],   
                      [imgsrc] = u.[imgsrc],   
                      [image] = u.[image],   
                      [UltimoAcceso] = u.[UltimoAcceso],   
                      [Idioma] = u.[Idioma],   
                      [CreadoPor] = u.[CreadoPor],   
                      [Sello] = u.[Sello],   
                      [UsuarioID] = u.[UsuarioID],   
                      --Foto=Null,                       
					  Foto = u.Foto,   
                      Ruta = u.idRuta  
         FROM AP_Usuario u  
              --  
              INNER JOIN ap_usuario u2 ON u2.UsuarioID = @pUsuarioSesion  
              INNER JOIN ap_perfilusuario pu ON pu.UsuarioID = u2.UsuarioID  
              INNER JOIN ap_perfil p ON p.IdPerfil = pu.PerfilID  
  
              --   
              INNER JOIN ap_perfilusuario pu3 ON pu3.UsuarioID = u.UsuarioID  
              INNER JOIN ap_perfil p3 ON p3.IdPerfil = pu3.PerfilID  
                                         AND p3.IdContrato = p.IdContrato  
         WHERE u.[UsuarioID] = @pUsuarioID AND ISNULL(U.IsGrupo,0)=0;
     END;