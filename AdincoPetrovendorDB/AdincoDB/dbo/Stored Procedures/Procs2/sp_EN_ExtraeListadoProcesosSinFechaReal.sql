-- =============================================
-- Author:      Reyna Olvera
-- Create date: 20181023
-- Description: Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeListadoProcesosSinFechaReal] --3,10061,0
    @idContrato INT,
    @idUsuario INT,
    @idTipoProceso INT
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
           idTipoProceso,
           CASE 
               WHEN idTipoProceso IN (10001,10002) THEN
                   'Es macroproceso'
               WHEN idTipoProceso=10000 THEN
                   CASE
                       WHEN p.IdInstalacion IS NULL THEN
                           --'SIMULADOR DE PROCESOS'
                           'Proceso precargado'
                       ELSE
                           LTRIM(COUNT(IPF.IdInstanciasProcesos)) + ' estimación de fechas guardadas'
                   END
           END AS instancias,
           p.IsProcesoEvento,
           ISNULL(p.IdInstalacion, 0) AS IdInstalacion
    FROM 
        EN_Procesos p
    JOIN 
        EN_ProcesosContrato PC 
    ON p.IdProceso = PC.idProceso
      AND PC.idContrato = @idContrato
    LEFT JOIN 
        dbo.EN_InstanciasProcesosFecha IPF 
    ON p.IdProceso = IPF.IdProceso
        AND IPF.IdInstanciasProcesos NOT IN
        (SELECT IdInstanciasProcesos FROM #ContienenFechaReal)
    WHERE P.idTipoProceso   <>  10003 AND P.Activo  =   1
    GROUP BY p.IdProceso,
             NombreProceso,
             p.Descripcion,
             idTipoProceso,
             p.IsProcesoEvento,
             p.IdInstalacion
    ORDER BY p.IdInstalacion,
             idTipoProceso,
             p.NombreProceso
             DESC;
END;