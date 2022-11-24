-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_DesactivaActividades] --3,10061,11105,12106--10010,10061,10011
    @idContrato INT,
    @idUsuario INT,
    @idActividad INT,
    @idProceso INT
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #TempProcesoActividad (orden INT IDENTITY(0, 1),
                                        idActividad INT,
                                        idproceso INT);

    UPDATE EN_ProcesosActividades
       SET Activo = 0,
           Orden = NULL
     WHERE IdProceso   = @idProceso
       AND IdContrato  = @idContrato
       AND idActividad = @idActividad;

    INSERT INTO #TempProcesoActividad (idActividad,
                                       idproceso)
    SELECT idActividad,
           IdProceso
      FROM EN_ProcesosActividades
     WHERE IdProceso =@idProceso
       AND Activo    = 1
	   AND Orden	>= 0
     ORDER BY Orden ASC;

    UPDATE pr
       SET Orden = pt.orden
      FROM EN_ProcesosActividades pr
      JOIN #TempProcesoActividad pt
        ON pr.IdProceso   = pt.idproceso
       AND pr.idActividad = pt.idActividad
     WHERE pr.IdProceso = @idProceso
       AND IdContrato   = @idContrato
	    AND pr.Orden	>= 0;
--  AND      idActividad    = @idActividad

END;
--SELECT * FROM dbo.EN_FrecuenciaEntregable WHERE IdFrecuenciaEntregable=10011
--Update dbo.EN_ProcesosActividades set orden =2,Activo=1 where idproceso=12107 AND idactividad=11108
--SELECT * FROM EN_ProcesosActividades

