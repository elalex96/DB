-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExtraeProcesosDeMacro]-- 12121,10061,3,10002,10001
    @IdProceso INT,
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
	      P.IdProceso,
		  idMacroProceso,
		  idProcesoHijo,
		  NombreProceso,
          Descripcion,
		  MP.Orden--,
		--  BitIniciaConAnterior
      FROM EN_MacroProcesosRelacion MP
      JOIN dbo.EN_Procesos P ON  MP.idProcesoHijo= p.IdProceso
	   JOIN en_procesosContrato PC ON PC.idProceso= p.IdProceso
		  WHERE PC.idContrato=@idContrato AND MP.idMacroProceso=@IdProceso and MP.IdprocesoOriginal is null
	  ORDER BY  MP.Orden,MP.CreadoEn ASC 
END;

