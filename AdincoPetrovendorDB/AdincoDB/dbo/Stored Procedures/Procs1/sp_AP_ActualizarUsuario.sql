USE adinco
IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = 'sp_AP_ActualizarUsuario')
    DROP PROCEDURE sp_AP_ActualizarUsuario
GO
CREATE PROC [dbo].[sp_AP_ActualizarUsuario]  
--  
@pUsuarioID     INT,   
@pUsuario       VARCHAR(100),   
@pContraseña    VARCHAR(30),   
@pNombre        VARCHAR(250),   
@pFoto          IMAGE,   
@pModificadoPor INT,   
@pPerfilIds     VARCHAR(250),   
@pIsActivo      BIT,   
@pRuta          INT,   
@pass           VARBINARY(MAX) = NULL,   
@salt           VARBINARY(MAX) = NULL  
--  
AS  
     DECLARE @pPerfilUsuarioID INT;  
     CREATE TABLE #tmpPerfiles(PerfilId INT);  
     BEGIN TRAN;  
     IF(@pass = 0x  
        OR @salt = 0x)  
         BEGIN  
             UPDATE AP_Usuario  
               SET   
                   Usuario = @pUsuario,   
                   Contraseña = CASE  
                                    WHEN ISNULL(@pContraseña, '') <> ''  
                                    THEN ISNULL(@pContraseña, '')  
                                    ELSE Contraseña  
                                END,   
                   Nombre = @pNombre,   
                   ModificadoPor = @pModificadoPor,   
                   ModificadoEl = GETDATE(),   
                   foto = @pFoto,   
                   IsActivo = @pIsActivo, 
				   IsEliminado = case when isnull(@pIsActivo, 0) = 1 then 0 else 1 end,
                   idRuta = @pRuta  
             WHERE UsuarioID = @pUsuarioID;  
         END;  
         ELSE  
         BEGIN  
             UPDATE AP_Usuario  
               SET   
                   Usuario = @pUsuario,   
                   Contraseña = CASE  
                                    WHEN ISNULL(@pContraseña, '') <> ''  
                                    THEN ISNULL(@pContraseña, '')  
                                    ELSE Contraseña  
                                END,   
                   Nombre = @pNombre,   
                   ModificadoPor = @pModificadoPor,   
                   ModificadoEl = GETDATE(),   
                   foto = @pFoto,   
                   IsActivo = @pIsActivo,
				   IsEliminado = case when isnull(@pIsActivo, 0) = 1 then 0 else 1 end,
                   idRuta = @pRuta,   
                   Pass = @pass,   
                   Salt = @salt  
             WHERE UsuarioID = @pUsuarioID;  
         END;  
     IF @@error <> 0  
         BEGIN  
             ROLLBACK TRAN;  
             GOTO fin;  
         END;  
  
     /********************PERFILES*************************/  
  
     INSERT INTO #tmpPerfiles(PerfilId)  
            SELECT splitdata  
            FROM [dbo].[fnSplitString](@pPerfilIds, ',');  
     IF @@error <> 0  
         BEGIN  
             ROLLBACK TRAN;  
             GOTO fin;  
         END;  
  
     /**********Eliminar los perfiles que no esten marcados*************/  
  
     DELETE AP_perfilusuario  
     FROM AP_perfilusuario pu  
     WHERE pu.UsuarioID = @pUsuarioID  
           AND NOT EXISTS  
     (  
         SELECT 1  
         FROM #tmpPerfiles tmp  
         WHERE tmp.PerfilId = pu.PerfilID  
     );  
     IF @@error <> 0  
         BEGIN  
             ROLLBACK TRAN;  
             GOTO fin;  
         END;  
  
     /*********Insertar los perfiles marcados******************/  
  
     SELECT @pPerfilUsuarioID = isnull(MAX(PerfilUsuarioID), 0)  
     FROM ap_perfilusuario;  
     INSERT INTO ap_perfilusuario  
     (  
  
     /*PerfilUsuarioID,*/  
  
     UsuarioID,   
     PerfilID,   
     CreadoPor,   
     RandomUpdate  
     )  
            SELECT  
  
            /*ROW_NUMBER ( ) OVER(ORDER BY PerfilId ASC) + @pPerfilUsuarioID,*/  
  
            @pUsuarioID,   
            PerfilID,   
            @pModificadoPor,   
            NULL  
            FROM #tmpPerfiles T1  
            WHERE NOT EXISTS  
            (  
                SELECT 1  
                FROM ap_perfilusuario S1  
                WHERE S1.UsuarioID = @pUsuarioID  
                      AND S1.PerfilID = T1.PerfilId  
            );  
     IF @@error <> 0  
         BEGIN  
             ROLLBACK TRAN;  
             GOTO fin;  
         END;  
     COMMIT TRAN;  
     fin:;