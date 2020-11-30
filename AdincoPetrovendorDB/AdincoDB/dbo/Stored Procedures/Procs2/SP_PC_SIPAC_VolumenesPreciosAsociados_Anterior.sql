CREATE PROCEDURE [dbo].[SP_PC_SIPAC_VolumenesPreciosAsociados_Anterior] @Contrato INT,
                                                              @Mes      DATE
AS
     BEGIN
         -- =============================================
	    -- Author:		Manuel Cruz
	    -- Create date: 02-06-17
	    -- Description:	
	    -- =============================================
         SET NOCOUNT ON;
         -- =============================================
	    declare @GasNoAsociado bit
	    select @GasNoAsociado = gasnoasociado from CO_Contrato where IdContrato= @Contrato

	    if (@GasNoAsociado =0) 
	    begin 

         CREATE TABLE #VolumenComercializado
         (tipohidrocarburo      INT,
          VolumenComercializado INT,
          PRIMARY KEY(tipohidrocarburo)
         )
         CREATE TABLE #Calculo
         (tipohidrocarburo INT,
          Volumen          INT,
          Precio           DECIMAL(16, 4),
          PRIMARY KEY(tipohidrocarburo)
         )
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
                       SUM((OP.PrecioVentaUnitario - OP.CostoUnitarioComercializacion) * ROUND(OP.VolumenVendido, 0) / VC.VolumenComercializado)
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
         ) AS SourceTable PIVOT(SUM(Volumen) FOR tipohidrocarburo IN([1],
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
         ) AS SourceTable PIVOT(SUM(precio) FOR tipohidrocarburo IN([1],
                                                                    [2],
                                                                    [3],
                                                                    [4],
                                                                    [5],
                                                                    [6])) AS PivotTable
         SELECT Ca.IDSIPAC AS RF_00,
                C.IDRegFiducidiario AS RI_00,
                C.NumeroContrato AS RF01_01,
                MONTH(VMPPG.MesReporte) AS RMPCT32_00,
                YEAR(VMPPG.MesReporte) AS RMPCT32_01,
                ROUND(VMPPG.VolumenPetroleoPuntoMedicion, 0) AS RMPCT32_02,
                CONVERT(DECIMAL(3, 1), VMPPG.GradosAPI) AS RMPCT32_03,
                CONVERT(DECIMAL(6, 2), VMPPG.ContenidoAzufre) AS RMPCT32_04,
                CONVERT(INT, VMPPG.VolumenCondensadoAutoconsumo) AS RMPCT32_05,
                ROUND(VMPPG.MetanoC1, 0) AS RMPCT32_06,
                ROUND(VMPPG.EtanoC2, 0) AS RMPCT32_07,
                ROUND(VMPPG.PropanoC3, 0) AS RMPCT32_08,
                ROUND(VMPPG.ButanoC4, 0) AS RMPCT32_09,
                CONVERT(INT, VMPPG.MetanoC1Autoconsumo) AS RMPCT32_10,
                CONVERT(INT, VMPPG.EtanoC2Autoconsumo) AS RMPCT32_11,
                CONVERT(INT, VMPPG.PropanoC3Autoconsumo) AS RMPCT32_12,
                CONVERT(INT, VMPPG.ButanoC4Autoconsumo) AS RMPCT32_13,
                CONVERT(INT, VMPPG.VolumenCondensadoPuntoMedicion) AS RMPCT32_14,
                CONVERT(INT, VMPPG.VolumenCondensadoAutoconsumo) AS RMPCT32_15,
                CONVERT(INT, ISNULL(V.[1], 0)) AS RMPCT32_16,
                CONVERT(INT, ISNULL(V.[3], 0)) AS RMPCT32_17,
                CONVERT(INT, ISNULL(V.[4], 0)) AS RMPCT32_18,
                CONVERT(INT, ISNULL(V.[5], 0)) AS RMPCT32_19,
                CONVERT(INT, ISNULL(V.[6], 0)) AS RMPCT32_20,
                CONVERT(INT, ISNULL(V.[2], 0)) AS RMPCT32_21,
                ISNULL(P.[1], 0) AS RMPCT32_22,
                ISNULL(P.[3], 0) AS RMPCT32_23,
                ISNULL(P.[4], 0) AS RMPCT32_24,
                ISNULL(P.[5], 0) AS RMPCT32_25,
                ISNULL(P.[6], 0) AS RMPCT32_26,
                --CASE WHEN VMPPG.VolumenCondensadoPuntoMedicion = 0--THEN	'NA'--ELSE	  LTRIM(ISNULL(P.[2],0))--END	  AS RMPCT32_27,
                ISNULL(P.[2], 0) AS RMPCT32_27,
                --CONVERT(INT, VMPPG.VolumenPetroleoContratistaReparticion) AS RMPCT32_28,--round((VMPPG.VolumenPetroleoPuntoMedicion * PRPC.PorcentajeRepPreliminarContratista / 100), 0) AS RMPCT32_28,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo < 0
                 --   THEN ROUND(((((VMPPG.VolumenPetroleoPuntoMedicion * FMP53.NuevaDistribucionProvisionalContratista)+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) / 100)) , 0)
                    THEN ROUND((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo, 0)
                    ELSE ROUND((((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)))), 0)
					  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo < 0
       --             THEN ROUND((((VMPPG.VolumenPetroleoPuntoMedicion+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
       --             ELSE ROUND(((VMPPG.VolumenPetroleoPuntoMedicion- FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_28,
                --CONVERT(INT, VMPPG.VolumenMetanoC1ContratistaReparticion) AS RMPCT32_29,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
                    THEN ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1), 0)
                    ELSE ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
					 --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1 < 0
      --              THEN ROUND((((VMPPG.MetanoC1+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC1) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
      --              ELSE ROUND(((VMPPG.MetanoC1) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_29,
              
                --CONVERT(INT, VMPPG.VolumenEtanoC2ContratistaReparticion) AS RMPCT32_30,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
                    THEN ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalContratista / 100) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2)), 0)
                    ELSE ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
                 --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC2 < 0
                 --   THEN ROUND((((VMPPG.EtanoC2) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
                 --   ELSE ROUND(((VMPPG.EtanoC2) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                
                END AS RMPCT32_30,
                --CONVERT(INT, VMPPG.VolumenPropanoC3ContratistaReparticion) AS RMPCT32_31,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
                    THEN ROUND((((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3)), 0)
                    ELSE ROUND(((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3 < 0
                  --  THEN ROUND((((VMPPG.PropanoC3+ FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC3) * FMP53.NuevaDistribucionProvisionalContratista / 100)) , 0)
                  --  ELSE ROUND(((VMPPG.PropanoC3) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                
                END AS RMPCT32_31,
                --CONVERT(INT, VMPPG.VolumenButanoC4ContratistaReparticion) AS RMPCT32_32,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
                    THEN ROUND((((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4)), 0)
                    ELSE ROUND(((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
                    --  WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 < 0
                    --THEN ROUND((((VMPPG.ButanoC4 + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaC4 ) * FMP53.NuevaDistribucionProvisionalContratista / 100)), 0)
                    --ELSE ROUND(((VMPPG.ButanoC4) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
             
                END AS RMPCT32_32,
                --CONVERT(INT, VMPPG.VolumenCondensadosContratistaReparticion) AS RMPCT32_33,--CONVERT(INT, VMPPG.VolumenCondensadoPuntoMedicion *( PRPC.PorcentajeRepPreliminarContratista /100)) AS RMPCT32_33,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
                    THEN ROUND((((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado)), 0)
                    ELSE ROUND(((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalContratista / 100))), 0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
                  --  THEN ROUND((((VMPPG.VolumenCondensadoPuntoMedicion + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado ) * FMP53.NuevaDistribucionProvisionalContratista / 100)), 0)
                  --  ELSE ROUND(((VMPPG.VolumenCondensadoPuntoMedicion) * FMP53.NuevaDistribucionProvisionalContratista / 100), 0)
                END AS RMPCT32_33,
                --CONVERT(INT, VMPPG.VolumenPetroleoEstadoReparticion) AS RMPCT32_34,--round((VMPPG.VolumenPetroleoPuntoMedicion * PRPC.PorcentajeRepPreliminarEstado / 100), 0) AS RMPCT32_34,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo < 0
                    THEN ROUND(((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo), 0)
                    ELSE ROUND(((VMPPG.VolumenPetroleoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo < 0
                --    THEN ROUND(((VMPPG.VolumenPetroleoPuntoMedicion  + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoPetroleo) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                --    ELSE ROUND(((VMPPG.VolumenPetroleoPuntoMedicion) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
   
                END AS RMPCT32_34,
                --CONVERT(INT, VMPPG.VolumenMetanoC1EstadoReparticion) AS RMPCT32_35,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 < 0
                    THEN ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1), 0)
                    ELSE ROUND(((VMPPG.MetanoC1 * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1 < 0
                  --  THEN ROUND(((VMPPG.MetanoC1+ FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC1) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                  --  ELSE ROUND(((VMPPG.MetanoC1) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                
                END AS RMPCT32_35,
                --CONVERT(INT, VMPPG.VolumenEtanoC2EstadoReparticion) AS RMPCT32_36,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2 < 0
                    THEN ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2), 0)
                    ELSE ROUND(((VMPPG.EtanoC2 * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2 < 0
                  --  THEN ROUND(((VMPPG.EtanoC2+ FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC2 ) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                  --  ELSE ROUND(((VMPPG.EtanoC2) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                
                END AS RMPCT32_36,
                --CONVERT(INT, VMPPG.VolumenPropanoC3EstadoReparticion) AS RMPCT32_37,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 < 0
                    THEN ROUND(((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3), 0)
                    ELSE ROUND(((VMPPG.PropanoC3 * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                   --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 < 0
                   -- THEN ROUND(((VMPPG.PropanoC3 + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC3 ) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                   -- ELSE ROUND(((VMPPG.PropanoC3) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                END AS RMPCT32_37,
                --CONVERT(INT, VMPPG.VolumenButanoC4EstadoReparticion) AS RMPCT32_38,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 < 0
                    THEN ROUND(((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4), 0)
                    ELSE ROUND(((VMPPG.ButanoC4 * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 < 0
                  --  THEN ROUND(((VMPPG.ButanoC4 + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoC4 ) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                  --  ELSE ROUND(((VMPPG.ButanoC4) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                END AS RMPCT32_38,
                --CONVERT(INT, VMPPG.VolumenCondensadosEstadoReparticion) AS RMPCT32_39,--CONVERT(INT, VMPPG.VolumenCondensadoPuntoMedicion * (PRPC.PorcentajeRepPreliminarEstado /100)) AS RMPCT32_39,
                CASE
                    WHEN FMP53.CompensacionVolSaldoAcumuladoEstadoCondensado < 0
                    THEN ROUND(((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalEstado / 100)) + FMP53.CompensacionVolNuevoSaldoAcumuladoEstadoCondensado), 0)
                    ELSE ROUND(((VMPPG.VolumenCondensadoPuntoMedicion * (FMP53.NuevaDistribucionProvisionalEstado / 100))), 0)
                  --WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado < 0
                  --  THEN ROUND(((VMPPG.VolumenCondensadoPuntoMedicion + FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaCondensado) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                  --  ELSE ROUND(((VMPPG.VolumenCondensadoPuntoMedicion) * FMP53.NuevaDistribucionProvisionalEstado / 100), 0)
                END AS RMPCT32_39,
                --CONVERT(INT, VMPPG.VolumenPetroleoContratistaCompensacion) AS RMPCT32_40,
                CASE
                    WHEN FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo > 0
                    THEN CONVERT(INT, FMP53.CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo)
                    ELSE 0
                END AS RMPCT32_40,
                --CONVERT(INT, VMPPG.VolumenMetanoC1ContratistaCompensacion) AS RMPCT32_41,
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

                --CONVERT(INT, VMPPG.VolumenPetroleoEstadoCompensacion) AS RMPCT32_46,--CONVERT(INT, VMPPG.VolumenMetanoC1EstadoCompensacion) AS RMPCT32_47,--CONVERT(INT, VMPPG.VolumenEtanoC2EstadoCompensacion) AS RMPCT32_48,--CONVERT(INT, VMPPG.VolumenPropanoC3EstadoCompensacion) AS RMPCT32_49,--CONVERT(INT, VMPPG.VolumenButanoC4EstadoCompensacion) AS RMPCT32_50,--CONVERT(INT, VMPPG.VolumenCondensadosEstadoCompensacion) AS RMPCT32_51
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
                END AS RMPCT32_51
         FROM PR_VolumenMensualProduccionPetroleo VMPPG
              LEFT JOIN CO_Contrato C ON VMPPG.IdContrato = C.IdContrato
              LEFT JOIN CO_Contratista Ca ON C.IdContratista = Ca.IdContratista
              LEFT JOIN #Precio P ON C.IdContrato = P.IdContrato
              LEFT JOIN #Volumen V ON C.IdContrato = V.IdContrato
              LEFT JOIN CP_PorcentajesReparticionPC PRPC ON PRPC.IdContrato = v.idcontrato
                                                            AND VMPPG.MesReporte = PRPC.MesReporte
              LEFT JOIN SIPAC_RM_FMP_53_M FMP53 ON FMP53.IdContrato = @Contrato
                                                   AND DATEADD(month, 1, DATEFROMPARTS(FMP53.anioreporte, FMP53.mesreporte, 1)) = @Mes
         WHERE VMPPG.IdContrato = @Contrato
               AND VMPPG.MesReporte = @Mes
			end
     END;