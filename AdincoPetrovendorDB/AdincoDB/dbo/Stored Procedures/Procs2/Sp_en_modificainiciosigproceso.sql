-- ============================================= 
-- Author:    Reyna Olvera 
-- Create date: 20181023 
-- ============================================= 
CREATE PROCEDURE [dbo].[Sp_en_modificainiciosigproceso] --3,10061,'hola','hi' 
  @idContrato          INT, 
  @idUsuario           INT, 
  @IdProceso           INT, 
  @idActividad         INT, 
  @BitIniciaSigProceso BIT 
AS 
  BEGIN 
      DECLARE @error VARCHAR(max); 
	  IF(@BitIniciaSigProceso=1)
	  BEGIN
		  UPDATE [en_procesosactividades] 
		  SET    bitiniciasigproceso = 0
		  WHERE  idproceso = @IdProceso AND idcontrato = @idContrato 
	  END

      UPDATE [en_procesosactividades] 
      SET    bitiniciasigproceso = @BitIniciaSigProceso 
      WHERE  idproceso = @IdProceso 
             AND idactividad = @idActividad 
             AND idcontrato = @idContrato 

      SELECT @error AS error; 
  END 