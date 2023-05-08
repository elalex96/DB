CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_21_M_DEBUG] 
-- [SIPAC_RC_CONT_21_M_DEBUG] 10036,'2018-11-01',1
-- Add the parameters for the stored procedure here
@Contrato      INT, 
@Mes           DATE, 
@IdPresupuesto INT
AS
     BEGIN
         -- =============================================
         -- Author:		Manuel Cruz-Yazmin Glez.
         -- Create date:	2017-11-24
         -- Description:	Reporte de CGI - Registro de costos. Plantilla
         --			antes RC_CONT_01_M actual  RC_CONT_21_M
         -- =============================================

         SET NOCOUNT ON;

         /**/

         IF OBJECT_ID('tempdb..#MontosConvertidosFacturas', 'U') IS NOT NULL
             DROP TABLE #MontosConvertidosFacturas;

         /**/

         CREATE TABLE #MontosConvertidosFacturas
         (idRegistro      INT, 
          UUID            VARCHAR(500), 
          idfactura       INT, 
          MontoRegistro   FLOAT, 
          TipoComprobante NVARCHAR(50), 
          RC2122          FLOAT
         );

         /**/

         INSERT INTO #MontosConvertidosFacturas
         (idRegistro, 
          UUID, 
          idfactura, 
          MontoRegistro, 
          TipoComprobante, 
          RC2122
         )
                SELECT R.IdRegistro, 
                       ISNULL(F.UUID, 'NÚMERO NO REGISTRADO') AS UUID, 
                       F.IdFactura, 
                       R.MontoRegistro, 
                       F.TipoComprobante, 
                       SUM(CASE
                               WHEN ISNULL(R.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END) AS [RC21_22]
                FROM dbo.CO_Registro R
                     LEFT JOIN dbo.FI_Factura F ON R.IdFactura = F.IdFactura
                     LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = F.IdMoneda
                                                              AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                              AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                              AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                WHERE F.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                GROUP BY R.IdRegistro, 
                         ISNULL(F.UUID, 'NÚMERO NO REGISTRADO'), 
                         F.IdFactura, 
                         R.MontoRegistro, 
                         F.TipoComprobante;
	   SELECT DISTINCT idfactura FROM #MontosConvertidosFacturas
         ----------------------------------------------------------------------------------------------------
         --PEDIMENTO COMPROBANTE
         IF OBJECT_ID('tempdb..#MontosConvertidosPedimentosCom', 'U') IS NOT NULL
             DROP TABLE #MontosConvertidosPedimentosCom;

         /**/

         CREATE TABLE #MontosConvertidosPedimentosCom
         (idRegistro             INT, 
          idPedimentoComprobante INT, 
          MontoRegistro          FLOAT, 
          RC2122                 FLOAT
         );

         /**/

         INSERT INTO #MontosConvertidosPedimentosCom
         (idRegistro, 
          idPedimentoComprobante, 
          MontoRegistro, 
          RC2122
         )
                SELECT R.IdRegistro, 
                       P.IdPedimentoComprobante, 
                       R.MontoRegistro, 
                       SUM(CASE
                               WHEN ISNULL(R.MontoRegistro, 0) <> 0
                               THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCDP.TipoCambio), 2) AS DECIMAL(15, 2))
                               ELSE 0
                           END) AS [RC21_22]
                FROM dbo.CO_Registro R
                     LEFT JOIN dbo.FI_PedimentoComprobante P ON P.IdPedimentoComprobante = R.IdPedimentoComprobante
                     LEFT JOIN dbo.CO_TipoCambioDiario TCDP ON TCDP.IdMoneda = P.IdMoneda
                                                               AND DAY(TCDP.Fecha) = DAY(P.FechaPago)
                                                               AND MONTH(TCDP.Fecha) = MONTH(P.FechaPago)
                                                               AND YEAR(TCDP.Fecha) = YEAR(P.FechaPago)
                WHERE P.IdContrato = @Contrato
                      AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                      AND R.IdEstado = 10004
                GROUP BY R.IdRegistro, 
                         P.IdPedimentoComprobante, 
                         R.MontoRegistro;

					SELECT * FROM #MontosConvertidosPedimentosCom
         /**/

         EXEC [SIPAC_RC_CONT_22_M_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC [SIPAC_RC_CONT_24_M_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;
         EXEC [SIPAC_RC_CONT_25_M_IdDoc] 
              @Contrato, 
              @Mes, 
              @IdPresupuesto;

         /**/

         SELECT 'Mike',--[RF_00], 
                [RI_00], 
                [RF01_01], 
                [RC21_00], 
                [RC21_01], 
                [RC21_02], 
                ROW_NUMBER() OVER(ORDER BY [RC21_11] ASC) AS [RC21_03], 
                [RC21_04], 
                [RC21_05], 
                [RC21_06], 
                [RC21_07], 
                [RC21_08], 
                [RC21_09], 
                [RC21_10], 
                [RC21_11], 
                [RC21_12], 
                [RC21_13], 
                [RC21_14], 
                [RC21_15], 
                [RC21_16], 
                [RC21_17], 
                [RC21_18], 
                [RC21_19], 
                [RC21_20], 
                [RC21_21], 
           --     [RC21_22], 
             --   [RC21_23], 
                [RC21_24], 
                [RC21_25], 
                [RC21_26]
         FROM
         (
             SELECT LTRIM(RTRIM(CON.IDSIPAC)) AS [RF_00], 
                    LTRIM(RTRIM(C.IDRegFiducidiario)) AS [RI_00], 
                    (C.NumeroContrato) AS [RF01_01], 
                    SUBSTRING(P.IdPresupuestoCNH, 22, 10) AS [RC21_00], 
                    LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)) AS [RC21_01], 
                    CAST(YEAR(R.MesPresentacion) AS INT) AS [RC21_02], 
                    NULL AS [RC21_03], 
                    SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2) AS [RC21_04],
                    CASE
                        WHEN R.CvTipoDocFacturacion = 1
                        THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                        ELSE 'NA'
                    END AS [RC21_05],
                    CASE
                        WHEN R.IdPedimentoComprobante IS NULL
                        THEN 'NA'
                    END AS [RC21_06],
                    CASE
                        WHEN R.IdPedimentoComprobante IS NULL
                        THEN 'NA'
                    END AS [RC21_07],
                    CASE
                        WHEN F.TipoComprobante LIKE '%ingreso%'
                             OR F.TipoComprobante LIKE 'I%'
                        THEN 'I'
                        WHEN(F.TipoComprobante) LIKE '%egreso%'
                            OR F.TipoComprobante LIKE 'E%'
                        THEN 'E'
                        WHEN(F.TipoComprobante) LIKE '%traslado%'
                            OR F.TipoComprobante LIKE 'T%'
                        THEN 'T'
                        WHEN(F.TipoComprobante) LIKE '%nómina%'
                            OR F.TipoComprobante LIKE 'N%'
                        THEN 'N'
                        WHEN(F.TipoComprobante) LIKE '%pago%'
                            OR F.TipoComprobante LIKE 'P%'
                        THEN 'P'
                        ELSE 'NA'
                    END AS [RC21_08],
                    CASE
                        WHEN F.MetodoPago LIKE '%exhibi%'
                             OR F.MetodoPago LIKE '%PUE%'
                             OR F.FormaPago LIKE '%exhibi%'
                             OR F.FormaPago LIKE '%PUE%'
                        THEN 'PUE'
                        WHEN F.MetodoPago LIKE '%parcia%'
                             OR F.MetodoPago LIKE '%dife%'
                             OR F.MetodoPago LIKE '%PPD%'
                             OR F.FormaPago LIKE '%parcia%'
                             OR F.FormaPago LIKE '%dife%'
                             OR F.FormaPago LIKE '%PPD%'
                        THEN 'PPD'
                    END AS [RC21_09], 
                    LTRIM(RTRIM(APCNH.id_Actividad)) AS [RC21_10], 
                    LTRIM(RTRIM(SP.[id_Sub-actividad])) AS [RC21_11], 
                    LTRIM(RTRIM(TP.id_Tarea)) AS [RC21_12],
                    CASE
                        WHEN R.CostosAtribuiblesAdministracion = 1
                        THEN 1
                        ELSE 0
                    END AS [RC21_13],
                    CASE
                        WHEN R.CostosAtribuiblesAdministracion = 1
                        THEN 'NA'
                        ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                    END AS [RC21_14],
                    CASE
                        WHEN R.CostosAtribuiblesAdministracion = 1
                        THEN 'NA'
                        ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                    END AS [RC21_15],
                    CASE
                        WHEN R.CostosAtribuiblesAdministracion = 1
                        THEN 'NA'
                        ELSE LTRIM(RTRIM(I.NombreInstalacion))
                    END AS [RC21_16], 
                    CC.Nivel3 AS [RC21_17], 
                    CC.Descripcion AS [RC21_18], 
                    R.Poliza AS [RC21_19], 
                    R.Comentarios AS [RC21_20],
                    CASE
                        WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                        THEN 1
                        WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                        THEN 2
                        ELSE 2
                    END AS [RC21_21],
                    --SUM(CASE
                    --        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                    --             AND (F.TipoComprobante LIKE '%ingreso%'
                    --                  OR F.TipoComprobante LIKE 'I%'
                    --                  OR F.TipoComprobante LIKE '%nómina%'
                    --                  OR F.TipoComprobante LIKE 'N%'
                    --                  OR F.TipoComprobante LIKE '%pago%'
                    --                  OR F.TipoComprobante LIKE 'P%')
                    --        THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    --        ELSE 0
                    --    END) AS [RC21_22],
                    ------CASE
                    ------    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                    ------         AND (TTF.TipoComprobante LIKE '%ingreso%'
                    ------              OR TTF.TipoComprobante LIKE 'I%'
                    ------              OR TTF.TipoComprobante LIKE '%nómina%'
                    ------              OR TTF.TipoComprobante LIKE 'N%'
                    ------              OR TTF.TipoComprobante LIKE '%pago%'
                    ------              OR TTF.TipoComprobante LIKE 'P%')
                    ------    THEN TTF.RC2122
                    ------    ELSE 0
                    ------END AS [RC21_22],
                    --SUM(   CASE
                    --           WHEN ISNULL(R.MontoRegistro, 0) <> 0
                    --                AND
                    --                (
                    --                    F.TipoComprobante LIKE '%egreso%'
                    --                    OR F.TipoComprobante LIKE 'E%'
                    --                ) THEN
                    --               CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                    --           ELSE
                    --               0
                    --       END
                    --   ) 
                    --CASE
                    --    WHEN ISNULL(TTF.MontoRegistro, 0) <> 0
                    --         AND (TTF.TipoComprobante LIKE '%egreso%'
                    --              OR TTF.TipoComprobante LIKE 'E%')
                    --    THEN TTF.RC2122
                    --    ELSE 0
                    --END AS [RC21_23], 
                    TM.TipoMonedaCorto AS [RC21_24],
                    CASE
                        WHEN TCD.IdMoneda = 2
                        THEN CAST(TCD.TipoCambio AS INT)
                        ELSE TCD.TipoCambio
                    END AS [RC21_25],
                    CASE
                        WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                        THEN 1
                        ELSE 2
                    END AS [RC21_26]
             FROM dbo.FI_Transfer TR
                  LEFT JOIN dbo.FI_TransferFactura TF ON TR.IdTransferencia = TF.IdTransfer
                  LEFT JOIN dbo.FI_Factura F ON TF.IdFactura = F.IdFactura
                  LEFT JOIN dbo.CO_Registro R ON R.IdFactura = F.IdFactura
                  LEFT JOIN dbo.CO_LineaPresupuestoMes LPM ON R.IdPrograma = LPM.IdLineaPresupuestoMes
                  LEFT JOIN dbo.CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
                  LEFT JOIN dbo.CO_AnioContractual AC ON AC.IdAnioContractual = P.IdAnioContractual
                  LEFT JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
                  LEFT JOIN dbo.CO_Contratista CON ON C.IdContratista = CON.IdContratista
                  LEFT JOIN dbo.CO_ActividadPetroleraCNH APCNH ON LPM.IdActividadPetrolera = APCNH.IdActividadPetrolera
                  LEFT JOIN dbo.CO_SubactividadPetrolera SP ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                  LEFT JOIN dbo.CO_TareaPetrolera TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
                  LEFT JOIN dbo.CO_Instalacion I ON R.IdInstalacion = I.IdInstalacion
                  LEFT JOIN dbo.PD_Campo CPO ON I.IdCampo = CPO.IdCampo
                  LEFT JOIN dbo.CO_Yacimiento Y ON CPO.IdYacimiento = Y.IdYacimiento
                  LEFT JOIN dbo.CO_CatalogoCuentaSH CC ON CC.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
                  LEFT JOIN dbo.PV_TipoMoneda TM ON F.IdMoneda = TM.IdMoneda
                  LEFT JOIN dbo.CO_TipoCambioDiario TCD ON TCD.IdMoneda = TM.IdMoneda
                                                           AND DAY(TCD.Fecha) = DAY(F.Fecha)
                                                           AND MONTH(TCD.Fecha) = MONTH(F.Fecha)
                                                           AND YEAR(TCD.Fecha) = YEAR(F.Fecha)
                  LEFT JOIN dbo.CO_RelacionEmpresas RE ON RE.IdContratista = CON.IdContratista
                                                          AND F.IdSubcontratista = RE.IdRelacionada
                  LEFT JOIN dbo.CO_Servicio S ON S.IdServicio = LPM.IdServicio
                  ----------------------------------------------------------------
                  --JOIN #MontosConvertidosFacturas TTF ON TTF.idfactura = R.IdFactura
                  --                                       AND TTF.idRegistro = R.IdRegistro
                  --                                       AND TTF.UUID = F.UUID
             ----------------------------------------------------------------

             WHERE C.IdContrato = @Contrato
                   AND DATEFROMPARTS(YEAR(R.MesPresentacion), MONTH(R.MesPresentacion), 1) = @Mes
                  -- AND R.IdEstado = 10004
                  -- AND R.CvTipoDocFacturacion = 1
                   --AND ISNULL(CONVERT(INT, F.ProcesadoSIPAC), 0) = 0
                   --AND P.IdPresupuesto = @IdPresupuesto
                   --AND CC.IdVersion = 10001
                  -- AND S.NombreServicio NOT LIKE '%No elegibles%'
             GROUP BY LTRIM(RTRIM(CON.IDSIPAC)), 
                      LTRIM(RTRIM(C.IDRegFiducidiario)), 
                      (C.NumeroContrato), 
                      SUBSTRING(P.IdPresupuestoCNH, 22, 10), 
                      LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)), 
                      CAST(YEAR(R.MesPresentacion) AS INT), 
                      SUBSTRING(F.IdDocFacturacionSIPAC, 1, 2),
                      CASE
                          WHEN R.CvTipoDocFacturacion = 1
                          THEN ISNULL(F.UUID, 'NÚMERO NO REGISTRADO')
                          ELSE 'NA'
                      END,
                      CASE
                          WHEN R.IdPedimentoComprobante IS NULL
                          THEN 'NA'
                      END,
                      CASE
                          WHEN R.IdPedimentoComprobante IS NULL
                          THEN 'NA'
                      END,
                      CASE
                          WHEN F.TipoComprobante LIKE '%ingreso%'
                               OR F.TipoComprobante LIKE 'I%'
                          THEN 'I'
                          WHEN(F.TipoComprobante) LIKE '%egreso%'
                              OR F.TipoComprobante LIKE 'E%'
                          THEN 'E'
                          WHEN(F.TipoComprobante) LIKE '%traslado%'
                              OR F.TipoComprobante LIKE 'T%'
                          THEN 'T'
                          WHEN(F.TipoComprobante) LIKE '%nómina%'
                              OR F.TipoComprobante LIKE 'N%'
                          THEN 'N'
                          WHEN(F.TipoComprobante) LIKE '%pago%'
                              OR F.TipoComprobante LIKE 'P%'
                          THEN 'P'
                          ELSE 'NA'
                      END,
                      CASE
                          WHEN F.MetodoPago LIKE '%exhibi%'
                               OR F.MetodoPago LIKE '%PUE%'
                               OR F.FormaPago LIKE '%exhibi%'
                               OR F.FormaPago LIKE '%PUE%'
                          THEN 'PUE'
                          WHEN F.MetodoPago LIKE '%parcia%'
                               OR F.MetodoPago LIKE '%dife%'
                               OR F.MetodoPago LIKE '%PPD%'
                               OR F.FormaPago LIKE '%parcia%'
                               OR F.FormaPago LIKE '%dife%'
                               OR F.FormaPago LIKE '%PPD%'
                          THEN 'PPD'
                      END, 
                      LTRIM(RTRIM(APCNH.id_Actividad)), 
                      LTRIM(RTRIM(SP.[id_Sub-actividad])), 
                      LTRIM(RTRIM(TP.id_Tarea)),
                      CASE
                          WHEN R.CostosAtribuiblesAdministracion = 1
                          THEN 1
                          ELSE 0
                      END,
                      CASE
                          WHEN R.CostosAtribuiblesAdministracion = 1
                          THEN 'NA'
                          ELSE LTRIM(RTRIM(ISNULL(CPO.NombreCampo, '-')))
                      END,
                      CASE
                          WHEN R.CostosAtribuiblesAdministracion = 1
                          THEN 'NA'
                          ELSE LTRIM(RTRIM(ISNULL(Y.NombreYacimiento, '-')))
                      END,
                      CASE
                          WHEN R.CostosAtribuiblesAdministracion = 1
                          THEN 'NA'
                          ELSE LTRIM(RTRIM(I.NombreInstalacion))
                      END, 
                      CC.Nivel3, 
                      CC.Descripcion, 
                      R.Poliza, 
                      R.Comentarios,
                      CASE
                          WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 1
                          THEN 1
                          WHEN ISNULL(CONVERT(INT, CC.Operacion), 3) = 0
                          THEN 2
                          ELSE 2
                      END,
                      --CASE
                      --    WHEN ISNULL(R.MontoRegistro, 0) <> 0
                      --         AND (F.TipoComprobante LIKE '%ingreso%'
                      --              OR F.TipoComprobante LIKE 'I%'
                      --              OR F.TipoComprobante LIKE '%nómina%'
                      --              OR F.TipoComprobante LIKE 'N%'
                      --              OR F.TipoComprobante LIKE '%pago%'
                      --              OR F.TipoComprobante LIKE 'P%')
                      --    THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                      --    ELSE 0
                      --END,

/*CASE
                 WHEN ISNULL(R.MontoRegistro, 0) <> 0
                      AND (F.TipoComprobante LIKE '%egreso%'
                           OR F.TipoComprobante LIKE 'E%')
                 THEN CAST(ROUND((ISNULL(R.MontoRegistro, 0) / TCD.TipoCambio), 2) AS DECIMAL(15, 2))
                 ELSE 0
             END,*/

                      TM.TipoMonedaCorto,
                      CASE
                          WHEN TCD.IdMoneda = 2
                          THEN CAST(TCD.TipoCambio AS INT)
                          ELSE TCD.TipoCambio
                      END,
                      CASE
                          WHEN ISNULL(RE.IdRelacionada, 2) <> 2
                          THEN 1
                          ELSE 2
                      END--, 
                      --TTF.RC2122, 
                      --TTF.MontoRegistro, 
                      --TTF.TipoComprobante

             /**/

         ) AS Resultado;
     END;