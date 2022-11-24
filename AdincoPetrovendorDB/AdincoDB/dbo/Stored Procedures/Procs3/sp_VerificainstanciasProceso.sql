-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20181023
-- Description:	Verifica las instancias de los procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerificainstanciasProceso] --3,10061,12092 
@idContrato int,
@idUsuario int,
@idProceso int
AS
BEGIN
  SET LANGUAGE spanish;
  DECLARE @idTipoProceso int;
  SELECT @idTipoProceso = idTipoProceso
  FROM dbo.EN_Procesos
  WHERE IdProceso = @idProceso;

  CREATE TABLE #ContienenFechaReal (
    IdInstanciasProcesos int
  );

  IF (@idTipoProceso = 10001)
  BEGIN
    SELECT IdInstanciasProcesos,
           MP.Descripcion,
           LTRIM(DAY(Fecha)) + '-' + DATENAME(MONTH, Fecha) + '-' + LTRIM(YEAR(Fecha)) AS Fecha,
           U.Nombre AS 'Creadopor',
           MIN(MCP.CreadoEn),
           LTRIM(DAY(FechaInicioProceso)) + '-' + DATENAME(MONTH, FechaInicioProceso) + '-'
           + LTRIM(YEAR(FechaInicioProceso)) AS FechaInicioProceso,
           LTRIM(DAY(FechaFinProceso)) + '-' + DATENAME(MONTH, FechaFinProceso) + '-'
           + LTRIM(YEAR(FechaFinProceso)) AS FechaFinProceso,
           MP.IdInstalacion
    FROM dbo.EN_MacroProcesosRelacion MCP
    JOIN dbo.EN_Procesos MP
      ON MP.IdProceso = MCP.idProcesoHijo
    JOIN dbo.EN_InstanciasProcesosFecha IP
      ON MCP.idProcesoHijo = IP.IdProceso
    JOIN dbo.AP_Usuario U
      ON U.UsuarioID = IP.CreadoPor
    WHERE MCP.idMacroProceso = @idProceso
    AND idContrato = @idContrato
    GROUP BY IdInstanciasProcesos,
             MP.Descripcion,
             MP.IdInstalacion,
             Fecha,
             U.Nombre,
             FechaInicioProceso,
             FechaFinProceso;

  END;
  ELSE
  IF (@idTipoProceso = 10002)
  BEGIN
    SELECT p.IdInstalacion AS IdInstanciasProcesos,
           ipf.Descripcion,
           LTRIM(DAY(MAX(FechaActividad))) + '-' + DATENAME(MONTH, MAX(FechaActividad)) + '-' + LTRIM(YEAR(MAX(FechaActividad))) AS Fecha,
           U.Nombre AS 'Creadopor',
           LTRIM(DAY(MIN(a.FechaInicioActividad))) + '-' + DATENAME(MONTH, MIN(a.FechaInicioActividad)) + '-'
           + LTRIM(YEAR(MIN(a.FechaInicioActividad))) AS FechaInicioProceso,
           LTRIM(DAY(MAX(FechaActividad))) + '-' + DATENAME(MONTH, MAX(FechaActividad)) + '-'
           + LTRIM(YEAR(MAX(FechaActividad))) AS FechaFinProceso,
           IdInstalacion
		  -- Select *
    FROM EN_MacroProcesosRelacion mpr
    JOIN EN_Procesos p
      ON mpr.idProcesoHijo = p.IdProceso and mpr.IdprocesoOriginal is not null
    JOIN EN_InstanciasProcesosFecha ipf
      ON p.IdProceso = ipf.IdProceso  
    JOIN EN_InstanciasActividades a
      ON ipf.IdInstanciasProcesos = a.IdInstanciasProcesos 
    JOIN dbo.AP_Usuario U
      ON  IPF.CreadoPor = U.UsuarioID 
    WHERE mpr.idMacroProceso =@idProceso
    GROUP BY ipf.Descripcion,
             p.IdInstalacion,
             U.Nombre

  END
  ELSE
  BEGIN
    INSERT INTO #ContienenFechaReal (IdInstanciasProcesos)
      SELECT ia.IdInstanciasProcesos
      FROM dbo.EN_InstanciasActividades ia
      JOIN dbo.EN_InstanciasProcesosFecha ipf
        ON ia.IdInstanciasProcesos = ipf.IdInstanciasProcesos
        AND ipf.IdProceso = @idProceso
      WHERE ia.FechaRealActividad IS NOT NULL
      GROUP BY ia.IdInstanciasProcesos;

    SELECT IP.IdInstanciasProcesos,
           LTRIM(DAY(Fecha)) + '-' + DATENAME(MONTH, Fecha) + '-' + LTRIM(YEAR(Fecha)) AS Fecha,
           U.Nombre AS 'Creadopor',
           IP.Descripcion,
           LTRIM(DAY(FechaInicioProceso)) + '-' + DATENAME(MONTH, FechaInicioProceso) + '-'
           + LTRIM(YEAR(FechaInicioProceso)) AS FechaInicioProceso,
           LTRIM(DAY(FechaFinProceso)) + '-' + DATENAME(MONTH, FechaFinProceso) + '-'
           + LTRIM(YEAR(FechaFinProceso)) AS FechaFinProceso,
           P.IdInstalacion
    FROM dbo.EN_InstanciasProcesosFecha IP
    JOIN EN_PROCESOS P
      ON IP.IdProceso = P.IdProceso
    JOIN dbo.AP_Usuario U
      ON U.UsuarioID = IP.CreadoPor
    WHERE IP.IdProceso = @idProceso
    AND idContrato = @idContrato
    AND IP.IdInstanciasProcesos NOT IN (SELECT
      IdInstanciasProcesos
    FROM #ContienenFechaReal);
  END;
END;