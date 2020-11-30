-- ============================================= 
-- Author:    Reyna Olvera 
-- Create date: 2019/02/14 
-- ============================================= 
CREATE PROCEDURE [dbo].[Sp_en_updateorden]-- 12121,10061,3,10002,10001 
  @IdProceso      INT, 
  @idUsuario      INT, 
  @idContrato     INT, 
  @orden          INT, 
  @idMacroproceso INT 
AS 
  BEGIN 
      SET nocount ON; 

      UPDATE en_macroprocesosrelacion 
      SET    orden = @orden 
      WHERE  idprocesohijo = @IdProceso 
             AND idmacroproceso = @idMacroproceso 

      IF @@ERROR <> 0 
        BEGIN 
            SELECT Cast(@@ERROR AS NVARCHAR(8)) AS error; 
        END 
      ELSE 
        BEGIN 
            SELECT '' AS error; 
        END 
  END; 