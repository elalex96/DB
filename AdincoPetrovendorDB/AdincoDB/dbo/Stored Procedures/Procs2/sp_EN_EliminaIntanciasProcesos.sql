-- =============================================
-- Author:  Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_EliminaIntanciasProcesos] --3,10061,11087,	12133
@idContrato int,
@idUsuario int,
@idInstanciaProceso int,
@idProceso int,
@Idinstalacion int
AS
BEGIN
  SET NOCOUNT ON;
  CREATE TABLE #InstanciasActividadesEtregables (
    idinstanciaProceso int,
    idInstanciaActividad int,
    idinstanciaEntregable int,
	idproceso int,IdActividad int
  );
  CREATE TABLE #ProcesosHijo (
    idproceso int
  );

  IF ((SELECT
      idTipoProceso
    FROM EN_Procesos
    WHERE IdProceso = @idProceso)
    = 10002)
  BEGIN
    INSERT INTO #ProcesosHijo (idproceso)
      SELECT idProcesoHijo
      FROM EN_MacroProcesosRelacion MPR
      JOIN EN_Procesos P
        ON MPR.idProcesoHijo = P.IdProceso
        AND MPR.idMacroProceso = @idProceso
        AND P.IdInstalacion = @Idinstalacion

    INSERT INTO #InstanciasActividadesEtregables 
	(idinstanciaProceso,
    IEIA.idInstanciaActividad,
    IEIA.idinstanciaEntregable,idproceso,IdActividad)
      SELECT IPF.IdInstanciasProcesos,
             IA.idInstanciaActividad,
             IEIA.idInstanciaEntregable,
			 P.idproceso,
			 IA.IdActividad
      FROM #ProcesosHijo P
	    JOIN EN_InstanciasProcesosFecha IPF
			  ON P.idproceso=IPF.IdProceso
      LEFT JOIN dbo.EN_InstanciasActividades IA
        ON IPF.IdInstanciasProcesos = IA.IdInstanciasProcesos
      LEFT JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
        ON IA.idInstanciaActividad = IEIA.idInstanciaActividad

	DELETE ER
	FROM
		EN_EntregableRelacion	ER
	JOIN	
		EN_EntregableDocumento ED
		ON	ER.DocumentoEntregablePadreId	=	ED.DocumentoEntregableId
	JOIN	
		EN_EntregableDocumento ED2
		ON	ER.DocumentoEntregableHijoId	=	ED2.DocumentoEntregableId
	WHERE
		(
			ED.idInstanciaEntregable IN (SELECT
			idinstanciaEntregable	FROM #InstanciasActividadesEtregables)
			OR	
			ED2.idInstanciaEntregable IN (SELECT
			idinstanciaEntregable	FROM #InstanciasActividadesEtregables)
		);


 DELETE FROM dbo.EN_InstanciasEntregables_InstanciaActividad
  WHERE idInstanciaActividad IN (SELECT
      idInstanciaActividad
    FROM #InstanciasActividadesEtregables)
    AND idInstanciaEntregable IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

	DELETE FROM dbo.EN_InstanciasActividades
	WHERE idInstanciaActividad IN (SELECT
		idInstanciaActividad
	FROM #InstanciasActividadesEtregables);


	DELETE DV 
	FROM
		EN_DocumentoVersion DV
	JOIN
		EN_EntregableDocumento	ED
		ON	DV.DocumentoEntregableId	=	ED.DocumentoEntregableId
	WHERE
		ED.idInstanciaEntregable	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)
		
	DELETE 
		EN_EntregableDocumento	
	WHERE
		idInstanciaEntregable	IN  (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

	DELETE 
		EN_URLResponsablesEntregables	
	WHERE
		idInstanciaEntregable	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

	DELETE 
		EN_HistorialAprobacionesLineaTiempo	
	WHERE
		idInstanciaEntregable	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

		DELETE 
		EN_ExcepcionesActividad	
	WHERE
		IdInstanciasEntregables	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)


	DELETE FROM dbo.EN_InstanciasEntregable
	WHERE idInstanciaEntregable IN (SELECT
		idinstanciaEntregable
	FROM #InstanciasActividadesEtregables);

	DELETE dbo.EN_InstanciasProcesosFecha
	WHERE IdInstanciasProcesos IN (SELECT
		idinstanciaProceso
	FROM #InstanciasActividadesEtregables);

	DELETE EN_ActividadesEntregables where IdActividad IN (SELECT
		IdActividad
	FROM #InstanciasActividadesEtregables);

	DELETE PA
	FROM EN_ProcesosActividades PA
	JOIN #InstanciasActividadesEtregables IAE ON PA.idActividad=IAE.IdActividad AND PA.IdProceso=IAE.idproceso

	DELETE FROM EN_Actividades WHERE IdActividad IN (SELECT IdActividad FROM #InstanciasActividadesEtregables);

	DELETE FROM EN_ProcesosContrato WHERE idProceso IN (SELECT idProceso FROM #InstanciasActividadesEtregables);
	
	DELETE FROM EN_ProcesosRondas WHERE idProceso IN (SELECT idProceso FROM #InstanciasActividadesEtregables);

	DELETE FROM EN_MacroProcesosRelacion WHERE idProcesoHijo IN (SELECT idProceso FROM #InstanciasActividadesEtregables) And idMacroProceso=@idProceso;

	DELETE FROM EN_Procesos WHERE idProceso IN (SELECT idProceso FROM #InstanciasActividadesEtregables);

  END
  ELSE
  BEGIN
	INSERT INTO #InstanciasActividadesEtregables (idinstanciaProceso,
    IEIA.idInstanciaActividad,
    IEIA.idinstanciaEntregable)
      SELECT IPF.IdInstanciasProcesos,
             IA.idInstanciaActividad,
             IEIA.idInstanciaEntregable
      FROM dbo.EN_InstanciasProcesosFecha IPF
      LEFT JOIN dbo.EN_InstanciasActividades IA
        ON IPF.IdInstanciasProcesos = IA.IdInstanciasProcesos
        AND IPF.IdInstanciasProcesos = @idInstanciaProceso
      LEFT JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
        ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
      WHERE IPF.IdInstanciasProcesos = @idInstanciaProceso;

	DELETE FROM dbo.EN_InstanciasEntregables_InstanciaActividad
  WHERE idInstanciaActividad IN (SELECT
      idInstanciaActividad
    FROM #InstanciasActividadesEtregables)
    AND idInstanciaEntregable IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

	DELETE FROM dbo.EN_InstanciasActividades
  WHERE idInstanciaActividad IN (SELECT
      idInstanciaActividad
    FROM #InstanciasActividadesEtregables);

	DELETE DV 
	FROM
		EN_DocumentoVersion DV
	JOIN
		EN_EntregableDocumento	ED
		ON	DV.DocumentoEntregableId	=	ED.DocumentoEntregableId
	WHERE
		ED.idInstanciaEntregable	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)
		
	DELETE 
		EN_EntregableDocumento	
	WHERE
		idInstanciaEntregable	IN  (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

	DELETE 
		EN_URLResponsablesEntregables	
	WHERE
		idInstanciaEntregable	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

	DELETE 
		EN_HistorialAprobacionesLineaTiempo	
	WHERE
		idInstanciaEntregable	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)

		DELETE 
		EN_ExcepcionesActividad	
	WHERE
		IdInstanciasEntregables	IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables)


	DELETE FROM dbo.EN_InstanciasEntregable
  WHERE idInstanciaEntregable IN (SELECT
      idinstanciaEntregable
    FROM #InstanciasActividadesEtregables);

	DELETE dbo.EN_InstanciasProcesosFecha
  WHERE IdInstanciasProcesos IN (SELECT
      idinstanciaProceso
    FROM #InstanciasActividadesEtregables);
  END

END;

