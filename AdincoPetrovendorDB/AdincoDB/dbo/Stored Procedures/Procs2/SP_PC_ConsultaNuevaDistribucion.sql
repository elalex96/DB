CREATE PROCEDURE dbo.SP_PC_ConsultaNuevaDistribucion
	@IdContrato	INT,
	@MesReporte	DATE
AS
BEGIN

SELECT
	@MesReporte		AS [Mes Reporte],
	ROUND(NuevaDistribucionProvisionalEstado,2)	AS [Nueva Dist Edo],
	ROUND(NuevaDistribucionProvisionalContratista,2)	AS [Nueva Dist Contratista],
	CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo	AS [Comp. Edo Petroleo],
	CompensacionVolNuevoSaldoAcumuladoEstadoC1			AS [Comp. Edo C1],
	CompensacionVolNuevoSaldoAcumuladoEstadoC2			AS [Comp. Edo C2],
	CompensacionVolNuevoSaldoAcumuladoEstadoC3			AS [Comp. Edo C3],
	CompensacionVolNuevoSaldoAcumuladoEstadoC4			AS [Comp. Edo C4],
	CompensacionVolNuevoSaldoAcumuladoEstadoCondensado	AS [Comp. Edo Condensado],
	CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo	AS [Comp. Contratista Petroleo],
	CompensacionVolNuevoSaldoAcumuladoContratistaC1		AS [Comp. Contratista C1],
	CompensacionVolNuevoSaldoAcumuladoContratistaC2		AS [Comp. Contratista C2],
	CompensacionVolNuevoSaldoAcumuladoContratistaC3		AS [Comp. Contratista C3],
	CompensacionVolNuevoSaldoAcumuladoContratistaC4		AS [Comp. Contratista C4],
	CompensacionVolNuevoSaldoAcumuladoContratistaCondensado	AS [Comp. Contratista Condensado]
FROM
	SIPAC_RM_FMP_53_M
WHERE
	IdContrato = @IdContrato
	AND AnioReporte	=	YEAR(DATEADD(MONTH, -1, @MesReporte))
	AND MesReporte = MONTH(DATEADD(MONTH, -1, @MesReporte))

END