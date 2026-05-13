CREATE PROCEDURE dbo.SP_PC_SIPAC_VolumenesPreciosNoAsociados
	@Contrato INT,
	@Mes      DATE
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 5-06-17
-- Description:	
-- =============================================
-- 20180801	BAAC	Se modifica para redondear el precio de los hidrocarburos a 2 decimales
-- 20180801	BAAC	Se modifica para agregar el volumen de Condensable (C5+) en el Condensado
-- 20190321	BAAC	Se modifica para que en caso de haber un btu o barril que no se puede repartir, se asigne al que tenga el porcentaje mayor del mismo
-- =============================================
-- 20240628	RO	Se modifica para que se filtre la información de la tabla PR_VolumenMensualProduccionPetroleo por el Activo = 1
SET NOCOUNT ON
-- =============================================
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

CREATE TABLE #VolPreciosNoAsociado
(
	IdContratista_RF_00	VARCHAR(20),
	IdContrato_RI_00		VARCHAR(30),
	NumeroContrato_RF01_01		VARCHAR(35),
	MesReporte_RMPCT33_00	INT,
	AnioReporte_RMPCT33_01	INT,
	VolMetanoPtoMed_RMPCT33_02	INT,
	VolEtanoPtoMed_RMPCT33_03	INT,
	VolPropanoPtoMed_RMPCT33_04	INT,
	VolButanoPtoMed_RMPCT33_05	INT,
	VolMetanoAutoCon_RMPCT33_06	INT,
	VolEtanoAutoCon_RMPCT33_07	INT,
	VolPropanoAutoCon_RMPCT33_08	INT,
	VolButanoAutoCon_RMPCT33_09	INT,
	VolCondensadosPtoMed_RMPCT33_10	INT,
	VolCondensadoAutocon_RMPCT33_11	INT,
	VolMetanoVendido_RMPCT33_12	INT,
	VolEtanoVendido_RMPCT33_13	INT,
	VolPropanoVendido_RMPCT33_14	INT,
	VolButanoVendido_RMPCT33_15	INT,
	VolCondensadoVendido_RMPCT33_16	INT,
	PrecioMetano_RMPCT33_17 FLOAT,
	PrecioEtano_RMPCT33_18 FLOAT,
	PrecioPropano_RMPCT33_19 FLOAT,
	PrecioButano_RMPCT33_20 FLOAT,
	PrecioCondensado_RMPCT33_21 FLOAT,
	VolMetanoContratistaReparticion_RMPCT33_22 INT,
	VolEtanoContratistaReparticion_RMPCT33_23 INT,
	VolPropanoContratistaReparticion_RMPCT33_24 INT,
	VolButanoContratistaReparticion_RMPCT33_25 INT,
	VolCondensadoContratistaReparticion_RMPCT33_26 INT,
	VolMetanoEstadoReparticion_RMPCT33_27 INT,
	VolEtanoEstadoReparticion_RMPCT33_28 INT,
	VolPropanoEstadoReparticion_RMPCT33_29 INT,
	VolButanoEstadoReparticion_RMPCT33_30 INT,
	VolCondensadoEstadoReparticion_RMPCT33_31 INT,
	VolMetanoContratistaCompensacion_RMPCT33_32 INT,
	VolEtanoContratistaCompensacion_RMPCT33_33 INT,
	VolPropanoContratistaCompensacion_RMPCT33_34 INT,
	VolButanoContratistaCompensacion_RMPCT33_35 INT,
	VolCondensadoContratistaCompensacion_RMPCT33_36 INT,
	VolMetanoEstadoCompensacion_RMPCT33_37 INT,
	VolEtanoEstadoCompensacion_RMPCT33_38 INT,
	VolPropanoEstadoCompensacion_RMPCT33_39 INT,
	VolButanoEstadoCompensacion_RMPCT33_40 INT,
	VolCondensadoEstadoCompensacion_RMPCT33_41 INT,
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

IF (@GasNoAsociado =1) 
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

		INSERT INTO #VolPreciosNoAsociado
		(
			IdContratista_RF_00,
			IdContrato_RI_00,
			NumeroContrato_RF01_01,
			MesReporte_RMPCT33_00,
			AnioReporte_RMPCT33_01,
			VolMetanoPtoMed_RMPCT33_02,
			VolEtanoPtoMed_RMPCT33_03,
			VolPropanoPtoMed_RMPCT33_04,
			VolButanoPtoMed_RMPCT33_05,
			VolMetanoAutoCon_RMPCT33_06,
			VolEtanoAutoCon_RMPCT33_07,
			VolPropanoAutoCon_RMPCT33_08,
			VolButanoAutoCon_RMPCT33_09,
			VolCondensadosPtoMed_RMPCT33_10,
			VolCondensadoAutocon_RMPCT33_11,
			VolMetanoVendido_RMPCT33_12,
			VolEtanoVendido_RMPCT33_13,
			VolPropanoVendido_RMPCT33_14,
			VolButanoVendido_RMPCT33_15,
			VolCondensadoVendido_RMPCT33_16,
			PrecioMetano_RMPCT33_17,
			PrecioEtano_RMPCT33_18,
			PrecioPropano_RMPCT33_19,
			PrecioButano_RMPCT33_20,
			PrecioCondensado_RMPCT33_21,
			VolMetanoContratistaReparticion_RMPCT33_22,
			VolEtanoContratistaReparticion_RMPCT33_23,
			VolPropanoContratistaReparticion_RMPCT33_24,
			VolButanoContratistaReparticion_RMPCT33_25,
			VolCondensadoContratistaReparticion_RMPCT33_26,
			VolMetanoEstadoReparticion_RMPCT33_27,
			VolEtanoEstadoReparticion_RMPCT33_28,
			VolPropanoEstadoReparticion_RMPCT33_29,
			VolButanoEstadoReparticion_RMPCT33_30,
			VolCondensadoEstadoReparticion_RMPCT33_31,
			VolMetanoContratistaCompensacion_RMPCT33_32,
			VolEtanoContratistaCompensacion_RMPCT33_33,
			VolPropanoContratistaCompensacion_RMPCT33_34,
			VolButanoContratistaCompensacion_RMPCT33_35,
			VolCondensadoContratistaCompensacion_RMPCT33_36,
			VolMetanoEstadoCompensacion_RMPCT33_37,
			VolEtanoEstadoCompensacion_RMPCT33_38,
			VolPropanoEstadoCompensacion_RMPCT33_39,
			VolButanoEstadoCompensacion_RMPCT33_40,
			VolCondensadoEstadoCompensacion_RMPCT33_41,
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
                --CONVERT(INT, VMPPG.VolumenCondensadoAutoconsumo) AS RMPCT32_05,
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
                --CONVERT(INT, ISNULL(V.[1], 0)) AS RMPCT32_16,
                ROUND(ISNULL(V.[3], 0),0) AS RMPCT32_17,
                ROUND(ISNULL(V.[4], 0),0) AS RMPCT32_18,
                ROUND(ISNULL(V.[5], 0),0) AS RMPCT32_19,
                ROUND(ISNULL(V.[6], 0),0) AS RMPCT32_20,
                ROUND(ISNULL(V.[2], 0),0) AS RMPCT32_21,
                --ISNULL(P.[1], 0) AS RMPCT32_22,
                ROUND(ISNULL(P.[3], 0),4) AS RMPCT32_23,
                ROUND(ISNULL(P.[4], 0),4) AS RMPCT32_24,
                ROUND(ISNULL(P.[5], 0),4) AS RMPCT32_25,
                ROUND(ISNULL(P.[6], 0),4) AS RMPCT32_26,
                --CASE WHEN VMPPG.VolumenCondensadoPuntoMedicion = 0--THEN	'NA'--ELSE	  LTRIM(ISNULL(P.[2],0))--END	  AS RMPCT32_27,
                ROUND(ISNULL(P.[2], 0),4) AS RMPCT32_27,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
                    THEN ROUND(ROUND(VMPPG.MetanoC1,0) * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1
                    ELSE ROUND(ROUND(VMPPG.MetanoC1,0) * (FMP53.NuevaDistribucionProvisionalContratistaC1 / 100),0)
					 --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
      --              THEN ROUND((((VMPPG.MetanoC1+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
      --            ELSE ROUND(((VMPPG.MetanoC1) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_29,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
                    THEN ROUND(ROUND(VMPPG.EtanoC2,0) * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2
                    ELSE ROUND(ROUND(VMPPG.EtanoC2,0) * (FMP53.NuevaDistribucionProvisionalContratistaC2 / 100),0)
                 --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
                 --   THEN ROUND((((VMPPG.EtanoC2) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
                 --   ELSE ROUND(((VMPPG.EtanoC2) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_30,
                --CONVERT(INT, VMPPG.VolumenPropanoC3ContratistaReparticion) AS RMPCT32_31,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
                    THEN ROUND(ROUND(VMPPG.PropanoC3,0) * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3
                    ELSE ROUND(ROUND(VMPPG.PropanoC3,0) * (FMP53.NuevaDistribucionProvisionalContratistaC3 / 100),0)
     --            WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
     --               THEN ROUND((((VMPPG.PropanoC3+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
					--ELSE ROUND(((VMPPG.PropanoC3) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_31,
                --CONVERT(INT, VMPPG.VolumenButanoC4ContratistaReparticion) AS RMPCT32_32,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
                    THEN ROUND(ROUND(VMPPG.ButanoC4,0) * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4
                    ELSE ROUND(ROUND(VMPPG.ButanoC4,0) * (FMP53.NuevaDistribucionProvisionalContratistaC4 / 100),0)
                    --  WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
                    --THEN ROUND((((VMPPG.ButanoC4 + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 ) * FMP53.NuevaDistribucionProvisionalContratista / 100)), 0)
                    --ELSE ROUND(((VMPPG.ButanoC4) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_32,
                --CONVERT(INT, VMPPG.VolumenCondensadosContratistaReparticion) AS RMPCT32_33,--CONVERT(INT, VMPPG.VolumenCondensadoPuntoMedicion *( PRPC.PorcentajeRepPreliminarContratista /100)) AS RMPCT32_33,

                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
                    THEN ROUND(ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
						+ ROUND(ROUND(VMPPG.VolumenCondensablePuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratistaC5 / 100),0)
                    ELSE ROUND(ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratista / 100),0)
						+ ROUND(ROUND(VMPPG.VolumenCondensablePuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalContratistaC5 / 100),0)
      --            WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
      --              THEN ROUND((((VMPPG.VolumenCondensadoPuntoMedicion + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado ) * FMP53.NuevaDistribucionProvisionalContratista / 100)), 0)
						--+  ROUND((VMPPG.VolumenCondensablePuntoMedicion * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
      --              ELSE ROUND(((VMPPG.VolumenCondensadoPuntoMedicion) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
						--+ ROUND(((VMPPG.VolumenCondensablePuntoMedicion) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_33,

                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 < 0
                    THEN ROUND(ROUND(VMPPG.MetanoC1,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC1)/ 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1
                    ELSE ROUND(ROUND(VMPPG.MetanoC1,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC1)/ 100),0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 < 0
                  --  THEN ROUND(((VMPPG.MetanoC1+ FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                  --  ELSE ROUND(((VMPPG.MetanoC1) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                
                END AS RMPCT32_35,
                --CONVERT(INT, VMPPG.VolumenEtanoC2EstadoReparticion) AS RMPCT32_36,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2 < 0
                    THEN ROUND(ROUND(VMPPG.EtanoC2,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC2) / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2
                    ELSE ROUND(ROUND(VMPPG.EtanoC2,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC2) / 100),0)
                END AS RMPCT32_36,
        --CONVERT(INT, VMPPG.VolumenPropanoC3EstadoReparticion) AS RMPCT32_37,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 < 0
                    THEN ROUND(ROUND(VMPPG.PropanoC3,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC3) / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3
                    ELSE ROUND(ROUND(VMPPG.PropanoC3,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC3) / 100),0)
                   --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 < 0
                   -- THEN ROUND(((VMPPG.PropanoC3 + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 ) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                   -- ELSE ROUND(((VMPPG.PropanoC3) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                END AS RMPCT32_37,
                --CONVERT(INT, VMPPG.VolumenButanoC4EstadoReparticion) AS RMPCT32_38,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 < 0
                    THEN ROUND(ROUND(VMPPG.ButanoC4,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC4) / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4
                    ELSE ROUND(ROUND(VMPPG.ButanoC4,0) * ((100.00-FMP53.NuevaDistribucionProvisionalContratistaC4) / 100),0)
		         END AS RMPCT32_38,

				CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado < 0
                    THEN ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
                    ELSE ROUND(((ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
						+  ROUND(ROUND(ISNULL(VMPPG.VolumenCondensablePuntoMedicion,0),0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
                END AS RMPCT32_39,
      --          CASE
      --              WHEN FMP53.CompensacionVolSaldoAcumuladoEstadoCondensado < 0		-- ESTABA MAL LA COLUMNA DE LA COMPENSACION
      --              THEN ROUND(ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100),0) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado
						--+ ROUND(ROUND(VMPPG.VolumenCondensablePuntoMedicion,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
      --              ELSE ROUND(ROUND(VMPPG.VolumenCondensadoPuntoMedicion,0) * (FMP53.NuevaDistribucionProvisionalEstado / 100),0)
						--+ ROUND(ROUND(VMPPG.VolumenCondensablePuntoMedicion,0) * ((100.00 - FMP53.NuevaDistribucionProvisionalContratistaC5) / 100),0)
      --          END AS RMPCT32_39,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1)
                    ELSE 0
                END AS RMPCT32_41,
                --CONVERT(INT, VMPPG.VolumenEtanoC2ContratistaCompensacion) AS RMPCT32_42,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)
                    ELSE 0
                END AS RMPCT32_42,
                --CONVERT(INT, VMPPG.VolumenPropanoC3ContratistaCompensacion) AS RMPCT32_43,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)
                    ELSE 0
                END AS RMPCT32_43,
                --CONVERT(INT, VMPPG.VolumenButanoC4ContratistaCompensacion) AS RMPCT32_44,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)
                    ELSE 0
                END AS RMPCT32_44,
                --CONVERT(INT, VMPPG.VolumenCondensadosContratistaCompensacion) AS RMPCT32_45,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)
                    ELSE 0
                END AS RMPCT32_45,
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
				FMP53.NuevaDistribucionProvisionalContratistaC1,
				FMP53.NuevaDistribucionProvisionalContratistaC2,
				FMP53.NuevaDistribucionProvisionalContratistaC3,
				FMP53.NuevaDistribucionProvisionalContratistaC4,
				FMP53.NuevaDistribucionProvisionalContratistaC5
         FROM PR_VolumenMensualProduccionPetroleo VMPPG
              LEFT JOIN CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
			  AND ISNULL(VMPPG.Activo,0) = 1
              LEFT JOIN CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
              LEFT JOIN #Precio P ON C.IdContrato = P.IdContrato
              LEFT JOIN #Volumen V ON C.IdContrato = V.IdContrato
              LEFT JOIN CP_PorcentajesReparticionPC PRPC ON PRPC.IdContrato = v.idcontrato
                                                            AND VMPPG.MesReporte = PRPC.MesReporte
              LEFT JOIN SIPAC_RM_FMP_53_M FMP53 ON FMP53.IdContrato = @Contrato
                                                   AND DATEADD(month, 1, DATEFROMPARTS(FMP53.anioreporte, FMP53.mesreporte, 1)) = @Mes
         WHERE VMPPG.IdContrato = @Contrato
               AND VMPPG.MesReporte = @Mes
			   AND ISNULL(VMPPG.Activo,0) = 1

		-- METANO
		IF 0 <> (SELECT	VolMetanoPtoMed_RMPCT33_02 - (VolMetanoContratistaReparticion_RMPCT33_22 + 
												VolMetanoEstadoReparticion_RMPCT33_27 +
												VolMetanoContratistaCompensacion_RMPCT33_32 + 
												VolMetanoEstadoCompensacion_RMPCT33_37)
				FROM #VolPreciosNoAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosNoAsociado
				SET	VolMetanoContratistaReparticion_RMPCT33_22 = CASE WHEN (VolMetanoPtoMed_RMPCT33_02*(NuevaDistribucionProvisionalContratistaC1/100)) - ROUND((VolMetanoPtoMed_RMPCT33_02*(NuevaDistribucionProvisionalContratistaC1/100)),0) > 
																	(VolMetanoPtoMed_RMPCT33_02*((100-NuevaDistribucionProvisionalContratistaC1)/100)) - ROUND((VolMetanoPtoMed_RMPCT33_02*((100-NuevaDistribucionProvisionalContratistaC1)/100)) ,0)
																	THEN VolMetanoContratistaReparticion_RMPCT33_22 + 1
																ELSE VolMetanoContratistaReparticion_RMPCT33_22
																END,
					VolMetanoEstadoReparticion_RMPCT33_27	=	CASE WHEN (VolMetanoPtoMed_RMPCT33_02*((100-NuevaDistribucionProvisionalContratistaC1)/100)) - ROUND((VolMetanoPtoMed_RMPCT33_02*((100-NuevaDistribucionProvisionalContratistaC1)/100)) ,0) >
																	(VolMetanoPtoMed_RMPCT33_02*(NuevaDistribucionProvisionalContratistaC1/100)) - ROUND((VolMetanoPtoMed_RMPCT33_02*(NuevaDistribucionProvisionalContratistaC1/100)),0)
																	THEN VolMetanoEstadoReparticion_RMPCT33_27 + 1
																ELSE VolMetanoEstadoReparticion_RMPCT33_27
																END
		END

		-- ETANO
		IF 0 <> (SELECT	VolEtanoPtoMed_RMPCT33_03 - (VolEtanoContratistaReparticion_RMPCT33_23 + 
												VolEtanoEstadoReparticion_RMPCT33_28 +
												VolEtanoContratistaCompensacion_RMPCT33_33 + 
												VolEtanoEstadoCompensacion_RMPCT33_38)
				FROM #VolPreciosNoAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosNoAsociado
				SET	VolEtanoContratistaReparticion_RMPCT33_23 = CASE WHEN (VolEtanoPtoMed_RMPCT33_03*(NuevaDistribucionProvisionalContratistaC2/100)) - ROUND((VolEtanoPtoMed_RMPCT33_03*(NuevaDistribucionProvisionalContratistaC2/100)),0) > 
																	(VolEtanoPtoMed_RMPCT33_03*((100-NuevaDistribucionProvisionalContratistaC2)/100)) - ROUND((VolEtanoPtoMed_RMPCT33_03*((100-NuevaDistribucionProvisionalContratistaC2)/100)) ,0)
																	THEN VolEtanoContratistaReparticion_RMPCT33_23 + 1
																ELSE VolEtanoContratistaReparticion_RMPCT33_23
																END,
					VolEtanoEstadoReparticion_RMPCT33_28	=	CASE WHEN (VolEtanoPtoMed_RMPCT33_03*((100-NuevaDistribucionProvisionalContratistaC2)/100)) - ROUND((VolEtanoPtoMed_RMPCT33_03*((100-NuevaDistribucionProvisionalContratistaC2)/100)) ,0) >
																	(VolEtanoPtoMed_RMPCT33_03*(NuevaDistribucionProvisionalContratistaC2/100)) - ROUND((VolEtanoPtoMed_RMPCT33_03*(NuevaDistribucionProvisionalContratistaC2/100)),0)
																	THEN VolEtanoEstadoReparticion_RMPCT33_28 + 1
																ELSE VolEtanoEstadoReparticion_RMPCT33_28
																END
		END

		-- PROPANO
		IF 0 <> (SELECT	VolPropanoPtoMed_RMPCT33_04 - (VolPropanoContratistaReparticion_RMPCT33_24 + 
												VolPropanoEstadoReparticion_RMPCT33_29 +
												VolPropanoContratistaCompensacion_RMPCT33_34 + 
												VolPropanoEstadoCompensacion_RMPCT33_39)
				FROM #VolPreciosNoAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosNoAsociado
				SET	VolPropanoContratistaReparticion_RMPCT33_24 = CASE WHEN (VolPropanoPtoMed_RMPCT33_04*(NuevaDistribucionProvisionalContratistaC3/100)) - ROUND((VolPropanoPtoMed_RMPCT33_04*(NuevaDistribucionProvisionalContratistaC3/100)),0) > 
																	(VolPropanoPtoMed_RMPCT33_04*((100-NuevaDistribucionProvisionalContratistaC3)/100)) - ROUND((VolPropanoPtoMed_RMPCT33_04*((100-NuevaDistribucionProvisionalContratistaC3)/100)) ,0)
																	THEN VolPropanoContratistaReparticion_RMPCT33_24 + 1
																ELSE VolPropanoContratistaReparticion_RMPCT33_24
																END,
					VolPropanoEstadoReparticion_RMPCT33_29	=	CASE WHEN (VolPropanoPtoMed_RMPCT33_04*((100-NuevaDistribucionProvisionalContratistaC3)/100)) - ROUND((VolPropanoPtoMed_RMPCT33_04*((100-NuevaDistribucionProvisionalContratistaC3)/100)) ,0) >
																	(VolPropanoPtoMed_RMPCT33_04*(NuevaDistribucionProvisionalContratistaC3/100)) - ROUND((VolPropanoPtoMed_RMPCT33_04*(NuevaDistribucionProvisionalContratistaC3/100)),0)
																	THEN VolPropanoEstadoReparticion_RMPCT33_29 + 1
																ELSE VolPropanoEstadoReparticion_RMPCT33_29
																END
		END

		-- BUTANO
		IF 0 <> (SELECT	VolButanoPtoMed_RMPCT33_05 - (VolButanoContratistaReparticion_RMPCT33_25 + 
												VolButanoEstadoReparticion_RMPCT33_30 +
												VolButanoContratistaCompensacion_RMPCT33_35 + 
												VolButanoEstadoCompensacion_RMPCT33_40)
				FROM #VolPreciosNoAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosNoAsociado
				SET	VolButanoContratistaReparticion_RMPCT33_25 = CASE WHEN (VolButanoPtoMed_RMPCT33_05*(NuevaDistribucionProvisionalContratistaC4/100)) - ROUND((VolButanoPtoMed_RMPCT33_05*(NuevaDistribucionProvisionalContratistaC4/100)),0) > 
																	(VolButanoPtoMed_RMPCT33_05*((100-NuevaDistribucionProvisionalContratistaC4)/100)) - ROUND((VolButanoPtoMed_RMPCT33_05*((100-NuevaDistribucionProvisionalContratistaC4)/100)) ,0)
																	THEN VolButanoContratistaReparticion_RMPCT33_25 + 1
																ELSE VolButanoContratistaReparticion_RMPCT33_25
																END,
					VolButanoEstadoReparticion_RMPCT33_30	=	CASE WHEN (VolButanoPtoMed_RMPCT33_05*((100-NuevaDistribucionProvisionalContratistaC4)/100)) - ROUND((VolButanoPtoMed_RMPCT33_05*((100-NuevaDistribucionProvisionalContratistaC4)/100)) ,0) >
																	(VolButanoPtoMed_RMPCT33_05*(NuevaDistribucionProvisionalContratistaC4/100)) - ROUND((VolButanoPtoMed_RMPCT33_05*(NuevaDistribucionProvisionalContratistaC4/100)),0)
																	THEN VolButanoEstadoReparticion_RMPCT33_30 + 1
																ELSE VolButanoEstadoReparticion_RMPCT33_30
																END
		END

		-- CONDENSADO
		IF 0 <> (SELECT	VolCondensadosPtoMed_RMPCT33_10 - (VolCondensadoContratistaReparticion_RMPCT33_26 + 
												VolCondensadoEstadoReparticion_RMPCT33_31 +
												VolCondensadoContratistaCompensacion_RMPCT33_36 + 
												VolCondensadoEstadoCompensacion_RMPCT33_41)
				FROM #VolPreciosNoAsociado)
		BEGIN
			-- SI EXISTE DIFERENCIA, SE VALIDA QUIEN TIENE MAS PROPORCION DEL MMBTU RESTANTE, PARA ASIGNARSELO
			UPDATE	#VolPreciosNoAsociado
				SET	VolCondensadoContratistaReparticion_RMPCT33_26 = CASE WHEN (VolCondensadosPtoMed_RMPCT33_10*(NuevaDistribucionProvisionalContratistaC5/100)) - ROUND((VolCondensadosPtoMed_RMPCT33_10*(NuevaDistribucionProvisionalContratistaC5/100)),0) > 
																	(VolCondensadosPtoMed_RMPCT33_10*((100-NuevaDistribucionProvisionalContratistaC5)/100)) - ROUND((VolCondensadosPtoMed_RMPCT33_10*((100-NuevaDistribucionProvisionalContratistaC5)/100)) ,0)
																	THEN VolCondensadoContratistaReparticion_RMPCT33_26 + 1
																ELSE VolCondensadoContratistaReparticion_RMPCT33_26
																END,
					VolCondensadoEstadoReparticion_RMPCT33_31	=	CASE WHEN (VolCondensadosPtoMed_RMPCT33_10*((100-NuevaDistribucionProvisionalContratistaC5)/100)) - ROUND((VolCondensadosPtoMed_RMPCT33_10*((100-NuevaDistribucionProvisionalContratistaC5)/100)) ,0) >
																	(VolCondensadosPtoMed_RMPCT33_10*(NuevaDistribucionProvisionalContratistaC5/100)) - ROUND((VolCondensadosPtoMed_RMPCT33_10*(NuevaDistribucionProvisionalContratistaC5/100)),0)
																	THEN VolCondensadoEstadoReparticion_RMPCT33_31 + 1
																ELSE VolCondensadoEstadoReparticion_RMPCT33_31
																END
		END

		SELECT
			IdContratista_RF_00,
			IdContrato_RI_00,
			NumeroContrato_RF01_01,
			MesReporte_RMPCT33_00,
			AnioReporte_RMPCT33_01,
			VolMetanoPtoMed_RMPCT33_02,
			VolEtanoPtoMed_RMPCT33_03,
			VolPropanoPtoMed_RMPCT33_04,
			VolButanoPtoMed_RMPCT33_05,
			VolMetanoAutoCon_RMPCT33_06,
			VolEtanoAutoCon_RMPCT33_07,
			VolPropanoAutoCon_RMPCT33_08,
			VolButanoAutoCon_RMPCT33_09,
			VolCondensadosPtoMed_RMPCT33_10,
			VolCondensadoAutocon_RMPCT33_11,
			VolMetanoVendido_RMPCT33_12,
			VolEtanoVendido_RMPCT33_13,
			VolPropanoVendido_RMPCT33_14,
			VolButanoVendido_RMPCT33_15,
			VolCondensadoVendido_RMPCT33_16,
			PrecioMetano_RMPCT33_17,
			PrecioEtano_RMPCT33_18,
			PrecioPropano_RMPCT33_19,
			PrecioButano_RMPCT33_20,
			PrecioCondensado_RMPCT33_21,
			VolMetanoContratistaReparticion_RMPCT33_22,
			VolEtanoContratistaReparticion_RMPCT33_23,
			VolPropanoContratistaReparticion_RMPCT33_24,
			VolButanoContratistaReparticion_RMPCT33_25,
			VolCondensadoContratistaReparticion_RMPCT33_26,
			VolMetanoEstadoReparticion_RMPCT33_27,
			VolEtanoEstadoReparticion_RMPCT33_28,
			VolPropanoEstadoReparticion_RMPCT33_29,
			VolButanoEstadoReparticion_RMPCT33_30,
			VolCondensadoEstadoReparticion_RMPCT33_31,
			VolMetanoContratistaCompensacion_RMPCT33_32,
			VolEtanoContratistaCompensacion_RMPCT33_33,
			VolPropanoContratistaCompensacion_RMPCT33_34,
			VolButanoContratistaCompensacion_RMPCT33_35,
			VolCondensadoContratistaCompensacion_RMPCT33_36,
			VolMetanoEstadoCompensacion_RMPCT33_37,
			VolEtanoEstadoCompensacion_RMPCT33_38,
			VolPropanoEstadoCompensacion_RMPCT33_39,
			VolButanoEstadoCompensacion_RMPCT33_40,
			VolCondensadoEstadoCompensacion_RMPCT33_41
		FROM 
			#VolPreciosNoAsociado

	END
END