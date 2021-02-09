CREATE PROCEDURE [dbo].[SP_AP_SAVEUSERGRIDDESIGN] @IdNombreGrid  VARCHAR(MAX), 
                                                 @Configuracion VARCHAR(MAX), 
                                                 @CountColumns  INT, 
                                                 @IdContrato    INT, 
                                                 @IdUsuario     INT 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      IF EXISTS (SELECT * 
                 FROM   DBO.Ap_configuraciongrids 
                 WHERE  idusuario = @IdUsuario 
                        AND idnombregrid = @IdNombreGrid) 
        BEGIN 
            UPDATE DBO.Ap_configuraciongrids 
            SET    configuracion = @Configuracion 
            WHERE  idusuario = @IdUsuario 
                   AND idnombregrid = @IdNombreGrid; 
        END 
      ELSE 
        BEGIN 
            INSERT INTO DBO.Ap_configuraciongrids 
                        (idusuario, 
                         idnombregrid, 
                         configuracion, 
                         cantidadcolumnas, 
                         creadoen) 
            VALUES      (@IdUsuario, 
                         @IdNombreGrid, 
                         @Configuracion, 
                         @CountColumns, 
                         Getdate() ); 
        END; 
  END; 
GO