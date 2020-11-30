-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Activa desactiva actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ActivaActividadPorId]
    @idContrato INT,
    @idUsuario INT,
    @IdActividad INT,
    @IdProceso INT,
    @Activo INT
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #TempProcesoActividad
    (
        orden INT IDENTITY(0, 1),
        idActividad INT,
        idproceso INT
    );
    DECLARE @Orden INT,
            @ActivoActual INT;

    SELECT @ActivoActual = Activo
    FROM dbo.EN_ProcesosActividades
    WHERE idActividad = @IdActividad
          AND IdProceso = @IdProceso;

    IF (@Activo = 1 AND @ActivoActual = 0)
    BEGIN
        SELECT @Orden =( MAX(Orden)+1)
        FROM dbo.EN_ProcesosActividades
        WHERE IdProceso = @IdProceso;

        UPDATE dbo.EN_ProcesosActividades
        SET Activo = 1,
            Orden = @Orden
        WHERE idActividad = @IdActividad
              AND IdProceso = @IdProceso;
    END;
    ELSE IF (@Activo = 0 AND @ActivoActual = 1)
    BEGIN
        UPDATE EN_ProcesosActividades
        SET Activo = 0,
            Orden = NULL
        WHERE IdProceso = @IdProceso
              AND IdContrato = @idContrato
              AND idActividad = @IdActividad;

        INSERT INTO #TempProcesoActividad (idActividad, idproceso)
        SELECT idActividad,
               IdProceso
        FROM EN_ProcesosActividades
        WHERE IdProceso = @IdProceso
              AND Activo = 1
			  AND Orden > =0
        ORDER BY Orden ASC;

        UPDATE pr
        SET Orden = pt.orden
        FROM EN_ProcesosActividades pr
        JOIN #TempProcesoActividad pt ON pr.IdProceso = pt.idproceso
                                         AND pr.idActividad = pt.idActividad
        WHERE pr.IdProceso = @IdProceso
              AND IdContrato = @idContrato
			  AND pr.Orden > = 0 ;
    END;
END;

