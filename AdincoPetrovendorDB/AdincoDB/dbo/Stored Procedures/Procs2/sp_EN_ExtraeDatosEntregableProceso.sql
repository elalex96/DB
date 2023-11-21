USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_EN_ExtraeDatosEntregableProceso'
)
    DROP PROCEDURE sp_EN_ExtraeDatosEntregableProceso;
/****** Object:  StoredProcedure [dbo].[sp_EN_ExtraeDatosEntregableProceso]    Script Date: 06/11/2023 06:36:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20200424
-- =============================================
-- =============================================
-- Author:  	Daniel AC
-- Create date: 07/11/2023
-- Se agrega la columna NoRecalcular a la consulta
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeDatosEntregableProceso] --3,10061,309927
@IdContrato int,
@IdUsuario int,
@IdInstanciaEntregable	 INT
AS
BEGIN

DECLARE @IsEntregableProceso INT	=	0, 
		@IdInstanciaActividad INT	=	0, 
		@IdProceso INT = 0, 
		@IdInstanciaProceso	INT = 0, 
		@OrdenActividad INT, 
		@EntregablesFaltantes INT = 0, 
		@ActividadesFaltantes INT =0,
		@ActividadesSiguientesConFechas INT = 0,
		@NoRecalculo BIT;

SELECT @IsEntregableProceso = COUNT(1), 
		@IdInstanciaActividad	=	IA.idInstanciaActividad,
		@IdProceso =	IPF.IdProceso,
		@IdInstanciaProceso	=	IA.IdInstanciasProcesos,
		@OrdenActividad	=	PA.Orden
FROM
	EN_InstanciasEntregable	 IE	(NOLOCK)
JOIN	
	EN_ContratoEntregable	CE	(NOLOCK)
	ON IE.idInstanciaEntregable	=	@IdInstanciaEntregable
	AND	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND CE.IdContrato	=	@IdContrato
JOIN
	EN_InstanciasEntregables_InstanciaActividad		IEIA	(NOLOCK)
	ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
JOIN
	EN_InstanciasActividades	IA	(NOLOCK)
	ON IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
JOIN
	EN_ActividadesEntregables	AE	(NOLOCK)
	ON IA.IdActividad	=	AE.IdActividad
	AND	CE.IdEntregable	=	AE.IdEntregable
JOIN
	EN_InstanciasProcesosFecha	IPF	(NOLOCK)
	ON IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
JOIN
	EN_ProcesosActividades PA	(NOLOCK)
	ON IA.IdActividad	=	PA.idActividad
	AND IPF.IdProceso	=	PA.IdProceso
	AND PA.IdContrato	=	@IdContrato
	AND PA.Orden >= 0
GROUP BY IA.idInstanciaActividad,IPF.IdProceso,IA.IdInstanciasProcesos,PA.Orden


SELECT   DISTINCT @EntregablesFaltantes= COUNT(1)  
FROM EN_InstanciasEntregable IE	(NOLOCK)
JOIN	
	EN_ContratoEntregable	CE	(NOLOCK)
	ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND CE.IdContrato	=	@IdContrato
JOIN
	EN_InstanciasEntregables_InstanciaActividad		IEIA	(NOLOCK)
	ON IEIA.idInstanciaActividad = @IdInstanciaActividad 
	AND IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
WHERE 
	IEIA.idInstanciaEntregable <>	@IdInstanciaEntregable
	AND IE.Activo = 1
	AND FechaRealEntregaRegulador IS NULL


SELECT DISTINCT @ActividadesFaltantes = 
COUNT(1)  
FROM EN_InstanciasActividades	IA	(NOLOCK)
JOIN
	EN_Actividades	A	(NOLOCK)
	ON	IA.IdActividad	=	A.IdActividad
JOIN 
	EN_ProcesosActividades	PA	(NOLOCK)
	ON A.IdActividad	=	PA.IdActividad
JOIN 
	EN_Procesos	P	(NOLOCK)
	ON PA.IdProceso	=	P.IdProceso
WHERE IdInstanciasProcesos = @IdInstanciaProceso
AND	Orden <  @OrdenActividad
AND ORDEN	>= 0
AND FechaRealActividad IS NULL

SELECT DISTINCT @ActividadesSiguientesConFechas = COUNT(1)  
FROM EN_InstanciasActividades	IA	(NOLOCK)
JOIN
	EN_Actividades	A	(NOLOCK)
	ON	IA.IdActividad	=	A.IdActividad
JOIN 
	EN_ProcesosActividades	PA	(NOLOCK)
	ON A.IdActividad	=	PA.IdActividad
JOIN 
	EN_Procesos	P	(NOLOCK)
	ON PA.IdProceso	=	P.IdProceso
WHERE IdInstanciasProcesos = @IdInstanciaProceso
AND	Orden >  @OrdenActividad
AND ORDEN	>= 0
AND FechaRealActividad IS NOT NULL


SET @NoRecalculo  = (SELECT NoRecalculo 
					FROM EN_InstanciasProcesosFecha (NOLOCK)
					WHERE IdInstanciasProcesos = @IdInstanciaProceso);


SELECT @IsEntregableProceso AS IsEntregableProceso , 
	@IdInstanciaActividad AS IdInstanciaActividad , 
	@IdProceso AS IdProceso, 
	@IdInstanciaProceso AS IdInstanciaProceso, 
	@EntregablesFaltantes AS EntregablesFaltantes , 
	@ActividadesFaltantes AS ActividadesFaltantes,
	@ActividadesSiguientesConFechas AS ActividadesSiguientesConFechas,
	ISNULL(@NoRecalculo,0) AS NoRecalculo;

END