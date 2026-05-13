-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeListadoProcesosConFechaReal]--3,10061
    @idContrato INT,
    @idUsuario INT-- ,
   -- @idTipoProceso INT
AS
BEGIN

    SET NOCOUNT ON;

    CREATE TABLE #ContienenFechaReal
    (
        IdInstanciasProcesos INT
    );
    INSERT INTO #ContienenFechaReal (IdInstanciasProcesos)
    SELECT ia.IdInstanciasProcesos
    FROM dbo.EN_InstanciasActividades ia
    JOIN dbo.EN_InstanciasProcesosFecha ipf ON ia.IdInstanciasProcesos = ipf.IdInstanciasProcesos
    JOIN dbo.EN_ProcesosContrato pc ON ipf.IdProceso = pc.idProceso
                                       AND pc.idContrato = @idContrato
                                       AND ipf.idContrato = @idContrato
    WHERE ia.FechaRealActividad IS NOT NULL
    GROUP BY ia.IdInstanciasProcesos;

    SELECT p.IdProceso,
           NombreProceso,
           p.Descripcion,
           p.IsProcesoEvento,
           LTRIM(COUNT(IPF.IdInstanciasProcesos)) + ' estimación de fechas guardadas' AS instancias,
		   p.idTipoProceso
    FROM EN_Procesos p
    JOIN EN_ProcesosContrato PC ON p.IdProceso = PC.idProceso
                                   AND PC.idContrato = @idContrato
                                   AND p.idTipoProceso = 10000
                                   AND p.IdInstalacion IS NOT NULL
    JOIN dbo.EN_InstanciasProcesosFecha IPF ON p.IdProceso = IPF.IdProceso
                                               AND IPF.IdInstanciasProcesos IN
                                                   (
                                                       SELECT IdInstanciasProcesos FROM #ContienenFechaReal
                                                   )
    GROUP BY p.IdProceso,
             NombreProceso,
             p.Descripcion,
             p.IsProcesoEvento,
			 p.idTipoProceso
    UNION ALL
    SELECT p.IdProceso,
           NombreProceso,
           p.Descripcion,
           p.IsProcesoEvento,
           'Es macroproceso' AS instancias,
		   p.idTipoProceso
    FROM EN_Procesos p
    JOIN EN_ProcesosContrato PC ON p.IdProceso = PC.idProceso
                                   AND PC.idContrato =@idContrato
                                   AND p.idTipoProceso = 10001
END;