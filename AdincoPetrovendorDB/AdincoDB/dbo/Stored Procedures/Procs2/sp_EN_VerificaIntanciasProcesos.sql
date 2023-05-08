-- =============================================
-- Author:  Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_VerificaIntanciasProcesos] --3,10061,11047,12092
@idContrato int,
@idUsuario int,
@idInstanciaProceso int,
@idProceso int,
@Idinstalacion INT
AS
BEGIN
  SET NOCOUNT ON;
  Create table #ProcesosHijo(idproceso int);
  
  IF((SELECT idTipoProceso FROM EN_Procesos WHERE IdProceso=@idProceso)=10002)
	BEGIN 
		INSERT INTO #ProcesosHijo(idproceso)
		SELECT idProcesoHijo FROM EN_MacroProcesosRelacion MPR
		JOIN EN_Procesos P ON MPR.idProcesoHijo=P.IdProceso AND MPR.idMacroProceso=@idProceso
		AND P.IdInstalacion=@Idinstalacion
	
		 SELECT COUNT(1)
			  FROM dbo.EN_InstanciasProcesosFecha IPF
			  JOIN #ProcesosHijo P
			  ON IPF.IdProceso=P.idproceso
			  JOIN dbo.EN_InstanciasActividades IA
				ON IPF.IdInstanciasProcesos = IA.IdInstanciasProcesos
			  JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
				ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
			  JOIN dbo.EN_InstanciasEntregable IE
				ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
			  JOIN dbo.EN_Actividad A
				ON IE.ActividadID = A.ActividadID
				AND A.IdContratoEntregable = IE.IdContratoEntregable
			  LEFT JOIN EN_EntregableDocumento ED
				ON ED.idInstanciaEntregable = IE.idInstanciaEntregable
			  WHERE A.EstadoID <> 10000
			  AND IE.Activo = 1
	END
	ELSE
	BEGIN --PROCESOS DE EVENTO
		  SELECT COUNT(1)
		  FROM dbo.EN_InstanciasProcesosFecha IPF
		  JOIN dbo.EN_InstanciasActividades IA
			ON IPF.IdInstanciasProcesos = IA.IdInstanciasProcesos
			AND IPF.IdInstanciasProcesos = @idInstanciaProceso
		  JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
			ON IA.idInstanciaActividad = IEIA.idInstanciaActividad
		  JOIN dbo.EN_InstanciasEntregable IE
			ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
		  JOIN dbo.EN_Actividad A
			ON IE.ActividadID = A.ActividadID
			AND A.IdContratoEntregable = IE.IdContratoEntregable
		  LEFT JOIN EN_EntregableDocumento ED
			ON ED.idInstanciaEntregable = IE.idInstanciaEntregable
		  WHERE IPF.IdInstanciasProcesos = @idInstanciaProceso
		  AND A.EstadoID <> 10000
		  AND IE.Activo = 1
	END

END;

