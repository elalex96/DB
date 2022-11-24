
-- =============================================
-- Author:		Manuel Cruz
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
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_25_M]
    @Contrato      INT,
    @Mes           DATE,
    @IdPresupuesto INT          = 0,
    @Plantilla     VARCHAR(150) = ''
AS
    BEGIN
        SET NOCOUNT ON;

        /*Generar nombre de archivos*/

        EXEC [SIPAC_RC_CONT_25_M_IdDoc]
            @Contrato,
            @Mes,
            @IdPresupuesto;

        /**/

        SELECT
            LTRIM(RTRIM(CO_Contratista.IDSIPAC))                                                  AS [RF_00],
            CO_Contrato.IdRegFiducidiario                                                         AS [RI_00],
            CO_Contrato.NumeroContrato                                                            AS [RF01_01],
            MONTH(CO_Registro.MesPresentacion)                                                    AS [RC25_00],
            YEAR(CO_Registro.MesPresentacion)                                                     AS [RC25_01],
            CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf')      AS [RC25_02],
            FI_PedimentoComprobante.HashSHA256                                                    AS [RC25_03],
            LTRIM(RTRIM(FI_PedimentoComprobante.IdDocFacturacionSIPAC))                           AS [RC25_04],
            SUBSTRING(LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)), 0, 36)              AS [RC25_05],
            SUM(CAST(ROUND((CO_Registro.MontoRegistro), 2) AS DECIMAL(15, 2)))                    AS [RC25_06],
            PV_MetodoPago.C_FormaPago                                                             AS [RC25_07],
            FI_Transfer.FechaPago                                                                 AS [RC25_08],
            SUBSTRING(CO_Contratista.RFC, 0, 13)                                                  AS [RC25_09],
            SUBSTRING(CO_Contratista.RazonSocial, 0, 120)                                         AS [RC25_10],
            SUBSTRING(PV_Subcontratista.RazonSocial, 0, 120)                                      AS [RC25_11],
            REPLACE(PV_Subcontratista.RFC, ' ', '')                                               AS [RC25_12],
            SUBSTRING(REPLACE(ISNULL(FI_PedimentoComprobante.NumFacturaC, 'NA'), ' ', ''), 0, 30) AS [RC25_13],
            FI_PedimentoComprobante.FechaPago                                                     AS [RC25_14],
            SUM(CAST(ROUND((CO_Registro.MontoRegistro), 2) AS DECIMAL(15, 2)))                    AS [RC25_15],
            SUM(   CASE
                       WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                           THEN CAST(ROUND((ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(15, 2))
                       ELSE
                           0
                   END
               )                                                                                  AS [RC25_16],
            2                                                                                     AS [RC25_17]
        FROM
            dbo.FI_Transfer WITH (NOLOCK)
            JOIN
                dbo.FI_TransferFactura WITH (NOLOCK)
                    ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
            JOIN
                dbo.FI_PedimentoComprobante WITH (NOLOCK)
                    ON FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
            JOIN
                dbo.CO_Registro WITH (NOLOCK)
                    ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
            JOIN
                dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
            JOIN
                dbo.CO_Presupuesto WITH (NOLOCK)
                    ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
            JOIN
                dbo.CO_AnioContractual WITH (NOLOCK)
                    ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
            JOIN
                dbo.CO_Contrato WITH (NOLOCK)
                    ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
            JOIN
                dbo.CO_Contratista WITH (NOLOCK)
                    ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
            JOIN
                dbo.FI_Documento WITH (NOLOCK)
                    ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_Documento.IdPedimentoComprobante
            JOIN
                dbo.PV_Subcontratista WITH (NOLOCK)
                    ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
            JOIN
                dbo.PV_TipoMoneda WITH (NOLOCK)
                    ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
            JOIN
                dbo.CO_TipoCambioDiario WITH (NOLOCK)
                    ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
                       AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_PedimentoComprobante.FechaPago)
                       AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_PedimentoComprobante.FechaPago)
                       AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_PedimentoComprobante.FechaPago)
            JOIN
                dbo.PV_MetodoPago WITH (NOLOCK)
                    ON PV_MetodoPago.idMetodoPago = FI_Transfer.IdMetodoPago
            JOIN
                dbo.CO_Servicio SER WITH (NOLOCK)
                    ON SER.IdServicio = CO_LineaPresupuestoMes.IdServicio
        WHERE
            CO_Registro.CvTipoDocFacturacion = 3
            AND CO_Contrato.IdContrato = @Contrato
            AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
            AND CO_Registro.IdEstado = 10004
            AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0
            AND SER.NombreServicio NOT LIKE '%No elegibles%'
            AND ISNULL(FI_PedimentoComprobante.EsnotaCredito, 0) <> 1
            AND CO_Presupuesto.IdPresupuesto = CASE
                                                   WHEN @IdPresupuesto = 0
                                                       THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                   ELSE
                                                       @IdPresupuesto
                                               END
        GROUP BY
            LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
            CO_Contrato.IdRegFiducidiario,
            CO_Contrato.NumeroContrato,
            MONTH(CO_Registro.MesPresentacion),
            YEAR(CO_Registro.MesPresentacion),
            CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf'),
            FI_PedimentoComprobante.HashSHA256,
            LTRIM(RTRIM(FI_PedimentoComprobante.IdDocFacturacionSIPAC)),
            SUBSTRING(LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)), 0, 36),
            PV_MetodoPago.C_FormaPago,
            FI_Transfer.FechaPago,
            SUBSTRING(CO_Contratista.RFC, 0, 13),
            SUBSTRING(CO_Contratista.RazonSocial, 0, 120),
            SUBSTRING(PV_Subcontratista.RazonSocial, 0, 120),
            REPLACE(PV_Subcontratista.RFC, ' ', ''),
            SUBSTRING(REPLACE(ISNULL(FI_PedimentoComprobante.NumFacturaC, 'NA'), ' ', ''), 0, 30),
            FI_PedimentoComprobante.FechaPago;

    END;