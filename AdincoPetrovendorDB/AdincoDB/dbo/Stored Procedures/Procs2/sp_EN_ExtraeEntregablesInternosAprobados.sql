CREATE PROCEDURE [dbo].[sp_EN_ExtraeEntregablesInternosAprobados]--254176,10061,3,18725
@IdInstanciaEntregable INT,
@IdUsuario INT,
@IdContrato INT,
@IdContratoentregable  INT
AS
BEGIN
--Select * from EN_InstanciasEntregable where idInstanciaEntregable=254176
    -- =============================================
    -- Author:	Reyna Olvera
    -- Create date: 2019-10-02
    -- Description:	
    -- =============================================
    SET NOCOUNT ON;
    DECLARE @IdEntregable INT =0, @IdProceso int, @FechaInstancia date;

		CREATE TABLE #InstanciasAprobadas
		(
			id int identity (1,1),
			idInstanciaEntregable	INT,
			IdContratoEntregable INT,
			FechasLimiteAprobacion DATE,
			FechaInicioElaboracion DATE,
			FechalimiteAprobacionAnterior DATE
		)
		CREATE TABLE #InstanciasFlujo
		(
			id int identity (1,1),
			idInstanciaEntregable	INT,
			IdContratoEntregable INT,
			FechasLimiteAprobacion DATE,
			FechaInicioElaboracion DATE,
			FechalimiteAprobacionAnterior DATE
		)
		CREATE TABLE #ContratosEntregables
		(
			IdContratoEntregable INT
		)


		SELECT @IdEntregable=  --11711
		CE.IdEntregable,
		 @FechaInstancia=
		ie.FechasLimiteAprobacion FROM dbo.EN_InstanciasEntregable IE
		JOIN dbo.EN_ContratoEntregable CE ON Ie.IdContratoEntregable=CE.IdContratoEntregable
		WHERE idInstanciaEntregable=@idInstanciaEntregable;  --**62622--

		SELECT @IdProceso=
		p.IdProceso FROM dbo.EN_ActividadesEntregables AE
	     JOIN  dbo.EN_ProcesosActividades PA ON AE.IdActividad=PA.idActividad AND pa.IdContrato=@IdContrato  --***
		 JOIN EN_Procesos p on pa.IdProceso=p.IdProceso AND P.IdInstalacion is not null AND p.IsProcesoEvento=0
		 WHERE AE.IdEntregable=@IdEntregable  --***

		 Insert into #ContratosEntregables
		 (IdContratoEntregable)
		SELECT ce.IdContratoEntregable from EN_ActividadesEntregables AE
			 JOIN  dbo.EN_ProcesosActividades PA ON AE.IdActividad=PA.idActividad AND pa.IdContrato=@IdContrato  --***
			 JOIN EN_Procesos p on pa.IdProceso=p.IdProceso AND P.IdInstalacion is not null AND p.IsProcesoEvento=0 AND p.IdProceso=@IdProceso ---12102
			 JOIN EN_ContratoEntregable ce on AE.IdEntregable = CE.IdEntregable AND CE.IdContrato=@IdContrato  --***
			 where ce.IdContratoEntregable != @IdContratoentregable;--16818--

		INSERT INTO #InstanciasAprobadas
		(
		idInstanciaEntregable,
		IdContratoEntregable,
		FechasLimiteAprobacion,
		FechaInicioElaboracion,
		FechalimiteAprobacionAnterior)
		Select idInstanciaEntregable,
		IE.IdContratoEntregable,
		FechasLimiteAprobacion,
		FechaInicioElaboracion,
		Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechaInicioElaboracion,1)
		from EN_InstanciasEntregable IE
			JOIN EN_Actividad a on IE.ActividadID=a.ActividadID 
			where ie.IdContratoEntregable in (
			Select * from #ContratosEntregables
			) AND FechasLimiteAprobacion < @FechaInstancia
	UNION ALL
		Select idInstanciaEntregable,
		IE.IdContratoEntregable,
		FechasLimiteAprobacion,
		FechaInicioElaboracion,
		Adinco.dbo.FN_EN_RestaDiasHabiles(IE.FechaInicioElaboracion,1)
		from EN_InstanciasEntregable IE
			where ie.idInstanciaEntregable=@idInstanciaEntregable--62622--
			--Select * from #InstanciasAprobadas

		Insert into #InstanciasFlujo
		(
		idInstanciaEntregable,
		IdContratoEntregable,
		FechasLimiteAprobacion,
		FechaInicioElaboracion,
		FechalimiteAprobacionAnterior)
		SELECT 
		 ia2.idInstanciaEntregable,
		 ia2.IdContratoEntregable,
		 ia2.FechasLimiteAprobacion,
		 ia2.FechaInicioElaboracion,
		 ia2.FechalimiteAprobacionAnterior FROM #InstanciasAprobadas IA1
		LEFT JOIN #InstanciasAprobadas  IA2 ON IA1.FechalimiteAprobacionAnterior=IA2.FechasLimiteAprobacion
		WHERE ia2.id is  not null

	SELECT ia.FechasLimiteAprobacion,e.DocumentoEntregable, IdLineaTiempo, ia.idInstanciaEntregable,e.Consecutivo, es.NombreEstado
	FROM
	#InstanciasFlujo IA 
	JOIN EN_InstanciasEntregable ie on ia.idInstanciaEntregable=ie.idInstanciaEntregable
	JOIN EN_Actividad a on ie.ActividadID=a.ActividadID
	JOIN EN_Estado es on a.EstadoID=es.EstadoID
	JOIN EN_ContratoEntregable ce on ia.IdContratoEntregable=ce.IdContratoEntregable
	JOIN EN_Entregable e on ce.IdEntregable=e.IdEntregable
	JOIN EN_HistorialAprobacionesLineaTiempo HAL on IA.idInstanciaEntregable=HAL.idInstanciaEntregable 
	AND idTipoOperacion=4
	GROUP BY ia.FechasLimiteAprobacion,e.DocumentoEntregable, IdLineaTiempo, ia.idInstanciaEntregable,e.Consecutivo, es.NombreEstado
	ORDER BY ia.FechasLimiteAprobacion;

	END;

