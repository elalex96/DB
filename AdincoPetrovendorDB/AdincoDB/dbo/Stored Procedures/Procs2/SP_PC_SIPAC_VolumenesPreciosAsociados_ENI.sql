CREATE PROCEDURE dbo.SP_PC_SIPAC_VolumenesPreciosAsociados_ENI
	@Contrato INT,
	@Mes      DATE
AS
     BEGIN
-- ======================================================================
-- Author:		Manuel Cruz
-- Create date: 02-06-17
-- Description:	
-- ======================================================================
-- 20180801	BAAC	Se modifica para redondear el precio de los hidrocarburos a 2 decimales
-- 20180801	BAAC	Se modifica para agregar el volumen de Condensable (C5+) en el Condensado
-- 20180913	BAAC	Se modifica para asignar NA a los precios si no hay volumenes producidos de los hidrocarburos
-- 20190321	BAAC	Se modifica para que en caso de haber un btu o barril que no se puede repartir, se asigne al que tenga el porcentaje mayor del mismo
-- ======================================================================
-- 20240628	RO	Se modifica para que se filtre la información de la tabla PR_VolumenMensualProduccionPetroleo por el Activo = 1
SET NOCOUNT ON
-- ======================================================================
CREATE TABLE #VolumenComercializado
(
	tipohidrocarburo      INT,
	VolumenComercializado INT,
	PRIMARY KEY(tipohidrocarburo)
)

CREATE TABLE #Calculo
(
	tipohidrocarburo INT,
	Volumen          INT,
	Precio           DECIMAL(16, 4),
	PRIMARY KEY(tipohidrocarburo)
)

CREATE TABLE #VolPreciosAsociado
(
	IdContratista_RF_00	VARCHAR(20),
	IdContrato_RI_00		VARCHAR(30),
	NumeroContrato_RF01_01		VARCHAR(35),
	MesReporte_RMPCT32_00	INT,
	AnioReporte_RMPCT32_01	INT,
	VolPetroPtoMed_RMPCT32_02	INT,
	GradosAPI_RMPCT32_03		FLOAT,
	Azufre_RMPCT32_04			FLOAT,
	VolPetroAutoCon_RMPCT32_05	INT,
	VolMetanoPtoMed_RMPCT32_06	INT,
	VolEtanoPtoMed_RMPCT32_07	INT,
	VolPropanoPtoMed_RMPCT32_08	INT,
	VolButanoPtoMed_RMPCT32_09	INT,
	VolMetanoAutoCon_RMPCT32_10	INT,
	VolEtanoAutoCon_RMPCT32_11	INT,
	VolPropanoAutoCon_RMPCT32_12	INT,
	VolButanoAutoCon_RMPCT32_13	INT,
	VolCondensadosPtoMed_RMPCT32_14	INT,
	VolCondensadoAutocon_RMPCT32_15	INT,
	VolPetroVendido_RMPCT32_16	INT,
	VolMetanoVendido_RMPCT32_17	INT,
	VolEtanoVendido_RMPCT32_18	INT,
	VolPropanoVendido_RMPCT32_19	INT,
	VolButanoVendido_RMPCT32_20	INT,
	VolCondensadoVendido_RMPCT32_21	INT,
	PrecioPetro_RMPCT32_22 FLOAT,
	PrecioMetano_RMPCT32_23 FLOAT,
	PrecioEtano_RMPCT32_24 FLOAT,
	PrecioPropano_RMPCT32_25 FLOAT,
	PrecioButano_RMPCT32_26 FLOAT,
	PrecioCondensado_RMPCT32_27 FLOAT,
	--PrecioMetano_RMPCT32_23 VARCHAR(8),
	--PrecioEtano_RMPCT32_24 VARCHAR(8),
	--PrecioPropano_RMPCT32_25 VARCHAR(8),
	--PrecioButano_RMPCT32_26 VARCHAR(8),
	--PrecioCondensado_RMPCT32_27 VARCHAR(8),
	VolPetroContratistaReparticion_RMPCT32_28 INT,
	VolMetanoContratistaReparticion_RMPCT32_29 INT,
	VolEtanoContratistaReparticion_RMPCT32_30 INT,
	VolPropanoContratistaReparticion_RMPCT32_31 INT,
	VolButanoContratistaReparticion_RMPCT32_32 INT,
	VolCondensadoContratistaReparticion_RMPCT32_33 INT,
	VolPetroEstadoReparticion_RMPCT32_34 INT,
	VolMetanoEstadoReparticion_RMPCT32_35 INT,
	VolEtanoEstadoReparticion_RMPCT32_36 INT,
	VolPropanoEstadoReparticion_RMPCT32_37 INT,
	VolButanoEstadoReparticion_RMPCT32_38 INT,
	VolCondensadoEstadoReparticion_RMPCT32_39 INT,
	VolPetroContratistaCompensacion_RMPCT32_40 INT,
	VolMetanoContratistaCompensacion_RMPCT32_41 INT,
	VolEtanoContratistaCompensacion_RMPCT32_42 INT,
	VolPropanoContratistaCompensacion_RMPCT32_43 INT,
	VolButanoContratistaCompensacion_RMPCT32_44 INT,
	VolCondensadoContratistaCompensacion_RMPCT32_45 INT,
	VolPetroEstadoCompensacion_RMPCT32_46 INT,
	VolMetanoEstadoCompensacion_RMPCT32_47 INT,
	VolEtanoEstadoCompensacion_RMPCT32_48 INT,
	VolPropanoEstadoCompensacion_RMPCT32_49 INT,
	VolButanoEstadoCompensacion_RMPCT32_50 INT,
	VolCondensadoEstadoCompensacion_RMPCT32_51 INT,
	NuevaDistribucionProvisionalContratistaPetroleo	FLOAT,
	NuevaDistribucionProvisionalEstadoPetroleo		FLOAT,
	NuevaDistribucionProvisionalContratistaC1		FLOAT,
	NuevaDistribucionProvisionalContratistaC2		FLOAT,
	NuevaDistribucionProvisionalContratistaC3		FLOAT,
	NuevaDistribucionProvisionalContratistaC4		FLOAT,
	NuevaDistribucionProvisionalContratistaC5		FLOAT
)

DECLARE @GasNoAsociado BIT

SELECT @GasNoAsociado = gasnoasociado 
FROM CO_Contrato
WHERE IdContrato= @Contrato

IF (@GasNoAsociado =0) 
BEGIN 
    EXEC dbo.sp_PC_SIPAC_Procesar_IdFacturaVenta
        @Contrato,
        @Mes

    -- Volumen Comercializado en Base a Reglas de Mercado
    INSERT INTO #VolumenComercializado
    (tipohidrocarburo,
    VolumenComercializado
    )
    SELECT TH.TipoHidrocarburo,
            SUM(ROUND(VolumenVendido, 0))
    FROM COM_OperacionComercializacion AS OP
            LEFT JOIN CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
    WHERE OP.MesReporte = @Mes
            AND OP.IdContrato = @Contrato
            AND OP.OperacionBajoReglasMercado = 1
    GROUP BY th.tipohidrocarburo

        INSERT INTO #Calculo
        (tipohidrocarburo,
        Volumen,
        Precio
        )
    SELECT TH.tipohidrocarburo,
            SUM(ROUND(OP.VolumenVendido, 0)),
            --SUM(OP.PrecioVentaUnitario * CONVERT( DECIMAL(14, 0), OP.VolumenVendido) / VC.VolumenComercializado)
            SUM((ROUND(OP.PrecioVentaUnitario,4) - ROUND(OP.CostoUnitarioComercializacion,4)) * ROUND(OP.VolumenVendido, 0) / VC.VolumenComercializado)
    FROM COM_OperacionComercializacion AS OP
            LEFT JOIN CO_TipoHidrocarburo AS TH ON OP.IdTipoHidrocarburo = TH.Idtipohidrocarburo
            LEFT JOIN #VolumenComercializado VC ON TH.tipohidrocarburo = VC.tipohidrocarburo
    WHERE OP.MesReporte = @Mes
            AND OP.IdContrato = @Contrato
            AND OP.OperacionBajoReglasMercado = 1
    GROUP BY TH.tipohidrocarburo

        SELECT @Contrato AS idcontrato,
            @Mes AS mesreporte,
            *
        INTO #Volumen
        FROM
        (
            SELECT tipohidrocarburo,
                volumen
            FROM #Calculo
        ) AS SourceTable PIVOT(SUM(Volumen) 
		FOR tipohidrocarburo IN([1],
                            [2],
                            [3],
                            [4],
                            [5],
                            [6])) AS PivotTable
        SELECT @Contrato AS idcontrato,
            @Mes AS mesreporte,
            *
        INTO #Precio
        FROM
        (
            SELECT tipohidrocarburo,
                precio
            FROM #Calculo
        ) AS SourceTable PIVOT(SUM(precio) 
		FOR tipohidrocarburo IN([1],
                            [2],
                            [3],
                            [4],
							[5],
                            [6])) AS PivotTable
	IF 0 <(SELECT COUNT(1)
			FROM #Volumen
			WHERE ROUND(ISNULL([1], 0),0) > 0
			AND ROUND(ISNULL([2], 0),0) > 0
			AND ROUND(ISNULL([3], 0),0) > 0
			AND ROUND(ISNULL([4], 0),0) > 0
			AND ROUND(ISNULL([5], 0),0) > 0
			AND ROUND(ISNULL([6], 0),0) > 0)
	BEGIN
		INSERT INTO #VolPreciosAsociado
		(
		    IdContratista_RF_00,
		    IdContrato_RI_00,
		    NumeroContrato_RF01_01,
		    MesReporte_RMPCT32_00,
		    AnioReporte_RMPCT32_01,
		    VolPetroPtoMed_RMPCT32_02,
		    GradosAPI_RMPCT32_03,
		    Azufre_RMPCT32_04,
		    VolPetroAutoCon_RMPCT32_05,
		    VolMetanoPtoMed_RMPCT32_06,
		    VolEtanoPtoMed_RMPCT32_07,
		    VolPropanoPtoMed_RMPCT32_08,
		    VolButanoPtoMed_RMPCT32_09,
		    VolMetanoAutoCon_RMPCT32_10,
		    VolEtanoAutoCon_RMPCT32_11,
		    VolPropanoAutoCon_RMPCT32_12,
		    VolButanoAutoCon_RMPCT32_13,
		    VolCondensadosPtoMed_RMPCT32_14,
		    VolCondensadoAutocon_RMPCT32_15,
		    VolPetroVendido_RMPCT32_16,
		    VolMetanoVendido_RMPCT32_17,
		    VolEtanoVendido_RMPCT32_18,
		    VolPropanoVendido_RMPCT32_19,
		    VolButanoVendido_RMPCT32_20,
		    VolCondensadoVendido_RMPCT32_21,
		    PrecioPetro_RMPCT32_22,
		    PrecioMetano_RMPCT32_23,
		    PrecioEtano_RMPCT32_24,
		    PrecioPropano_RMPCT32_25,
		    PrecioButano_RMPCT32_26,
		    PrecioCondensado_RMPCT32_27,
		    VolPetroContratistaReparticion_RMPCT32_28,
		    VolMetanoContratistaReparticion_RMPCT32_29,
		    VolEtanoContratistaReparticion_RMPCT32_30,
		    VolPropanoContratistaReparticion_RMPCT32_31,
		    VolButanoContratistaReparticion_RMPCT32_32,
		    VolCondensadoContratistaReparticion_RMPCT32_33,
		    VolPetroEstadoReparticion_RMPCT32_34,
		    VolMetanoEstadoReparticion_RMPCT32_35,
		    VolEtanoEstadoReparticion_RMPCT32_36,
		    VolPropanoEstadoReparticion_RMPCT32_37,
		    VolButanoEstadoReparticion_RMPCT32_38,
		    VolCondensadoEstadoReparticion_RMPCT32_39,
		    VolPetroContratistaCompensacion_RMPCT32_40,
		    VolMetanoContratistaCompensacion_RMPCT32_41,
		    VolEtanoContratistaCompensacion_RMPCT32_42,
		    VolPropanoContratistaCompensacion_RMPCT32_43,
		    VolButanoContratistaCompensacion_RMPCT32_44,
		    VolCondensadoContratistaCompensacion_RMPCT32_45,
		    VolPetroEstadoCompensacion_RMPCT32_46,
		    VolMetanoEstadoCompensacion_RMPCT32_47,
		    VolEtanoEstadoCompensacion_RMPCT32_48,
		    VolPropanoEstadoCompensacion_RMPCT32_49,
		    VolButanoEstadoCompensacion_RMPCT32_50,
		    VolCondensadoEstadoCompensacion_RMPCT32_51,
			NuevaDistribucionProvisionalContratistaPetroleo,
			NuevaDistribucionProvisionalEstadoPetroleo,
			NuevaDistribucionProvisionalContratistaC1,
			NuevaDistribucionProvisionalContratistaC2,
			NuevaDistribucionProvisionalContratistaC3,
			NuevaDistribucionProvisionalContratistaC4,
			NuevaDistribucionProvisionalContratistaC5
		)
         SELECT Ca.IDSIPAC AS RF_00,
                C.IDRegFiducidiario AS RI_00,
                C.NumeroContrato AS RF01_01,
                MONTH(VMPPG.MesReporte) AS RMPCT32_00,
                YEAR(VMPPG.MesReporte) AS RMPCT32_01,
				ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0) AS RMPCT32_02,
                CONVERT(DECIMAL(3, 1), VMPPG.GradosAPI) AS RMPCT32_03,
                CONVERT(DECIMAL(6, 2), VMPPG.ContenidoAzufre) AS RMPCT32_04,
                ROUND(VMPPG.VolumenPetroleoAutoconsumo,0) AS RMPCT32_05,
                ROUND(VMPPG.MetanoC1, 0) AS RMPCT32_06,
                ROUND(VMPPG.EtanoC2, 0) AS RMPCT32_07,
                ROUND(VMPPG.PropanoC3, 0) AS RMPCT32_08,
                ROUND(VMPPG.ButanoC4, 0) AS RMPCT32_09,
                ROUND(VMPPG.MetanoC1Autoconsumo,0) AS RMPCT32_10,
                ROUND(VMPPG.EtanoC2Autoconsumo,0) AS RMPCT32_11,
                ROUND(VMPPG.PropanoC3Autoconsumo,0) AS RMPCT32_12,
                ROUND(VMPPG.ButanoC4Autoconsumo,0) AS RMPCT32_13,
                ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) AS RMPCT32_14,
                ROUND(VMPPG.VolumenCondensadoAutoconsumo,0) + ROUND(ISNULL(VMPPG.VolumenCondensableAutoconsumo,0),0) AS RMPCT32_15,
                ROUND(ISNULL(V.[1], 0),0) AS RMPCT32_16,
                ROUND(ISNULL(V.[3], 0),0) AS RMPCT32_17,
                ROUND(ISNULL(V.[4], 0),0) AS RMPCT32_18,
                ROUND(ISNULL(V.[5], 0),0) AS RMPCT32_19,
                ROUND(ISNULL(V.[6], 0),0) AS RMPCT32_20,
                ROUND(ISNULL(V.[2], 0),0) AS RMPCT32_21,
                ROUND(ISNULL(P.[1], 0),4) AS RMPCT32_22,
                ROUND(ISNULL(P.[3], 0),4) AS RMPCT32_23,
                ROUND(ISNULL(P.[4], 0),4) AS RMPCT32_24,
                ROUND(ISNULL(P.[5], 0),4) AS RMPCT32_25,
                ROUND(ISNULL(P.[6], 0),4) AS RMPCT32_26,
                ROUND(ISNULL(P.[2], 0),4) AS RMPCT32_27,
				CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo < 0
					THEN ROUND( (VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))	+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo, 0 )
					ELSE ROUND( (VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)), 0 )
                END AS RMPCT32_28,
                CASE
WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
                    THEN ROUND(((ROUND(VMPPG.MetanoC1,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1), 0)
                    ELSE ROUND(((ROUND(VMPPG.MetanoC1,0) * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100))), 0)
                END AS RMPCT32_29,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
                    THEN ROUND(((ROUND(VMPPG.EtanoC2,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)), 0)
                    ELSE ROUND(((ROUND(VMPPG.EtanoC2,0) * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100))), 0)
                END AS RMPCT32_30,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
                    THEN ROUND((((ROUND(VMPPG.PropanoC3,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)), 0)
                    ELSE ROUND(((ROUND(VMPPG.PropanoC3,0) * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100))), 0)
                END AS RMPCT32_31,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
                    THEN ROUND((((ROUND(VMPPG.ButanoC4,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)), 0)
                    ELSE ROUND(((ROUND(VMPPG.ButanoC4,0) * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100))), 0)
                END AS RMPCT32_32,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
                    THEN ROUND((((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * (FMP53.NuevaDistribucionProvisionalContratista / 100),0)
					--WHEN VMPPG.MesReporte = '20170601' AND VMPPG.IdContrato = 10010 
					--THEN  ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * ( 69.464847 / 100))), 0)	-- SE PONE FIJA LA DISTRIBUCION POR EL REPROCESO
					--	+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * (FMP53.NuevaDistribucionProvisionalContratistaC5 / 100),0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * (FMP53.NuevaDistribucionProvisionalContratista / 100),0)
                END AS RMPCT32_33,
                CASE
					WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo < 0
                    THEN ROUND(((ROUND(VMPPG.VolumenPetroleoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo), 0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenPetroleoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                END AS RMPCT32_34,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 < 0
                    THEN ROUND(((ROUND(VMPPG.MetanoC1,0) * ((100.00 -FMP53.NuevaDistribucionProvisionalContratista) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1), 0)
                    ELSE ROUND(((ROUND(VMPPG.MetanoC1,0) * ((100.00 -FMP53.NuevaDistribucionProvisionalContratista) / 100))), 0)
                END AS RMPCT32_35,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2 < 0
                    THEN ROUND(((ROUND(VMPPG.EtanoC2,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2), 0)
                    ELSE ROUND(((ROUND(VMPPG.EtanoC2,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100))), 0)
                END AS RMPCT32_36,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 < 0
                    THEN ROUND(((ROUND(VMPPG.PropanoC3,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3), 0)
                    ELSE ROUND(((ROUND(VMPPG.PropanoC3,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100))), 0)
					END AS RMPCT32_37,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 < 0
                    THEN ROUND(((ROUND(VMPPG.ButanoC4,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4), 0)
                    ELSE ROUND(((ROUND(VMPPG.ButanoC4,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100))), 0)
                END AS RMPCT32_38,
                CASE
					WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado < 0
                    THEN ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100),0)
					--WHEN VMPPG.MesReporte = '20170601' AND VMPPG.IdContrato = 10010 
					--THEN  ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * ( 30.535152 / 100))), 0) -- SE PONE FIJA LA DISTRIBUCION POR EL REPROCESO
					--	+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratista) / 100),0)
                END AS RMPCT32_39,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo)
                    ELSE 0
                END AS RMPCT32_40,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1)
                    ELSE 0
                END AS RMPCT32_41,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)
                    ELSE 0
                END AS RMPCT32_42,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)
                    ELSE 0
                END AS RMPCT32_43,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)
                    ELSE 0
                END AS RMPCT32_44,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > 0
					THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)
                    ELSE 0
                END AS RMPCT32_45,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo)
					ELSE 0
                END AS RMPCT32_46,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1)
                    ELSE 0
                END AS RMPCT32_47,
				CASE
                    WHEN CompensacionVolNuevoSaldoAcumuladoEstadoC2 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2)
                    ELSE 0
                END AS RMPCT32_48,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3)
                    ELSE 0
                END AS RMPCT32_49,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4)
                    ELSE 0
                END AS RMPCT32_50,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado)
                    ELSE 0
                END AS RMPCT32_51,
				FMP53.NuevaDistribucionProvisionalContratista,
				FMP53.NuevaDistribucionProvisionalEstado,
				FMP53.NuevaDistribucionProvisionalContratista,
				FMP53.NuevaDistribucionProvisionalContratista,
				FMP53.NuevaDistribucionProvisionalContratista,
				FMP53.NuevaDistribucionProvisionalContratista,
				FMP53.NuevaDistribucionProvisionalContratista
         FROM PR_VolumenMensualProduccionPetroleo VMPPG
        LEFT JOIN CO_Contrato C 
			ON VMPPG.IdContrato = C.IdContrato
			AND ISNULL(VMPPG.Activo,0) = 1
        LEFT JOIN CO_Contratista Ca 
			ON C.IdContratista = Ca.IdContratista
        LEFT JOIN #Precio P 
			ON C.IdContrato = P.IdContrato
        LEFT JOIN #Volumen V 
			ON C.IdContrato = V.IdContrato
        LEFT JOIN CP_PorcentajesReparticionPC PRPC 
			ON PRPC.IdContrato = v.idcontrato
            AND VMPPG.MesReporte = PRPC.MesReporte
        LEFT JOIN SIPAC_RM_FMP_53_M FMP53 
			ON FMP53.IdContrato = @Contrato
            AND DATEADD(month, 1, DATEFROMPARTS(FMP53.anioreporte, FMP53.mesreporte, 1)) = @Mes
        WHERE VMPPG.IdContrato = @Contrato
               AND VMPPG.MesReporte = @Mes
			   AND ISNULL(VMPPG.Activo,0) = 1

		-- SE VALIDA SI AL SUMAR LOS VALORES DE REPARTICION DEL PETROLEO, EXISTE DIFERENCIA CONTRA LA PRODUCCION
		IF 0 <> (SELECT	VolPetroPtoMed_RMPCT32_02 - (VolPetroContratistaReparticion_RMPCT32_28 + 
											VolPetroEstadoReparticion_RMPCT32_34 +
											VolPetroContratistaCompensacion_RMPCT32_40 + 
											VolPetroEstadoCompensacion_RMPCT32_46)
			FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL BARRIL RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolPetroContratistaReparticion_RMPCT32_28 = CASE WHEN (VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)),0) > 
																	(VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) ,0)
																	THEN VolPetroContratistaReparticion_RMPCT32_28 + 1
																ELSE VolPetroContratistaReparticion_RMPCT32_28
																END,
					VolPetroEstadoReparticion_RMPCT32_34	=	CASE WHEN (VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) ,0) >
																	(VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)),0)
																	THEN VolPetroEstadoReparticion_RMPCT32_34 + 1
																ELSE VolPetroEstadoReparticion_RMPCT32_34
																END
		END

		-- METANO
		IF 0 <> (SELECT	VolMetanoPtoMed_RMPCT32_06 - (VolMetanoContratistaReparticion_RMPCT32_29 + 
												VolMetanoEstadoReparticion_RMPCT32_35 +
												VolMetanoContratistaCompensacion_RMPCT32_41 + 
												VolMetanoEstadoCompensacion_RMPCT32_47)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolMetanoContratistaReparticion_RMPCT32_29 = CASE WHEN (VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)),0) > 
																	(VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) ,0)
																	THEN VolMetanoContratistaReparticion_RMPCT32_29 + 1
																ELSE VolMetanoContratistaReparticion_RMPCT32_29
																END,
					VolMetanoEstadoReparticion_RMPCT32_35	=	CASE WHEN (VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) ,0) >
																	(VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)),0)
																	THEN VolMetanoEstadoReparticion_RMPCT32_35 + 1
																ELSE VolMetanoEstadoReparticion_RMPCT32_35
																END
		END

		-- ETANO
		IF 0 <> (SELECT	VolEtanoPtoMed_RMPCT32_07 - (VolEtanoContratistaReparticion_RMPCT32_30 + 
												VolEtanoEstadoReparticion_RMPCT32_36 +
												VolEtanoContratistaCompensacion_RMPCT32_42 + 
												VolEtanoEstadoCompensacion_RMPCT32_48)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolEtanoContratistaReparticion_RMPCT32_30 = CASE WHEN (VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)),0) > 
																	(VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) ,0)
																	THEN VolEtanoContratistaReparticion_RMPCT32_30 + 1
																ELSE VolEtanoContratistaReparticion_RMPCT32_30
																END,
					VolEtanoEstadoReparticion_RMPCT32_36	=	CASE WHEN (VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) ,0) >
																	(VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)),0)
																	THEN VolEtanoEstadoReparticion_RMPCT32_36 + 1
																ELSE VolEtanoEstadoReparticion_RMPCT32_36
																END
		END

		-- PROPANO
		IF 0 <> (SELECT	VolPropanoPtoMed_RMPCT32_08 - (VolPropanoContratistaReparticion_RMPCT32_31 + 
												VolPropanoEstadoReparticion_RMPCT32_37 +
												VolPropanoContratistaCompensacion_RMPCT32_43 + 
												VolPropanoEstadoCompensacion_RMPCT32_49)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolPropanoContratistaReparticion_RMPCT32_31 = CASE WHEN (VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)),0) > 
																	(VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) ,0)
																	THEN VolPropanoContratistaReparticion_RMPCT32_31 + 1
																ELSE VolPropanoContratistaReparticion_RMPCT32_31
																END,
					VolPropanoEstadoReparticion_RMPCT32_37	=	CASE WHEN (VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) ,0) >
																	(VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)),0)
																	THEN VolPropanoEstadoReparticion_RMPCT32_37 + 1
																ELSE VolPropanoEstadoReparticion_RMPCT32_37
																END
		END

		-- BUTANO
		IF 0 <> (SELECT	VolButanoPtoMed_RMPCT32_09 - (VolButanoContratistaReparticion_RMPCT32_32 + 
												VolButanoEstadoReparticion_RMPCT32_38 +
												VolButanoContratistaCompensacion_RMPCT32_44 + 
												VolButanoEstadoCompensacion_RMPCT32_50)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolButanoContratistaReparticion_RMPCT32_32 = CASE WHEN (VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)),0) > 
																	(VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) ,0)
																	THEN VolButanoContratistaReparticion_RMPCT32_32 + 1
																ELSE VolButanoContratistaReparticion_RMPCT32_32
																END,
					VolButanoEstadoReparticion_RMPCT32_38	=	CASE WHEN (VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) ,0) >
																	(VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)),0)
																	THEN VolButanoEstadoReparticion_RMPCT32_38 + 1
																ELSE VolButanoEstadoReparticion_RMPCT32_38
																END
		END

		-- CONDENSADO
		IF 0 <> (SELECT	VolCondensadosPtoMed_RMPCT32_14 - (VolCondensadoContratistaReparticion_RMPCT32_33 + 
												VolCondensadoEstadoReparticion_RMPCT32_39 +
												VolCondensadoContratistaCompensacion_RMPCT32_45 + 
												VolCondensadoEstadoCompensacion_RMPCT32_51)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL BARRIL RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolCondensadoContratistaReparticion_RMPCT32_33 = CASE WHEN (VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)),0) > 
																	(VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) ,0)
																	THEN VolCondensadoContratistaReparticion_RMPCT32_33 + 1
																ELSE VolCondensadoContratistaReparticion_RMPCT32_33
																END,
					VolCondensadoEstadoReparticion_RMPCT32_39	=	CASE WHEN (VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) ,0) >
																	(VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)),0)
																	THEN VolCondensadoEstadoReparticion_RMPCT32_39 + 1
																ELSE VolCondensadoEstadoReparticion_RMPCT32_39
																END
		END

		SELECT
			IdContratista_RF_00,
		    IdContrato_RI_00,
		    NumeroContrato_RF01_01,
		    MesReporte_RMPCT32_00,
		    AnioReporte_RMPCT32_01,
		    VolPetroPtoMed_RMPCT32_02,
		    GradosAPI_RMPCT32_03,
		    Azufre_RMPCT32_04,
		    VolPetroAutoCon_RMPCT32_05,
		    VolMetanoPtoMed_RMPCT32_06,
		    VolEtanoPtoMed_RMPCT32_07,
		    VolPropanoPtoMed_RMPCT32_08,
		    VolButanoPtoMed_RMPCT32_09,
		    VolMetanoAutoCon_RMPCT32_10,
		    VolEtanoAutoCon_RMPCT32_11,
		    VolPropanoAutoCon_RMPCT32_12,
		    VolButanoAutoCon_RMPCT32_13,
		    VolCondensadosPtoMed_RMPCT32_14,
		    VolCondensadoAutocon_RMPCT32_15,
		    VolPetroVendido_RMPCT32_16,
		    VolMetanoVendido_RMPCT32_17,
		    VolEtanoVendido_RMPCT32_18,
		    VolPropanoVendido_RMPCT32_19,
		    VolButanoVendido_RMPCT32_20,
		    VolCondensadoVendido_RMPCT32_21,
		    PrecioPetro_RMPCT32_22,
		    PrecioMetano_RMPCT32_23,
		    PrecioEtano_RMPCT32_24,
		    PrecioPropano_RMPCT32_25,
		    PrecioButano_RMPCT32_26,
		    PrecioCondensado_RMPCT32_27,
		    VolPetroContratistaReparticion_RMPCT32_28,
		    VolMetanoContratistaReparticion_RMPCT32_29,
		    VolEtanoContratistaReparticion_RMPCT32_30,
		    VolPropanoContratistaReparticion_RMPCT32_31,
		    VolButanoContratistaReparticion_RMPCT32_32,
		    VolCondensadoContratistaReparticion_RMPCT32_33,
		    VolPetroEstadoReparticion_RMPCT32_34,
		    VolMetanoEstadoReparticion_RMPCT32_35,
		    VolEtanoEstadoReparticion_RMPCT32_36,
		    VolPropanoEstadoReparticion_RMPCT32_37,
		    VolButanoEstadoReparticion_RMPCT32_38,
		    VolCondensadoEstadoReparticion_RMPCT32_39,
		    VolPetroContratistaCompensacion_RMPCT32_40,
		    VolMetanoContratistaCompensacion_RMPCT32_41,
		    VolEtanoContratistaCompensacion_RMPCT32_42,
		    VolPropanoContratistaCompensacion_RMPCT32_43,
		    VolButanoContratistaCompensacion_RMPCT32_44,
		    VolCondensadoContratistaCompensacion_RMPCT32_45,
		    VolPetroEstadoCompensacion_RMPCT32_46,
		    VolMetanoEstadoCompensacion_RMPCT32_47,
		    VolEtanoEstadoCompensacion_RMPCT32_48,
		    VolPropanoEstadoCompensacion_RMPCT32_49,
		    VolButanoEstadoCompensacion_RMPCT32_50,
		    VolCondensadoEstadoCompensacion_RMPCT32_51
		FROM
			#VolPreciosAsociado

	END

	IF 0 <(SELECT COUNT(1)
			FROM #Volumen
			WHERE ROUND(ISNULL([1], 0),0) > 0
			AND ROUND(ISNULL([2], 0),0) = 0
			AND ROUND(ISNULL([3], 0),0) = 0
			AND ROUND(ISNULL([4], 0),0) = 0
			AND ROUND(ISNULL([5], 0),0) = 0
			AND ROUND(ISNULL([6], 0),0) = 0)
	BEGIN

		INSERT INTO #VolPreciosAsociado
		(
		    IdContratista_RF_00,
		    IdContrato_RI_00,
		    NumeroContrato_RF01_01,
		    MesReporte_RMPCT32_00,
		    AnioReporte_RMPCT32_01,
		    VolPetroPtoMed_RMPCT32_02,
		    GradosAPI_RMPCT32_03,
		    Azufre_RMPCT32_04,
		    VolPetroAutoCon_RMPCT32_05,
		    VolMetanoPtoMed_RMPCT32_06,
		    VolEtanoPtoMed_RMPCT32_07,
		    VolPropanoPtoMed_RMPCT32_08,
		    VolButanoPtoMed_RMPCT32_09,
		    VolMetanoAutoCon_RMPCT32_10,
		    VolEtanoAutoCon_RMPCT32_11,
		    VolPropanoAutoCon_RMPCT32_12,
		    VolButanoAutoCon_RMPCT32_13,
		    VolCondensadosPtoMed_RMPCT32_14,
		    VolCondensadoAutocon_RMPCT32_15,
		    VolPetroVendido_RMPCT32_16,
		    VolMetanoVendido_RMPCT32_17,
		    VolEtanoVendido_RMPCT32_18,
		    VolPropanoVendido_RMPCT32_19,
		    VolButanoVendido_RMPCT32_20,
		    VolCondensadoVendido_RMPCT32_21,
		    PrecioPetro_RMPCT32_22,
		    --PrecioMetano_RMPCT32_23,
		    --PrecioEtano_RMPCT32_24,
		    --PrecioPropano_RMPCT32_25,
		    --PrecioButano_RMPCT32_26,
		    --PrecioCondensado_RMPCT32_27,
		    VolPetroContratistaReparticion_RMPCT32_28,
		    VolMetanoContratistaReparticion_RMPCT32_29,
		    VolEtanoContratistaReparticion_RMPCT32_30,
		    VolPropanoContratistaReparticion_RMPCT32_31,
		    VolButanoContratistaReparticion_RMPCT32_32,
		    VolCondensadoContratistaReparticion_RMPCT32_33,
		    VolPetroEstadoReparticion_RMPCT32_34,
		    VolMetanoEstadoReparticion_RMPCT32_35,
		    VolEtanoEstadoReparticion_RMPCT32_36,
		    VolPropanoEstadoReparticion_RMPCT32_37,
		    VolButanoEstadoReparticion_RMPCT32_38,
		    VolCondensadoEstadoReparticion_RMPCT32_39,
		    VolPetroContratistaCompensacion_RMPCT32_40,
		    VolMetanoContratistaCompensacion_RMPCT32_41,
		    VolEtanoContratistaCompensacion_RMPCT32_42,
		    VolPropanoContratistaCompensacion_RMPCT32_43,
		    VolButanoContratistaCompensacion_RMPCT32_44,
		    VolCondensadoContratistaCompensacion_RMPCT32_45,
		    VolPetroEstadoCompensacion_RMPCT32_46,
		    VolMetanoEstadoCompensacion_RMPCT32_47,
		    VolEtanoEstadoCompensacion_RMPCT32_48,
		    VolPropanoEstadoCompensacion_RMPCT32_49,
		    VolButanoEstadoCompensacion_RMPCT32_50,
		    VolCondensadoEstadoCompensacion_RMPCT32_51,
			NuevaDistribucionProvisionalContratistaPetroleo,
			NuevaDistribucionProvisionalEstadoPetroleo,
			NuevaDistribucionProvisionalContratistaC1,
			NuevaDistribucionProvisionalContratistaC2,
			NuevaDistribucionProvisionalContratistaC3,
			NuevaDistribucionProvisionalContratistaC4,
			NuevaDistribucionProvisionalContratistaC5
		)
         SELECT Ca.IDSIPAC AS RF_00,
                C.IDRegFiducidiario AS RI_00,
                C.NumeroContrato AS RF01_01,
                MONTH(VMPPG.MesReporte) AS RMPCT32_00,
                YEAR(VMPPG.MesReporte) AS RMPCT32_01,
				ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0) AS RMPCT32_02,
                CONVERT(DECIMAL(3, 1), VMPPG.GradosAPI) AS RMPCT32_03,
                CONVERT(DECIMAL(6, 2), VMPPG.ContenidoAzufre) AS RMPCT32_04,
                ROUND(VMPPG.VolumenPetroleoAutoconsumo,0) AS RMPCT32_05,
                ROUND(VMPPG.MetanoC1, 0) AS RMPCT32_06,
                ROUND(VMPPG.EtanoC2, 0) AS RMPCT32_07,
                ROUND(VMPPG.PropanoC3, 0) AS RMPCT32_08,
                ROUND(VMPPG.ButanoC4, 0) AS RMPCT32_09,
                ROUND(VMPPG.MetanoC1Autoconsumo,0) AS RMPCT32_10,
                ROUND(VMPPG.EtanoC2Autoconsumo,0) AS RMPCT32_11,
                ROUND(VMPPG.PropanoC3Autoconsumo,0) AS RMPCT32_12,
                ROUND(VMPPG.ButanoC4Autoconsumo,0) AS RMPCT32_13,
                ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) + ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) AS RMPCT32_14,
                ROUND(VMPPG.VolumenCondensadoAutoconsumo,0) + ROUND(ISNULL(VMPPG.VolumenCondensableAutoconsumo,0),0) AS RMPCT32_15,
				ROUND(ISNULL(V.[1], 0),0) AS RMPCT32_16,
                ROUND(ISNULL(V.[3], 0),0) AS RMPCT32_17,
                ROUND(ISNULL(V.[4], 0),0) AS RMPCT32_18,
                ROUND(ISNULL(V.[5], 0),0) AS RMPCT32_19,
                ROUND(ISNULL(V.[6], 0),0) AS RMPCT32_20,
                ROUND(ISNULL(V.[2], 0),0) AS RMPCT32_21,
                ROUND(ISNULL(P.[1], 0),4) AS RMPCT32_22,
                --'NA' AS RMPCT32_23,
                --'NA' AS RMPCT32_24,
                --'NA' AS RMPCT32_25,
                --'NA' AS RMPCT32_26,
                --'NA' AS RMPCT32_27,
				CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo < 0
					THEN ROUND( (VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))	+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo, 0 )
					ELSE ROUND( (VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)), 0 )
               END AS RMPCT32_28,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
                    THEN ROUND(((ROUND(VMPPG.MetanoC1,0) * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1), 0)
                    ELSE ROUND(((ROUND(VMPPG.MetanoC1,0) * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100))), 0)
                END AS RMPCT32_29,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
                    THEN ROUND(((ROUND(VMPPG.EtanoC2,0) * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)), 0)
                    ELSE ROUND(((ROUND(VMPPG.EtanoC2,0) * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100))), 0)
                END AS RMPCT32_30,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
                    THEN ROUND((((ROUND(VMPPG.PropanoC3,0) * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)), 0)
                    ELSE ROUND(((ROUND(VMPPG.PropanoC3,0) * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100))), 0)
                END AS RMPCT32_31,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
                    THEN ROUND((((ROUND(VMPPG.ButanoC4,0) * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)), 0)
                    ELSE ROUND(((ROUND(VMPPG.ButanoC4,0) * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100))), 0)
                END AS RMPCT32_32,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
                    THEN ROUND((((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * (FMP53.NuevaDistribucionProvisionalContratistaC5 / 100),0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * (FMP53.NuevaDistribucionProvisionalContratistaC5 / 100),0)
                END AS RMPCT32_33,
                CASE
					WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo < 0
                    THEN ROUND(((ROUND(VMPPG.VolumenPetroleoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo), 0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenPetroleoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                END AS RMPCT32_34,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 < 0
			        THEN ROUND(((ROUND(VMPPG.MetanoC1,0) * ((100.00 -FMP53.NuevaDistribucionProvisionalContratistaC1) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1), 0)
                    ELSE ROUND(((ROUND(VMPPG.MetanoC1,0) * ((100.00 -FMP53.NuevaDistribucionProvisionalContratistaC1) / 100))), 0)
                END AS RMPCT32_35,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2 < 0
                    THEN ROUND(((ROUND(VMPPG.EtanoC2,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC2) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2), 0)
                    ELSE ROUND(((ROUND(VMPPG.EtanoC2,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC2) / 100))), 0)
                END AS RMPCT32_36,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 < 0
                    THEN ROUND(((ROUND(VMPPG.PropanoC3,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC3) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3), 0)
                    ELSE ROUND(((ROUND(VMPPG.PropanoC3,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC3) / 100))), 0)
                END AS RMPCT32_37,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 < 0
                    THEN ROUND(((ROUND(VMPPG.ButanoC4,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC4) / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4), 0)
                    ELSE ROUND(((ROUND(VMPPG.ButanoC4,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC4) / 100))), 0)
                END AS RMPCT32_38,
                CASE
                    --WHEN FMP53.CompensacionVolSaldoAcumuladoEstadoCondensado < 0 -- SE CAMBIA PORQUE LA COLUMNA ESTA INCORRECTA
					WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado < 0
                    THEN ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
                END AS RMPCT32_39,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo)
                    ELSE 0
                END AS RMPCT32_40,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1)
                    ELSE 0
                END AS RMPCT32_41,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)
                    ELSE 0
                END AS RMPCT32_42,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)
                    ELSE 0
                END AS RMPCT32_43,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)
                    ELSE 0
                END AS RMPCT32_44,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)
                    ELSE 0
                END AS RMPCT32_45,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo)
					ELSE 0
                END AS RMPCT32_46,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1)
                    ELSE 0
                END AS RMPCT32_47,
				CASE
                    WHEN CompensacionVolNuevoSaldoAcumuladoEstadoC2 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2)
                    ELSE 0
                END AS RMPCT32_48,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3)
        ELSE 0
                END AS RMPCT32_49,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4)
                    ELSE 0
            END AS RMPCT32_50,
                CASE
                WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado > 0
					THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado)
                    ELSE 0
                END AS RMPCT32_51,
				FMP53.NuevaDistribucionProvisionalContratista,
				FMP53.NuevaDistribucionProvisionalEstado,
				FMP53.NuevaDistribucionProvisionalContratistaC1,
				FMP53.NuevaDistribucionProvisionalContratistaC2,
				FMP53.NuevaDistribucionProvisionalContratistaC3,
				FMP53.NuevaDistribucionProvisionalContratistaC4,
				FMP53.NuevaDistribucionProvisionalContratistaC5
         FROM PR_VolumenMensualProduccionPetroleo VMPPG
        LEFT JOIN CO_Contrato C 
			ON VMPPG.IdContrato = C.IdContrato
			AND ISNULL(VMPPG.Activo,0) = 1
        LEFT JOIN CO_Contratista Ca 
			ON C.IdContratista = Ca.IdContratista
        LEFT JOIN #Precio P 
			ON C.IdContrato = P.IdContrato
        LEFT JOIN #Volumen V 
			ON C.IdContrato = V.IdContrato
        LEFT JOIN CP_PorcentajesReparticionPC PRPC 
			ON PRPC.IdContrato = v.idcontrato
            AND VMPPG.MesReporte = PRPC.MesReporte
        LEFT JOIN SIPAC_RM_FMP_53_M FMP53 
			ON FMP53.IdContrato = @Contrato
            AND DATEADD(month, 1, DATEFROMPARTS(FMP53.anioreporte, FMP53.mesreporte, 1)) = @Mes
        WHERE VMPPG.IdContrato = @Contrato
               AND VMPPG.MesReporte = @Mes
			   AND ISNULL(VMPPG.Activo,0) = 1

		-- SE VALIDA SI AL SUMAR LOS VALORES DE REPARTICION DEL PETROLEO, EXISTE DIFERENCIA CONTRA LA PRODUCCION
		IF 0 <> (SELECT	VolPetroPtoMed_RMPCT32_02 - (VolPetroContratistaReparticion_RMPCT32_28 + 
											VolPetroEstadoReparticion_RMPCT32_34 +
											VolPetroContratistaCompensacion_RMPCT32_40 + 
											VolPetroEstadoCompensacion_RMPCT32_46)
			FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL BARRIL RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolPetroContratistaReparticion_RMPCT32_28 = CASE WHEN (VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)),0) > 
																	(VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) ,0)
																	THEN VolPetroContratistaReparticion_RMPCT32_28 + 1
																ELSE VolPetroContratistaReparticion_RMPCT32_28
																END,
					VolPetroEstadoReparticion_RMPCT32_34	=	CASE WHEN (VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalEstadoPetroleo/100)) ,0) >
																	(VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)) - ROUND((VolPetroPtoMed_RMPCT32_02*(NuevaDistribucionProvisionalContratistaPetroleo/100)),0)
																	THEN VolPetroEstadoReparticion_RMPCT32_34 + 1
																ELSE VolPetroEstadoReparticion_RMPCT32_34
																END
		END

		-- METANO
		IF 0 <> (SELECT	VolMetanoPtoMed_RMPCT32_06 - (VolMetanoContratistaReparticion_RMPCT32_29 + 
												VolMetanoEstadoReparticion_RMPCT32_35 +
												VolMetanoContratistaCompensacion_RMPCT32_41 + 
												VolMetanoEstadoCompensacion_RMPCT32_47)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolMetanoContratistaReparticion_RMPCT32_29 = CASE WHEN (VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)),0) > 
																	(VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) ,0)
																	THEN VolMetanoContratistaReparticion_RMPCT32_29 + 1
																ELSE VolMetanoContratistaReparticion_RMPCT32_29
																END,
					VolMetanoEstadoReparticion_RMPCT32_35	=	CASE WHEN (VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*((100-NuevaDistribucionProvisionalContratistaC1)/100)) ,0) >
																	(VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)) - ROUND((VolMetanoPtoMed_RMPCT32_06*(NuevaDistribucionProvisionalContratistaC1/100)),0)
																	THEN VolMetanoEstadoReparticion_RMPCT32_35 + 1
																ELSE VolMetanoEstadoReparticion_RMPCT32_35
																END
		END

		-- ETANO
		IF 0 <> (SELECT	VolEtanoPtoMed_RMPCT32_07 - (VolEtanoContratistaReparticion_RMPCT32_30 + 
												VolEtanoEstadoReparticion_RMPCT32_36 +
												VolEtanoContratistaCompensacion_RMPCT32_42 + 
												VolEtanoEstadoCompensacion_RMPCT32_48)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolEtanoContratistaReparticion_RMPCT32_30 = CASE WHEN (VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)),0) > 
																	(VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) ,0)
																	THEN VolEtanoContratistaReparticion_RMPCT32_30 + 1
																ELSE VolEtanoContratistaReparticion_RMPCT32_30
																END,
					VolEtanoEstadoReparticion_RMPCT32_36	=	CASE WHEN (VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*((100-NuevaDistribucionProvisionalContratistaC2)/100)) ,0) >
																	(VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)) - ROUND((VolEtanoPtoMed_RMPCT32_07*(NuevaDistribucionProvisionalContratistaC2/100)),0)
																	THEN VolEtanoEstadoReparticion_RMPCT32_36 + 1
																ELSE VolEtanoEstadoReparticion_RMPCT32_36
																END
		END

		-- PROPANO
		IF 0 <> (SELECT	VolPropanoPtoMed_RMPCT32_08 - (VolPropanoContratistaReparticion_RMPCT32_31 + 
												VolPropanoEstadoReparticion_RMPCT32_37 +
												VolPropanoContratistaCompensacion_RMPCT32_43 + 
												VolPropanoEstadoCompensacion_RMPCT32_49)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolPropanoContratistaReparticion_RMPCT32_31 = CASE WHEN (VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)),0) > 
																	(VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) ,0)
																	THEN VolPropanoContratistaReparticion_RMPCT32_31 + 1
																ELSE VolPropanoContratistaReparticion_RMPCT32_31
																END,
					VolPropanoEstadoReparticion_RMPCT32_37	=	CASE WHEN (VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*((100-NuevaDistribucionProvisionalContratistaC3)/100)) ,0) >
																	(VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)) - ROUND((VolPropanoPtoMed_RMPCT32_08*(NuevaDistribucionProvisionalContratistaC3/100)),0)
																	THEN VolPropanoEstadoReparticion_RMPCT32_37 + 1
																ELSE VolPropanoEstadoReparticion_RMPCT32_37
																END
		END

		-- BUTANO
		IF 0 <> (SELECT	VolButanoPtoMed_RMPCT32_09 - (VolButanoContratistaReparticion_RMPCT32_32 + 
												VolButanoEstadoReparticion_RMPCT32_38 +
												VolButanoContratistaCompensacion_RMPCT32_44 + 
												VolButanoEstadoCompensacion_RMPCT32_50)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolButanoContratistaReparticion_RMPCT32_32 = CASE WHEN (VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)),0) > 
																	(VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) ,0)
																	THEN VolButanoContratistaReparticion_RMPCT32_32 + 1
																ELSE VolButanoContratistaReparticion_RMPCT32_32
																END,
					VolButanoEstadoReparticion_RMPCT32_38	=	CASE WHEN (VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*((100-NuevaDistribucionProvisionalContratistaC4)/100)) ,0) >
																	(VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)) - ROUND((VolButanoPtoMed_RMPCT32_09*(NuevaDistribucionProvisionalContratistaC4/100)),0)
																	THEN VolButanoEstadoReparticion_RMPCT32_38 + 1
																ELSE VolButanoEstadoReparticion_RMPCT32_38
																END
		END

		-- CONDENSADO
		IF 0 <> (SELECT	VolCondensadosPtoMed_RMPCT32_14 - (VolCondensadoContratistaReparticion_RMPCT32_33 + 
												VolCondensadoEstadoReparticion_RMPCT32_39 +
												VolCondensadoContratistaCompensacion_RMPCT32_45 + 
												VolCondensadoEstadoCompensacion_RMPCT32_51)
				FROM #VolPreciosAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL BARRIL RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosAsociado
				SET	VolCondensadoContratistaReparticion_RMPCT32_33 = CASE WHEN (VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)),0) > 
																	(VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) ,0)
																	THEN VolCondensadoContratistaReparticion_RMPCT32_33 + 1
																ELSE VolCondensadoContratistaReparticion_RMPCT32_33
																END,
					VolCondensadoEstadoReparticion_RMPCT32_39	=	CASE WHEN (VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*((100-NuevaDistribucionProvisionalContratistaC5)/100)) ,0) >
																	(VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)) - ROUND((VolCondensadosPtoMed_RMPCT32_14*(NuevaDistribucionProvisionalContratistaC5/100)),0)
																	THEN VolCondensadoEstadoReparticion_RMPCT32_39 + 1
																ELSE VolCondensadoEstadoReparticion_RMPCT32_39
																END
		END

		SELECT
			IdContratista_RF_00,
		    IdContrato_RI_00,
		    NumeroContrato_RF01_01,
		    MesReporte_RMPCT32_00,
		    AnioReporte_RMPCT32_01,
		    VolPetroPtoMed_RMPCT32_02,
		    GradosAPI_RMPCT32_03,
		    Azufre_RMPCT32_04,
		    VolPetroAutoCon_RMPCT32_05,
		    VolMetanoPtoMed_RMPCT32_06,
		    VolEtanoPtoMed_RMPCT32_07,
		    VolPropanoPtoMed_RMPCT32_08,
		    VolButanoPtoMed_RMPCT32_09,
		    VolMetanoAutoCon_RMPCT32_10,
		    VolEtanoAutoCon_RMPCT32_11,
		    VolPropanoAutoCon_RMPCT32_12,
		    VolButanoAutoCon_RMPCT32_13,
		    VolCondensadosPtoMed_RMPCT32_14,
		    VolCondensadoAutocon_RMPCT32_15,
		    VolPetroVendido_RMPCT32_16,
		    VolMetanoVendido_RMPCT32_17,
		    VolEtanoVendido_RMPCT32_18,
		    VolPropanoVendido_RMPCT32_19,
		    VolButanoVendido_RMPCT32_20,
		    VolCondensadoVendido_RMPCT32_21,
		    PrecioPetro_RMPCT32_22,
			'NA' AS RMPCT32_23,
            'NA' AS RMPCT32_24,
            'NA' AS RMPCT32_25,
            'NA' AS RMPCT32_26,
            'NA' AS RMPCT32_27,
		    --PrecioMetano_RMPCT32_23,
		    --PrecioEtano_RMPCT32_24,
		    --PrecioPropano_RMPCT32_25,
		    --PrecioButano_RMPCT32_26,
		    --PrecioCondensado_RMPCT32_27,
		    VolPetroContratistaReparticion_RMPCT32_28,
		    VolMetanoContratistaReparticion_RMPCT32_29,
		    VolEtanoContratistaReparticion_RMPCT32_30,
		    VolPropanoContratistaReparticion_RMPCT32_31,
		    VolButanoContratistaReparticion_RMPCT32_32,
		    VolCondensadoContratistaReparticion_RMPCT32_33,
		    VolPetroEstadoReparticion_RMPCT32_34,
		    VolMetanoEstadoReparticion_RMPCT32_35,
		    VolEtanoEstadoReparticion_RMPCT32_36,
		    VolPropanoEstadoReparticion_RMPCT32_37,
		    VolButanoEstadoReparticion_RMPCT32_38,
		    VolCondensadoEstadoReparticion_RMPCT32_39,
		    VolPetroContratistaCompensacion_RMPCT32_40,
		    VolMetanoContratistaCompensacion_RMPCT32_41,
		    VolEtanoContratistaCompensacion_RMPCT32_42,
		    VolPropanoContratistaCompensacion_RMPCT32_43,
		    VolButanoContratistaCompensacion_RMPCT32_44,
		    VolCondensadoContratistaCompensacion_RMPCT32_45,
		    VolPetroEstadoCompensacion_RMPCT32_46,
		    VolMetanoEstadoCompensacion_RMPCT32_47,
		    VolEtanoEstadoCompensacion_RMPCT32_48,
		    VolPropanoEstadoCompensacion_RMPCT32_49,
		    VolButanoEstadoCompensacion_RMPCT32_50,
		    VolCondensadoEstadoCompensacion_RMPCT32_51
		FROM
			#VolPreciosAsociado

	END

END
END
