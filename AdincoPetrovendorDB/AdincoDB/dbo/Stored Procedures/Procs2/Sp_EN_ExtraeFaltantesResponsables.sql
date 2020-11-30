-- =============================================
-- Author:		Reyna Olvera
-- Create date: 18/03/2019
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Sp_EN_ExtraeFaltantesResponsables] --10041,10061,11060
    @idContrato INT, --3
    @idUsuario INT,
    @idProceso INT
AS
BEGIN

  Create table #ProcesosHijo(idproceso int);
  
  IF((SELECT idTipoProceso FROM EN_Procesos WHERE IdProceso=@idProceso)=10002)
	BEGIN 
		INSERT INTO #ProcesosHijo(idproceso)
		SELECT idProcesoHijo FROM EN_MacroProcesosRelacion MPR
		JOIN EN_Procesos P ON MPR.idProcesoHijo=P.IdProceso
		 AND MPR.idMacroProceso=@idProceso
		 AND MPR.IdprocesoOriginal IS NULL

			SELECT AE.IdEntregable,
           E.DocumentoEntregable,
           CE.IdContratoEntregable,
           CE.IdContrato
    FROM dbo.#ProcesosHijo P
        JOIN dbo.EN_ProcesosActividades PA
            ON PA.IdProceso = P.IdProceso
               AND PA.Activo = 1
        LEFT JOIN dbo.EN_ActividadesEntregables AE
            ON PA.idActividad = AE.IdActividad
        LEFT JOIN EN_Entregable E
            ON AE.IdEntregable = E.IdEntregable
        LEFT JOIN EN_ContratoEntregable CE
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
		  AND PA.Orden	>=	0
          AND
          (
              AA.ActividadID IS NULL
              OR AEl.ActividadID IS NULL
              OR AR.ActividadID IS NULL
              OR CE.DiasElaboracion IS NULL
              OR CE.DiasElaboracion = 0
              OR CE.DiasRevision IS NULL
              OR CE.DiasRevision = 0
              OR CE.DiasAprobacion IS NULL
          )
    GROUP BY AE.IdEntregable,
             E.DocumentoEntregable,
             CE.IdContratoEntregable,
             CE.IdContrato;
	END
   ELSE
	BEGIN
		SELECT AE.IdEntregable,
           E.DocumentoEntregable,
           CE.IdContratoEntregable,
           CE.IdContrato
    --,*
    FROM dbo.EN_Procesos P
        JOIN dbo.EN_ProcesosActividades PA
            ON PA.IdProceso = P.IdProceso
               AND PA.Activo = 1
        LEFT JOIN dbo.EN_ActividadesEntregables AE
            ON PA.idActividad = AE.IdActividad
        LEFT JOIN EN_Entregable E
            ON AE.IdEntregable = E.IdEntregable
        LEFT JOIN EN_ContratoEntregable CE
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
    WHERE P.IdProceso = @idProceso
          AND AE.IdEntregable IS NOT NULL
		  AND PA.Orden	>=	0
          AND
          (
              AA.ActividadID IS NULL
              OR AEl.ActividadID IS NULL
              OR AR.ActividadID IS NULL
              OR CE.DiasElaboracion IS NULL
              OR CE.DiasElaboracion = 0
              OR CE.DiasRevision IS NULL
              OR CE.DiasRevision = 0
              OR CE.DiasAprobacion IS NULL
          )
    GROUP BY AE.IdEntregable,
             E.DocumentoEntregable,
             CE.IdContratoEntregable,
             CE.IdContrato;
	END

END;


