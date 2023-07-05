CREATE PROCEDURE [dbo].[sp_AP_ObtenerPerfilPorUsuarioGrid]   
@UsuarioID       INT,   
@SoloAsignados   BIT = 1,   
@UsuarioSesionId INT  
AS  
     BEGIN  
         DECLARE @IsAdministradorRoot INT;  
  
         SELECT @IsAdministradorRoot = COUNT(PerfilID)  
         FROM dbo.AP_PerfilUsuario  
         WHERE UsuarioID = @UsuarioSesionId  
               AND PerfilID  IN(128, 416,6); --Para saber si el usuario tiene el perfil administrador no es dependiente del contrato  
         --SELECT @IsAdministradorRoot=COUNT(PerfilID) FROM dbo.AP_PerfilUsuario WHERE UsuarioID=@UsuarioSesionId AND PerfilID=128   --******Para pr  (SOLO PARA ADMINISTRADORES ADINCO SERA EL PERFIL 128 ADMINISTRADOR ROOT)  
       
	   IF (@IsAdministradorRoot > 0)
             BEGIN  
                 SELECT [PerfilUsuarioID] = ISNULL(pu.[PerfilUsuarioID], 0),   
                        Asignado = CAST(CASE  
                                            WHEN pu.[PerfilUsuarioID] > 0  
                                            THEN 1  
                                            ELSE 0  
                                        END AS BIT),   
                        pu.[UsuarioID],   
                        PerfilID = p.IdPerfil,   
                        p.Descripcion,   
                        c.NumeroContrato,   
                        c.DescripcionContrato,   
                        ISNULL(p.[CreadoPor], 0) CreadoPor  
                 FROM AP_Perfil p  
                      INNER JOIN CO_Contrato c ON c.IdContrato = p.IdContrato  
                      LEFT JOIN [dbo].[AP_PerfilUsuario] pu ON pu.PerfilID = p.IdPerfil  
                                                               AND pu.UsuarioID = @UsuarioID 
				     WHERE(@SoloAsignados = 1 AND pu.[PerfilUsuarioID] > 0) OR @SoloAsignados = 0  
                 ORDER BY pu.[PerfilUsuarioID] DESC,   
                          p.Descripcion;  
             END;  
             ELSE  
             BEGIN  
                 SELECT  
                 --RowNumber = ROW_NUMBER ( ) OVER(ORDER BY pu.[PerfilUsuarioID] ASC)  ,  
                 [PerfilUsuarioID] = ISNULL(pu.[PerfilUsuarioID], 0),   
                 Asignado = CAST(CASE  
                                     WHEN pu.[PerfilUsuarioID] > 0  
                                     THEN 1  
                                     ELSE 0  
                                 END AS BIT),   
                 pu.[UsuarioID],   
                 PerfilID = p.IdPerfil,   
                 p.Descripcion,   
                 c.NumeroContrato,   
                 c.DescripcionContrato,   
                 ISNULL(p.[CreadoPor], 0) CreadoPor  
                 FROM AP_Perfil p  
                      INNER JOIN CO_Contrato c ON c.IdContrato = p.IdContrato  
                      INNER JOIN AP_Usuario u2 ON u2.UsuarioID = @UsuarioSesionId  
                      INNER JOIN AP_PerfilUsuario pu2 ON pu2.UsuarioID = u2.UsuarioID  
                      INNER JOIN AP_Perfil p2 ON p2.IdPerfil = pu2.PerfilID  
                                                 AND p2.IdContrato = p.IdContrato  
                      LEFT JOIN [dbo].[AP_PerfilUsuario] pu ON pu.PerfilID = p.IdPerfil  
                                                               AND pu.UsuarioID = @UsuarioID  
                 WHERE(@SoloAsignados = 1 AND pu.[PerfilUsuarioID] > 0) OR @SoloAsignados = 0  
				 GROUP BY 
				 pu.[PerfilUsuarioID],
				 pu.[UsuarioID],   
                 p.IdPerfil,   
                 p.Descripcion,   
                 c.NumeroContrato,   
                 c.DescripcionContrato,   
                 ISNULL(p.[CreadoPor], 0)
                 ORDER BY pu.[PerfilUsuarioID] DESC,   
                          p.Descripcion;  
             END;  
     END; 
