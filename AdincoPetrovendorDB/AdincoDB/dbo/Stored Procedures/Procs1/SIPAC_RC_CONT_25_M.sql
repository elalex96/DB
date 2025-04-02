IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SIPAC_RC_CONT_25_M'
    )
    DROP PROCEDURE SIPAC_RC_CONT_25_M;
GO
-- =============================================    
-- Author:  Manuel Cruz    
-- Create date: 2017-03-29    
-- Description:      
-- =============================================    
-- Modificado:       Marcos Garcia    
-- Fecha Modificado: 2020-01-13    
-- Description:     *Agregar Validacion de @IdPresupuesto = 0    
--                  *Agregar WITH (NOLOCK) en las tablas    
-- =============================================    
-- Modificado:       Manuel Cruz    
-- Fecha Modificado: 2021-03-22    
-- Description:      Se remplazo columna PCD.PrecioUnitario por R.MontoRegistro para evitar multiplicar los montos a reportar debido al desglose del detalle de conceptos de PE.    
-- =============================================    
-- Modificado:       Reyna Olvera    
-- Fecha Modificado: 2022-08-18    
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS    
-- =============================================    
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 16 de Febrero del 2023  
-- Description:      Se agrega la opción obtener el nuevo campo IDSIPAC desde la tabla CO_Contrato, si este viene vacío o nulo se obtendrá desde la tabla que ya se obtenía anteriormente CO_Contratista  
-- =============================================  
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 13 de Abril del 2023  
-- Description:      Se agregan case cuando el tipocambio de la tabla CO_TipoCambioDiario es 0 o nulo y 
--					 se agrega si este mismo valor es nulo se muestre como 0 para identificar en el reporte que el tipo cambio no se encuentra agregado
-- ============================================= 
-- Modificado:       Neri del Angel  
-- Fecha Modificado: 18 de Abril del 2023  
-- Description:     Se ajusta para que no se multiplique el número de gastos por el número de transferencias
--					Se ajusta para que si se generan n transferencias con distintos métodos de pago se tome en cuenta solo el del mayor monto para no mostrar 2 registros con diferente método de pago
-- ============================================= 
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_25_M]
    @Contrato INT,
    @Mes DATE,
    @IdPresupuesto INT = 0,
    @Plantilla VARCHAR(150) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Aprobado INT = 10004,
            @TipoComprobanteExtranjero INT = 3

    CREATE TABLE #TEMPORAL_25_M_SP
    (
        IdContratista_RF_00 VARCHAR(2000),
        IdContrato_RI_00 VARCHAR(2000),
        NumeroContrato_RF01_01 VARCHAR(2000),
        MesReporte_RC25_00 INT,
        AnioReporte_RC25_01 INT,
        NomArchivo_PDF_RC25_02 VARCHAR(2000),
        TimbreHASH_PDF_RC25_03 VARCHAR(2000),
        IdDocFacturacion_RC25_04 VARCHAR(2000),
        FolioCompExtranjero_RC25_05 VARCHAR(2000),
        ImporteTotalAntesImpuestos_RC25_06 MONEY,
        FormaPago_RC25_07 VARCHAR(2000),
        FechaPago_RC25_08 DATE,
        RFC_Importador_RC25_09 VARCHAR(2000),
        RZImportador_RC25_10 VARCHAR(2000),
        RZEmisorCompExtranjero_RC25_11 VARCHAR(2000),
        IdFiscal_RC25_12 VARCHAR(2000),
        NumFactura_RC25_13 VARCHAR(2000),
        FechaFactura_RC25_14 DATE,
        ValMontFact_RC25_15 MONEY,
        ValDolares_RC25_16 MONEY NULL,
        ClasDocSoporte_RC25_17 INT,
        IdPedimentoComprobante INT,
        ConTransferencia BIT,
        IdMoneda INT
    );

    CREATE TABLE #TransferenciasMaximas
    (
        IdPedimentoComprobante INT,
        IdTransferencia INT,
        MontoMaximo MONEY,
        FormaPago VARCHAR(2000),
        FechaPago DATE,
        RN INT
    )

    INSERT INTO #TEMPORAL_25_M_SP
    (
        IdContratista_RF_00,
        IdContrato_RI_00,
        NumeroContrato_RF01_01,
        MesReporte_RC25_00,
        AnioReporte_RC25_01,
        NomArchivo_PDF_RC25_02,
        TimbreHASH_PDF_RC25_03,
        IdDocFacturacion_RC25_04,
        FolioCompExtranjero_RC25_05,
        ImporteTotalAntesImpuestos_RC25_06,
        RFC_Importador_RC25_09,
        RZImportador_RC25_10,
        RZEmisorCompExtranjero_RC25_11,
        IdFiscal_RC25_12,
        NumFactura_RC25_13,
        FechaFactura_RC25_14,
        ValMontFact_RC25_15,
        ValDolares_RC25_16,
        ClasDocSoporte_RC25_17,
        IdPedimentoComprobante,
        ConTransferencia,
        IdMoneda
    )
    SELECT CASE
               WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN
                   LTRIM(RTRIM(CO_Contrato.IDSIPAC))
               ELSE
                   LTRIM(RTRIM(CO_Contratista.IDSIPAC))
           END AS [RF_00],
           CO_Contrato.IdRegFiducidiario AS [RI_00],
           CO_Contrato.NumeroContrato AS [RF01_01],
           MONTH(CO_Registro.MesPresentacion) AS [RC25_00],
           YEAR(CO_Registro.MesPresentacion) AS [RC25_01],
           CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC25_02],
           FI_PedimentoComprobante.HashSHA256 AS [RC25_03],
           LTRIM(RTRIM(FI_PedimentoComprobante.IdDocFacturacionSIPAC)) AS [RC25_04],
           SUBSTRING(LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)), 0, 36) AS [RC25_05],
           SUM(CAST(ROUND((CO_Registro.MontoRegistro), 2) AS DECIMAL(15, 2))) AS [RC25_06],
           SUBSTRING(CO_Contratista.RFC, 0, 13) AS [RC25_09],
           SUBSTRING(CO_Contratista.RazonSocial, 0, 120) AS [RC25_10],
           SUBSTRING(PV_Subcontratista.RazonSocial, 0, 120) AS [RC25_11],
           REPLACE(PV_Subcontratista.RFC, ' ', '') AS [RC25_12],
           SUBSTRING(REPLACE(ISNULL(FI_PedimentoComprobante.NumFacturaC, 'NA'), ' ', ''), 0, 30) AS [RC25_13],
           FI_PedimentoComprobante.FechaPago AS [RC25_14],
           SUM(CAST(ROUND((CO_Registro.MontoRegistro), 2) AS DECIMAL(15, 2))) AS [RC25_15],
           SUM(CAST(ROUND((CO_Registro.MontoRegistro), 2) AS DECIMAL(15, 2))) AS [RC25_16],
           2 AS [RC25_17],
           CO_Registro.IdPedimentoComprobante,
           0,
           PV_TipoMoneda.IdMoneda
    FROM dbo.CO_Registro WITH (NOLOCK)
        JOIN dbo.FI_PedimentoComprobante WITH (NOLOCK)
            ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        JOIN dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN dbo.CO_Presupuesto WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
        JOIN dbo.CO_AnioContractual WITH (NOLOCK)
            ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
        JOIN dbo.CO_Contrato WITH (NOLOCK)
            ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
        JOIN dbo.CO_Contratista WITH (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
        JOIN dbo.FI_Documento WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_Documento.IdPedimentoComprobante
        JOIN dbo.PV_Subcontratista WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
        JOIN dbo.PV_TipoMoneda WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        JOIN dbo.CO_Servicio WITH (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
    WHERE CO_Registro.CvTipoDocFacturacion = @TipoComprobanteExtranjero
          AND CO_Contrato.IdContrato = @Contrato
          AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
          AND CO_Registro.IdEstado = @Aprobado
          AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0
          AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
          AND ISNULL(FI_PedimentoComprobante.EsnotaCredito, 0) <> 1
          AND CO_Presupuesto.IdPresupuesto = CASE
                                                 WHEN @IdPresupuesto = 0 THEN
                                                     CO_LineaPresupuestoMes.IdPresupuesto
                                                 ELSE
                                                     @IdPresupuesto
                                             END
    GROUP BY CASE
                 WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN
                     LTRIM(RTRIM(CO_Contrato.IDSIPAC))
                 ELSE
                     LTRIM(RTRIM(CO_Contratista.IDSIPAC))
             END,
             CO_Contrato.IdRegFiducidiario,
             CO_Contrato.NumeroContrato,
             MONTH(CO_Registro.MesPresentacion),
             YEAR(CO_Registro.MesPresentacion),
             CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf'),
             FI_PedimentoComprobante.HashSHA256,
             LTRIM(RTRIM(FI_PedimentoComprobante.IdDocFacturacionSIPAC)),
             SUBSTRING(LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)), 0, 36),
             SUBSTRING(CO_Contratista.RFC, 0, 13),
             SUBSTRING(CO_Contratista.RazonSocial, 0, 120),
             SUBSTRING(PV_Subcontratista.RazonSocial, 0, 120),
             REPLACE(PV_Subcontratista.RFC, ' ', ''),
             SUBSTRING(REPLACE(ISNULL(FI_PedimentoComprobante.NumFacturaC, 'NA'), ' ', ''), 0, 30),
             FI_PedimentoComprobante.FechaPago,
             CO_Registro.IdPedimentoComprobante,
             PV_TipoMoneda.IdMoneda;

    INSERT INTO #TransferenciasMaximas
    (
        IdPedimentoComprobante,
        IdTransferencia,
        MontoMaximo,
        FormaPago,
        FechaPago,
        RN
    )
    SELECT FI_TransferFactura.IdPedimentoComprobante,
           FI_TransferFactura.IdTransfer,
           FI_TransferFactura.MontoPagado,
           ISNULL(PV_MetodoPago.C_FormaPago, ''),
           FI_Transfer.FechaPago,
           ROW_NUMBER() OVER (PARTITION BY FI_TransferFactura.IdPedimentoComprobante
                              ORDER BY FI_TransferFactura.MontoPagado DESC
                             ) AS RN
    FROM #TEMPORAL_25_M_SP
        JOIN FI_TransferFactura WITH (NOLOCK)
            ON #TEMPORAL_25_M_SP.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
        JOIN FI_Transfer WITH (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        JOIN PV_MetodoPago WITH (NOLOCK)
            ON FI_Transfer.IdMetodoPago = PV_MetodoPago.idMetodoPago
    GROUP BY FI_TransferFactura.IdPedimentoComprobante,
             FI_TransferFactura.IdTransfer,
             FI_TransferFactura.MontoPagado,
             ISNULL(PV_MetodoPago.C_FormaPago, ''),
             FI_Transfer.FechaPago

    UPDATE #TEMPORAL_25_M_SP
    SET #TEMPORAL_25_M_SP.FormaPago_RC25_07 = #TransferenciasMaximas.FormaPago,
        #TEMPORAL_25_M_SP.FechaPago_RC25_08 = #TransferenciasMaximas.FechaPago,
        #TEMPORAL_25_M_SP.ConTransferencia = 1
    FROM #TEMPORAL_25_M_SP
        JOIN #TransferenciasMaximas
            ON #TEMPORAL_25_M_SP.IdPedimentoComprobante = #TransferenciasMaximas.IdPedimentoComprobante
               AND #TransferenciasMaximas.RN = 1

    UPDATE #TEMPORAL_25_M_SP
    SET #TEMPORAL_25_M_SP.ValDolares_RC25_16 = CASE
                                                   WHEN ISNULL(CO_TipoCambioDiario.TipoCambio, 0) = 0 THEN
                                                       0
                                                   WHEN ISNULL(#TEMPORAL_25_M_SP.ValDolares_RC25_16, 0) <> 0 THEN
                                                       CAST(ROUND(
                                                                     (ISNULL(#TEMPORAL_25_M_SP.ValDolares_RC25_16, 0)
                                                                      / CO_TipoCambioDiario.TipoCambio
                                                                     ),
                                                                     2
                                                                 ) AS DECIMAL(15, 2))
                                                   ELSE
                                                       0
                                               END
    FROM #TEMPORAL_25_M_SP
        LEFT JOIN dbo.CO_TipoCambioDiario WITH (NOLOCK)
            ON #TEMPORAL_25_M_SP.ConTransferencia = 1
               AND #TEMPORAL_25_M_SP.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND DAY(#TEMPORAL_25_M_SP.FechaPago_RC25_08) = DAY(CO_TipoCambioDiario.Fecha)
               AND MONTH(#TEMPORAL_25_M_SP.FechaPago_RC25_08) = MONTH(CO_TipoCambioDiario.Fecha)
               AND YEAR(#TEMPORAL_25_M_SP.FechaPago_RC25_08) = YEAR(CO_TipoCambioDiario.Fecha)

    SELECT IdContratista_RF_00,
           IdContrato_RI_00,
           NumeroContrato_RF01_01,
           MesReporte_RC25_00,
           AnioReporte_RC25_01,
           NomArchivo_PDF_RC25_02,
           TimbreHASH_PDF_RC25_03,
           IdDocFacturacion_RC25_04,
           FolioCompExtranjero_RC25_05,
           ImporteTotalAntesImpuestos_RC25_06,
           FormaPago_RC25_07,
           FechaPago_RC25_08,
           RFC_Importador_RC25_09,
           RZImportador_RC25_10,
           RZEmisorCompExtranjero_RC25_11,
           IdFiscal_RC25_12,
           NumFactura_RC25_13,
           FechaFactura_RC25_14,
           ValMontFact_RC25_15,
           ValDolares_RC25_16,
           ClasDocSoporte_RC25_17,
		   'NA' AS RC25_18,
		   'NA' AS RC25_19
    FROM #TEMPORAL_25_M_SP
    WHERE ConTransferencia = 1
END;

