CREATE PROCEDURE [dbo].[p_ReportePerforacionET] --11463,10112
	@pIdContrato int,
	@pIdProceso int
AS
BEGIN

DECLARE @TipoProceso INT

SELECT @TipoProceso = idTipoProceso
FROM EN_Procesos
WHERE IdProceso=@pIdProceso

IF 10000 = @TipoProceso
BEGIN

	SELECT TOP 40
	FechasLimiteAprobacion = convert(varchar(10),ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad),103),
	e.NombreActividad,
	Cargo = CASE WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 1 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 2 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 3 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 4 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 5 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 6 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 7 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 8 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 9 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 10 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 11 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 12 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 13 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 14 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 15 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 16 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 17 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 18 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 19 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 20 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 21 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 22 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 23 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 24 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 25 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 26 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 27 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ) = 28 THEN -.75
			end,
	SUBSTRING(p.NombreProceso,0,30) AS NombreProceso,
		e.IdActividad,
		e.NombreActividad,
		ie.FechaCalculadaEntregaReg,
		pa.Orden,
		ROW_NUMBER() OVER(ORDER BY ie.FechaCalculadaEntregaReg ASC)
   --SELECT *
	FROM dbo.EN_Procesos p
	left join EN_ProcesosActividades pa on pa.IdProceso = p.IdProceso
		AND pa.Activo = 1
	left join [dbo].[EN_Actividades] e on e.IdActividad = pa.idActividad
		and e.activo = 1
	left join EN_InstanciasProcesosFecha ipf on ipf.IdProceso = p.IdProceso
		and ipf.Activo = 1
	left join EN_InstanciasActividades ia on ia.IdActividad = e.IdActividad
		and ia.Activo = 1
	left  join EN_InstanciasEntregables_InstanciaActividad iea on iea.idInstanciaActividad = ia.idInstanciaActividad
	left join EN_InstanciasEntregable ie on ie.idInstanciaEntregable = iea.idInstanciaEntregable
	where p.IdProceso=@pIdProceso and
	pa.IdContrato = @pIdContrato
	AND e.Activo=1
	GROUP BY 
		convert(varchar(10),ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad),103),
		SUBSTRING(p.NombreProceso,0,30)  ,
		e.IdActividad,
		e.NombreActividad,
		ie.FechaCalculadaEntregaReg,
		pa.Orden
	order by ie.FechaCalculadaEntregaReg--,pa.Orden
END
ELSE
BEGIN

	SELECT TOP 40
	FechasLimiteAprobacion = convert(varchar,ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad),103),
	e.NombreActividad,
	Cargo = CASE WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 1 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 2 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 3 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 4 THEN -.50
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 5 THEN .25
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 6 THEN -.25
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 7 THEN 1.25
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 8 THEN -1.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 9 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 10 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 11 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 12 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 13 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 14 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 15 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 16 THEN 1.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 17 THEN -1.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 18 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 19 THEN .25
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 20 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 21 THEN 1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 22 THEN .75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 23 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 24 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 25 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 26 THEN -1
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 27 THEN -.5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 28 THEN -.75
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 29 THEN .5
					WHEN  ROW_NUMBER() OVER(ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ) = 30 THEN .75
			end,
	--Cargo = CASE WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 1 THEN 1
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 2 THEN .75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 3 THEN .5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 4 THEN -.75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 5 THEN -.5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 6 THEN -1
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 7 THEN -.5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 8 THEN -.75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 9 THEN .5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 10 THEN .75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 11 THEN 1
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 12 THEN .75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 13 THEN .5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 14 THEN -.75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 15 THEN -.5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 16 THEN -1
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 17 THEN -.5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 88 THEN -.75
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 19 THEN .5
	--				WHEN  ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ) = 20 THEN .75
	--		end,
	SUBSTRING(p.NombreProceso,0,30) AS NombreProceso,
		e.IdActividad,
		e.NombreActividad,
		--ie.FechasLimiteAprobacion,
		ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) as FechasLimiteAprobacion,
		pa.Orden,
		--ROW_NUMBER() OVER(ORDER BY ie.FechasLimiteAprobacion ASC)
		ROW_NUMBER() OVER (ORDER BY ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) ASC)
	FROM	EN_MacroProcesosRelacion	MP
	JOIN	dbo.EN_Procesos p
		ON	MP.idProcesoHijo	=	P.IdProceso
	left join EN_ProcesosActividades pa on pa.IdProceso = p.IdProceso
		and pa.Activo = 1
	left join [dbo].[EN_Actividades] e on e.IdActividad = pa.idActividad
	left join EN_InstanciasProcesosFecha ipf on ipf.IdProceso = p.IdProceso
		and ipf.activo = 1
	left join EN_InstanciasActividades ia on ia.IdActividad = e.IdActividad
		and ia.activo = 1
	left  join EN_InstanciasEntregables_InstanciaActividad iea on iea.idInstanciaActividad = ia.idInstanciaActividad
	left join EN_InstanciasEntregable ie on ie.idInstanciaEntregable = iea.idInstanciaEntregable
	where MP.idMacroProceso	=	@pIdProceso
		AND pa.IdContrato = @pIdContrato
		AND e.Activo = 1
	group BY 
		convert(varchar,ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad),103),
		SUBSTRING(p.NombreProceso,0,30)  ,
		e.IdActividad,
		e.NombreActividad,
		--ie.FechasLimiteAprobacion,
		ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad),
		pa.Orden
	order by ISNULL(ie.FechaCalculadaEntregaReg,ia.FechaActividad) --ie.FechasLimiteAprobacion--,pa.Orden
END

END
