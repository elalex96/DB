-- =============================================
-- Author:      Manuel Cruz
-- Create date: 22-08-2019
-- Description:    
-- =============================================
-- Author:      Marcos Garcia
-- Create date: 20-12-2019
-- Description: * Agregar Numero de Contrato   
--				* Agregar facturas de FI_FacturaContrato
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select, ajustes de join en orden de llamado de tablas,
--			eliminación de codigo comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasMetodoPago]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT dbo.FI_Factura.IdFactura,
           dbo.FI_Factura.Serie,
           dbo.CO_Contrato.NumeroContrato,
           dbo.FI_Factura.Folio,
           dbo.FI_Factura.Fecha,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%' THEN
                   dbo.FI_Factura.FormaPago
               WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   dbo.FI_Factura.MetodoPago
           END AS FormaPago,
           dbo.FI_Factura.SubTotal,
           dbo.FI_Factura.Moneda,
           dbo.FI_Factura.MontoConIva,
           dbo.FI_Factura.TipoComprobante,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
           dbo.FI_Factura.UUID,
           dbo.FI_Factura.FechaRecepcion,
           dbo.PV_Subcontratista.RazonSocial,
           dbo.FI_Factura.Emisor
    FROM dbo.FI_Factura (NOLOCK)
        JOIN dbo.PV_Subcontratista (NOLOCK)
            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        LEFT JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
    WHERE dbo.CO_Contrato.IdContrato = @IdContrato
          AND dbo.FI_Factura.TipoComprobante <> 'P'
          AND (
                  dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                  OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                  OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
              )
          AND dbo.FI_TransferFactura.IdTransferFactura IS NULL
    GROUP BY dbo.FI_Factura.IdFactura,
             dbo.FI_Factura.Serie,
             dbo.CO_Contrato.NumeroContrato,
             dbo.FI_Factura.Folio,
             dbo.FI_Factura.Fecha,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%' THEN
                     dbo.FI_Factura.FormaPago
                 WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     dbo.FI_Factura.MetodoPago
             END,
             dbo.FI_Factura.SubTotal,
dbo.FI_Factura.Moneda,
             dbo.FI_Factura.MontoConIva,
             dbo.FI_Factura.TipoComprobante,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
             END,
             SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15),
             dbo.FI_Factura.UUID,
             dbo.FI_Factura.FechaRecepcion,
             dbo.PV_Subcontratista.RazonSocial,
             dbo.FI_Factura.Emisor
    UNION
    --
    SELECT dbo.FI_Factura.IdFactura,
           dbo.FI_Factura.Serie,
           dbo.CO_Contrato.NumeroContrato,
           dbo.FI_Factura.Folio,
           dbo.FI_Factura.Fecha,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%' THEN
                   dbo.FI_Factura.FormaPago
               WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   dbo.FI_Factura.MetodoPago
           END AS FormaPago,
           dbo.FI_Factura.SubTotal,
           dbo.FI_Factura.Moneda,
           dbo.FI_Factura.MontoConIva,
           dbo.FI_Factura.TipoComprobante,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
           dbo.FI_Factura.UUID,
           dbo.FI_Factura.FechaRecepcion,
           dbo.PV_Subcontratista.RazonSocial,
           dbo.FI_Factura.Emisor
    FROM dbo.FI_Factura (NOLOCK)
        JOIN dbo.PV_Subcontratista (NOLOCK)
            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        JOIN dbo.FI_FacturaContrato (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_FacturaContrato.IdFactura
        LEFT JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
		 LEFT JOIN 	FI_Transfer
					ON FI_TransferFactura.IdTransfer	=	FI_Transfer.IdTransferencia
					AND FI_Transfer.IdContrato = @IdContrato
    WHERE dbo.FI_FacturaContrato.IdContrato = @IdContrato
          AND dbo.FI_Factura.TipoComprobante <> 'P'
          AND (
                  dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                  OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                  OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
              )
          AND FI_Transfer.IdTransferencia IS NULL
    GROUP BY dbo.FI_Factura.IdFactura,
             dbo.FI_Factura.Serie,
             dbo.CO_Contrato.NumeroContrato,
             dbo.FI_Factura.Folio,
             dbo.FI_Factura.Fecha,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%' THEN
                     dbo.FI_Factura.FormaPago
                 WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     dbo.FI_Factura.MetodoPago
             END,
             dbo.FI_Factura.SubTotal,
             dbo.FI_Factura.Moneda,
             dbo.FI_Factura.MontoConIva,
             dbo.FI_Factura.TipoComprobante,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
             END,
             SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15),
             dbo.FI_Factura.UUID,
             dbo.FI_Factura.FechaRecepcion,
             dbo.PV_Subcontratista.RazonSocial,
             dbo.FI_Factura.Emisor
    UNION
    --
    SELECT dbo.FI_Factura.IdFactura,
           dbo.FI_Factura.Serie,
           dbo.CO_Contrato.NumeroContrato,
           dbo.FI_Factura.Folio,
           dbo.FI_Factura.Fecha,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.FormaPago
               WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.MetodoPago
           END AS FormaPago,
           dbo.FI_Factura.SubTotal,
           dbo.FI_Factura.Moneda,
           dbo.FI_Factura.MontoConIva,
           dbo.FI_Factura.TipoComprobante,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
           dbo.FI_Factura.UUID,
           dbo.FI_Factura.FechaRecepcion,
           dbo.PV_Subcontratista.RazonSocial,
           dbo.FI_Factura.Emisor
    FROM dbo.FI_Factura (NOLOCK)
        JOIN dbo.PV_Subcontratista (NOLOCK)
            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        LEFT JOIN dbo.FI_CPDocRelacionado CPDR (NOLOCK)
            ON dbo.FI_Factura.UUID = CPDR.IdDocumento
        LEFT JOIN dbo.FI_ComplementoDePago CP (NOLOCK)
            ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
        LEFT JOIN dbo.FI_TransferFactura (NOLOCK)
            ON CP.IdFactura = dbo.FI_TransferFactura.IdFactura
    WHERE dbo.CO_Contrato.IdContrato = @IdContrato
          AND dbo.FI_Factura.TipoComprobante <> 'P'
          AND (
                  dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                  OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                  OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                  OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
              )
          AND dbo.FI_TransferFactura.IdTransferFactura IS NULL
    GROUP BY dbo.FI_Factura.IdFactura,
             dbo.FI_Factura.Serie,
             dbo.CO_Contrato.NumeroContrato,
             dbo.FI_Factura.Folio,
             dbo.FI_Factura.Fecha,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.FormaPago
                 WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.MetodoPago
             END,
             dbo.FI_Factura.SubTotal,
             dbo.FI_Factura.Moneda,
             dbo.FI_Factura.MontoConIva,
             dbo.FI_Factura.TipoComprobante,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
             END,
             SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15),
             dbo.FI_Factura.UUID,
             dbo.FI_Factura.FechaRecepcion,
             dbo.PV_Subcontratista.RazonSocial,
             dbo.FI_Factura.Emisor
    UNION
    --
    SELECT dbo.FI_Factura.IdFactura,
           dbo.FI_Factura.Serie,
           dbo.CO_Contrato.NumeroContrato,
           dbo.FI_Factura.Folio,
           dbo.FI_Factura.Fecha,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.FormaPago
               WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.MetodoPago
           END AS FormaPago,
           dbo.FI_Factura.SubTotal,
           dbo.FI_Factura.Moneda,
           dbo.FI_Factura.MontoConIva,
           dbo.FI_Factura.TipoComprobante,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
           dbo.FI_Factura.UUID,
           dbo.FI_Factura.FechaRecepcion,
           dbo.PV_Subcontratista.RazonSocial,
           dbo.FI_Factura.Emisor
    FROM dbo.FI_Factura (NOLOCK)
        JOIN dbo.PV_Subcontratista (NOLOCK)
            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        JOIN dbo.FI_FacturaContrato (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_FacturaContrato.IdFactura
        LEFT JOIN dbo.FI_CPDocRelacionado CPDR (NOLOCK)
            ON dbo.FI_Factura.UUID = CPDR.IdDocumento
        LEFT JOIN dbo.FI_ComplementoDePago CP (NOLOCK)
            ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
        LEFT JOIN dbo.FI_TransferFactura (NOLOCK)
            ON CP.IdFactura = dbo.FI_TransferFactura.IdFactura
		LEFT JOIN 	FI_Transfer
					ON FI_TransferFactura.IdTransfer	=	FI_Transfer.IdTransferencia
					AND FI_Transfer.IdContrato = @IdContrato
    WHERE dbo.FI_FacturaContrato.IdContrato = @IdContrato
          AND dbo.FI_Factura.TipoComprobante <> 'P'
          AND (
                  dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                  OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                  OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                  OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
              )
          AND FI_Transfer.IdTransferencia IS NULL
    GROUP BY dbo.FI_Factura.IdFactura,
             dbo.FI_Factura.Serie,
             dbo.CO_Contrato.NumeroContrato,
             dbo.FI_Factura.Folio,
             dbo.FI_Factura.Fecha,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.FormaPago
                 WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.MetodoPago
             END,
             dbo.FI_Factura.SubTotal,
             dbo.FI_Factura.Moneda,
             dbo.FI_Factura.MontoConIva,
             dbo.FI_Factura.TipoComprobante,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
             END,
             SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15),
             dbo.FI_Factura.UUID,
             dbo.FI_Factura.FechaRecepcion,
             dbo.PV_Subcontratista.RazonSocial,
             dbo.FI_Factura.Emisor
    UNION
    --
    SELECT dbo.FI_Factura.IdFactura,
           dbo.FI_Factura.Serie,
           dbo.CO_Contrato.NumeroContrato,
           dbo.FI_Factura.Folio,
           dbo.FI_Factura.Fecha,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.FormaPago
               WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.MetodoPago
           END AS FormaPago,
           dbo.FI_Factura.SubTotal,
           dbo.FI_Factura.Moneda,
           dbo.FI_Factura.MontoConIva,
           dbo.FI_Factura.TipoComprobante,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
           dbo.FI_Factura.UUID,
           dbo.FI_Factura.FechaRecepcion,
           dbo.PV_Subcontratista.RazonSocial,
           dbo.FI_Factura.Emisor
    FROM dbo.FI_Factura (NOLOCK)
        JOIN dbo.PV_Subcontratista (NOLOCK)
            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        LEFT JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
    WHERE dbo.CO_Contrato.IdContrato = @IdContrato
          AND dbo.FI_Factura.TipoComprobante <> 'P'
          AND (
                  dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                  OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                  OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                  OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
              )
          AND dbo.FI_TransferFactura.IdTransferFactura IS NULL
    GROUP BY dbo.FI_Factura.IdFactura,
             dbo.FI_Factura.Serie,
             dbo.CO_Contrato.NumeroContrato,
             dbo.FI_Factura.Folio,
             dbo.FI_Factura.Fecha,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
       OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.FormaPago
                 WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.MetodoPago
             END,
             dbo.FI_Factura.SubTotal,
             dbo.FI_Factura.Moneda,
             dbo.FI_Factura.MontoConIva,
             dbo.FI_Factura.TipoComprobante,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
             END,
             SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15),
             dbo.FI_Factura.UUID,
             dbo.FI_Factura.FechaRecepcion,
             dbo.PV_Subcontratista.RazonSocial,
             dbo.FI_Factura.Emisor
    UNION
    --
    SELECT dbo.FI_Factura.IdFactura,
           dbo.FI_Factura.Serie,
           dbo.CO_Contrato.NumeroContrato,
           dbo.FI_Factura.Folio,
           dbo.FI_Factura.Fecha,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.FormaPago
               WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   dbo.FI_Factura.MetodoPago
           END AS FormaPago,
           dbo.FI_Factura.SubTotal,
           dbo.FI_Factura.Moneda,
           dbo.FI_Factura.MontoConIva,
           dbo.FI_Factura.TipoComprobante,
           CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
           dbo.FI_Factura.UUID,
           dbo.FI_Factura.FechaRecepcion,
           dbo.PV_Subcontratista.RazonSocial,
           dbo.FI_Factura.Emisor
    FROM dbo.FI_Factura (NOLOCK)
        JOIN dbo.PV_Subcontratista (NOLOCK)
            ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        JOIN dbo.FI_FacturaContrato (NOLOCK)
            ON dbo.FI_Factura.IdContrato = dbo.FI_FacturaContrato.IdContrato
        LEFT JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
		LEFT JOIN 	FI_Transfer
					ON FI_TransferFactura.IdTransfer	=	FI_Transfer.IdTransferencia
					AND FI_Transfer.IdContrato = @IdContrato
    WHERE dbo.FI_FacturaContrato.IdContrato = @IdContrato
          AND dbo.FI_Factura.TipoComprobante <> 'P'
          AND (
                  dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                  OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                  OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                  OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                  OR dbo.FI_Factura.FormaPago LIKE '%PPD%'
              )
          AND FI_Transfer.IdTransferencia IS NULL
    GROUP BY dbo.FI_Factura.IdFactura,
             dbo.FI_Factura.Serie,
             dbo.CO_Contrato.NumeroContrato,
             dbo.FI_Factura.Folio,
             dbo.FI_Factura.Fecha,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.FormaPago
                 WHEN dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     dbo.FI_Factura.MetodoPago
             END,
             dbo.FI_Factura.SubTotal,
             dbo.FI_Factura.Moneda,
             dbo.FI_Factura.MontoConIva,
             dbo.FI_Factura.TipoComprobante,
             CASE
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                      OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                      OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                      OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                      OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                      OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
             END,
             SUBSTRING(dbo.FI_Factura.LugarExpedicion, 0, 15),
             dbo.FI_Factura.UUID,
             dbo.FI_Factura.FechaRecepcion,
             dbo.PV_Subcontratista.RazonSocial,
             dbo.FI_Factura.Emisor
    ORDER BY MetodoPago,
             dbo.FI_Factura.Fecha DESC;
END;
