CREATE PROCEDURE [dbo].[co_sp_ExtraeIdLineaPresupuestoPorWBSContrato]--1,10038,''
    @IdUsuario INT,
    @IdContrato INT,
	@WBS VARCHAR(300) =''
AS
BEGIN
	IF(@WBS='')
	BEGIN
		SELECT 
			WL.Id,WBS.WBS,IdLineaPresupuesto, WBS.IdContrato, PM.IdPresupuesto
		FROM
			Petrovendor.dbo.WDEA_WBSLineaPresupuesto WL
		JOIN 
			Petrovendor.dbo.WDEA_WBS WBS (NOLOCK)  
			ON WL.IdWBS = WBS.Id
		JOIN
			CO_LineaPresupuestoMes	PM (NOLOCK)  
			ON	IdLineaPresupuesto	=	PM.IdLineaPresupuestoMes
		WHERE 
			WBS.IdContrato = @IdContrato
			AND WL.Activo = 1
			AND WBS.Activo = 1
		ORDER BY WL.id 
		DESC
	END
	ELSE
	BEGIN
		SELECT 
			WL.Id,WBS.WBS,IdLineaPresupuesto , PM.IdPresupuesto
		FROM
			Petrovendor.dbo.WDEA_WBSLineaPresupuesto WL
		JOIN 
			Petrovendor.dbo.WDEA_WBS WBS (NOLOCK)  
			ON WL.IdWBS = WBS.Id
			AND WL.Activo = 1
			AND WBS.Activo = 1
		JOIN
			CO_LineaPresupuestoMes	PM (NOLOCK)  
			ON	IdLineaPresupuesto	=	PM.IdLineaPresupuestoMes
		WHERE 
			WBS.IdContrato = @IdContrato
			AND	WBS.WBS = @WBS
		ORDER BY WL.id 
		DESC
	END

END;

------------------------------------------------------------------------------