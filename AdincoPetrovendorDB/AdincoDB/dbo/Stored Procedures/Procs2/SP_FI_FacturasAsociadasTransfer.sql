IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_FacturasAsociadasTransfer'
)
    DROP PROCEDURE SP_FI_FacturasAsociadasTransfer;
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 14-09-2017
-- Description:	
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajustado de orden en los join, se quitan lefts joins posibles, renombrado por tablas
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasAsociadasTransfer] 
    @IdTran INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @Count INT;

    CREATE TABLE #TablaFacturasAsociadasTransfer
    (
        IdFactura INT,
        TipoComprobante VARCHAR(100),
        Serie VARCHAR(50),
        Folio VARCHAR(50),
        Fecha DATETIME,
        FormaPago VARCHAR(50),
        SubTotal MONEY,
        Moneda VARCHAR(50),
        MontoConIva MONEY,
        MetodoPago VARCHAR(50),
        UUID VARCHAR(100),
        FechaRecepcion DATETIME,
        RazonSocial VARCHAR(100),
        Emisor VARCHAR(100),
        MontoPagado MONEY,
        Row INT
    )

    CREATE TABLE #TablaFacturasAsociadasTransferCP
    (
        IdFactura INT,
        TipoComprobante VARCHAR(100),
        Serie VARCHAR(50),
        Folio VARCHAR(50),
        Fecha DATETIME,
        FormaPago VARCHAR(50),
        SubTotal MONEY,
        Moneda VARCHAR(50),
        MontoConIva MONEY,
        MetodoPago VARCHAR(50),
        UUID VARCHAR(100),
        FechaRecepcion DATETIME,
        RazonSocial VARCHAR(100),
        Emisor VARCHAR(100),
        MontoPagado MONEY,
        Row INT
    )

    INSERT INTO #TablaFacturasAsociadasTransfer
    (
        IdFactura,
        TipoComprobante,
        Serie,
        Folio,
        Fecha,
        FormaPago,
        SubTotal,
        Moneda,
        MontoConIva,
        MetodoPago,
        UUID,
        FechaRecepcion,
        RazonSocial,
        Emisor,
        MontoPagado,
        Row
    )
    SELECT FI_Factura.IdFactura,
           FI_Factura.TipoComprobante,
           FI_Factura.Serie,
           FI_Factura.Folio,
           FI_Factura.Fecha,
           FI_Factura.FormaPago,
           FI_Factura.SubTotal,
           FI_Factura.Moneda,
           FI_Factura.MontoConIva,
           FI_Factura.MetodoPago,
           FI_Factura.UUID,
           FI_Factura.FechaRecepcion,
           PV_Subcontratista.RazonSocial,
           FI_Factura.Emisor,
           SUM(   CASE
                      WHEN FI_ComplementoDePago.IdFactura IS NULL THEN
                          CAST(FI_TransferFactura.MontoPagado AS MONEY)
                      ELSE
                          FI_ComplementoDePago.Monto
                  END
              ) AS MontoPagado,
           ROW_NUMBER() OVER (ORDER BY FI_Factura.IdFactura ASC) AS Row
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura  (NOLOCK)
            ON FI_Transfer.IdTransferencia = @IdTran
               AND FI_Transfer.IdContrato = @IdContrato
               AND FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
        JOIN FI_Factura  (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_Factura.IdFactura
        JOIN PV_Subcontratista (NOLOCK)
            ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
        LEFT JOIN FI_ComplementoDePago  (NOLOCK)
            ON FI_Factura.IdFactura = FI_ComplementoDePago.IdFactura
    GROUP BY FI_Factura.IdFactura,
             FI_Factura.TipoComprobante,
             FI_Factura.Serie,
             FI_Factura.Folio,
             FI_Factura.Fecha,
             FI_Factura.FormaPago,
             FI_Factura.SubTotal,
             FI_Factura.Moneda,
             FI_Factura.MontoConIva,
             FI_Factura.MetodoPago,
             FI_Factura.UUID,
             FI_Factura.FechaRecepcion,
             PV_Subcontratista.RazonSocial,
             FI_Factura.Emisor
    SELECT @Count = COUNT(*)
    FROM #TablaFacturasAsociadasTransfer

    INSERT INTO #TablaFacturasAsociadasTransferCP
    (
        IdFactura,
        TipoComprobante,
        Serie,
        Folio,
        Fecha,
        FormaPago,
        SubTotal,
        Moneda,
        MontoConIva,
        MetodoPago,
        UUID,
        FechaRecepcion,
        RazonSocial,
        Emisor,
        MontoPagado,
        Row
    )
    SELECT FI_Factura.IdFactura,
           FI_Factura.TipoComprobante,
           FI_Factura.Serie,
           FI_Factura.Folio,
           FI_Factura.Fecha,
           FI_Factura.FormaPago,
           FI_Factura.SubTotal,
           FI_Factura.Moneda,
           FI_Factura.MontoConIva,
           FI_Factura.MetodoPago,
           FI_CPDocRelacionado.IdDocumento AS UUID,
           FI_Factura.FechaRecepcion,
           PV_Subcontratista.RazonSocial,
           FI_Factura.Emisor,
           FI_CPDocRelacionado.ImpPagado AS MontoPagado,
           ROW_NUMBER() OVER (ORDER BY FI_Factura.IdFactura ASC) + @Count AS Row
    FROM FI_CPDocRelacionado (NOLOCK) 
        JOIN FI_ComplementoDePago (NOLOCK)
            ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura
        JOIN FI_Transfer (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia 
        JOIN FI_Factura (NOLOCK) 
            ON FI_CPDocRelacionado.IdDocumento = FI_Factura.UUID
        JOIN PV_Subcontratista (NOLOCK) 
            ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
    WHERE FI_Transfer.IdTransferencia = @IdTran
          AND FI_Transfer.IdContrato = @IdContrato
    GROUP BY FI_Factura.IdFactura,
             FI_Factura.TipoComprobante,
             FI_Factura.Serie,
             FI_Factura.Folio,
             FI_Factura.Fecha,
             FI_Factura.FormaPago,
             FI_Factura.SubTotal,
             FI_Factura.Moneda,
             FI_Factura.MontoConIva,
             FI_Factura.MetodoPago,
             FI_CPDocRelacionado.IdDocumento,
             FI_Factura.FechaRecepcion,
             PV_Subcontratista.RazonSocial,
             FI_Factura.Emisor,
             FI_CPDocRelacionado.ImpPagado;
    DELETE #TablaFacturasAsociadasTransferCP
    FROM #TablaFacturasAsociadasTransferCP
        JOIN #TablaFacturasAsociadasTransfer
            ON #TablaFacturasAsociadasTransferCP.IdFactura = #TablaFacturasAsociadasTransfer.IdFactura

    INSERT INTO #TablaFacturasAsociadasTransfer
    (
        IdFactura,
        TipoComprobante,
        Serie,
        Folio,
        Fecha,
        FormaPago,
        SubTotal,
        Moneda,
        MontoConIva,
        MetodoPago,
        UUID,
        FechaRecepcion,
        RazonSocial,
        Emisor,
        MontoPagado,
        Row
    )
    SELECT IdFactura,
           TipoComprobante,
           Serie,
           Folio,
           Fecha,
           FormaPago,
           SubTotal,
           Moneda,
           MontoConIva,
           MetodoPago,
           UUID,
           FechaRecepcion,
           RazonSocial,
           Emisor,
           MontoPagado,
           Row
    FROM #TablaFacturasAsociadasTransferCP


    SELECT @Count = COUNT(*)
    FROM #TablaFacturasAsociadasTransfer

    INSERT INTO #TablaFacturasAsociadasTransfer
    (
        IdFactura,
        TipoComprobante,
        Serie,
        Folio,
        Fecha,
        FormaPago,
        SubTotal,
        Moneda,
        MontoConIva,
        MetodoPago,
        UUID,
        FechaRecepcion,
        RazonSocial,
        Emisor,
        MontoPagado,
        Row
    )
    SELECT 0 AS IdFactura,
           '¡NO CARGADO EN ADINCO!' AS TipoComprobante,
           FI_Factura.Serie,
           FI_Factura.Folio,
           FI_Factura.Fecha,
           FI_Factura.FormaPago,
           FI_Factura.SubTotal,
           FI_Factura.Moneda,
           FI_Factura.MontoConIva,
           FI_Factura.MetodoPago,
           FI_CPDocRelacionado.IdDocumento AS UUID,
           FI_Factura.FechaRecepcion,
           '',
           FI_Factura.Emisor,
           FI_CPDocRelacionado.ImpPagado AS MontoPagado,
           ROW_NUMBER() OVER (ORDER BY FI_CPDocRelacionado.IdDocumento ASC) + @Count AS Row
    FROM FI_CPDocRelacionado (NOLOCK)
        JOIN FI_ComplementoDePago (NOLOCK)
            ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_TransferFactura.IdFactura
        JOIN FI_Transfer (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        LEFT JOIN FI_Factura (NOLOCK)
            ON FI_CPDocRelacionado.IdDocumento = FI_Factura.UUID       
    WHERE FI_Transfer.IdTransferencia = @IdTran
          AND FI_Transfer.IdContrato = @IdContrato
          AND FI_Factura.IdFactura IS NULL
    GROUP BY FI_Factura.Serie,
             FI_Factura.Folio,
             FI_Factura.Fecha,
             FI_Factura.FormaPago,
             FI_Factura.SubTotal,
             FI_Factura.Moneda,
             FI_Factura.MontoConIva,
             FI_Factura.MetodoPago,
             FI_CPDocRelacionado.IdDocumento,
             FI_Factura.FechaRecepcion,
             FI_Factura.Emisor,
             FI_CPDocRelacionado.ImpPagado;

    SELECT IdFactura,
           TipoComprobante,
           Serie,
           Folio,
           Fecha,
           FormaPago,
           SubTotal,
           Moneda,
           MontoConIva,
           MetodoPago,
           UUID,
           FechaRecepcion,
           RazonSocial,
           Emisor,
           MontoPagado
    FROM #TablaFacturasAsociadasTransfer
    ORDER BY Row ASC
END;