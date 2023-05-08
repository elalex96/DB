-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeProcesosReporte] --3,10061
    @idContrato INT, @idUsuario INT
--@IdContratoCb INT
AS BEGIN
    SET NOCOUNT ON;
    SELECT p.IdProceso, NombreProceso, Descripcion, IdInstalacion, IsProcesoEvento
    FROM EN_Procesos p
         JOIN EN_ProcesosContrato PC ON PC.idProceso=p.IdProceso
    WHERE PC.idContrato=@idContrato AND((p.IdInstalacion IS NOT NULL AND p.IsProcesoEvento=1)OR(p.IdInstalacion IS NULL AND p.IsProcesoEvento=0)OR(p.IdInstalacion IS NOT NULL AND p.IsProcesoEvento=0)OR(P.IdInstalacion IS NULL AND p.idTipoProceso<>10000))
	AND p.Activo=1;
END;
