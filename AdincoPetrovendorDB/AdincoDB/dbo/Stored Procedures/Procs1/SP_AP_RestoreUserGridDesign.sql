
-- =============================================  
-- Author:    
-- Create date:   
-- Description:  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_AP_RestoreUserGridDesign] @IdNombreGrid VARCHAR(MAX), 
                                                    @CountColumns INT, 
                                                    @IdContrato   INT, 
                                                    @IdUsuario    INT 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      DECLARE @cantidadcolumnas INT; 

      IF EXISTS (SELECT * 
                 FROM   DBO.Ap_configuraciongrids 
                 WHERE  idusuario = @IdUsuario 
                        AND idnombregrid = @IdNombreGrid) 
        BEGIN 
            SELECT @cantidadcolumnas = Isnull(cantidadcolumnas, 0) 
            FROM   DBO.Ap_configuraciongrids 
            WHERE  idusuario = @IdUsuario 
                   AND idnombregrid = @IdNombreGrid; 

            IF( @CountColumns <> @cantidadcolumnas ) 
              BEGIN 
                  DELETE FROM DBO.Ap_configuraciongrids 
                  WHERE  idusuario = @IdUsuario 
                         AND idnombregrid = @IdNombreGrid; 
              END 
            ELSE 
              BEGIN 
                  SELECT configuracion 
                  FROM   DBO.Ap_configuraciongrids 
                  WHERE  idusuario = @IdUsuario 
                         AND idnombregrid = @IdNombreGrid; 
              END 
        END 
  END; 
