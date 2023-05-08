---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================
-- Author:        Manuel CD
-- Create date: 25-0817
-- Description:    
-- =============================================
--20180731: Reyna Olvera
--Modificado para mostrar los montos de dicha transferencia correctamente
-- =============================================
--20180912: Reyna Olvera
--MUestra el tipo de cambio diari del día de la factura
-- =============================================
--20190304: Manuel Cruz
--Facturas para contratos de jaguar tabla relacion dbo.FI_FacturaContrato
-- =============================================
--20190329: Manuel Cruz
--Filtro para solo PUE y PPD
-- =============================================
--20191220: Marcos Garcia
--Agregar Numero de Contrato
--Agregar UNION para las facturas que estan en FI_FacturaContrato se muestren al estar en una Transferencia
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Verificacion de NOLOCK, Nombrado de Tablas en select, ajustes de join en orden de llamado de tablas,
--			 eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasProveedorTransfer] --10876,10046,10,33081,1
    @IdSubcontratista INT,
    @IdContrato       INT,
    @IdUsuario        INT,
    @IdTransfer       INT,
    @Accion           INT
AS
    BEGIN
        SET NOCOUNT ON;
        SET LANGUAGE spanish;
        --
        CREATE TABLE #TransferenciasContratoFactura
            (
                IdTransferFactura INT PRIMARY KEY,
                Idtransferencia   int,
                IdFactura         int,
                MontoPagado       FLOAT
            );

        INSERT INTO #TransferenciasContratoFactura
            (
                IdTransferFactura,
                Idtransferencia,
                IdFactura,
                MontoPagado
            )
                    SELECT
                        IdTransferFactura,
                        Idtransferencia,
                        IdFactura,
                        FI_TransferFactura.MontoPagado
                    FROM
                        FI_TransferFactura
                        JOIN
                            FI_Transfer (NOLOCK)
                                ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
                    WHERE
                        FI_Transfer.IdContrato = @IdContrato

        IF (
               @IdTransfer = 0
               AND @Accion = 0
           )
            BEGIN
                SELECT
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END                                              AS FormaPago,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END                                              AS MetodoPago,
                    SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado                                  AS MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio               AS TCD
                FROM
                    dbo.CO_Contrato (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.CO_Contrato.IdContrato = dbo.FI_Factura.IdContrato
                               AND dbo.CO_Contrato.IdContrato = @IdContrato
                               AND dbo.FI_Factura.TipoComprobante <> 'P'
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                               AND dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    LEFT JOIN
                        #TransferenciasContratoFactura TCF (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = TCF.IdFactura
                    LEFT JOIN
                        dbo.CO_TipoCambioDiario (NOLOCK)
                            ON CONVERT(DATE, dbo.FI_Factura.Fecha) = dbo.CO_TipoCambioDiario.Fecha
                               AND dbo.CO_TipoCambioDiario.IdMoneda = 1
                WHERE
                    (
                        dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                        OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                        OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                        OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                    )
                    AND TCF.IdTransferFactura IS NULL
                GROUP BY
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END                                              AS FormaPago,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END                                              AS MetodoPago,
                    SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado                                  AS MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio               AS TCD
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.FI_FacturaContrato (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_FacturaContrato.IdFactura
                               AND dbo.FI_Factura.TipoComprobante <> 'P'
                               AND dbo.FI_FacturaContrato.IdContrato = @IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                               AND dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    LEFT JOIN
                        #TransferenciasContratoFactura TCF (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = TCF.IdFactura
                    LEFT JOIN
                        dbo.CO_TipoCambioDiario (NOLOCK)
                            ON CONVERT(DATE, dbo.FI_Factura.Fecha) = dbo.CO_TipoCambioDiario.Fecha
                               AND dbo.CO_TipoCambioDiario.IdMoneda = 1
                WHERE
                    (
                        dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                        OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                        OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                        OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                    )
                    AND TCF.IdTransferFactura IS NULL
                GROUP BY
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio
                ORDER BY
                    dbo.FI_Factura.IdFactura DESC;
            END;
        IF (
               @IdTransfer <> 0
               AND @Accion <> 0
           )
            BEGIN
                SELECT
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END                                              AS FormaPago,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END                                              AS MetodoPago,
                    SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado                                  AS MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio               AS TCD
                FROM
                    dbo.CO_Contrato (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.CO_Contrato.IdContrato = dbo.FI_Factura.IdContrato
                               AND dbo.CO_Contrato.IdContrato = @IdContrato
                               AND dbo.FI_Factura.TipoComprobante <> 'P'
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        #TransferenciasContratoFactura TCF (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = TCF.IdFactura
                    LEFT JOIN
                        dbo.CO_TipoCambioDiario (NOLOCK)
                            ON CONVERT(DATE, dbo.FI_Factura.Fecha) = dbo.CO_TipoCambioDiario.Fecha
                               AND dbo.CO_TipoCambioDiario.IdMoneda = 1
                WHERE
                    dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    AND dbo.CO_Contrato.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante <> 'P'
                    AND (
                            dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                        )
                    AND TCF.IdTransferFactura IS NULL
                GROUP BY
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END                                              AS FormaPago,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END                                              AS MetodoPago,
                    SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado                                  AS MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio               AS TCD
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.FI_FacturaContrato (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_FacturaContrato.IdFactura
                               AND dbo.FI_Factura.TipoComprobante <> 'P'
                               AND dbo.FI_FacturaContrato.IdContrato = @IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                               AND dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    LEFT JOIN
                        #TransferenciasContratoFactura TCF (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = TCF.IdFactura
                    LEFT JOIN
                        dbo.CO_TipoCambioDiario (NOLOCK)
                            ON CONVERT(DATE, dbo.FI_Factura.Fecha) = dbo.CO_TipoCambioDiario.Fecha
                               AND dbo.CO_TipoCambioDiario.IdMoneda = 1
                WHERE
                    dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    AND dbo.FI_FacturaContrato.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante <> 'P'
                    AND (
                            dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                        )
                    AND TCF.IdTransferFactura IS NULL
                GROUP BY
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END                                              AS FormaPago,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END                                              AS MetodoPago,
                    SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado                                  AS MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio               AS TCD
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.FI_FacturaContrato (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_FacturaContrato.IdFactura
                               AND dbo.FI_Factura.TipoComprobante <> 'P'
                               AND dbo.FI_FacturaContrato.IdContrato = @IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                               AND dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    LEFT JOIN
                        #TransferenciasContratoFactura TCF (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = TCF.IdFactura
                    LEFT JOIN
                        dbo.CO_TipoCambioDiario (NOLOCK)
                            ON CONVERT(DATE, dbo.FI_Factura.Fecha) = dbo.CO_TipoCambioDiario.Fecha
                               AND dbo.CO_TipoCambioDiario.IdMoneda = 1
                WHERE
                    dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    AND dbo.FI_FacturaContrato.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante <> 'P'
                    AND (
                            dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                        )
                    -- AND dbo.FI_TransferFactura.IdTransferFactura IS NULL
                    AND TCF.Idtransferencia = @IdTransfer
                GROUP BY
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END                                              AS FormaPago,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END                                              AS MetodoPago,
                    SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado                                  AS MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio               AS TCD
                FROM
                    dbo.CO_Contrato (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.CO_Contrato.IdContrato = dbo.FI_Factura.IdContrato
                               AND dbo.FI_Factura.TipoComprobante <> 'P'
                               AND dbo.CO_Contrato.IdContrato = @IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                               AND dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    JOIN
                        #TransferenciasContratoFactura TCF (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = TCF.IdFactura
                    LEFT JOIN
                        dbo.CO_TipoCambioDiario (NOLOCK)
                            ON CONVERT(DATE, dbo.FI_Factura.Fecha) = dbo.CO_TipoCambioDiario.Fecha
                               AND dbo.CO_TipoCambioDiario.IdMoneda = 1
                WHERE
                    dbo.PV_Subcontratista.IdSubcontratista = @IdSubcontratista
                    AND dbo.CO_Contrato.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante <> 'P'
                    AND (
                            dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                            OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                        )
                    AND TCF.Idtransferencia = @IdTransfer
                GROUP BY
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.FormaPago
                        WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN dbo.FI_Factura.MetodoPago
                    END,
                    dbo.FI_Factura.NoCertificado,
                    dbo.FI_Factura.CondicionesDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    CASE
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                             OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                            THEN 'PUE'
                        WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                             OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                             OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                             OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                             OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
                            THEN 'PPD'
                    END,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.PV_Subcontratista.RazonSocial,
                    dbo.FI_Factura.Emisor,
                    TCF.MontoPagado,
                    dbo.CO_TipoCambioDiario.TipoCambio
                ORDER BY
                    dbo.FI_Factura.IdFactura DESC;
            END;
    END;


