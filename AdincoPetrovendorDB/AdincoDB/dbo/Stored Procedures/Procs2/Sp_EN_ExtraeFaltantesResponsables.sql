-- =============================================
-- Author:		Reyna Olvera
-- Create date: 18/03/2019
-- Description:	
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/01/2023
-- Description:	se iguala la consulta a la validacion del guardado de las fechas
-- =============================================
CREATE PROCEDURE [dbo].[Sp_EN_ExtraeFaltantesResponsables] --10041,10061,11060
    @idContrato INT, --3
    @idUsuario INT,
    @idProceso INT
AS
BEGIN
		 CREATE TABLE #ActividadesGuarda (
    IdProceso int,
    DescripcionProceso varchar(2500),
    IdContrato int,
    Orden int,
    IdActividad int,
    NombreActividad varchar(2500),
    Dias int,
    DiasNaturales bit,
    FechaInicial date,
    FechaLimite date,
    IdActividadPredecesora int,
    IdActividadSucesora int,
	PRIMARY KEY (IdActividad)
  );

    CREATE TABLE #ActividadesGuardaSinEntregable (
    IdProceso int,
    DescripcionProceso varchar(2500),
    IdContrato int,
    Orden int,
    IdActividad int,
    NombreActividad varchar(2500),
    Dias int,
    DiasNaturales bit,
    FechaInicial date,
    FechaLimite date,
    IdActividadPredecesora int,
    IdActividadSucesora int,
	PRIMARY KEY (IdActividad)
  );

  Create table #ProcesosHijo(idproceso int);

  DECLARE @FECHA DATETIME = GETDATE()
  
  IF((SELECT idTipoProceso FROM EN_Procesos WHERE IdProceso=@idProceso)=10002)
	BEGIN 
		INSERT INTO #ProcesosHijo(idproceso)
		SELECT idProcesoHijo FROM EN_MacroProcesosRelacion MPR (NOLOCK)
		JOIN EN_Procesos P (NOLOCK) ON MPR.idProcesoHijo=P.IdProceso
		 AND MPR.idMacroProceso=@idProceso
		 AND MPR.IdprocesoOriginal IS NULL

			SELECT AE.IdEntregable,
           E.DocumentoEntregable,
           CE.IdContratoEntregable,
           CE.IdContrato
    FROM dbo.#ProcesosHijo P
        JOIN dbo.EN_ProcesosActividades PA (NOLOCK)
            ON PA.IdProceso = P.IdProceso
               AND PA.Activo = 1
		JOIN dbo.EN_Actividades AS ACT (NOLOCK)
			ON PA.idActividad = ACT.IdActividad
            AND ACT.Activo = 1
        LEFT JOIN dbo.EN_ActividadesEntregables AE (NOLOCK)
            ON PA.idActividad = AE.IdActividad
        LEFT JOIN EN_Entregable E (NOLOCK)
            ON AE.IdEntregable = E.IdEntregable
        LEFT JOIN EN_ContratoEntregable CE
            ON AE.IdEntregable = CE.IdEntregable (NOLOCK)
               AND CE.IdContrato = @idContrato
        LEFT JOIN dbo.EN_Actividad AEl (NOLOCK)
            ON AEl.IdContratoEntregable = CE.IdContratoEntregable
               AND AEl.EstadoID = 10000
               AND AEl.Activo  = 1
        LEFT JOIN dbo.EN_Actividad AR (NOLOCK)
            ON AR.IdContratoEntregable = CE.IdContratoEntregable
               AND AR.EstadoID = 10001
               AND AR.Activo  = 1
        LEFT JOIN dbo.EN_Actividad AA (NOLOCK)
            ON AA.IdContratoEntregable = CE.IdContratoEntregable
               AND AA.EstadoID = 10002
               AND AA.Activo  = 1
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
		

INSERT INTO #ActividadesGuarda	(IdProceso,DescripcionProceso,IdContrato,Orden,IdActividad,NombreActividad,Dias,DiasNaturales,FechaInicial,FechaLimite,IdActividadPredecesora,IdActividadSucesora)
EXEC	sp_GeneraFechasProcesos	@idContrato,
								@idUsuario,
								@FECHA,
								@idProceso


        INSERT INTO #ActividadesGuardaSinEntregable 
		(IdProceso,DescripcionProceso,IdContrato,Orden,IdActividad,NombreActividad,Dias,DiasNaturales,FechaInicial,FechaLimite,IdActividadPredecesora,IdActividadSucesora)
          SELECT	AE.IdProceso,
					AE.DescripcionProceso,
					AE.IdContrato,
					AE.Orden,
					AE.IdActividad,
					AE.NombreActividad,
					AE.Dias,
					AE.DiasNaturales,
					AE.FechaInicial,
					AE.FechaLimite,
					AE.IdActividadPredecesora,
					AE.IdActividadSucesora
          FROM	
			#ActividadesGuarda	AE
          LEFT	JOIN 
			dbo.EN_ActividadesEntregables	A (NOLOCK)
            ON	AE.IdActividad	=	A.IdActividad
          WHERE	A.IdActividad	IS	NULL


        DELETE	AG
		FROM	
			#ActividadesGuarda AG
		JOIN
			#ActividadesGuardaSinEntregable ASE
			ON AG.IdActividad = ASE.IdActividad

        SELECT	E.IdEntregable,
           E.DocumentoEntregable,
           CE.IdContratoEntregable,
           CE.IdContrato
        FROM
			#ActividadesGuarda A
        JOIN
			EN_ActividadesEntregables	AE
			ON	A.idActividad = AE.IdActividad
        LEFT JOIN
			EN_Entregable E
			ON	AE.IdEntregable = E.IdEntregable
			AND E.IsActivo = 1
        LEFT JOIN
			EN_ContratoEntregable CE
			ON	AE.IdEntregable	=	CE.IdEntregable
			AND	CE.IdContrato	=	@idContrato
			AND CE.Activo = 1
        LEFT JOIN
			dbo.EN_Actividad AEl
			ON	AEl.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	AEl.EstadoID	=	10000
			AND AEl.Activo = 1
        LEFT JOIN 
			dbo.EN_Actividad	AR
			ON	AR.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	AR.EstadoID	=	10001
			AND AR.Activo = 1
        LEFT JOIN 
			dbo.EN_Actividad	AA
			ON	AA.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	AA.EstadoID	=	10002
			AND AA.Activo = 1
        WHERE
			AE.IdEntregable IS NOT NULL
			AND (
				AA.ActividadID IS NULL
				OR AEl.ActividadID IS NULL
				OR AR.ActividadID IS NULL
				OR CE.DiasElaboracion IS NULL
				OR CE.DiasElaboracion = 0
				OR CE.DiasRevision IS NULL
				OR CE.DiasRevision = 0
				OR CE.DiasAprobacion IS NULL
				)--Verifica los responsables


	END

END;

