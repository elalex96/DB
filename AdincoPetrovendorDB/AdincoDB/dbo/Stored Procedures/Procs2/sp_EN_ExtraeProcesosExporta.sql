-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20181023
-- Description:	Genera y simula Calculo de fechas de macroproceso
-- =============================================
CREATE PROCEDURE sp_EN_ExtraeProcesosExporta --3,10061
@IdContrato int,
@IdUsuario int
AS
BEGIN
--DROP TABLE #InstanciasProceso

CREATE TABLE #InstanciasProceso(IdProceso INT,
						IdInstanciasProcesos INT,
						idTipoProceso INT,
						IdInstalacion INT,
						NombreProceso VARCHAR(MAX),
						Descripcion varchar(MAX),
						FechaInicio DATE,
						FechaFin DATE);

INSERT INTO #InstanciasProceso (IdProceso ,IdInstanciasProcesos ,idTipoProceso ,IdInstalacion ,NombreProceso,Descripcion,FechaInicio,FechaFin )
				SELECT 
					P.IdProceso,IPF.IdInstanciasProcesos,P.idTipoProceso,P.IdInstalacion,--VISIBLES NO EN GRID
					P.NombreProceso,IPF.Descripcion, MIN(IA.FechaInicioActividad) AS FechaInicio ,MAX(ISNULL(IA.FechaRealActividad,FechaActividad)) AS FechaFin
				FROM 
					EN_InstanciasActividades	IA
				JOIN
					EN_InstanciasProcesosFecha	IPF
					ON IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
				JOIN
					EN_PROCESOS	P
					ON	IPF.IdProceso	=	P.IdProceso
				JOIN 
					EN_ProcesosContrato PC
					ON P.IdProceso	=	PC.IdProceso
					AND PC.IdContrato	=	@IdContrato
				WHERE P.IdTipoProceso	=	10000
					AND P.ACTIVO =	1
					AND IA.ACTIVO	=	1
					AND IPF.ACTIVO	=	1
				GROUP BY P.IdProceso,IPF.IdInstanciasProcesos,P.idTipoProceso,P.IdInstalacion, P.NombreProceso,IPF.Descripcion


INSERT INTO #InstanciasProceso (IdProceso ,IdInstanciasProcesos ,idTipoProceso ,IdInstalacion ,NombreProceso,Descripcion,FechaInicio,FechaFin )
				SELECT 
					MP.IdProceso,0,MP.idTipoProceso,P.IdInstalacion,--VISIBLES NO EN GRID
					MP.NombreProceso,IPF.Descripcion, MIN(IA.FechaInicioActividad) AS FechaInicio ,MAX(ISNULL(IA.FechaRealActividad,FechaActividad)) AS FechaFin
				FROM
					EN_InstanciasActividades	IA
				JOIN
					En_InstanciasProcesosFecha	IPF
					ON IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
				JOIN 
					EN_Actividades	A
					ON	IA.IdActividad	=	A.IdActividad
				JOIN 
					EN_Procesos	P
					ON	IPF.IdProceso	=	P.IdProceso
				JOIN
					EN_MacroProcesosRelacion	MPR
					ON P.IdProceso	=	MPR.idProcesoHijo
				JOIN
					EN_Procesos MP
					ON MPR.idMacroProceso	=	MP.IdProceso
				JOIN 
					EN_ProcesosContrato PC
					ON MP.IdProceso	=	PC.IdProceso
					AND PC.IdContrato	=	@IdContrato
				WHERE
					MP.ACTIVO =	1
					AND	P.ACTIVO =	1
					AND IA.ACTIVO	=	1
					AND IPF.ACTIVO	=	1
				GROUP BY MP.IdProceso,MP.idTipoProceso,P.IdInstalacion,MP.NombreProceso,IPF.Descripcion
				ORDER BY MP.NombreProceso, MIN(IA.FechaInicioActividad),MAX(ISNULL(IA.FechaRealActividad,FechaActividad)) 
	


SELECT IdProceso ,IdInstanciasProcesos ,idTipoProceso ,IdInstalacion ,NombreProceso ,Descripcion,FechaInicio ,FechaFin FROM #InstanciasProceso
END