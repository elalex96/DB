CREATE PROCEDURE [dbo].[PC_Generar_VolMensualProduccion_RM53]
	@IdContrato INT,
    @MesReporte DATE,
	@Usuario	INT,
	@FechaLimite	DATETIME,
	@Debug		BIT
AS
BEGIN
-- =============================================
-- Author:		Barbara Arrañaga
-- Create date: 2018-03-07
-- Description:	Proceso para generar automaticamente la infornmación de las tablas PR_VolumenMensualProduccionPetroleo y SIPAC_RM_FMP_53_M
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- =============================================
-- 20180726	BAAC	Se modifica para agregar los valores de condensable
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #PC_VolumenProduccionPeriodo
(
	Id	INT,
	IdContrato	INT,
	MesReporte	DATE,
	FechaInicio	DATE,
	FechaFin	DATE,
	VolumenPetroleoPuntoMedicion	FLOAT,
	GradosAPI	FLOAT,
	ContenidoAzufre	FLOAT,
	VolumenPetroleoAutoconsumo	FLOAT,
	MetanoC1	FLOAT,
	EtanoC2	FLOAT,
	PropanoC3	FLOAT,
	ButanoC4	FLOAT,
	MetanoC1Autoconsumo	FLOAT,
	EtanoC2Autoconsumo	FLOAT,
	PropanoC3Autoconsumo	FLOAT,
	ButanoC4Autoconsumo	FLOAT,
	VolumenCondensadoPuntoMedicion	FLOAT,
	VolumenCondensadoAutoconsumo	FLOAT,
	Bit_CasoFortuito	BIT,
	CantDiasCasoFortuito	INT,
	OtrosIngresosUsoCompartidoInfraestructura	DECIMAL(16,4),
	VolumenPetroleoContratistaReparticion	FLOAT,
	VolumenMetanoC1ContratistaReparticion	FLOAT,
	VolumenEtanoC2ContratistaReparticion	FLOAT,
	VolumenPropanoC3ContratistaReparticion	FLOAT,
	VolumenButanoC4ContratistaReparticion	FLOAT,
	VolumenCondensadosContratistaReparticion	FLOAT,
	VolumenPetroleoEstadoReparticion	FLOAT,
	VolumenMetanoC1EstadoReparticion	FLOAT,
	VolumenEtanoC2EstadoReparticion	FLOAT,
	VolumenPropanoC3EstadoReparticion	FLOAT,
	VolumenButanoC4EstadoReparticion	FLOAT,
	VolumenCondensadosEstadoReparticion	FLOAT,
	VolumenPetroleoContratistaCompensacion	FLOAT,
	VolumenMetanoC1ContratistaCompensacion	FLOAT,
	VolumenEtanoC2ContratistaCompensacion	FLOAT,
	VolumenPropanoC3ContratistaCompensacion	FLOAT,
	VolumenButanoC4ContratistaCompensacion	FLOAT,
	VolumenCondensadosContratistaCompensacion	FLOAT,
	VolumenPetroleoEstadoCompensacion	FLOAT,
	VolumenMetanoC1EstadoCompensacion	FLOAT,
	VolumenEtanoC2EstadoCompensacion	FLOAT,
	VolumenPropanoC3EstadoCompensacion	FLOAT,
	VolumenButanoC4EstadoCompensacion	FLOAT,
	VolumenCondensadosEstadoCompensacion	FLOAT,
	AcumuladoCostosRecuperablesInsolutos	MONEY,
	VolumenCondensablePuntoMedicion		FLOAT,
	VolumenCondensableAutoconsumo		FLOAT
)
CREATE TABLE #Temp_PC_VolumenProduccionPeriodo
(
	IdContrato	INT,
	MesReporte	DATE,
	FechaInicio	DATE,
	FechaFin	DATE,
	VolumenPetroleoPuntoMedicion	FLOAT,
	GradosAPI	FLOAT,
	ContenidoAzufre	FLOAT,
	VolumenPetroleoAutoconsumo	FLOAT,
	MetanoC1	FLOAT,
	EtanoC2	FLOAT,
	PropanoC3	FLOAT,
	ButanoC4	FLOAT,
	MetanoC1Autoconsumo	FLOAT,
	EtanoC2Autoconsumo	FLOAT,
	PropanoC3Autoconsumo	FLOAT,
	ButanoC4Autoconsumo	FLOAT,
	VolumenCondensadoPuntoMedicion	FLOAT,
	VolumenCondensadoAutoconsumo	FLOAT,
	Bit_CasoFortuito	BIT,
	CantDiasCasoFortuito	INT,
	OtrosIngresosUsoCompartidoInfraestructura	DECIMAL(16,4),
	VolumenPetroleoContratistaReparticion	FLOAT,
	VolumenMetanoC1ContratistaReparticion	FLOAT,
	VolumenEtanoC2ContratistaReparticion	FLOAT,
	VolumenPropanoC3ContratistaReparticion	FLOAT,
	VolumenButanoC4ContratistaReparticion	FLOAT,
	VolumenCondensadosContratistaReparticion	FLOAT,
	VolumenPetroleoEstadoReparticion	FLOAT,
	VolumenMetanoC1EstadoReparticion	FLOAT,
	VolumenEtanoC2EstadoReparticion	FLOAT,
	VolumenPropanoC3EstadoReparticion	FLOAT,
	VolumenButanoC4EstadoReparticion	FLOAT,
	VolumenCondensadosEstadoReparticion	FLOAT,
	VolumenPetroleoContratistaCompensacion	FLOAT,
	VolumenMetanoC1ContratistaCompensacion	FLOAT,
	VolumenEtanoC2ContratistaCompensacion	FLOAT,
	VolumenPropanoC3ContratistaCompensacion	FLOAT,
	VolumenButanoC4ContratistaCompensacion	FLOAT,
	VolumenCondensadosContratistaCompensacion	FLOAT,
	VolumenPetroleoEstadoCompensacion	FLOAT,
	VolumenMetanoC1EstadoCompensacion	FLOAT,
	VolumenEtanoC2EstadoCompensacion	FLOAT,
	VolumenPropanoC3EstadoCompensacion	FLOAT,
	VolumenButanoC4EstadoCompensacion	FLOAT,
	VolumenCondensadosEstadoCompensacion	FLOAT,
	AcumuladoCostosRecuperablesInsolutos	MONEY,
	VolumenCondensablePuntoMedicion		FLOAT,
	VolumenCondensableAutoconsumo		FLOAT
)
CREATE TABLE #PC_RM
(
	Id	INT,
	Mes	DATE,
	IdSIPAC	VARCHAR(500),
	IDRegistroFiduciario	VARCHAR(500),
	IDContratoCNH	VARCHAR(500),
	MesReporte	INT,
	AnioReporte	INT,
	ContraprestacionEstadoCuotaExplo	MONEY,
	ContraprestacionesEstadoProdInsuficiente	MONEY,
	VolCalculadoDistribucionFinalEstadoPetroleo	INT,
	VolCalculadoDistribucionFinalEstadoC1	INT,
	VolCalculadoDistribucionFinalEstadoC2	INT,
	VolCalculadoDistribucionFinalEstadoC3	INT,
	VolCalculadoDistribucionFinalEstadoC4	INT,
	VolCalculadoDistribucionFinalEstadoCondensados	INT,
	VolCalculadoDistribucionFinalContratistaPetroleo	INT,
	VolCalculadoDistribucionFinalContratistaC1	INT,
	VolCalculadoDistribucionFinalContratistaC2	INT,
	VolCalculadoDistribucionFinalContratistaC3	INT,
	VolCalculadoDistribucionFinalContratistaC4	INT,
	VolCalculadoDistribucionFinalContratistaCondensado	INT,
	VolRecibidoEstadoPuntoMedPetroleo	INT,
	VolRecibidoEstadoPuntoMedC1	INT,
	VolRecibidoEstadoPuntoMedC2	INT,
	VolRecibidoEstadoPuntoMedC3	INT,
	VolRecibidoEstadoPuntoMedC4	INT,
	VolRecibidoEstadoPuntoMedCondensado	INT,
	VolRecibidoContratistaPuntoMedPetroleo	INT,
	VolRecibidoContratistaPuntoMedC1	INT,
	VolRecibidoContratistaPuntoMedC2	INT,
	VolRecibidoContratistaPuntoMedC3	INT,
	VolRecibidoContratistaPuntoMedC4	INT,
	VolRecibidoContratistaPuntoMedCondensado	INT,
	CompensacionVolSaldoAcumuladoEstadoPetroleo	INT,
	CompensacionVolSaldoAcumuladoEstadoC1	INT,
	CompensacionVolSaldoAcumuladoEstadoC2	INT,
	CompensacionVolSaldoAcumuladoEstadoC3	INT,
	CompensacionVolSaldoAcumuladoEstadoC4	INT,
	CompensacionVolSaldoAcumuladoEstadoCondensado	INT,
	CompensacionVolSaldoAcumuladoContratistaPetroleo	INT,
	CompensacionVolSaldoAcumuladoContratistaC1	INT,
	CompensacionVolSaldoAcumuladoContratistaC2	INT,
	CompensacionVolSaldoAcumuladoContratistaC3	INT,
	CompensacionVolSaldoAcumuladoContratistaC4	INT,
	CompensacionVolSaldoAcumuladoContratistaCondensado	INT,
	CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo	INT,
	CompensacionVolNuevoSaldoAcumuladoEstadoC1	INT,
	CompensacionVolNuevoSaldoAcumuladoEstadoC2	INT,
	CompensacionVolNuevoSaldoAcumuladoEstadoC3	INT,
	CompensacionVolNuevoSaldoAcumuladoEstadoC4	INT,
	CompensacionVolNuevoSaldoAcumuladoEstadoCondensado	INT,
	CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo	INT,
	CompensacionVolNuevoSaldoAcumuladoContratistaC1	INT,
	CompensacionVolNuevoSaldoAcumuladoContratistaC2	INT,
	CompensacionVolNuevoSaldoAcumuladoContratistaC3	INT,
	CompensacionVolNuevoSaldoAcumuladoContratistaC4	INT,
	CompensacionVolNuevoSaldoAcumuladoContratistaCondensado	INT,
	NuevaDistribucionProvisionalEstado	FLOAT,
	NuevaDistribucionProvisionalContratista	FLOAT
)

CREATE TABLE #Totales
(
	Total_Produccion_Petroleo	FLOAT,
	Total_Dist_Oper_Petroleo	FLOAT,
	Total_Dist_Estado_Petroleo	FLOAT,
	Total_Vol_Oper_Activo		FLOAT,
	Total_Vol_Estado_Activo		FLOAT,
	Total_MMBTU			FLOAT,
	Total_C1			FLOAT,
	Total_C2			FLOAT,
	Total_C3			FLOAT,
	Total_C4			FLOAT,
	Total_Dist_Vol_Oper_C1	FLOAT,
	Total_Dist_Vol_Oper_C2	FLOAT,
	Total_Dist_Vol_Oper_C3	FLOAT,
	Total_Dist_Vol_Oper_C4	FLOAT,
	Total_Dist_Vol_Oper_MMBTU	FLOAT,
	Total_Dist_Vol_Estado_C1	FLOAT,
	Total_Dist_Vol_Estado_C2	FLOAT,
	Total_Dist_Vol_Estado_C3	FLOAT,
	Total_Dist_Vol_Estado_C4	FLOAT,
	Total_Dist_Vol_Estado_MMBTU	FLOAT,
	Total_Produccion_Condensado	FLOAT,
	Total_Dist_Oper_Condensado	FLOAT,
	Total_Dist_Estado_Condensado	FLOAT,
	Total_Vol_Oper_Condensado	FLOAT,
	Total_Vol_Estado_Condensado	FLOAT,
	Total_Produccion_Condensable	FLOAT
)

CREATE TABLE #NuevaDistribucionProvisional
(
	NuevaDistribucionOperPetroleo	FLOAT,
	NuevaDistribucionOperCondensado	FLOAT,
	NuevaDistribucionEstadoPetroleo	FLOAT,
	NuevaDistribucionEstadoCondensado	FLOAT,
	NuevaDistribucionOperC1			FLOAT,
	NuevaDistribucionOperC2			FLOAT,
	NuevaDistribucionOperC3			FLOAT,
	NuevaDistribucionOperC4			FLOAT,
	NuevaDistribucionOperC5			FLOAT,
	NuevaDistribucionEstadoC1		FLOAT,
	NuevaDistribucionEstadoC2		FLOAT,
	NuevaDistribucionEstadoC3		FLOAT,
	NuevaDistribucionEstadoC4		FLOAT,
	NuevaDistribucionEstadoC5		FLOAT
)

DECLARE 
	@NumContrato	VARCHAR(50)

SELECT @NumContrato = NumeroContrato
FROM	dbo.CO_Contrato
WHERE	IdContrato	=	@IdContrato

INSERT INTO #PC_VolumenProduccionPeriodo
(
    Id,
    IdContrato,
    MesReporte,
    FechaInicio,
    FechaFin,
    VolumenPetroleoPuntoMedicion,
    GradosAPI,
    ContenidoAzufre,
    VolumenPetroleoAutoconsumo,
    MetanoC1,
    EtanoC2,
    PropanoC3,
    ButanoC4,
    MetanoC1Autoconsumo,
    EtanoC2Autoconsumo,
    PropanoC3Autoconsumo,
    ButanoC4Autoconsumo,
    VolumenCondensadoPuntoMedicion,
    VolumenCondensadoAutoconsumo,
    Bit_CasoFortuito,
    CantDiasCasoFortuito,
    OtrosIngresosUsoCompartidoInfraestructura,
    VolumenPetroleoContratistaReparticion,
    VolumenMetanoC1ContratistaReparticion,
    VolumenEtanoC2ContratistaReparticion,
    VolumenPropanoC3ContratistaReparticion,
    VolumenButanoC4ContratistaReparticion,
    VolumenCondensadosContratistaReparticion,
    VolumenPetroleoEstadoReparticion,
    VolumenMetanoC1EstadoReparticion,
    VolumenEtanoC2EstadoReparticion,
    VolumenPropanoC3EstadoReparticion,
    VolumenButanoC4EstadoReparticion,
    VolumenCondensadosEstadoReparticion,
    VolumenPetroleoContratistaCompensacion,
    VolumenMetanoC1ContratistaCompensacion,
    VolumenEtanoC2ContratistaCompensacion,
    VolumenPropanoC3ContratistaCompensacion,
	VolumenButanoC4ContratistaCompensacion,
    VolumenCondensadosContratistaCompensacion,
    VolumenPetroleoEstadoCompensacion,
    VolumenMetanoC1EstadoCompensacion,
    VolumenEtanoC2EstadoCompensacion,
    VolumenPropanoC3EstadoCompensacion,
    VolumenButanoC4EstadoCompensacion,
    VolumenCondensadosEstadoCompensacion,
    AcumuladoCostosRecuperablesInsolutos,
	VolumenCondensablePuntoMedicion,
	VolumenCondensableAutoconsumo
)
SELECT	ROW_NUMBER() OVER (ORDER BY FechaInicio) AS Id,
	IdContrato,
    MesReporte,
    FechaInicio,
    FechaFin,
    VolumenPetroleoPuntoMedicion,
    GradosAPI,
    ContenidoAzufre,
    VolumenPetroleoAutoconsumo,
    MetanoC1,
    EtanoC2,
    PropanoC3,
    ButanoC4,
    MetanoC1Autoconsumo,
    EtanoC2Autoconsumo,
    PropanoC3Autoconsumo,
    ButanoC4Autoconsumo,
    VolumenCondensadoPuntoMedicion,
    VolumenCondensadoAutoconsumo,
    Bit_CasoFortuito,
    CantDiasCasoFortuito,
    OtrosIngresosUsoCompartidoInfraestructura,
    VolumenPetroleoContratistaReparticion,
    VolumenMetanoC1ContratistaReparticion,
    VolumenEtanoC2ContratistaReparticion,
    VolumenPropanoC3ContratistaReparticion,
    VolumenButanoC4ContratistaReparticion,
    VolumenCondensadosContratistaReparticion,
    VolumenPetroleoEstadoReparticion,
    VolumenMetanoC1EstadoReparticion,
    VolumenEtanoC2EstadoReparticion,
    VolumenPropanoC3EstadoReparticion,
    VolumenButanoC4EstadoReparticion,
    VolumenCondensadosEstadoReparticion,
    VolumenPetroleoContratistaCompensacion,
    VolumenMetanoC1ContratistaCompensacion,
    VolumenEtanoC2ContratistaCompensacion,
    VolumenPropanoC3ContratistaCompensacion,
    VolumenButanoC4ContratistaCompensacion,
    VolumenCondensadosContratistaCompensacion,
    VolumenPetroleoEstadoCompensacion,
    VolumenMetanoC1EstadoCompensacion,
    VolumenEtanoC2EstadoCompensacion,
    VolumenPropanoC3EstadoCompensacion,
    VolumenButanoC4EstadoCompensacion,
    VolumenCondensadosEstadoCompensacion,
    AcumuladoCostosRecuperablesInsolutos,
	VolumenCondensablePuntoMedicion,
	VolumenCondensableAutoconsumo
FROM
	PC_VolumenProduccionPeriodo
WHERE
	IdContrato	=	@IdContrato
	AND	MesReporte	=	@MesReporte


INSERT INTO #PC_RM
(
    Id,
    Mes,
    IdSIPAC,
    IDRegistroFiduciario,
    IDContratoCNH,
    MesReporte,
    AnioReporte,
    ContraprestacionEstadoCuotaExplo,
    ContraprestacionesEstadoProdInsuficiente,
    VolCalculadoDistribucionFinalEstadoPetroleo,
    VolCalculadoDistribucionFinalEstadoC1,
    VolCalculadoDistribucionFinalEstadoC2,
    VolCalculadoDistribucionFinalEstadoC3,
    VolCalculadoDistribucionFinalEstadoC4,
    VolCalculadoDistribucionFinalEstadoCondensados,
    VolCalculadoDistribucionFinalContratistaPetroleo,
    VolCalculadoDistribucionFinalContratistaC1,
    VolCalculadoDistribucionFinalContratistaC2,
    VolCalculadoDistribucionFinalContratistaC3,
    VolCalculadoDistribucionFinalContratistaC4,
    VolCalculadoDistribucionFinalContratistaCondensado,
    VolRecibidoEstadoPuntoMedPetroleo,
    VolRecibidoEstadoPuntoMedC1,
    VolRecibidoEstadoPuntoMedC2,
    VolRecibidoEstadoPuntoMedC3,
    VolRecibidoEstadoPuntoMedC4,
    VolRecibidoEstadoPuntoMedCondensado,
    VolRecibidoContratistaPuntoMedPetroleo,
    VolRecibidoContratistaPuntoMedC1,
    VolRecibidoContratistaPuntoMedC2,
    VolRecibidoContratistaPuntoMedC3,
    VolRecibidoContratistaPuntoMedC4,
    VolRecibidoContratistaPuntoMedCondensado,
    CompensacionVolSaldoAcumuladoEstadoPetroleo,
    CompensacionVolSaldoAcumuladoEstadoC1,
    CompensacionVolSaldoAcumuladoEstadoC2,
    CompensacionVolSaldoAcumuladoEstadoC3,
    CompensacionVolSaldoAcumuladoEstadoC4,
    CompensacionVolSaldoAcumuladoEstadoCondensado,
    CompensacionVolSaldoAcumuladoContratistaPetroleo,
    CompensacionVolSaldoAcumuladoContratistaC1,
    CompensacionVolSaldoAcumuladoContratistaC2,
    CompensacionVolSaldoAcumuladoContratistaC3,
	CompensacionVolSaldoAcumuladoContratistaC4,
    CompensacionVolSaldoAcumuladoContratistaCondensado,
    CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo,
    CompensacionVolNuevoSaldoAcumuladoEstadoC1,
    CompensacionVolNuevoSaldoAcumuladoEstadoC2,
    CompensacionVolNuevoSaldoAcumuladoEstadoC3,
    CompensacionVolNuevoSaldoAcumuladoEstadoC4,
    CompensacionVolNuevoSaldoAcumuladoEstadoCondensado,
    CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo,
    CompensacionVolNuevoSaldoAcumuladoContratistaC1,
    CompensacionVolNuevoSaldoAcumuladoContratistaC2,
    CompensacionVolNuevoSaldoAcumuladoContratistaC3,
    CompensacionVolNuevoSaldoAcumuladoContratistaC4,
    CompensacionVolNuevoSaldoAcumuladoContratistaCondensado,
    NuevaDistribucionProvisionalEstado,
    NuevaDistribucionProvisionalContratista
)
SELECT 
	ROW_NUMBER() OVER (ORDER BY DATEFROMPARTS( [Año de reporte (RM53_01)], [Mes de reporte (RM53_00)], 1 )) AS Id,
	DATEFROMPARTS( [Año de reporte (RM53_01)], [Mes de reporte (RM53_00)], 1 )	AS [Mes],
	[ID del contratista asignado por el SIPAC (RF_00)] AS [IdSIPAC],
	[ID registro fiduciario del contrato (RI_00)] AS [IdRegistroFiduciario],
	[ID del contrato asignado por CNH (RF01_01)] AS [IdContratoCNH],
	CONVERT(INT, [Mes de reporte (RM53_00)]) AS [MesReporte],
	CONVERT(INT, [Año de reporte (RM53_01)]) AS [AnioReporte],
	CONVERT(DECIMAL(16,4), REPLACE([Cálculo de contraprestaciones en efectivo a favor del Estado: Cu],',',''))		AS [ContraprestacionEstadoCuotaExplo],
	CONVERT(DECIMAL(16,4), CASE [Cálculo de contraprestaciones en efectivo a favor del Estado: Pa] WHEN 'NA' THEN 0 ELSE [Cálculo de contraprestaciones en efectivo a favor del Estado: Pa] END)		AS [ContraprestacionesEstadoProdInsuficiente],
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor del],',',''))		AS VolCalculadoDistribucionFinalEstadoPetroleo,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de1],',',''))		AS VolCalculadoDistribucionFinalEstadoC1,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de2],',',''))		AS VolCalculadoDistribucionFinalEstadoC2,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de3],',',''))		AS VolCalculadoDistribucionFinalEstadoC3,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de4],',',''))		AS VolCalculadoDistribucionFinalEstadoC4,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de5],',',''))		AS VolCalculadoDistribucionFinalEstadoCondensados,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de6],',',''))		AS VolCalculadoDistribucionFinalContratistaPetroleo,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de7],',',''))		AS VolCalculadoDistribucionFinalContratistaC1,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de8],',',''))		AS VolCalculadoDistribucionFinalContratistaC2,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor de9],',',''))		AS VolCalculadoDistribucionFinalContratistaC3,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor d10],',',''))		AS VolCalculadoDistribucionFinalContratistaC4,
	CONVERT(INT, REPLACE([Volumen calculado por concepto de Distribución Final a favor d11],',',''))		AS VolCalculadoDistribucionFinalContratistaCondensado,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Estado en el punto d],',',''))		AS VolRecibidoEstadoPuntoMedPetroleo,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Estado en el punto 1],',',''))		AS VolRecibidoEstadoPuntoMedC1,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Estado en el punto 2],',',''))		AS VolRecibidoEstadoPuntoMedC2,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Estado en el punto 3],',',''))		AS VolRecibidoEstadoPuntoMedC3,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Estado en el punto 4],',',''))		AS VolRecibidoEstadoPuntoMedC4,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Estado en el punto 5],',',''))		AS VolRecibidoEstadoPuntoMedCondensado,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Contratista en el pu],',',''))		AS VolRecibidoContratistaPuntoMedPetroleo,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Contratista en el p1],',',''))		AS VolRecibidoContratistaPuntoMedC1,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Contratista en el p2],',',''))		AS VolRecibidoContratistaPuntoMedC2,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Contratista en el p3],',',''))		AS VolRecibidoContratistaPuntoMedC3,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Contratista en el p4],',',''))		AS VolRecibidoContratistaPuntoMedC4,
	CONVERT(INT, REPLACE([Volumen total efectivamente recibido por el Contratista en el p5],',',''))		AS VolRecibidoContratistaPuntoMedCondensado,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de petróleo a favor],',',''))		AS	CompensacionVolSaldoAcumuladoEstadoPetroleo,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de metano a favor d],',',''))		AS	CompensacionVolSaldoAcumuladoEstadoC1,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de etano a favor de],',',''))		AS	CompensacionVolSaldoAcumuladoEstadoC2,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de propano a favor ],',',''))		AS	CompensacionVolSaldoAcumuladoEstadoC3,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de butano a favor d],',',''))		AS	CompensacionVolSaldoAcumuladoEstadoC4,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de condensados a fa],',',''))		AS	CompensacionVolSaldoAcumuladoEstadoCondensado,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de petróleo a favo1],',',''))		AS	CompensacionVolSaldoAcumuladoContratistaPetroleo,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de metano a favor 1],',',''))		AS	CompensacionVolSaldoAcumuladoContratistaC1,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de etano a favor d1],',',''))		AS	CompensacionVolSaldoAcumuladoContratistaC2,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de propano a favor1],',',''))		AS	CompensacionVolSaldoAcumuladoContratistaC3,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de butano a favor 1],',',''))		AS	CompensacionVolSaldoAcumuladoContratistaC4,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Saldo acumulado de condensados a f1],',',''))		AS	CompensacionVolSaldoAcumuladoContratistaCondensado,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de petróleo a],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de metano a f],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoEstadoC1,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de etano a fa],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoEstadoC2,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de propano a ],',',''))			AS	CompensacionVolNuevoSaldoAcumuladoEstadoC3,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de butano a f],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoEstadoC4,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de condensado],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoEstadoCondensado,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de petróleo 1],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de metano a 1],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoContratistaC1,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de etano a f1],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoContratistaC2,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de propano a1],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoContratistaC3,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de butano a 1],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoContratistaC4,
	CONVERT(INT, REPLACE([Compensaciones volumétricas: Nuevo saldo acumulado de condensad1],',',''))		AS	CompensacionVolNuevoSaldoAcumuladoContratistaCondensado,
	CONVERT(FLOAT, REPLACE([Nueva Distribución Provisional a favor del Estado (RM53_52)],',',''))		AS	NuevaDistribucionProvisionalEstado,
	CONVERT(FLOAT, REPLACE([Nueva Distribución Provisional a favor del Contratista (RM53_53)],',',''))		AS	NuevaDistribucionProvisionalContratista
FROM
	PC_RM 
WHERE
	[id del contrato asignado por CNH (RF01_01)] = @NumContrato
	AND DATEFROMPARTS( [Año de reporte (RM53_01)], [Mes de reporte (RM53_00)], 1 ) BETWEEN DATEADD(MONTH,-2,@MesReporte) AND  DATEADD(MONTH,-1,@MesReporte)
ORDER BY
	DATEFROMPARTS( [Año de reporte (RM53_01)], [Mes de reporte (RM53_00)], 1 )


INSERT INTO #Totales
(
    Total_Produccion_Petroleo,
    Total_Dist_Oper_Petroleo,
    Total_Dist_Estado_Petroleo,
    Total_Vol_Oper_Activo,
    Total_Vol_Estado_Activo,
    Total_MMBTU,
    Total_C1,
    Total_C2,
    Total_C3,
    Total_C4,
    Total_Dist_Vol_Oper_C1,
    Total_Dist_Vol_Oper_C2,
    Total_Dist_Vol_Oper_C3,
    Total_Dist_Vol_Oper_C4,
    Total_Dist_Vol_Oper_MMBTU,
    Total_Dist_Vol_Estado_C1,
    Total_Dist_Vol_Estado_C2,
    Total_Dist_Vol_Estado_C3,
    Total_Dist_Vol_Estado_C4,
    Total_Dist_Vol_Estado_MMBTU,
    Total_Produccion_Condensado,
    Total_Dist_Oper_Condensado,
    Total_Dist_Estado_Condensado,
    Total_Vol_Oper_Condensado,
    Total_Vol_Estado_Condensado,
	Total_Produccion_Condensable
)
SELECT
	SUM(VP.VolumenPetroleoPuntoMedicion)	AS [Total_Produccion_Petroleo], 
	SUM((VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))) AS [Total_Dist_Oper_Petroleo],
	SUM((VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)))	AS [Total_Dist_Estado_Petroleo],
	SUM((VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) + CASE WHEN RM.Id = 1 THEN 0
		ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo	END)			AS	[Total_Vol_Oper_Activo],
	SUM((VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) + CASE WHEN RM.Id = 1 THEN 0
		ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo	END)		AS	[Total_Vol_Estado_Activo],
	SUM(VP.MetanoC1 + VP.EtanoC2 + VP.PropanoC3 + VP.ButanoC4)	AS [Total_MMBTU],
	SUM(VP.MetanoC1)	AS [Total_C1],
	SUM(VP.EtanoC2)	AS [Total_C2],
	SUM(VP.PropanoC3)	AS [Total_C3],
	SUM(VP.ButanoC4)	AS [Total_C4],
	SUM(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Total_Dist_Vol_Oper_C1],
	SUM(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Total_Dist_Vol_Oper_C2],
	SUM(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Total_Dist_Vol_Oper_C3],
	SUM(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Total_Dist_Vol_Oper_C4],
	SUM((VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) +
	(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) +
	(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) +
	(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)))	AS [Total_Dist_Vol_Oper_MMBTU],
	SUM(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Total_Dist_Vol_Estado_C1],
	SUM(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Total_Dist_Vol_Estado_C2],
	SUM(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Total_Dist_Vol_Estado_C3],
	SUM(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Total_Dist_Vol_Estado_C4],
	SUM((VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) +
	(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) +
	(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) +
	(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)))	AS [Total_Dist_Vol_Estado_MMBTU],
	SUM(VP.VolumenCondensadoPuntoMedicion)	AS [Total_Produccion_Condensado],
	SUM(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Total_Dist_Oper_Condensado], 
	SUM(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Total_Dist_Estado_Condensado],
	SUM((VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) + CASE WHEN RM.Id = 1 THEN 0
		ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
	END)		AS	[Total_Vol_Oper_Condensado],
	SUM((VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) + CASE WHEN RM.Id = 1 THEN 0
		ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
	END)		AS	[Total_Vol_Estado_Condensado],
	SUM(VP.VolumenCondensablePuntoMedicion)
FROM
	#PC_VolumenProduccionPeriodo	VP
JOIN
	#PC_RM	RM
	ON	VP.Id	=	RM.Id

-- ********************  PETROLEO *****************
IF @Debug = 1
BEGIN
	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		VP.VolumenPetroleoPuntoMedicion		AS [Producción Activo 15.56°C], 
		RM.NuevaDistribucionProvisionalContratista	AS [%Dist_Vol Oper],
		RM.NuevaDistribucionProvisionalEstado	AS [%Dist_Vol Estado],
		(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist_Oper], 
		(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist_Estado], 
		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
		END		AS [Comp_Vol. Oper],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
		END		AS [FINAL Comp_Vol. Oper],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo
		END		AS [Comp_Vol. Estado],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo
		END		AS [FINAL Comp_Vol. Estado],

		(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) + CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
		END		AS	[Total Vol_Oper],

		(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) + CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
		END		AS	[NVO Total Vol_Oper],

		(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) + CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo
		END		AS	[Total Vol_Estado],

		(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) + CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo
		END		AS	[NVO Total Vol_Estado],

		CASE WHEN T.Total_Produccion_Petroleo = 0 THEN 0
			ELSE (VP.VolumenPetroleoPuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Petroleo
		END				AS [NuevaDistribucionOper],
		VP.VolumenCondensablePuntoMedicion
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id
	CROSS JOIN #Totales	T
END

INSERT INTO #NuevaDistribucionProvisional
(
    NuevaDistribucionOperPetroleo,
    NuevaDistribucionOperCondensado,
    NuevaDistribucionEstadoPetroleo,
    NuevaDistribucionEstadoCondensado,

	NuevaDistribucionOperC1,
	NuevaDistribucionOperC2,
	NuevaDistribucionOperC3,
	NuevaDistribucionOperC4,
	NuevaDistribucionEstadoC1,
	NuevaDistribucionEstadoC2,
	NuevaDistribucionEstadoC3,
	NuevaDistribucionEstadoC4,

	NuevaDistribucionOperC5,
	NuevaDistribucionEstadoC5
)
SELECT 
	SUM ( CASE WHEN T.Total_Produccion_Petroleo = 0 THEN 0 ELSE (VP.VolumenPetroleoPuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Petroleo END)	AS [NuevaDistribucionOperPetroleo],
	SUM ( CASE WHEN T.Total_Produccion_Condensado = 0 THEN 0 ELSE (VP.VolumenCondensadoPuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Condensado END)	AS [NuevaDistribucionOperCondensado],
	100.00 - SUM ( CASE WHEN T.Total_Produccion_Petroleo = 0 THEN 0 ELSE (VP.VolumenPetroleoPuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Petroleo END)	AS [NuevaDistribucionEstadoPetroleo],
	100.00 - SUM ( CASE WHEN T.Total_Produccion_Condensado = 0 THEN 0 ELSE (VP.VolumenCondensadoPuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Condensado END)	AS [NuevaDistribucionEstadoCondensado],
	SUM ( CASE WHEN T.Total_C1 = 0 THEN 0 ELSE (VP.MetanoC1 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C1 END)	AS [NuevaDistribucionOperC1],
	SUM ( CASE WHEN T.Total_C2 = 0 THEN 0 ELSE (VP.EtanoC2 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C2 END)	AS [NuevaDistribucionOperC2],
	SUM ( CASE WHEN T.Total_C3 = 0 THEN 0 ELSE (VP.PropanoC3 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C3 END)	AS [NuevaDistribucionOperC3],
	SUM ( CASE WHEN T.Total_C4 = 0 THEN 0 ELSE (VP.ButanoC4 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C4 END)	AS [NuevaDistribucionOperC4],
	100.00 - SUM ( CASE WHEN T.Total_C1 = 0 THEN 0 ELSE (VP.MetanoC1 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C1 END)	AS [NuevaDistribucionEstadoC1],
	100.00 - SUM ( CASE WHEN T.Total_C2 = 0 THEN 0 ELSE (VP.EtanoC2 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C2 END)	AS [NuevaDistribucionEstadoC2],
	100.00 - SUM ( CASE WHEN T.Total_C3 = 0 THEN 0 ELSE (VP.PropanoC3 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C3 END)	AS [NuevaDistribucionEstadoC3],
	100.00 - SUM ( CASE WHEN T.Total_C4 = 0 THEN 0 ELSE (VP.ButanoC4 * RM.NuevaDistribucionProvisionalContratista) / T.Total_C4 END)	AS [NuevaDistribucionEstadoC4],
	SUM ( CASE WHEN T.Total_Produccion_Condensable = 0 THEN 0 ELSE (VP.VolumenCondensablePuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Condensable END)	AS [NuevaDistribucionOperC5],
	100.00 - SUM ( CASE WHEN T.Total_Produccion_Condensable = 0 THEN 0 ELSE (VP.VolumenCondensablePuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Condensable END)	AS [NuevaDistribucionEstadoC5]
FROM
	#PC_VolumenProduccionPeriodo	VP
JOIN
	#PC_RM	RM
	ON	VP.Id	=	RM.Id
CROSS JOIN #Totales	T

IF @Debug = 1
BEGIN

	SELECT * FROM #NuevaDistribucionProvisional

	-- ********************  GASES *****************
	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		VP.MetanoC1 + VP.EtanoC2 + VP.PropanoC3 + VP.ButanoC4	AS [MMBTU],
		VP.MetanoC1	AS [C1],
		VP.EtanoC2	AS [C2],
		VP.PropanoC3	AS [C3],
		VP.ButanoC4		AS [C4],
		'Falta C5+'		AS [C5+]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id

	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		RM.NuevaDistribucionProvisionalContratista	AS [%Dist_Vol Oper],
		(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist Vol Oper C1],
		(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist Vol Oper C2],
		(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist Vol Oper C3],
		(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist Vol Oper C4],
		'Falta C5+'		AS [Dist Vol Oper C5+],
		(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) +
		(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) +
		(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) +
		(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Total MMBTU]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id

	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		RM.NuevaDistribucionProvisionalEstado	AS [%Dist_Vol Estado],
		(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist Vol Estado C1],
		(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist Vol Estado C2],
		(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist Vol Estado C3],
		(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist Vol Estado C4],
		'Falta C5+'		AS [Dist Vol Oper C5+],
		(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) +
		(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) +
		(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) +
		(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Total MMBTU]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id

	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1
		END		AS [Comp_Vol. Oper C1],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1 > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1) > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1
		END		AS [FINAL Comp_Vol. Oper C1],


		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2
		END		AS [Comp_Vol. Oper C2],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2 > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2) > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2
		END		AS [FINAL Comp_Vol. Oper C2],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3
		END		AS [Comp_Vol. Oper C3],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3 > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3) > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3
		END		AS [FINAL Comp_Vol. Oper C3],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4
		END		AS [Comp_Vol. Oper C4],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4 > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4) > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4
		END		AS [FINAL Comp_Vol. Oper C4],

		'FALTA C5+'		AS	 [Comp_Vol. Oper C5+]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id
	WHERE
		RM.Id <> 1

	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1
		END		AS [Comp_Vol. Estado C1],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1) > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN -(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1 > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1
		END		AS [FINAL Comp_Vol. Estado C1],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2
		END		AS [Comp_Vol. Estado C2],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2) > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2 > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2
		END		AS [FINAL Comp_Vol. Estado C2],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3
		END		AS [Comp_Vol. Estado C3],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3) > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3 > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3
		END		AS [FINAL Comp_Vol. Estado C3],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4
		END		AS [Comp_Vol. Estado C4],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4) > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4 > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4
		END		AS [FINAL Comp_Vol. Estado C4],

		'FALTA C5+'		AS	 [Comp_Vol. Estado C5+]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id
	WHERE
		RM.Id <> 1

	SELECT
		T.Total_Dist_Vol_Oper_C1 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1	AS [Comp Vol Oper MMBTU C1],
		T.Total_Dist_Vol_Oper_C2 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2	AS [Comp Vol Oper MMBTU C2],
		T.Total_Dist_Vol_Oper_C3 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3	AS [Comp Vol Oper MMBTU C3],
		T.Total_Dist_Vol_Oper_C4 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4	AS [Comp Vol Oper MMBTU C4],
		'N/A'	AS [Comp Vol Oper MMBTU C5+],
		(T.Total_Dist_Vol_Oper_C1 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1) + 
		(T.Total_Dist_Vol_Oper_C2 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2) +
		(T.Total_Dist_Vol_Oper_C3 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3) +
		(T.Total_Dist_Vol_Oper_C4 + RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4)	AS [Comp Vol Oper MMBTU Total]
	FROM #Totales	T
	CROSS JOIN
		#PC_RM	RM
	WHERE
		RM.Id <> 1

	SELECT
		T.Total_Dist_Vol_Estado_C1 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1	AS [Comp Vol Estado MMBTU C1],
		T.Total_Dist_Vol_Estado_C2 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2	AS [Comp Vol Estado MMBTU C2],
		T.Total_Dist_Vol_Estado_C3 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3	AS [Comp Vol Estado MMBTU C3],
		T.Total_Dist_Vol_Estado_C4 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4	AS [Comp Vol Estado MMBTU C4],
		'N/A'	AS [Comp Vol Estado MMBTU C5+],
		(T.Total_Dist_Vol_Estado_C1 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1) + 
		(T.Total_Dist_Vol_Estado_C2 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2) +
		(T.Total_Dist_Vol_Estado_C3 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3) +
		(T.Total_Dist_Vol_Estado_C4 + RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4)	AS [Comp Vol Estado MMBTU Total]
	FROM #Totales	T
	CROSS JOIN
		#PC_RM	RM
	WHERE
		RM.Id <> 1

	-- ********************  CONDENSADO *****************
	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		VP.VolumenCondensadoPuntoMedicion		AS [Producción Activo 15.56°C], 
		RM.NuevaDistribucionProvisionalContratista	AS [%Dist_Vol Oper],
		RM.NuevaDistribucionProvisionalEstado	AS [%Dist_Vol Estado],
		(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist_Oper], 
		(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist_Estado], 
		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
		END		AS [Comp_Vol. Oper],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
		END		AS [FINAL Comp_Vol. Oper],

		CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
		END		AS [Comp_Vol. Estado],

		CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
		END		AS [FINAL Comp_Vol. Estado],

		(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) + CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
		END		AS	[Total Vol_Oper],

		(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) + CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
		END		AS	[Nvo Total Vol_Oper],

		(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) + CASE WHEN RM.Id = 1 THEN 0
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
		END		AS	[Total Vol_Estado],

		(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) + CASE WHEN RM.Id = 1 THEN 0
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
			THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
			WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
			THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
			ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
		END		AS	[NVO Total Vol_Estado],
		CASE WHEN T.Total_Produccion_Condensado = 0 THEN 0 ELSE
		(VP.VolumenCondensadoPuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Condensado END	AS [NuevaDistribucionOperCondensado]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id
	CROSS JOIN
		#Totales	T

	-- ********************  CONDENSABLE *****************
	SELECT
		LTRIM(VP.FechaInicio) + ' A ' + LTRIM(VP.FechaFin) AS [Periodos],
		VP.VolumenCondensablePuntoMedicion		AS [Producción Activo 15.56°C], 
		RM.NuevaDistribucionProvisionalContratista	AS [%Dist_Vol Oper],
		RM.NuevaDistribucionProvisionalEstado	AS [%Dist_Vol Estado],
		(VP.VolumenCondensablePuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))	AS [Dist_Oper], 
		(VP.VolumenCondensablePuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))	AS [Dist_Estado], 

		(VP.VolumenCondensablePuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 	AS	[Total Vol_Oper],

		(VP.VolumenCondensablePuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 		AS	[Total Vol_Estado],
		CASE WHEN T.Total_Produccion_Condensable = 0 THEN 0
			ELSE (VP.VolumenCondensablePuntoMedicion * RM.NuevaDistribucionProvisionalContratista) / T.Total_Produccion_Condensable	
		END		AS [NuevaDistribucionOperCondensable]
	FROM
		#PC_VolumenProduccionPeriodo	VP
	JOIN
		#PC_RM	RM
		ON	VP.Id	=	RM.Id
	CROSS JOIN
		#Totales	T
END

IF @MesReporte IN ( '20211001', '20211101', '20211201', '20220101')
	SELECT @FechaLimite = '20220630 23:59'

-- SE VALIDA SI EL REPORTE GENERADO ES DEL MES ANTERIOR, EN CUYO CASO SE BORRA LA INFORMACIÓN, SI ES MAS ANTIGUO SOLO SE MUESTRA LA INFORMACION YA GENERADA
IF @FechaLimite >= GETDATE()
BEGIN
	IF @Debug = 1
	BEGIN

		SELECT 'INSERT INTO SIPAC_RM_FMP_53_M'
		SELECT VP.IdContrato, 
			RM.IdSIPAC,
			RM.IdRegistroFiduciario,
			RM.IdContratoCNH,
			MONTH(DATEADD(MONTH,-1,VP.MesReporte))	AS [MesReporte],
			YEAR(DATEADD(MONTH,-1,VP.MesReporte))		AS [AnioReporte],
			RM.ContraprestacionEstadoCuotaExplo,
			RM.ContraprestacionesEstadoProdInsuficiente,
			RM.VolCalculadoDistribucionFinalEstadoPetroleo,
			RM.VolCalculadoDistribucionFinalEstadoC1,
			RM.VolCalculadoDistribucionFinalEstadoC2,
			RM.VolCalculadoDistribucionFinalEstadoC3,
			RM.VolCalculadoDistribucionFinalEstadoC4,
			RM.VolCalculadoDistribucionFinalEstadoCondensados,
			RM.VolCalculadoDistribucionFinalContratistaPetroleo,
			RM.VolCalculadoDistribucionFinalContratistaC1,
			RM.VolCalculadoDistribucionFinalContratistaC2,
			RM.VolCalculadoDistribucionFinalContratistaC3,
			RM.VolCalculadoDistribucionFinalContratistaC4,
			RM.VolCalculadoDistribucionFinalContratistaCondensado,
			RM.VolRecibidoEstadoPuntoMedPetroleo,
			RM.VolRecibidoEstadoPuntoMedC1,
			RM.VolRecibidoEstadoPuntoMedC2,
			RM.VolRecibidoEstadoPuntoMedC3,
			RM.VolRecibidoEstadoPuntoMedC4,
			RM.VolRecibidoEstadoPuntoMedCondensado,
			RM.VolRecibidoContratistaPuntoMedPetroleo,
			RM.VolRecibidoContratistaPuntoMedC1,
			RM.VolRecibidoContratistaPuntoMedC2,
			RM.VolRecibidoContratistaPuntoMedC3,
			RM.VolRecibidoContratistaPuntoMedC4,
			RM.VolRecibidoContratistaPuntoMedCondensado,
			RM.CompensacionVolSaldoAcumuladoEstadoPetroleo,
			RM.CompensacionVolSaldoAcumuladoEstadoC1,
			RM.CompensacionVolSaldoAcumuladoEstadoC2,
			RM.CompensacionVolSaldoAcumuladoEstadoC3,
			RM.CompensacionVolSaldoAcumuladoEstadoC4,
			RM.CompensacionVolSaldoAcumuladoEstadoCondensado,
			RM.CompensacionVolSaldoAcumuladoContratistaPetroleo,
			RM.CompensacionVolSaldoAcumuladoContratistaC1,
			RM.CompensacionVolSaldoAcumuladoContratistaC2,
			RM.CompensacionVolSaldoAcumuladoContratistaC3,
			RM.CompensacionVolSaldoAcumuladoContratistaC4,
			RM.CompensacionVolSaldoAcumuladoContratistaCondensado,
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1) > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1 > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC1],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2) > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2 > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC2],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3) > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3 > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC3],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4) > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4 > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC4],

			CASE WHEN RM.Id = 1 THEN 0
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoCondensado],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1 > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1) > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC1],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2 > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2) > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC2],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3 > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3) > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC3],

			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4 > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4) > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC4],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
			END	AS [CompensacionVolNuevoSaldoAcumuladoContratistaCondensado],
			CASE WHEN ND.NuevaDistribucionEstadoPetroleo = 100 THEN ND.NuevaDistribucionEstadoCondensado ELSE ND.NuevaDistribucionEstadoPetroleo END	AS [NuevaDistribucionProvisionalEstado],
			CASE WHEN ND.NuevaDistribucionOperPetroleo = 0 THEN ND.NuevaDistribucionOperCondensado ELSE ND.NuevaDistribucionOperPetroleo END AS [NuevaDistribucionProvisionalContratista],
			ND.NuevaDistribucionOperC1,
			ND.NuevaDistribucionOperC2,
			ND.NuevaDistribucionOperC3,
			ND.NuevaDistribucionOperC4,
			ND.NuevaDistribucionOperC5
		FROM
			#PC_VolumenProduccionPeriodo	VP
		JOIN
			#PC_RM	RM
			ON	VP.Id	=	RM.Id
		CROSS JOIN #NuevaDistribucionProvisional	ND
		WHERE
			RM.Id	=	2

		SELECT 'INSERT INTO PR_VolumenMensualProduccionPetroleo'
		SELECT IdContrato,
				MesReporte,
				SUM(VolumenPetroleoPuntoMedicion)	AS [VolumenPetroleoPuntoMedicion],
				AVG(GradosAPI)						AS [GradosAPI],
				AVG(ContenidoAzufre)				AS [ContenidoAzufre],
				SUM(VolumenPetroleoAutoconsumo)		AS [VolumenPetroleoAutoconsumo],
				SUM(MetanoC1)						AS [MetanoC1],
				SUM(EtanoC2)						AS [EtanoC2],
				SUM(PropanoC3)						AS [PropanoC3],
				SUM(ButanoC4)						AS [ButanoC4],
				SUM(MetanoC1Autoconsumo)			AS [MetanoC1Autoconsumo],
				SUM(EtanoC2Autoconsumo)				AS [EtanoC2Autoconsumo],
				SUM(PropanoC3Autoconsumo)			AS [PropanoC3Autoconsumo],
				SUM(ButanoC4Autoconsumo)			AS [ButanoC4Autoconsumo],
				SUM(VolumenCondensadoPuntoMedicion)	AS [VolumenCondensadoPuntoMedicion],
				SUM(VolumenCondensadoAutoconsumo)	AS [VolumenCondensadoAutoconsumo],
				CASE WHEN SUM(CONVERT(INT,ISNULL(Bit_CasoFortuito,0))) >= 1 THEN 1
					ELSE 0
				END		AS [Bit_CasoFortuito],
				SUM(ISNULL(CantDiasCasoFortuito,0))			AS [CantDiasCasoFortuito],
				SUM(ISNULL(OtrosIngresosUsoCompartidoInfraestructura,0))	AS [OtrosIngresosUsoCompartidoInfraestructura],
				SUM(ISNULL(VolumenPetroleoContratistaReparticion,0))		AS [VolumenPetroleoContratistaReparticion],
				SUM(ISNULL(VolumenMetanoC1ContratistaReparticion,0))		AS [VolumenMetanoC1ContratistaReparticion],
				SUM(ISNULL(VolumenEtanoC2ContratistaReparticion,0))		AS [VolumenEtanoC2ContratistaReparticion],
				SUM(ISNULL(VolumenPropanoC3ContratistaReparticion,0))		AS [VolumenPropanoC3ContratistaReparticion],
				SUM(ISNULL(VolumenButanoC4ContratistaReparticion,0))		AS [VolumenButanoC4ContratistaReparticion],
				SUM(ISNULL(VolumenCondensadosContratistaReparticion,0))	AS [VolumenCondensadosContratistaReparticion],
				SUM(ISNULL(VolumenPetroleoEstadoReparticion,0))			AS [VolumenPetroleoEstadoReparticion],
				SUM(ISNULL(VolumenMetanoC1EstadoReparticion,0))			AS [VolumenMetanoC1EstadoReparticion],
				SUM(ISNULL(VolumenEtanoC2EstadoReparticion,0))			AS [VolumenEtanoC2EstadoReparticion],
				SUM(ISNULL(VolumenPropanoC3EstadoReparticion,0))			AS [VolumenPropanoC3EstadoReparticion],
				SUM(ISNULL(VolumenButanoC4EstadoReparticion,0))			AS [VolumenButanoC4EstadoReparticion],
				SUM(ISNULL(VolumenCondensadosEstadoReparticion,0))		AS [VolumenCondensadosEstadoReparticion],
				SUM(ISNULL(VolumenPetroleoContratistaCompensacion,0))		AS [VolumenPetroleoContratistaCompensacion],
				SUM(ISNULL(VolumenMetanoC1ContratistaCompensacion,0))		AS [VolumenMetanoC1ContratistaCompensacion],
				SUM(ISNULL(VolumenEtanoC2ContratistaCompensacion,0))		AS [VolumenEtanoC2ContratistaCompensacion],
				SUM(ISNULL(VolumenPropanoC3ContratistaCompensacion,0))	AS [VolumenPropanoC3ContratistaCompensacion],
				SUM(ISNULL(VolumenButanoC4ContratistaCompensacion,0))		AS [VolumenButanoC4ContratistaCompensacion],
				SUM(ISNULL(VolumenCondensadosContratistaCompensacion,0))		AS [VolumenCondensadosContratistaCompensacion],
				SUM(ISNULL(VolumenPetroleoEstadoCompensacion,0))		AS [VolumenPetroleoEstadoCompensacion],
				SUM(ISNULL(VolumenMetanoC1EstadoCompensacion,0))		AS [VolumenMetanoC1EstadoCompensacion],
				SUM(ISNULL(VolumenEtanoC2EstadoCompensacion,0))			AS [VolumenEtanoC2EstadoCompensacion],
				SUM(ISNULL(VolumenPropanoC3EstadoCompensacion,0))		AS [VolumenPropanoC3EstadoCompensacion],
				SUM(ISNULL(VolumenButanoC4EstadoCompensacion,0))		AS [VolumenButanoC4EstadoCompensacion],
				SUM(ISNULL(VolumenCondensadosEstadoCompensacion,0))		AS [VolumenCondensadosEstadoCompensacion],
				SUM(ISNULL(AcumuladoCostosRecuperablesInsolutos,0))		AS [AcumuladoCostosRecuperablesInsolutos],
				SUM(ISNULL(VolumenCondensablePuntoMedicion,0))			AS [VolumenCondensablePuntoMedicion],
				SUM(ISNULL(VolumenCondensableAutoconsumo,0))			AS [VolumenCondensableAutoconsumo]
		FROM
			 #PC_VolumenProduccionPeriodo
		GROUP BY
			IdContrato,
			MesReporte
	END
    ELSE
	BEGIN
		--Se borran los registros generados anteriormente del mismo mes
		DELETE
		FROM	SIPAC_RM_FMP_53_M
		WHERE	IdContrato	=	@IdContrato
			AND	AnioReporte	=	YEAR(DATEADD(MONTH,-1,@MesReporte))
			AND	MesReporte	=	MONTH(DATEADD(MONTH,-1,@MesReporte))

		INSERT INTO dbo.SIPAC_RM_FMP_53_M
		(
		    IdContrato,
		    IDSIPAC,
		    IDRegistroFiduciario,
		    IDContratoCNH,
		    MesReporte,
		    AnioReporte,
		    ContraprestacionEstadoCuotaExplo,
		    ContraprestacioneEstadoProdInsuficiente,
		    VolCalculadoDistribucionFinalEstadoPetroleo,
		    VolCalculadoDistribucionFinalEstadoC1,
		    VolCalculadoDistribucionFinalEstadoC2,
		    VolCalculadoDistribucionFinalEstadoC3,
		    VolCalculadoDistribucionFinalEstadoC4,
		    VolCalculadoDistribucionFinalEstadoCondensados,
		    VolCalculadoDistribucionFinalContratistaPetroleo,
		    VolCalculadoDistribucionFinalContratistaC1,
		    VolCalculadoDistribucionFinalContratistaC2,
		    VolCalculadoDistribucionFinalContratistaC3,
		    VolCalculadoDistribucionFinalContratistaC4,
		    VolCalculadoDistribucionFinalContratistaCondensado,
		    VolRecibidoEstadoPuntoMedPetroleo,
		    VolRecibidoEstadoPuntoMedC1,
		    VolRecibidoEstadoPuntoMedC2,
		    VolRecibidoEstadoPuntoMedC3,
		    VolRecibidoEstadoPuntoMedC4,
		    VolRecibidoEstadoPuntoMedCondensado,
		    VolRecibidoContratistaPuntoMedPetroleo,
		    VolRecibidoContratistaPuntoMedC1,
		    VolRecibidoContratistaPuntoMedC2,
		    VolRecibidoContratistaPuntoMedC3,
		    VolRecibidoContratistaPuntoMedC4,
		    VolRecibidoContratistaPuntoMedCondensado,
		    CompensacionVolSaldoAcumuladoEstadoPetroleo,
		    CompensacionVolSaldoAcumuladoEstadoC1,
		    CompensacionVolSaldoAcumuladoEstadoC2,
		    CompensacionVolSaldoAcumuladoEstadoC3,
		   CompensacionVolSaldoAcumuladoEstadoC4,
		    CompensacionVolSaldoAcumuladoEstadoCondensado,
		    CompensacionVolSaldoAcumuladoContratistaPetroleo,
		    CompensacionVolSaldoAcumuladoContratistaC1,
		    CompensacionVolSaldoAcumuladoContratistaC2,
		    CompensacionVolSaldoAcumuladoContratistaC3,
		    CompensacionVolSaldoAcumuladoContratistaC4,
		    CompensacionVolSaldoAcumuladoContratistaCondensado,
		    CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo,
		    CompensacionVolNuevoSaldoAcumuladoEstadoC1,
		    CompensacionVolNuevoSaldoAcumuladoEstadoC2,
		    CompensacionVolNuevoSaldoAcumuladoEstadoC3,
		    CompensacionVolNuevoSaldoAcumuladoEstadoC4,
		    CompensacionVolNuevoSaldoAcumuladoEstadoCondensado,
		    CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo,
		    CompensacionVolNuevoSaldoAcumuladoContratistaC1,
		    CompensacionVolNuevoSaldoAcumuladoContratistaC2,
		    CompensacionVolNuevoSaldoAcumuladoContratistaC3,
		    CompensacionVolNuevoSaldoAcumuladoContratistaC4,
		    CompensacionVolNuevoSaldoAcumuladoContratistaCondensado,
		    NuevaDistribucionProvisionalEstado,
		    NuevaDistribucionProvisionalContratista,
			NuevaDistribucionProvisionalContratistaC1,
			NuevaDistribucionProvisionalContratistaC2,
			NuevaDistribucionProvisionalContratistaC3,
			NuevaDistribucionProvisionalContratistaC4,
			NuevaDistribucionProvisionalContratistaC5
		)
		SELECT VP.IdContrato, 
			RM.IdSIPAC,
			RM.IdRegistroFiduciario,
			RM.IdContratoCNH,
			MONTH(DATEADD(MONTH,-1,VP.MesReporte))	AS [MesReporte],
			YEAR(DATEADD(MONTH,-1,VP.MesReporte))		AS [AnioReporte],
			RM.ContraprestacionEstadoCuotaExplo,
			RM.ContraprestacionesEstadoProdInsuficiente,
			RM.VolCalculadoDistribucionFinalEstadoPetroleo,
			RM.VolCalculadoDistribucionFinalEstadoC1,
			RM.VolCalculadoDistribucionFinalEstadoC2,
			RM.VolCalculadoDistribucionFinalEstadoC3,
			RM.VolCalculadoDistribucionFinalEstadoC4,
			RM.VolCalculadoDistribucionFinalEstadoCondensados,
			RM.VolCalculadoDistribucionFinalContratistaPetroleo,
			RM.VolCalculadoDistribucionFinalContratistaC1,
			RM.VolCalculadoDistribucionFinalContratistaC2,
			RM.VolCalculadoDistribucionFinalContratistaC3,
			RM.VolCalculadoDistribucionFinalContratistaC4,
			RM.VolCalculadoDistribucionFinalContratistaCondensado,
			RM.VolRecibidoEstadoPuntoMedPetroleo,
			RM.VolRecibidoEstadoPuntoMedC1,
			RM.VolRecibidoEstadoPuntoMedC2,
			RM.VolRecibidoEstadoPuntoMedC3,
			RM.VolRecibidoEstadoPuntoMedC4,
			RM.VolRecibidoEstadoPuntoMedCondensado,
			RM.VolRecibidoContratistaPuntoMedPetroleo,
			RM.VolRecibidoContratistaPuntoMedC1,
			RM.VolRecibidoContratistaPuntoMedC2,
			RM.VolRecibidoContratistaPuntoMedC3,
			RM.VolRecibidoContratistaPuntoMedC4,
			RM.VolRecibidoContratistaPuntoMedCondensado,
			RM.CompensacionVolSaldoAcumuladoEstadoPetroleo,
			RM.CompensacionVolSaldoAcumuladoEstadoC1,
			RM.CompensacionVolSaldoAcumuladoEstadoC2,
			RM.CompensacionVolSaldoAcumuladoEstadoC3,
			RM.CompensacionVolSaldoAcumuladoEstadoC4,
			RM.CompensacionVolSaldoAcumuladoEstadoCondensado,
			RM.CompensacionVolSaldoAcumuladoContratistaPetroleo,
			RM.CompensacionVolSaldoAcumuladoContratistaC1,
			RM.CompensacionVolSaldoAcumuladoContratistaC2,
			RM.CompensacionVolSaldoAcumuladoContratistaC3,
			RM.CompensacionVolSaldoAcumuladoContratistaC4,
			RM.CompensacionVolSaldoAcumuladoContratistaCondensado,
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1) > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1 > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC1
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC1],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2) > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2 > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC2
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC2],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3) > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3 > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC3
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC3],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4) > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN -(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4 > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)) THEN (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoC4
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoC4],

			CASE WHEN RM.Id = 1 THEN 0
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
			END		AS [CompensacionVolNuevoSaldoAcumuladoEstadoCondensado],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) > (VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.VolumenPetroleoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1 > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1) > (VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.MetanoC1 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC1
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC1],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2 > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2) > (VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.EtanoC2 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC2
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC2],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3 > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3) > (VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.PropanoC3 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC3
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC3],

			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4 > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100)) THEN (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4) > (VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.ButanoC4 * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaC4
			END		AS [CompensacionVolNuevoSaldoAcumuladoContratistaC4],
			CASE 
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado>0 AND RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100)) 
				THEN (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalEstado/100))
				WHEN RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado<0 AND ABS(RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado) > (VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100)) 
				THEN -(VP.VolumenCondensadoPuntoMedicion * (RM.NuevaDistribucionProvisionalContratista/100))
				ELSE RM.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
			END	AS [CompensacionVolNuevoSaldoAcumuladoContratistaCondensado],
			CASE WHEN ND.NuevaDistribucionEstadoPetroleo = 100 THEN ND.NuevaDistribucionEstadoCondensado ELSE ND.NuevaDistribucionEstadoPetroleo END	AS [NuevaDistribucionProvisionalEstado],
			CASE WHEN ND.NuevaDistribucionOperPetroleo = 0 THEN ND.NuevaDistribucionOperCondensado ELSE ND.NuevaDistribucionOperPetroleo END AS [NuevaDistribucionProvisionalContratista],
			ND.NuevaDistribucionOperC1,
			ND.NuevaDistribucionOperC2,
			ND.NuevaDistribucionOperC3,
			ND.NuevaDistribucionOperC4,
			ND.NuevaDistribucionOperC5
		FROM
			#PC_VolumenProduccionPeriodo	VP
		JOIN
			#PC_RM	RM
			ON	VP.Id	=	RM.Id
		CROSS JOIN #NuevaDistribucionProvisional	ND
		WHERE
			RM.Id	=	2
		
		
		INSERT INTO #Temp_PC_VolumenProduccionPeriodo
		(
		    IdContrato,
		    MesReporte,
		    VolumenPetroleoPuntoMedicion,
		    GradosAPI,
		    ContenidoAzufre,
		    VolumenPetroleoAutoconsumo,
		    MetanoC1,
		    EtanoC2,
		    PropanoC3,
		    ButanoC4,
		    MetanoC1Autoconsumo,
		    EtanoC2Autoconsumo,
		    PropanoC3Autoconsumo,
		    ButanoC4Autoconsumo,
		    VolumenCondensadoPuntoMedicion,
		    VolumenCondensadoAutoconsumo,
		    Bit_CasoFortuito,
		    CantDiasCasoFortuito,
		    OtrosIngresosUsoCompartidoInfraestructura,
		    VolumenPetroleoContratistaReparticion,
		    VolumenMetanoC1ContratistaReparticion,
		    VolumenEtanoC2ContratistaReparticion,
		    VolumenPropanoC3ContratistaReparticion,
		    VolumenButanoC4ContratistaReparticion,
		    VolumenCondensadosContratistaReparticion,
		    VolumenPetroleoEstadoReparticion,
		    VolumenMetanoC1EstadoReparticion,
		    VolumenEtanoC2EstadoReparticion,
		    VolumenPropanoC3EstadoReparticion,
		    VolumenButanoC4EstadoReparticion,
		    VolumenCondensadosEstadoReparticion,
		    VolumenPetroleoContratistaCompensacion,
		    VolumenMetanoC1ContratistaCompensacion,
		    VolumenEtanoC2ContratistaCompensacion,
		    VolumenPropanoC3ContratistaCompensacion,
		    VolumenButanoC4ContratistaCompensacion,
		    VolumenCondensadosContratistaCompensacion,
		    VolumenPetroleoEstadoCompensacion,
		    VolumenMetanoC1EstadoCompensacion,
		    VolumenEtanoC2EstadoCompensacion,
		    VolumenPropanoC3EstadoCompensacion,
		    VolumenButanoC4EstadoCompensacion,
		    VolumenCondensadosEstadoCompensacion,
		    AcumuladoCostosRecuperablesInsolutos,
			VolumenCondensablePuntoMedicion,
			VolumenCondensableAutoconsumo
		)
		SELECT
			IdContrato,
			MesReporte,
			SUM(VolumenPetroleoPuntoMedicion)	AS [VolumenPetroleoPuntoMedicion],
			AVG(GradosAPI)						AS [GradosAPI],
			AVG(ContenidoAzufre)				AS [ContenidoAzufre],
			SUM(VolumenPetroleoAutoconsumo)		AS [VolumenPetroleoAutoconsumo],
			SUM(MetanoC1)						AS [MetanoC1],
			SUM(EtanoC2)						AS [EtanoC2],
			SUM(PropanoC3)						AS [PropanoC3],
			SUM(ButanoC4)						AS [ButanoC4],
			SUM(MetanoC1Autoconsumo)			AS [MetanoC1Autoconsumo],
			SUM(EtanoC2Autoconsumo)				AS [EtanoC2Autoconsumo],
			SUM(PropanoC3Autoconsumo)			AS [PropanoC3Autoconsumo],
			SUM(ButanoC4Autoconsumo)			AS [ButanoC4Autoconsumo],
			SUM(VolumenCondensadoPuntoMedicion)	AS [VolumenCondensadoPuntoMedicion],
			SUM(VolumenCondensadoAutoconsumo)	AS [VolumenCondensadoAutoconsumo],
			CASE WHEN SUM(CONVERT(INT,ISNULL(Bit_CasoFortuito,0))) >= 1 THEN 1
				ELSE 0
			END		AS [Bit_CasoFortuito],
			SUM(ISNULL(CantDiasCasoFortuito,0))			AS [CantDiasCasoFortuito],
			SUM(ISNULL(OtrosIngresosUsoCompartidoInfraestructura,0))	AS [OtrosIngresosUsoCompartidoInfraestructura],
			SUM(ISNULL(VolumenPetroleoContratistaReparticion,0))		AS [VolumenPetroleoContratistaReparticion],
			SUM(ISNULL(VolumenMetanoC1ContratistaReparticion,0))		AS [VolumenMetanoC1ContratistaReparticion],
			SUM(ISNULL(VolumenEtanoC2ContratistaReparticion,0))		AS [VolumenEtanoC2ContratistaReparticion],
			SUM(ISNULL(VolumenPropanoC3ContratistaReparticion,0))		AS [VolumenPropanoC3ContratistaReparticion],
			SUM(ISNULL(VolumenButanoC4ContratistaReparticion,0))		AS [VolumenButanoC4ContratistaReparticion],
			SUM(ISNULL(VolumenCondensadosContratistaReparticion,0))	AS [VolumenCondensadosContratistaReparticion],
			SUM(ISNULL(VolumenPetroleoEstadoReparticion,0))			AS [VolumenPetroleoEstadoReparticion],
			SUM(ISNULL(VolumenMetanoC1EstadoReparticion,0))			AS [VolumenMetanoC1EstadoReparticion],
			SUM(ISNULL(VolumenEtanoC2EstadoReparticion,0))			AS [VolumenEtanoC2EstadoReparticion],
			SUM(ISNULL(VolumenPropanoC3EstadoReparticion,0))			AS [VolumenPropanoC3EstadoReparticion],
			SUM(ISNULL(VolumenButanoC4EstadoReparticion,0))			AS [VolumenButanoC4EstadoReparticion],
			SUM(ISNULL(VolumenCondensadosEstadoReparticion,0))		AS [VolumenCondensadosEstadoReparticion],
			SUM(ISNULL(VolumenPetroleoContratistaCompensacion,0))		AS [VolumenPetroleoContratistaCompensacion],
			SUM(ISNULL(VolumenMetanoC1ContratistaCompensacion,0))		AS [VolumenMetanoC1ContratistaCompensacion],
			SUM(ISNULL(VolumenEtanoC2ContratistaCompensacion,0))		AS [VolumenEtanoC2ContratistaCompensacion],
			SUM(ISNULL(VolumenPropanoC3ContratistaCompensacion,0))	AS [VolumenPropanoC3ContratistaCompensacion],
			SUM(ISNULL(VolumenButanoC4ContratistaCompensacion,0))		AS [VolumenButanoC4ContratistaCompensacion],
			SUM(ISNULL(VolumenCondensadosContratistaCompensacion,0))		AS [VolumenCondensadosContratistaCompensacion],
			SUM(ISNULL(VolumenPetroleoEstadoCompensacion,0))		AS [VolumenPetroleoEstadoCompensacion],
			SUM(ISNULL(VolumenMetanoC1EstadoCompensacion,0))		AS [VolumenMetanoC1EstadoCompensacion],
			SUM(ISNULL(VolumenEtanoC2EstadoCompensacion,0))			AS [VolumenEtanoC2EstadoCompensacion],
			SUM(ISNULL(VolumenPropanoC3EstadoCompensacion,0))		AS [VolumenPropanoC3EstadoCompensacion],
			SUM(ISNULL(VolumenButanoC4EstadoCompensacion,0))		AS [VolumenButanoC4EstadoCompensacion],
			SUM(ISNULL(VolumenCondensadosEstadoCompensacion,0))		AS [VolumenCondensadosEstadoCompensacion],
			SUM(ISNULL(AcumuladoCostosRecuperablesInsolutos,0))		AS [AcumuladoCostosRecuperablesInsolutos],
			SUM(ISNULL(VolumenCondensablePuntoMedicion,0))			AS [VolumenCondensablePuntoMedicion],
			SUM(ISNULL(VolumenCondensableAutoconsumo,0))			AS [VolumenCondensableAutoconsumo]
		FROM
			 #PC_VolumenProduccionPeriodo
		GROUP BY
			IdContrato,
			MesReporte


		IF EXISTS(SELECT 1 FROM	PR_VolumenMensualProduccionPetroleo 
					WHERE IdContrato = @IdContrato
						AND	MesReporte	=	@MesReporte
						AND Activo = 1)
		BEGIN
			
			UPDATE PR_VolumenMensualProduccionPetroleo
			SET 
		    VolumenPetroleoPuntoMedicion = #Temp_PC_VolumenProduccionPeriodo.VolumenPetroleoPuntoMedicion,
		    GradosAPI=  #Temp_PC_VolumenProduccionPeriodo.GradosAPI,
		    ContenidoAzufre= #Temp_PC_VolumenProduccionPeriodo.ContenidoAzufre,
		    VolumenPetroleoAutoconsumo = #Temp_PC_VolumenProduccionPeriodo.VolumenPetroleoAutoconsumo,
		    MetanoC1 = #Temp_PC_VolumenProduccionPeriodo.MetanoC1,
		    EtanoC2 = #Temp_PC_VolumenProduccionPeriodo.EtanoC2,
		    PropanoC3 = #Temp_PC_VolumenProduccionPeriodo.PropanoC3,
		    ButanoC4 = #Temp_PC_VolumenProduccionPeriodo.ButanoC4,
		    MetanoC1Autoconsumo = #Temp_PC_VolumenProduccionPeriodo.MetanoC1Autoconsumo,
		    EtanoC2Autoconsumo = #Temp_PC_VolumenProduccionPeriodo.EtanoC2Autoconsumo,
		    PropanoC3Autoconsumo = #Temp_PC_VolumenProduccionPeriodo.PropanoC3Autoconsumo,
		    ButanoC4Autoconsumo = #Temp_PC_VolumenProduccionPeriodo.ButanoC4Autoconsumo,
		    VolumenCondensadoPuntoMedicion = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensadoPuntoMedicion,
		    VolumenCondensadoAutoconsumo = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensadoAutoconsumo,
		    Bit_CasoFortuito = #Temp_PC_VolumenProduccionPeriodo.Bit_CasoFortuito,
		    CantDiasCasoFortuito = #Temp_PC_VolumenProduccionPeriodo.CantDiasCasoFortuito,
		    OtrosIngresosUsoCompartidoInfraestructura = #Temp_PC_VolumenProduccionPeriodo.OtrosIngresosUsoCompartidoInfraestructura,
		    VolumenPetroleoContratistaReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenPetroleoContratistaReparticion,
		    VolumenMetanoC1ContratistaReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenMetanoC1ContratistaReparticion,
		    VolumenEtanoC2ContratistaReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenEtanoC2ContratistaReparticion,
		    VolumenPropanoC3ContratistaReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenPropanoC3ContratistaReparticion,
		    VolumenButanoC4ContratistaReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenButanoC4ContratistaReparticion,
		    VolumenCondensadosContratistaReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensadosContratistaReparticion,
		    VolumenPetroleoEstadoReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenPetroleoEstadoReparticion,
		    VolumenMetanoC1EstadoReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenMetanoC1EstadoReparticion,
		    VolumenEtanoC2EstadoReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenEtanoC2EstadoReparticion	,
		    VolumenPropanoC3EstadoReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenPropanoC3EstadoReparticion,
		    VolumenButanoC4EstadoReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenButanoC4EstadoReparticion,
		    VolumenCondensadosEstadoReparticion = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensadosEstadoReparticion,
		    VolumenPetroleoContratistaCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenPetroleoContratistaCompensacion,
		    VolumenMetanoC1ContratistaCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenMetanoC1ContratistaCompensacion,
		    VolumenEtanoC2ContratistaCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenEtanoC2ContratistaCompensacion,
		    VolumenPropanoC3ContratistaCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenPropanoC3ContratistaCompensacion,
		    VolumenButanoC4ContratistaCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenButanoC4ContratistaCompensacion,
		    VolumenCondensadosContratistaCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensadosContratistaCompensacion,
		    VolumenPetroleoEstadoCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenPetroleoEstadoCompensacion,
		    VolumenMetanoC1EstadoCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenMetanoC1EstadoCompensacion,
		    VolumenEtanoC2EstadoCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenEtanoC2EstadoCompensacion,
		    VolumenPropanoC3EstadoCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenPropanoC3EstadoCompensacion,
		    VolumenButanoC4EstadoCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenButanoC4EstadoCompensacion,
		    VolumenCondensadosEstadoCompensacion = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensadosEstadoCompensacion,
		    AcumuladoCostosRecuperablesInsolutos = #Temp_PC_VolumenProduccionPeriodo.AcumuladoCostosRecuperablesInsolutos,
			VolumenCondensablePuntoMedicion = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensablePuntoMedicion,
			VolumenCondensableAutoconsumo = #Temp_PC_VolumenProduccionPeriodo.VolumenCondensableAutoconsumo,
			ModificadoEl = GETDATE(),
			ModificadoPor = @Usuario
			FROM PR_VolumenMensualProduccionPetroleo
			INNER JOIN #Temp_PC_VolumenProduccionPeriodo 
				ON  PR_VolumenMensualProduccionPetroleo.IdContrato = #Temp_PC_VolumenProduccionPeriodo.IdContrato
					AND PR_VolumenMensualProduccionPetroleo.MesReporte = #Temp_PC_VolumenProduccionPeriodo.MesReporte
					AND PR_VolumenMensualProduccionPetroleo.Activo = 1
			WHERE PR_VolumenMensualProduccionPetroleo.Activo = 1
			AND PR_VolumenMensualProduccionPetroleo.IdContrato = @IdContrato
			AND PR_VolumenMensualProduccionPetroleo.MesReporte = @MesReporte
			
		END
		ELSE 
		BEGIN

			INSERT INTO dbo.PR_VolumenMensualProduccionPetroleo
			(
				IdContrato,
				MesReporte,
				VolumenPetroleoPuntoMedicion,
				GradosAPI,
				ContenidoAzufre,
				VolumenPetroleoAutoconsumo,
				MetanoC1,
				EtanoC2,
				PropanoC3,
				ButanoC4,
				MetanoC1Autoconsumo,
				EtanoC2Autoconsumo,
				PropanoC3Autoconsumo,
				ButanoC4Autoconsumo,
				VolumenCondensadoPuntoMedicion,
				VolumenCondensadoAutoconsumo,
				Bit_CasoFortuito,
				CantDiasCasoFortuito,
				OtrosIngresosUsoCompartidoInfraestructura,
				VolumenPetroleoContratistaReparticion,
				VolumenMetanoC1ContratistaReparticion,
				VolumenEtanoC2ContratistaReparticion,
				VolumenPropanoC3ContratistaReparticion,
				VolumenButanoC4ContratistaReparticion,
				VolumenCondensadosContratistaReparticion,
				VolumenPetroleoEstadoReparticion,
				VolumenMetanoC1EstadoReparticion,
				VolumenEtanoC2EstadoReparticion,
				VolumenPropanoC3EstadoReparticion,
				VolumenButanoC4EstadoReparticion,
				VolumenCondensadosEstadoReparticion,
				VolumenPetroleoContratistaCompensacion,
				VolumenMetanoC1ContratistaCompensacion,
				VolumenEtanoC2ContratistaCompensacion,
				VolumenPropanoC3ContratistaCompensacion,
				VolumenButanoC4ContratistaCompensacion,
				VolumenCondensadosContratistaCompensacion,
				VolumenPetroleoEstadoCompensacion,
				VolumenMetanoC1EstadoCompensacion,
				VolumenEtanoC2EstadoCompensacion,
				VolumenPropanoC3EstadoCompensacion,
				VolumenButanoC4EstadoCompensacion,
				VolumenCondensadosEstadoCompensacion,
				AcumuladoCostosRecuperablesInsolutos,
				VolumenCondensablePuntoMedicion,
				VolumenCondensableAutoconsumo,
				Activo,
				CreadoEl,
				CreadoPor
			)
			SELECT
				IdContrato,
				MesReporte,
				VolumenPetroleoPuntoMedicion,
				GradosAPI,
				ContenidoAzufre,
				VolumenPetroleoAutoconsumo,
				MetanoC1,
				EtanoC2,
				PropanoC3,
				ButanoC4,
				MetanoC1Autoconsumo,
				EtanoC2Autoconsumo,
				PropanoC3Autoconsumo,
				ButanoC4Autoconsumo,
				VolumenCondensadoPuntoMedicion,
				VolumenCondensadoAutoconsumo,
				Bit_CasoFortuito,
				CantDiasCasoFortuito,
				OtrosIngresosUsoCompartidoInfraestructura,
				VolumenPetroleoContratistaReparticion,
				VolumenMetanoC1ContratistaReparticion,
				VolumenEtanoC2ContratistaReparticion,
				VolumenPropanoC3ContratistaReparticion,
				VolumenButanoC4ContratistaReparticion,
				VolumenCondensadosContratistaReparticion,
				VolumenPetroleoEstadoReparticion,
				VolumenMetanoC1EstadoReparticion,
				VolumenEtanoC2EstadoReparticion,
				VolumenPropanoC3EstadoReparticion,
				VolumenButanoC4EstadoReparticion,
				VolumenCondensadosEstadoReparticion,
				VolumenPetroleoContratistaCompensacion,
				VolumenMetanoC1ContratistaCompensacion,
				VolumenEtanoC2ContratistaCompensacion,
				VolumenPropanoC3ContratistaCompensacion,
				VolumenButanoC4ContratistaCompensacion,
				VolumenCondensadosContratistaCompensacion,
				VolumenPetroleoEstadoCompensacion,
				VolumenMetanoC1EstadoCompensacion,
				VolumenEtanoC2EstadoCompensacion,
				VolumenPropanoC3EstadoCompensacion,
				VolumenButanoC4EstadoCompensacion,
				VolumenCondensadosEstadoCompensacion,
				AcumuladoCostosRecuperablesInsolutos,
				VolumenCondensablePuntoMedicion,
				VolumenCondensableAutoconsumo,
				1,
				GETDATE(),
				@Usuario
			FROM
				 #Temp_PC_VolumenProduccionPeriodo

		END
	END
END
END
