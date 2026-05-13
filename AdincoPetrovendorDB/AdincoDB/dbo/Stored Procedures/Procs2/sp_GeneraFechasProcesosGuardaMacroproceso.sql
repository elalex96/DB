CREATE PROCEDURE [dbo].[sp_GeneraFechasProcesosGuardaMacroproceso] --3,10061,'prueba 1.2',1
@idContrato int,
@idUsuario int,
@DescripcionProcesoCalculo varchar(max),
@FechaSeleccionada bit-- 1=Inicial 0=final
--@FechasGenerados TableParameterType READONLY
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @SinResponsables int = 0--, @FechaSeleccionada bit ;
  /* SELECT *
   FROM ##FechasGenerados;
   SELECT *
   FROM ##OrdenProcesos;*/
   --DROP TABLE #TempFechaLimites
   Create table #TempFechaLimites(IdInstanciasProcesos int, FechaInicioProceso DATE, FechaFinProceso DATE, Fecha DATE);

  UPDATE PG
  SET PG.EsProcesoParaCopia =
                             CASE ISNULL(P.IDINSTALACION, 0)
                               WHEN 0 THEN 1
                               ELSE 0
                             END,
      PG.NombreCInstalacion =
                             CASE ISNULL(P.IDINSTALACION, 0)
                               WHEN 0 THEN LTRIM(p.NombreProceso) + '-' + LTRIM(C.NombreInstalacion)
                               ELSE P.NombreProceso
                             END
  FROM dbo.EN_Procesos P
  JOIN ##OrdenProcesos PG
    ON P.IdProceso = PG.IDPROCESO
  JOIN CO_Instalacion C
    ON PG.Idinstalacion = C.IdInstalacion

  --SE GUARDA EL PROCESO 
  INSERT INTO EN_Procesos (NombreProceso,
  Descripcion,
  CreadoPor,
  CreadoEl,
  Activo,
  idTipoProceso,
  IsProcesoEvento,
  IsSerie,
  IdInstalacion,
  Clave)
    SELECT NombreCInstalacion,
           op.IdProceso,
          @IdUsuario,
           GETDATE(),
           1,
           10003,
           1,
           IsSerie,
           op.IdInstalacion,
           ''
    FROM ##OrdenProcesos OP
    JOIN EN_Procesos P
      ON OP.IdProceso = P.IdProceso
    WHERE EsProcesoParaCopia = 1;

  UPDATE PG
  SET IdProcesoCreado =
                       --SELECT 
                       CASE PG.EsProcesoParaCopia
                         WHEN 1 THEN P.IdProceso
                         ELSE PG.IdProceso
                       END
  FROM dbo.EN_Procesos P
  JOIN ##OrdenProcesos PG
    ON P.Descripcion = LTRIM(PG.IDPROCESO)

  INSERT INTO EN_ProcesosContrato (idContrato, idProceso, CreadoPor, CreadoEn, Activo)
    SELECT @idContrato,
           P.IdProceso,
           @IdUsuario,
           GETDATE(),
           1
    FROM dbo.EN_Procesos P
    JOIN ##OrdenProcesos PG
      ON P.Descripcion = LTRIM(PG.IDPROCESO)
    WHERE EsProcesoParaCopia = 1;

  INSERT INTO EN_ProcesosRondas (IdProceso, IdRonda, CreadoPor, CreadoEl, Activo)
    SELECT p.IdProceso,
           IdRonda,
           @IdUsuario,
           GETDATE(),
           1
    FROM dbo.EN_Procesos P
    JOIN ##OrdenProcesos PG
      ON P.Descripcion = LTRIM(PG.IDPROCESO)
    JOIN CO_Contrato c
      ON c.IdContrato = @idContrato
    WHERE EsProcesoParaCopia = 1;

  INSERT INTO EN_Actividades (NombreActividad, Dias, DiasNaturales, CreadoPor, CreadoEl, Activo, IdRegulador, IdActividadOriginal)
    SELECT NombreActividad,
           PG.IdProcesoCreado,
           DiasNaturales,
           @idUsuario,
           GETDATE(),
           1,
           IdRegulador,
           a.idActividad
    -- sELECT *
    FROM dbo.EN_ProcesosActividades PA-------------------
    JOIN EN_Actividades a
      ON pa.idActividad = a.IdActividad
    JOIN ##OrdenProcesos PG
      ON PA.IdProceso = PG.IdProceso
      AND PG.EsProcesoParaCopia = 1
      AND pa.Activo = 1
	  AND PA.Orden	>= 0
      AND a.Activo = 1;

  INSERT INTO dbo.EN_ProcesosActividades (IdProceso,
  idActividad,
  IdContrato,
  Orden,
  CreadoPor,
  CreadoEl,
  ModificadoPor,
  ModificadoEl,
  Activo, BitIniciaSigProceso)
    SELECT PG.IdProcesoCreado,
           ao.idActividad,
           @idContrato,
           Orden,
           @idUsuario,
           GETDATE(),
           @idUsuario,
           GETDATE(),
           1,
           pa.BitIniciaSigProceso
    --select *
    FROM dbo.EN_ProcesosActividades pa
    JOIN EN_Actividades ao
      ON pa.IdActividad = ao.IdActividadOriginal ------
    JOIN ##OrdenProcesos PG
      ON PA.IdProceso = PG.IdProceso
      AND AO.DIAS = PG.IdProcesoCreado
      AND PG.EsProcesoParaCopia = 1
      AND pa.Activo = 1
	  AND PA.Orden	>= 0
      AND ao.Activo = 1;

  UPDATE FG
  SET IdActividadCreada =
                         CASE op.EsProcesoParaCopia
                           WHEN 1 THEN AO.IdActividad
                           ELSE AO.IdActividadOriginal
                         END
  FROM ##FechasGenerados FG
  JOIN ##OrdenProcesos OP
    ON FG.IDPROCESO = OP.IDPROCESO --AND OP.IdInstanciaProceso=0
  JOIN EN_ProcesosActividades PA
    ON OP.IdProcesoCreado = PA.IdProceso
  JOIN EN_Actividades AO
    ON AO.DIAS = OP.IdProcesoCreado
    AND FG.IDACTIVIDAD = AO.IdActividadOriginal

  INSERT INTO EN_ActividadesEntregables (IdActividad,
  IdEntregable,
  CreadoPor,
  CreadoEl,
  Activo)
    SELECT ao.IdActividad,
           IdEntregable,
           @idUsuario,
           GETDATE(),
           1
    FROM dbo.EN_ActividadesEntregables AE
    JOIN dbo.EN_ProcesosActividades pa
      ON AE.IdActividad = PA.IdActividad --where AE.idActividad=11156
    JOIN ##OrdenProcesos PG
      ON PA.IdProceso = PG.IdProceso
      AND PG.EsProcesoParaCopia = 1
      AND pa.Activo = 1
    JOIN EN_Actividades ao
      ON pa.IdActividad = ao.IdActividadOriginal
      AND ao.Activo = 1
      AND PG.idProcesoCreado = ao.Dias
	WHERE  PA.Orden	>= 0

  INSERT INTO EN_MacroProcesosRelacion (idMacroProceso,
  idProcesoHijo,
  CreadoPor,
  CreadoEn,
  Activo,
  Orden,
  IdprocesoOriginal)
    SELECT idMacroproceso,
           idprocesoCreado,
           @idUsuario,
           GETDATE(),
           1,
           ordenprocesos,
           idproceso
    FROM ##OrdenProcesos
    WHERE esprocesoParaCopia = 1

  UPDATE P
  SET P.Descripcion = P.NOMBREPROCESO
  FROM EN_Procesos P
  JOIN ##OrdenProcesos OP
    ON P.IDPROCESO = OP.idprocesoCreado

  --se genera el if de los responsables

  SELECT @SinResponsables = COUNT(1)
  FROM ##FechasGenerados FG
  JOIN EN_ActividadesEntregables AE
    ON FG.IdActividadCreada = AE.IdActividad
  JOIN EN_ContratoEntregable CE
    ON AE.IdEntregable = CE.IdEntregable
    AND CE.IdContrato = @idContrato
  LEFT JOIN dbo.EN_Actividad AEl
    ON AEl.IdContratoEntregable = CE.IdContratoEntregable
    AND AEl.EstadoID = 10000
  LEFT JOIN dbo.EN_Actividad AR
    ON AR.IdContratoEntregable = CE.IdContratoEntregable
    AND AR.EstadoID = 10001
  LEFT JOIN dbo.EN_Actividad AA
    ON AA.IdContratoEntregable = CE.IdContratoEntregable
    AND AA.EstadoID = 10002
  WHERE AE.IdEntregable IS NOT NULL
  AND (
  AA.ActividadID IS NULL
  OR AEl.ActividadID IS NULL
  OR AR.ActividadID IS NULL
  OR CE.DiasElaboracion IS NULL
  OR CE.DiasElaboracion = 0
  OR CE.DiasRevision IS NULL
  OR CE.DiasRevision = 0
  OR CE.DiasAprobacion IS NULL);

  IF (@SinResponsables = 0)
  BEGIN
    --############################# SE GENERA LAS DIVERSAS INSTANCIAS RELACIONADAS AL PROCESO EN CASO DE QUE LOS ENTREGABLES TENGAN RESPONSABLES#######################################
    INSERT INTO EN_InstanciasProcesosFecha (IdProceso, Descripcion, Fecha, FechaInicial, idContrato, CreadoPor, CreadoEl, Activo, FechaInicioProceso, FechaFinProceso)
      SELECT IdPRocesoCreado,
             @DescripcionProcesoCalculo,
             CASE @FechaSeleccionada
               WHEN 1 THEN MIN(FechaInicial)
               ELSE MAX(FechaLimite)
             END,
             @FechaSeleccionada,
             @idContrato,
             @idUsuario,
             GETDATE(),
             1,
             MIN(FechaInicial),
             MAX(FechaLimite)
      FROM ##FechasGenerados FG
      JOIN ##OrdenProcesos OP
        ON FG.IDPROCESO = OP.IDPROCESO
        AND OP.IdInstanciaProceso = 0
      GROUP BY IdPRocesoCreado

    INSERT INTO EN_InstanciasActividades (IdInstanciasProcesos,
    IdActividad,
    FechaActividad,
    CreadoPor,
    CreadoEl,
    Activo,
    FechaRealActividad,
    FechaInicioActividad)
      SELECT IPF.IdInstanciasProcesos,
             AO.IdActividad,
             FG.FECHALIMITE,
             @idUsuario,
             GETDATE(),
             1,
             NULL,
             FG.FechaInicial
      FROM ##FechasGenerados FG
      JOIN ##OrdenProcesos OP
        ON FG.IDPROCESO = OP.IDPROCESO
        AND OP.IdInstanciaProceso = 0
      JOIN EN_InstanciasProcesosFecha IPF
        ON OP.IdProcesoCreado = IPF.IdProceso
      JOIN EN_ProcesosActividades PA
        ON OP.IdProcesoCreado = PA.IdProceso
      JOIN EN_Actividades AO
        ON AO.DIAS = OP.IdProcesoCreado
        AND FG.IDACTIVIDAD = AO.IdActividadOriginal
      GROUP BY IPF.IdInstanciasProcesos,
               AO.IdActividad,
               FG.FECHALIMITE,
               FG.FechaInicial

    INSERT INTO EN_InstanciasEntregable (FechasLimiteElaboracion,
    FechasLimiteRevision,
    FechasLimiteAprobacion,
    FechaEnvioMensajeAtrasoRevision,
    idFrecuencua,
    IdContratoEntregable,
    ActividadID,
    CorreoEnviado,
    CreadoPor,
    CreadoEn,
    Activo,
    FechaCalculadaEntregaReg,
    ContieneAjusteFechas,
    BitContieneAcuse)
      SELECT NULL,
             NULL,
             FG.FechaLimite,
             NULL,
             E.IdFrecuenciaEntregable,
             CE.IdContratoEntregable,
             AEl.ActividadID,
             0,
             @idUsuario,
             GETDATE(),
             1,
             FG.FechaLimite,
             IPF.IdInstanciasProcesos,
             0
      -- SELECT *  
      FROM ##FechasGenerados FG
      JOIN ##OrdenProcesos OP
        ON FG.IDPROCESO = OP.IDPROCESO
        AND OP.IdInstanciaProceso = 0
      JOIN EN_ActividadesEntregables AE
        ON FG.IdActividadCreada = AE.IdActividad
      JOIN EN_ContratoEntregable CE
        ON AE.IdEntregable = CE.IdEntregable
        AND CE.IdContrato = @idContrato
      JOIN EN_InstanciasProcesosFecha IPF
        ON OP.IdProcesoCreado = IPF.IdProceso
      JOIN EN_Entregable E
        ON AE.IdEntregable = E.IdEntregable
      LEFT JOIN dbo.EN_Actividad AEl
        ON AEl.IdContratoEntregable = CE.IdContratoEntregable
        AND AEl.EstadoID = 10000
		

    UPDATE IE
    SET FechasLimiteRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(
    IE.FechasLimiteAprobacion, CE.DiasAprobacion)
    FROM dbo.EN_InstanciasEntregable IE
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable
      AND CE.IdContrato =	@idContrato 
      AND FechasLimiteRevision IS NULL
    JOIN dbo.EN_Actividad A
      ON IE.ActividadID = A.ActividadID
      AND A.EstadoID = 10000
    JOIN EN_InstanciasProcesosFecha IPF
      ON IE.ContieneAjusteFechas = IPF.IdInstanciasProcesos

    UPDATE IE
    SET FechasLimiteElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(
    IE.FechasLimiteRevision,
    CE.DiasRevision)
    --sELECT  Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision,CE.DiasRevision), FechasLimiteElaboracion
    FROM dbo.EN_InstanciasEntregable IE
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable
      AND CE.IdContrato = @idContrato 
      AND FechasLimiteElaboracion IS NULL
    JOIN dbo.EN_Actividad A
      ON IE.ActividadID = A.ActividadID
      AND A.EstadoID = 10000
    JOIN EN_InstanciasProcesosFecha IPF
      ON IE.ContieneAjusteFechas = IPF.IdInstanciasProcesos

    UPDATE IE
    SET FechasLimiteElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision, CE.DiasRevision)
    FROM dbo.EN_InstanciasEntregable IE
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable
      AND CE.IdContrato = @idContrato 
      AND FechaInicioElaboracion IS NULL
    JOIN dbo.EN_Actividad A
      ON IE.ActividadID = A.ActividadID
      AND A.EstadoID = 10000
    JOIN EN_InstanciasProcesosFecha IPF
      ON IE.ContieneAjusteFechas = IPF.IdInstanciasProcesos

	  UPDATE IE
	   set IE.FechaInicioElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion, CE.DiasElaboracion),
        IE.FechaEnvioMensajeAtrasoRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion, CE.DiasAlerta)
    --SELECT FechasLimiteElaboracion, Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision,  CE.DiasRevision),IE.FechaEnvioMensajeAtrasoRevision, Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion, CE.DiasAlerta )
    FROM dbo.EN_InstanciasEntregable IE
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable
      AND CE.IdContrato = @idContrato 
      AND FechaInicioElaboracion IS NULL
    JOIN dbo.EN_Actividad A
      ON IE.ActividadID = A.ActividadID
      AND A.EstadoID = 10000
    JOIN EN_InstanciasProcesosFecha IPF
      ON IE.ContieneAjusteFechas = IPF.IdInstanciasProcesos

    INSERT INTO EN_InstanciasEntregables_InstanciaActividad (idInstanciaEntregable,
    idInstanciaActividad,
    CreadoPor,
    CreadoEl,
    Activo)
      SELECT idInstanciaEntregable,
             idInstanciaActividad,
             @idUsuario,
             GETDATE(),
             1
			--SELECT *
      FROM 
		##FechasGenerados FG
      JOIN 
		##OrdenProcesos OP
        ON FG.IDPROCESO = OP.IDPROCESO
        AND OP.IdInstanciaProceso = 0
      JOIN 
		EN_ActividadesEntregables AE
        ON FG.IdActividadCreada = AE.IdActividad
      JOIN 
		EN_InstanciasActividades IA
        ON AE.IdActividad = IA.IdActividad
      JOIN 
		EN_InstanciasProcesosFecha IPF
        ON OP.IdProcesoCreado = IPF.IdProceso
      JOIN 
		EN_InstanciasEntregable IE
        ON IPF.IdInstanciasProcesos = IE.ContieneAjusteFechas
	JOIN 
		EN_ContratoEntregable	CE
		ON AE.IdEntregable	=	CE.IdEntregable
		AND IE.IdContratoEntregable	=CE.IdContratoEntregable
	group by 
		idInstanciaEntregable,idInstanciaActividad

    UPDATE IE
    SET ContieneAjusteFechas = 0
    FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP
      ON FG.IDPROCESO = OP.IDPROCESO
      AND OP.IdInstanciaProceso = 0
    JOIN EN_InstanciasProcesosFecha IPF
      ON OP.IdProcesoCreado = IPF.IdProceso
    JOIN EN_InstanciasEntregable IE
      ON IPF.IdInstanciasProcesos = IE.ContieneAjusteFechas
  --##########################################################################################################################################################################
  END

  UPDATE ao
  SET ao.DIAS = a.Dias
  --Select  ao.DIAS,a.Dias, ao.idActividad,a.idactividad
  FROM dbo.EN_ProcesosActividades pa
  JOIN EN_Actividades ao
    ON pa.IdActividad = ao.IdActividadOriginal ------
  JOIN EN_Actividades a
    ON ao.IdActividadOriginal = a.IdActividad
  JOIN ##OrdenProcesos PG
    ON PA.IdProceso = PG.IdProceso
    AND AO.DIAS = PG.IdProcesoCreado
    AND PG.EsProcesoParaCopia = 1
    AND pa.Activo = 1
    AND ao.Activo = 1;

  IF (SELECT
      COUNT(1)
    FROM ##FechasGenerados
    WHERE IdInstanciaproceso <> 0 )>= 1
  BEGIN

  INSERT INTO #TempFechaLimites(IdInstanciasProcesos,FechaInicioProceso,FechaFinProceso,Fecha)
	SELECT IPF.IdInstanciasProcesos,
	MIN(FG.FechaInicial), 
	MAX(FG.FechaLimite),
			CASE @FechaSeleccionada
               WHEN 1
			   THEN MIN(FG.FechaInicial)
			   WHEN 0
			   THEN MIN(FG.FechaLimite)
             END
	  FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP ON FG.IDPROCESO = OP.IDPROCESO AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasProcesosFecha IPF ON OP.IdInstanciaProceso = IPF.IdInstanciasProcesos
	GROUP BY IdInstanciasProcesos

    UPDATE IPF
    SET IPF.Descripcion = @DescripcionProcesoCalculo,
        IPF.idContrato=@idContrato,
        IPF.ModificadoPor=@idUsuario,
        IPF.ModificadoEl = GETDATE(),
        IPF.FechaInicial = @FechaSeleccionada,
        IPF.Activo = 1,
		IPF.FechaInicioProceso=TFL.FechaInicioProceso,
		IPF.FechaFinProceso=TFL.FechaFinProceso,
		IPF.Fecha=TFL.Fecha
FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP ON FG.IDPROCESO = OP.IDPROCESO AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasProcesosFecha IPF ON OP.IdInstanciaProceso = IPF.IdInstanciasProcesos
	JOIN #TempFechaLimites TFL ON IPF.IdInstanciasProcesos=TFL.IdInstanciasProcesos

    UPDATE IA
    SET IA.FechaActividad = FG.FechaLimite,
        IA.FechaInicioActividad = FG.FechaInicial
    FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP
      ON FG.IDPROCESO = OP.IDPROCESO
      AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasActividades IA
      ON FG.IdActividad = IA.IdActividad
      AND OP.IdInstanciaProceso = IA.IdInstanciasProcesos

    UPDATE IE
    SET IE.FechasLimiteAprobacion = FG.FechaLimite,
        IE.FechaCalculadaEntregaReg = FG.FechaLimite
    FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP
      ON FG.IDPROCESO = OP.IDPROCESO
      AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasActividades IA
      ON FG.IdActividad = IA.IdActividad
      AND OP.IdInstanciaProceso = IA.IdInstanciasProcesos
    JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
      ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
    JOIN EN_InstanciasEntregable IE
      ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable

    UPDATE IE
    SET IE.FechasLimiteRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteAprobacion, CE.DiasAprobacion)
    FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP
      ON FG.IDPROCESO = OP.IDPROCESO
      AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasActividades IA
      ON FG.IdActividad = IA.IdActividad
      AND OP.IdInstanciaProceso = IA.IdInstanciasProcesos
    JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
      ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
    JOIN EN_InstanciasEntregable IE
      ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable

    UPDATE IE
    SET IE.FechasLimiteElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteRevision, CE.DiasRevision)
    FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP
      ON FG.IDPROCESO = OP.IDPROCESO
      AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasActividades IA
      ON FG.IdActividad = IA.IdActividad
      AND OP.IdInstanciaProceso = IA.IdInstanciasProcesos
    JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
      ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
    JOIN EN_InstanciasEntregable IE
      ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable

    UPDATE IE
    SET FechaInicioElaboracion = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion, CE.DiasElaboracion),
        FechaEnvioMensajeAtrasoRevision = Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechasLimiteElaboracion, CE.DiasAlerta)
    FROM ##FechasGenerados FG
    JOIN ##OrdenProcesos OP
      ON FG.IDPROCESO = OP.IDPROCESO
      AND OP.IdInstanciaProceso > 0
    JOIN EN_InstanciasActividades IA
      ON FG.IdActividad = IA.IdActividad
      AND OP.IdInstanciaProceso = IA.IdInstanciasProcesos
    JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
      ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
    JOIN EN_InstanciasEntregable IE
      ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
    JOIN EN_ContratoEntregable CE
      ON IE.IdContratoEntregable = CE.IdContratoEntregable

  END
END



