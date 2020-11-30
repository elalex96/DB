-- =============================================
-- Author:		
-- Create date: 03/07/20174
-- Description:	
-- =============================================
CREATE PROC [dbo].[p_ConsultaUsuarios] --10061
--
@pIdUsuario INT
--
AS
     BEGIN
         DECLARE @IsAdministradorRoot INT;

         /**/

         SELECT @IsAdministradorRoot = COUNT(PerfilID)
         FROM dbo.AP_PerfilUsuario
         WHERE UsuarioID = @pIdUsuario
               AND PerfilID = 128 --en pr

         /**/

         IF @IsAdministradorRoot > 0
             BEGIN
                 SELECT l.UsuarioID, 
                        l.Usuario, 
                        l.Contraseña, 
                        l.Nombre, 
                        l.IsActivo, 
                        l.fchRegistro, 
                        l.IsEliminado, 
                        l.imgsrc, 
                        l.UltimoAcceso, 
                        l.Idioma, 
                        l.CreadoPor, 
                        l.IdTipoUsuario, 
                        l.Sello, 
                        l.image, 
                         Foto = null,
                 --(
                 --    SELECT Foto
                 --    FROM ap_usuario s1
                 --    WHERE s1.UsuarioID = l.UsuarioID
                 --), 
                        l.ModificadoPor, 
                        l.ModificadoEl, 
                        l.TFAuthentication, 
                        l.NumeroCelular, 
                        l.CodigoPais, 
                        l.idRuta
                 FROM AP_Usuario l
                      INNER JOIN AP_PerfilUsuario pu2 ON pu2.UsuarioID = l.UsuarioID
					  WHERE	ISNULL(l.IsGrupo,0)	=	0
                 GROUP BY l.UsuarioID, 
                          l.Usuario, 
                          l.Contraseña, 
                          l.Nombre, 
                          l.IsActivo, 
                          l.fchRegistro, 
                          l.IsEliminado, 
                          l.imgsrc, 
                          l.UltimoAcceso, 
                          l.Idioma, 
                          l.CreadoPor, 
                          l.IdTipoUsuario, 
                          l.Sello, 
                          l.image,
                          --l.Foto,
                          l.ModificadoPor, 
                          l.ModificadoEl, 
                          l.TFAuthentication, 
                          l.NumeroCelular, 
                          l.CodigoPais, 
                          l.idRuta
                 ORDER BY l.IsActivo DESC, 
                          l.UsuarioID;
             END;

                 /**/

             ELSE

         /**/

             BEGIN
                 SELECT l.UsuarioID, 
                        l.Usuario, 
                        l.Contraseña, 
                        l.Nombre, 
                        l.IsActivo, 
                        l.fchRegistro, 
                        l.IsEliminado, 
                        l.imgsrc, 
                        l.UltimoAcceso, 
                        l.Idioma, 
                        l.CreadoPor, 
                        l.IdTipoUsuario, 
                        l.Sello, 
                        l.image, 
                        Foto = null,
                 --(
                 --    SELECT Foto
                 --    FROM ap_usuario s1
                 --    WHERE s1.UsuarioID = l.UsuarioID
                 --), 
                        l.ModificadoPor, 
                        l.ModificadoEl, 
                        l.TFAuthentication, 
                        l.NumeroCelular, 
                        l.CodigoPais, 
                        l.idRuta
                 FROM [AP_Usuario] l
                      INNER JOIN AP_Usuario u ON u.UsuarioID = @pIdUsuario
                      ---USUARIO
                      INNER JOIN AP_PerfilUsuario pu ON pu.UsuarioID = u.UsuarioID
					  INNER JOIN ap_perfil p ON p.IdPerfil = pu.PerfilID
                      INNER JOIN ap_rolcontrato rc ON rc.IdRol = p.IdRol
                      --
                      INNER JOIN AP_PerfilUsuario pu2 ON pu2.UsuarioID = l.UsuarioID
                      INNER JOIN ap_perfil p2 ON p2.IdPerfil = pu2.PerfilID
                      INNER JOIN ap_rolcontrato rc2 ON rc2.IdRol = p2.IdRol
                                                       AND rc2.IdContrato = rc.IdContrato
					  WHERE	ISNULL(l.IsGrupo,0)	=	0
                 GROUP BY l.UsuarioID, 
                          l.Usuario, 
                          l.Contraseña, 
                          l.Nombre, 
                          l.IsActivo, 
                          l.fchRegistro, 
                          l.IsEliminado, 
                          l.imgsrc, 
                          l.UltimoAcceso, 
                          l.Idioma, 
                          l.CreadoPor, 
                          l.IdTipoUsuario, 
                          l.Sello, 
                          l.image,
                          --l.Foto,
                          l.ModificadoPor, 
                          l.ModificadoEl, 
                          l.TFAuthentication, 
                          l.NumeroCelular, 
                          l.CodigoPais, 
                          l.idRuta
                 ORDER BY l.IsActivo DESC, 
                          l.UsuarioID;
             END;
     END;

