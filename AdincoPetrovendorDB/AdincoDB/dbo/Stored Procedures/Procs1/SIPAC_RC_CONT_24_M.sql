-- =============================================  
-- Author:                            Yazmin Glez  
-- Create date:  2017-11-29  
-- Description:    
-- =============================================  
-- Modificado:       Marcos Garcia  
-- Fecha Modificado: 2020-01-13  
-- Description:     *Agregar Validacion de @IdPresupuesto = 0  
--                  *Agregar WITH (NOLOCK) en las tablas   
-- =============================================  
-- Modificado:       Reyna Olvera  
-- Fecha Modificado: 2022-08-18  
-- Description:      SE MODIFICA LA CONSULTA POR DEUDA TECNICA, SE MODIFICA LOS JOINS Y LEFT JOIS DE UBICACIÓN, SE QUITAN ALGUNOS ALIAS  
-- =============================================  
-- Modificado:       Neri del Angel
-- Fecha Modificado: 16 de Febrero del 2023
-- Description:      Se agrega la opción obtener el nuevo campo IDSIPAC desde la tabla CO_Contrato, si este viene vacío o nulo se obtendrá desde la tabla que ya se obtenía anteriormente CO_Contratista
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_24_M]   
    @Contrato      INT,  
    @Mes           DATE,  
    @IdPresupuesto INT          = 0,  
    @Plantilla     VARCHAR(150) = ''  
AS  
    BEGIN  
        SET NOCOUNT ON;  
  
  
        /*Generar nombre de archivos*/  
  
        EXEC [SIPAC_RC_CONT_24_M_IdDoc]  
            @Contrato,  
            @Mes,  
            @IdPresupuesto;  
  
        /**/  
  
        SELECT  
            CASE
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN
                    LTRIM(RTRIM(CO_Contrato.IDSIPAC))
                ELSE
                    LTRIM(RTRIM(CO_Contratista.IDSIPAC))
            END									                                             AS [RF_00],  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario))                                      AS [RI_00],  
            CO_Contrato.NumeroContrato                                                       AS [RF01_01],  
            MONTH(CO_Registro.MesPresentacion)                                               AS [RC24_00], --LTRIM(REPLICATE('0', 2-LEN(MONTH(R.MesPresentacion))))+LTRIM(MONTH(R.MesPresentacion)) AS [RC24_00],  
  
            YEAR(CO_Registro.MesPresentacion)                                                AS [RC24_01],  
            CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf') AS [RC24_02],  
            FI_PedimentoComprobante.HashSHA256                                               AS [RC24_03],  
            LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.NumeroPedimento, 0, 20)))          AS [RC24_04],  
            LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.AcuseElectronico, 0, 12)))         AS [RC24_05],  
            CASE  
                WHEN ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0) <> 0  
                    THEN CAST(ROUND(  
                                       (ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0)  
                                        / CO_TipoCambioDiario.TipoCambio  
                                       ), 2  
                                   ) AS DECIMAL(15, 2))  
                ELSE  
                    0  
            END                                                                              AS [RC24_06],  
            FI_PedimentoComprobanteDetalle.ImporteTotal                                      AS [RC24_07],  
            LTRIM(RTRIM(SUBSTRING(FI_ClavesPedimento.Clave, 0, 16)))                         AS [RC24_08],  
            FI_CFDIMetodoPago.Clave                                                          AS [RC24_09],  
            FI_Transfer.FechaPago                                                            AS [RC24_10],  
            FI_PedimentoComprobante.Regimen                                                  AS [RC24_11],  
            LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RFC, 0, 13)))                            AS [RC24_12],  
            FI_PedimentoComprobante.AduanaES                                                 AS [RC24_13],  
            LTRIM(RTRIM(SUBE.RFC))                                                           AS [RC24_14],  
            LTRIM(RTRIM(SUBE.RazonSocial))                                                   AS [RC24_15],  
            LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante))                           AS [RC24_16],  
            FI_PedimentoComprobante.FechaPago                                                AS [RC24_17],  
            FI_PedimentoComprobanteDetalle.ImporteTotal                     AS [RC24_18],  
            CASE  
                WHEN ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0) <> 0  
                    THEN CAST(ROUND(  
                                       (ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0)  
                                        / CO_TipoCambioDiario.TipoCambio  
                                       ), 2  
                                   ) AS DECIMAL(15, 2))  
                ELSE  
                    0  
            END                                                                              AS [RC24_19],  
            2                                                                                AS [RC24_20]  
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
                    ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante  
                       AND CO_Registro.CvTipoDocFacturacion = 2  
                       AND CO_Registro.IdEstado = 10004  
            JOIN  
                dbo.CO_LineaPresupuestoMes WITH (NOLOCK)  
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes  
            JOIN  
                dbo.CO_Presupuesto WITH (NOLOCK)  
                    ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto  
            JOIN  
                dbo.CO_AnioContractual WITH (NOLOCK)  
                    ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual  
            JOIN  
                dbo.CO_Contrato WITH (NOLOCK)  
                    ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato  
                       AND CO_Contrato.IdContrato = @Contrato  
            JOIN  
                dbo.CO_Contratista WITH (NOLOCK)  
                    ON CO_Contrato.IdContratista = CO_Contratista.IdContratista  
            JOIN  
                dbo.FI_PedimentoComprobanteDetalle WITH (NOLOCK)  
                    ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante  
            JOIN  
                dbo.PV_Subcontratista WITH (NOLOCK)  
                    ON FI_PedimentoComprobante.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista  
            JOIN  
                dbo.PV_TipoMoneda WITH (NOLOCK)  
                    ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda  
            JOIN  
                dbo.FI_CFDIMetodoPago WITH (NOLOCK)  
                    ON FI_Transfer.IdMetodoPago = FI_CFDIMetodoPago.IdCFDIMetodoPago  
            JOIN  
                dbo.PV_Subcontratista SUBE WITH (NOLOCK)  
                    ON FI_PedimentoComprobante.IdSubcontratistaExportador = SUBE.IdSubcontratista  
            JOIN  
                dbo.FI_ClavesPedimento WITH (NOLOCK)  
                    ON FI_PedimentoComprobante.ClavePedimento = FI_ClavesPedimento.IdPedimento  
            JOIN  
                dbo.CO_Servicio WITH (NOLOCK)  
                    ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio  
            LEFT JOIN  
                dbo.CO_TipoCambioDiario WITH (NOLOCK)  
                    ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda  
                       AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_PedimentoComprobante.FechaPago)  
                       AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_PedimentoComprobante.FechaPago)  
                       AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_PedimentoComprobante.FechaPago)  
        WHERE  
            CO_Registro.CvTipoDocFacturacion = 2  
            AND CO_Contrato.IdContrato = @Contrato  
            AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes  
            AND CO_Registro.IdEstado = 10004  
            AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0  
            AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'  
            AND CO_Presupuesto.IdPresupuesto = CASE  
                                                   WHEN @IdPresupuesto = 0  
                                                       THEN CO_LineaPresupuestoMes.IdPresupuesto  
                                                   ELSE  
                                                       @IdPresupuesto  
                                               END  
        GROUP BY  
            CASE
                WHEN ISNULL(CO_Contrato.IDSIPAC, '') <> '' THEN
                    LTRIM(RTRIM(CO_Contrato.IDSIPAC))
                ELSE
                    LTRIM(RTRIM(CO_Contratista.IDSIPAC))
            END,  
            LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),  
            CO_Contrato.NumeroContrato,  
            MONTH(CO_Registro.MesPresentacion),  
            YEAR(CO_Registro.MesPresentacion),  
            CONCAT(REPLACE(FI_PedimentoComprobante.IdDocFacturacionSIPAC, '-', '_'), '.pdf'),  
            FI_PedimentoComprobante.HashSHA256,  
            LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.NumeroPedimento, 0, 20))),  
            LTRIM(RTRIM(SUBSTRING(FI_PedimentoComprobante.AcuseElectronico, 0, 12))),  
            CASE  
                WHEN ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0) <> 0  
                    THEN CAST(ROUND(  
                                       (ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0)  
                                        / CO_TipoCambioDiario.TipoCambio  
                                       ), 2  
                                   ) AS DECIMAL(15, 2))  
                ELSE  
                    0  
            END,  
            FI_PedimentoComprobanteDetalle.ImporteTotal,  
            LTRIM(RTRIM(SUBSTRING(FI_ClavesPedimento.Clave, 0, 16))),  
            FI_CFDIMetodoPago.Clave,  
            FI_Transfer.FechaPago,  
            FI_PedimentoComprobante.Regimen,  
            LTRIM(RTRIM(SUBSTRING(PV_Subcontratista.RFC, 0, 13))),  
            FI_PedimentoComprobante.AduanaES,  
            LTRIM(RTRIM(SUBE.RFC)),  
            LTRIM(RTRIM(SUBE.RazonSocial)),  
            LTRIM(RTRIM(FI_PedimentoComprobante.FolioComprobante)),  
            FI_PedimentoComprobante.FechaPago,  
            FI_PedimentoComprobanteDetalle.ImporteTotal,  
            CASE  
                WHEN ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0) <> 0  
                    THEN CAST(ROUND(  
                                       (ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0)  
                                        / CO_TipoCambioDiario.TipoCambio  
                                       ), 2  
                                   ) AS DECIMAL(15, 2))  
                ELSE  
                    0  
            END;  
    END;  