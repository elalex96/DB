-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181220
-- Description:Extrae bloques del contrato
-- =============================================
CREATE PROCEDURE CO_SP_ConsultaComboBloques-- 3,10
   
    @idContrato INT,
    @idUsuario INT

AS
BEGIN

  SELECT Id AS bloque,Nombre FROM 
   PR_Bloque 
  WHERE IdContrato=@idContrato  AND Estatus=1

END;
