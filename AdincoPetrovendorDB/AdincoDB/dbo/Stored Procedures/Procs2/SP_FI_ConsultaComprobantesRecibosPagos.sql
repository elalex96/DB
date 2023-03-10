-- =============================================
-- Author:		Manuel Cruz
-- Create date: 10-05-2018
-- Description:	
-- =============================================
-- Author:		Marcos Garcia 
-- Alter date:  20-12-2018
-- Description:	* Agregar Numero de Contrato
--				* Agregar el Complemento para las facturas de FI_FacturaContrato
-- =============================================
-- Author:		Marcos Garcia
-- Alter date:  09-01-2020
-- Description:	* Agregar MAX() en FechaDePago
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de join en orden de llamado de tablas,
--			eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaComprobantesRecibosPagos]
    @IdProveedor       INT,
    @IdContrato        INT,
    @IdUsuario         INT,
    @IdTransferFacPago INT,
    @IdAccion          INT
AS
    BEGIN
        SET NOCOUNT ON;
        --========================       
        IF OBJECT_ID('tempdb..#IdFacturaComplemento', 'U') IS NOT NULL
            DROP TABLE #IdFacturaComplemento;
        --========================  
        CREATE TABLE #IdFacturaComplemento
            (
                IdFactura   INT,
                FormadePago NVARCHAR(MAX),
                Moneda      NVARCHAR(MAX),
                Monto       MONEY,
                FechaDePago DATETIME
            );
        --========================
        INSERT INTO #IdFacturaComplemento
            (
                IdFactura,
                FormadePago,
                Moneda,
                Monto,
                FechaDePago
            )
                    SELECT
                        dbo.FI_ComplementoDePago.IdFactura,
                        dbo.FI_ComplementoDePago.FormaDePagoP,
                        dbo.FI_ComplementoDePago.MonedaP,
                        dbo.FI_ComplementoDePago.Monto,
                        dbo.FI_ComplementoDePago.FechaDePago
                    FROM
                        dbo.FI_FacturaContrato (NOLOCK)
                        JOIN
                            dbo.FI_Factura (NOLOCK)
                                ON dbo.FI_FacturaContrato.IdFactura = dbo.FI_Factura.IdFactura
                        JOIN
                            dbo.FI_CPDocRelacionado (NOLOCK)
                                ON dbo.FI_Factura.UUID = dbo.FI_CPDocRelacionado.IdDocumento
                        JOIN
                            dbo.FI_ComplementoDePago (NOLOCK)
                                ON dbo.FI_CPDocRelacionado.IdComplementoDePago = dbo.FI_ComplementoDePago.IdComplementoDePago
                    WHERE
                        dbo.FI_FacturaContrato.IdContrato = @IdContrato
                    GROUP BY
                        dbo.FI_ComplementoDePago.IdFactura,
                        dbo.FI_ComplementoDePago.FormaDePagoP,
                        dbo.FI_ComplementoDePago.MonedaP,
                        dbo.FI_ComplementoDePago.Monto,
                        dbo.FI_ComplementoDePago.FechaDePago;

						--Select * from #IdFacturaComplemento
        --========================
        -- Insert statements for procedure here
        IF (
               @IdTransferFacPago = 0
               AND @IdAccion = 0
           )
            BEGIN
                SELECT
                    dbo.FI_Factura.IdFactura                                AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                                AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP                   AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)     AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(dbo.FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaDePago,
                    dbo.FI_ComplementoDePago.MonedaP,
                    SUM(dbo.FI_ComplementoDePago.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_ComplementoDePago (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.FI_ComplementoDePago.IdFactura = dbo.FI_Factura.IdFactura
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        dbo.FI_TransferFactura (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
                    LEFT JOIN
                        dbo.FI_Transfer (NOLOCK)
                            ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
							AND FI_Transfer.IdContrato = @IdContrato
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_Factura.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante = 'P'
                    AND dbo.FI_TransferFactura.IdTransfer IS NULL
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    dbo.FI_ComplementoDePago.MonedaP
                --
                UNION
                --
                SELECT
                    dbo.FI_Factura.IdFactura                                AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                                AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP                   AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)     AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(dbo.FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaDePago,
                    dbo.FI_ComplementoDePago.MonedaP,
                    SUM(dbo.FI_ComplementoDePago.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_ComplementoDePago (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.FI_ComplementoDePago.IdFactura = dbo.FI_Factura.IdFactura
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_Factura.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante = 'P'
                    AND ISNULL(dbo.FI_Factura.VarTransfer, 0) = 1
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    dbo.FI_ComplementoDePago.MonedaP
                ---
                UNION
                ---
                SELECT
                    dbo.FI_Factura.IdFactura                             AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                             AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago                    AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)  AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(#IdFacturaComplemento.FechaDePago AS DATE)) AS FechaDePago,
                    #IdFacturaComplemento.Moneda,
                    SUM(#IdFacturaComplemento.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        #IdFacturaComplemento (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = #IdFacturaComplemento.IdFactura
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        dbo.FI_TransferFactura (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
                    LEFT JOIN
                        dbo.FI_Transfer (NOLOCK)
                            ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
							AND FI_Transfer.IdContrato = @IdContrato
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_TransferFactura.IdTransfer IS NULL
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    #IdFacturaComplemento.Moneda
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura                             AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                             AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago                    AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)  AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(#IdFacturaComplemento.FechaDePago AS DATE)) AS FechaDePago,
                    #IdFacturaComplemento.Moneda,
                    SUM(#IdFacturaComplemento.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        #IdFacturaComplemento (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = #IdFacturaComplemento.IdFactura
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND ISNULL(dbo.FI_Factura.VarTransfer, 0) = 1
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    #IdFacturaComplemento.Moneda
                ORDER BY
                    dbo.FI_Factura.IdFactura DESC;
            END;
        IF (
               @IdTransferFacPago <> 0
               AND @IdAccion <> 0
           )
            BEGIN
                SELECT
                    dbo.FI_Factura.IdFactura                                AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                                AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP                   AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)     AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(dbo.FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaDePago,
                    dbo.FI_ComplementoDePago.MonedaP,
                    SUM(dbo.FI_ComplementoDePago.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_ComplementoDePago (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.FI_ComplementoDePago.IdFactura = dbo.FI_Factura.IdFactura
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        dbo.FI_TransferFactura (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
                    LEFT JOIN
                        dbo.FI_Transfer (NOLOCK)
                            ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_Factura.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante = 'P'
                    AND dbo.FI_TransferFactura.IdTransfer IS NULL
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    dbo.FI_ComplementoDePago.MonedaP
                UNION
                ---
                SELECT
                    dbo.FI_Factura.IdFactura                                AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                                AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP                   AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)     AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(dbo.FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaDePago,
                    dbo.FI_ComplementoDePago.MonedaP,
                    SUM(dbo.FI_ComplementoDePago.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_ComplementoDePago (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.FI_ComplementoDePago.IdFactura = dbo.FI_Factura.IdFactura
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        dbo.FI_TransferFactura (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
                    LEFT JOIN
                        dbo.FI_Transfer (NOLOCK)
                            ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_Factura.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante = 'P'
                    AND dbo.FI_TransferFactura.IdTransfer = @IdTransferFacPago
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    dbo.FI_ComplementoDePago.MonedaP
                UNION
                --
                SELECT
                    dbo.FI_Factura.IdFactura                                AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                                AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP                   AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)     AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(dbo.FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaDePago,
                    dbo.FI_ComplementoDePago.MonedaP,
                    SUM(dbo.FI_ComplementoDePago.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_ComplementoDePago (NOLOCK)
                    JOIN
                        dbo.FI_Factura (NOLOCK)
                            ON dbo.FI_ComplementoDePago.IdFactura = dbo.FI_Factura.IdFactura
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_Factura.IdContrato = @IdContrato
                    AND dbo.FI_Factura.TipoComprobante = 'P'
                    AND ISNULL(dbo.FI_Factura.VarTransfer, 0) = 1
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    dbo.FI_ComplementoDePago.FormaDePagoP,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    dbo.FI_ComplementoDePago.MonedaP
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura                             AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                             AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago                    AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)  AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(#IdFacturaComplemento.FechaDePago AS DATE)) AS FechaDePago,
                    #IdFacturaComplemento.Moneda,
                    SUM(#IdFacturaComplemento.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        #IdFacturaComplemento (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = #IdFacturaComplemento.IdFactura
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        dbo.FI_TransferFactura (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
                    LEFT JOIN
                        dbo.FI_Transfer (NOLOCK)
                            ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
							AND FI_Transfer.IdContrato = @IdContrato
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_TransferFactura.IdTransfer = @IdTransferFacPago
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    #IdFacturaComplemento.Moneda
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura                             AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                             AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago                    AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)  AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(#IdFacturaComplemento.FechaDePago AS DATE)) AS FechaDePago,
                    #IdFacturaComplemento.Moneda,
                    SUM(#IdFacturaComplemento.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        #IdFacturaComplemento (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = #IdFacturaComplemento.IdFactura
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                    LEFT JOIN
                        dbo.FI_TransferFactura (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
                    LEFT JOIN
                        dbo.FI_Transfer (NOLOCK)
                            ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
							AND FI_Transfer.IdContrato = @IdContrato
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND dbo.FI_Transfer.IdTransferencia IS NULL
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    #IdFacturaComplemento.Moneda
                UNION
                SELECT
                    dbo.FI_Factura.IdFactura                             AS IdCompReciboPago,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago                             AS MetodoDePago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago                    AS FormaDePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30)  AS RazonSocial,
                    dbo.FI_Factura.Emisor,
                    MAX(CAST(#IdFacturaComplemento.FechaDePago AS DATE)) AS FechaDePago,
                    #IdFacturaComplemento.Moneda,
                    SUM(#IdFacturaComplemento.Monto)                     AS MontoPagado
                FROM
                    dbo.FI_Factura (NOLOCK)
                    JOIN
                        dbo.CO_Contrato (NOLOCK)
                            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
                    JOIN
                        #IdFacturaComplemento (NOLOCK)
                            ON dbo.FI_Factura.IdFactura = #IdFacturaComplemento.IdFactura
                    JOIN
                        dbo.PV_Subcontratista (NOLOCK)
                            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
                WHERE
                    dbo.FI_Factura.IdSubcontratista = @IdProveedor
                    AND ISNULL(dbo.FI_Factura.VarTransfer, 0) = 1
                GROUP BY
                    SUBSTRING(dbo.PV_Subcontratista.RazonSocial, 0, 30),
                    dbo.FI_Factura.IdFactura,
                    dbo.FI_Factura.Serie,
                    dbo.CO_Contrato.NumeroContrato,
                    dbo.FI_Factura.Folio,
                    dbo.FI_Factura.Fecha,
                    dbo.FI_Factura.FormaPago,
                    dbo.FI_Factura.SubTotal,
                    dbo.FI_Factura.Moneda,
                    dbo.FI_Factura.MontoConIva,
                    dbo.FI_Factura.TipoComprobante,
                    #IdFacturaComplemento.FormadePago,
                    dbo.FI_Factura.LugarExpedicion,
                    dbo.FI_Factura.UUID,
                    dbo.FI_Factura.FechaTimbrado,
                    dbo.FI_Factura.FechaRecepcion,
                    dbo.FI_Factura.Emisor,
                    #IdFacturaComplemento.Moneda
                ORDER BY
                    dbo.FI_Factura.IdFactura DESC;
            END;
    END;
