
-- =============================================
-- Author: Manuel Cruz
-- Create date: 2017-04-10
-- Description:  
-- =============================================
-- Modificado:       Marcos Garcia
-- Fecha Modificado: 2020-01-13
-- Description:     *Agregar Validacion de @IdPresupuesto = 0
--                  *Agregar WITH (NOLOCK) en las tablas 
-- =============================================
CREATE PROCEDURE [dbo].[SIPAC_RC_CONT_25_M_IdDoc]
    @Contrato      INT,
    @Mes           DATE,
    @IdPresupuesto INT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        
        /*Verificar día de consulta*/
        IF OBJECT_ID('tempdb..#PedimentoComprobante', 'U') IS NOT NULL
            DROP TABLE #PedimentoComprobante;

        CREATE TABLE #PedimentoComprobante
            (
                IdPedimentoComprobante INT,
                IdContrato             INT,
                CvTipoDocFacturacion   INT,
                SIPAC                  INT
            );

        DECLARE @DiaReporte INT;
        DECLARE @DiaActual INT;
        --
        SELECT
            @DiaReporte = Dia
        FROM
            dbo.AP_Calendario WITH (NOLOCK)
        WHERE
            YEAR(@Mes) = Anio
            AND MONTH(@Mes) = Mes
            AND Descripcion = 'Recepción de Información para el cálculo de contraprestaciones';
        --
        SELECT
            @DiaActual = DAY(GETDATE());


        INSERT INTO #PedimentoComprobante
            (
                IdPedimentoComprobante,
                IdContrato,
                CvTipoDocFacturacion,
                SIPAC
            )
                    SELECT
                        FI_PedimentoComprobante.IdPedimentoComprobante,
                        FI_PedimentoComprobante.IdContrato,
                        FI_PedimentoComprobante.CvTipoDocFacturacion,
                        ROW_NUMBER() OVER (ORDER BY
                                               FI_PedimentoComprobante.FechaPago
                                          ) AS SIPAC
                    FROM
                        dbo.FI_Transfer WITH (NOLOCK)
                        JOIN
                            dbo.FI_TransferFactura WITH (NOLOCK)
                                ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                        JOIN
                            dbo.FI_PedimentoComprobante WITH (NOLOCK)
                                ON FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                        JOIN
                            dbo.CO_Registro WITH (NOLOCK)
                                ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                                   AND CO_Registro.CvTipoDocFacturacion = 3
                                   AND CO_Registro.IdEstado = 10004
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
                                   AND CO_Contrato.IdContrato = @Contrato
                        JOIN
                            dbo.FI_Documento WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_Documento.IdPedimentoComprobante
                        JOIN
                            dbo.FI_PedimentoComprobanteDetalle WITH (NOLOCK)
                                ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
                        JOIN
                            dbo.CO_Servicio WITH (NOLOCK)
                                ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio
                    WHERE
                        CO_Registro.CvTipoDocFacturacion = 3
                        AND CO_Contrato.IdContrato = @Contrato
                        AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Mes
                        AND CO_Registro.IdEstado = 10004
                        AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0
                        AND CO_Servicio.NombreServicio NOT LIKE '%No elegibles%'
                        AND ISNULL(FI_PedimentoComprobante.EsnotaCredito, 0) <> 1
                        AND CO_Presupuesto.IdPresupuesto = CASE
                                                               WHEN @IdPresupuesto = 0
                                                                   THEN CO_LineaPresupuestoMes.IdPresupuesto
                                                               ELSE
                                                                   @IdPresupuesto
                                                           END
                    GROUP BY
                        FI_PedimentoComprobante.IdPedimentoComprobante,
                        FI_PedimentoComprobante.IdContrato,
                        FI_PedimentoComprobante.CvTipoDocFacturacion,
                        FI_PedimentoComprobante.FechaPago;

        --

        UPDATE
            dbo.FI_PedimentoComprobante
        SET
            IdDocFacturacionSIPAC = 'PE-' + LTRIM(REPLICATE('0', 2 - LEN(MONTH(@Mes)))) + LTRIM(MONTH(@Mes))
                                    + LTRIM(YEAR(@Mes)) + '-'
                                    + RIGHT('000000' + CAST(#PedimentoComprobante.SIPAC AS VARCHAR(6)), 6)
        FROM
            FI_PedimentoComprobante	(NOLOCK)
            JOIN
                #PedimentoComprobante
                    ON FI_PedimentoComprobante.IdPedimentoComprobante = #PedimentoComprobante.IdPedimentoComprobante
        WHERE
            FI_PedimentoComprobante.IdPedimentoComprobante = #PedimentoComprobante.IdPedimentoComprobante;

    END;