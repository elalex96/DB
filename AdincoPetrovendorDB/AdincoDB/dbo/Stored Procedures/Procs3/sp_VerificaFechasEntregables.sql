-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Genera Calculo de fechas
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerificaFechasEntregables]-- 3,10061,12793,12219,12219--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT,
    @idInstanciaProceso INT,
	@idInstalacion INT
AS
BEGIN
    CREATE TABLE #ProcesoDeMacro
    (
        id INT IDENTITY(1, 1),
        idProceso INT
    );

    CREATE TABLE #InstanciasProceso
    (
        id INT IDENTITY(1, 1),
        IdInstanciasProcesos INT
    );
	DECLARE @IdTipoP INT;

	SELECT @IdTipoP	=	idTipoProceso FROM EN_Procesos WHERE IdProceso	=	@idProceso

    IF (@idInstanciaProceso <> 0 AND @IdTipoP <> 10002)
    BEGIN
        SELECT p.IdProceso,
               ie.idInstanciaEntregable,
               ia.IdInstanciasProcesos,
               ia.idInstanciaActividad,
               a.Activo,
               ia.Activo,
               ie.FechasLimiteAprobacion,
               ie.FechaCalculadaEntregaReg,
               ie.FechaRealEntregaRegulador,
               ISNULL(ie.FechaRealEntregaRegulador, ie.FechaCalculadaEntregaReg) AS FechaRegulador,
               e.DocumentoEntregable,
               e.Consecutivo,
               ia.FechaActividad,
               a.NombreActividad,
               f.FrecuenciaEntregable,
               ROW_NUMBER() OVER (ORDER BY FechasLimiteAprobacion ASC) AS c,
               CASE p.idTipoProceso
                   WHEN 10001 THEN
                       'true'
                   ELSE
                       'false'
               END AS isMacroProceso,
               CASE
                   WHEN ie.FechaRealEntregaRegulador IS NULL THEN
                       'false'
                   ELSE
                       'true'
               END AS isFechaReal,
               'Estado del entregable: ' + es.NombreEstado AS NombreEstado,
               ie.FechaInicioElaboracion,
               CASE
                   WHEN e.BitInterno = 1 THEN
                       'Entregable Interno'
                   ELSE
                       'Entregable'
               END AS TipoEntregable
		FROM EN_Entregable e (NOLOCK)
			 JOIN EN_ContratoEntregable ce (NOLOCK)
				  ON e.IdEntregable = ce.IdEntregable
					AND ce.IdContrato = @idContrato
			 
			 JOIN dbo.EN_InstanciasEntregable ie (NOLOCK)
				  ON ie.IdContratoEntregable = ce.IdContratoEntregable 
				    AND ie.Activo = 1 
             JOIN dbo.EN_InstanciasEntregables_InstanciaActividad ieia  (NOLOCK)
                ON ieia.idInstanciaEntregable = ie.idInstanciaEntregable
				   AND IEIA.ACTIVO = 1 				   
                   
            JOIN dbo.EN_InstanciasActividades ia (NOLOCK)
                ON ieia.idInstanciaActividad = ia.idInstanciaActividad  
            JOIN dbo.EN_InstanciasProcesosFecha IP (NOLOCK)
                ON ia.IdInstanciasProcesos = IP.IdInstanciasProcesos  
                   AND IP.Activo = 1
				   AND IP.IdInstanciasProcesos = @idInstanciaProceso  
            
            JOIN dbo.EN_FrecuenciaEntregable f (NOLOCK)
                ON e.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable  
            JOIN dbo.EN_Actividades a (NOLOCK)
                ON ia.IdActividad = a.IdActividad  
            JOIN dbo.EN_Procesos p (NOLOCK)
                ON p.IdProceso = IP.IdProceso  
            JOIN dbo.EN_Actividad ac (NOLOCK)
                ON ie.ActividadID = ac.ActividadID  
            JOIN dbo.EN_Estado es (NOLOCK)
                ON ac.EstadoID = es.EstadoID 
        ORDER BY ie.FechasLimiteAprobacion ASC;

    END;
    ELSE
    BEGIN

        INSERT INTO #ProcesoDeMacro (idProceso)
        SELECT 
			idProcesoHijo
        FROM 
			dbo.EN_MacroProcesosRelacion	MPR
		JOIN
			EN_Procesos	P
			ON	MPR.idProcesoHijo	=P.IdProceso
			AND P.IdInstalacion	=	@idInstalacion
			AND MPR.idMacroProceso =	@idProceso;

        INSERT INTO #InstanciasProceso (IdInstanciasProcesos)
		SELECT 
			IPF.IdInstanciasProcesos
        FROM 
			#ProcesoDeMacro	PM
		JOIN
			dbo.EN_InstanciasProcesosFecha	IPF
			ON	IPF.IdProceso	=	PM.idProceso


        SELECT p.IdProceso,
               ie.idInstanciaEntregable,
               ia.IdInstanciasProcesos,
               ia.idInstanciaActividad,
               a.Activo,
               ia.Activo,
               ie.FechasLimiteAprobacion,
               ie.FechaCalculadaEntregaReg,
               ie.FechaRealEntregaRegulador,
               ISNULL(ie.FechaRealEntregaRegulador, ie.FechaCalculadaEntregaReg) AS FechaRegulador,
               e.DocumentoEntregable,
               e.Consecutivo,
               ia.FechaActividad,
               a.NombreActividad,
               f.FrecuenciaEntregable,
               ROW_NUMBER() OVER (ORDER BY FechasLimiteAprobacion ASC) AS c,
               CASE p.idTipoProceso
                   WHEN 10001 THEN
                       'true'
                   ELSE
                       'false'
               END AS isMacroProceso,
               CASE
                   WHEN ie.FechaRealEntregaRegulador IS NULL THEN
                       'false'
                   ELSE
                       'true'
               END AS isFechaReal,
               'Estado del entregable: ' + es.NombreEstado AS NombreEstado,
               ie.FechaInicioElaboracion,
               CASE
                   WHEN e.BitInterno = 1 THEN
                       'Entregable Interno'
                   ELSE
                       'Entregable'
               END AS TipoEntregable
        FROM 
			dbo.EN_InstanciasEntregable ie	(NOLOCK)
		JOIN 
			dbo.EN_InstanciasEntregables_InstanciaActividad ieia	(NOLOCK)
			ON  ie.idInstanciaEntregable	=	ieia.idInstanciaEntregable
			AND ie.Activo = 1
		JOIN 
			dbo.EN_InstanciasActividades ia	(NOLOCK)
			ON ieia.idInstanciaActividad = ia.idInstanciaActividad
		JOIN
			#InstanciasProceso	TMPIP	(NOLOCK)
			ON	ia.IdInstanciasProcesos	=	TMPIP.IdInstanciasProcesos
		JOIN 
			dbo.EN_InstanciasProcesosFecha IP	(NOLOCK)
			ON TMPIP.IdInstanciasProcesos = IP.IdInstanciasProcesos
			AND IP.Activo = 1
		JOIN 
			dbo.EN_ContratoEntregable ce	(NOLOCK)
			ON ie.IdContratoEntregable = ce.IdContratoEntregable
			AND ce.IdContrato = @idContrato
		JOIN 
			dbo.EN_Entregable e	(NOLOCK)
			ON ce.IdEntregable = e.IdEntregable
		JOIN 
			dbo.EN_FrecuenciaEntregable f	(NOLOCK)
			ON e.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
		JOIN	
			dbo.EN_Actividades a	(NOLOCK)
			ON ia.IdActividad = a.IdActividad
		JOIN 
			dbo.EN_Procesos p	(NOLOCK)
			ON p.IdProceso = IP.IdProceso
		JOIN 
			dbo.EN_Actividad ac	(NOLOCK)
			ON ie.ActividadID = ac.ActividadID
		JOIN 
			dbo.EN_Estado es	(NOLOCK)
			ON ac.EstadoID = es.EstadoID
--        WHERE 
			--IP.IdInstanciasProcesos IN	(SELECT IdInstanciasProcesos FROM #InstanciasProceso)
        ORDER BY 
			ie.FechasLimiteAprobacion ASC;
    END;

END;