-- =============================================
-- Author:		Daniel Moreno
-- Create date: 2022-03-16
-- Description:	Procedimiento almacenado que obtiene la información de la carta CN ligada a una factura
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	10 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
-- =============================================
-- SP_FI_CCNFactura_CartaCN_Sel 10038,10,140033
CREATE PROC [dbo].[SP_FI_CCNFactura_CartaCN_Sel]
    @IdContrato INT,
    @IdUsuario INT,
    @IdFactura VARCHAR(500)
AS
SELECT DISTINCT
    Petrovendor.dbo.FI_Factura.IdFactura,
    Petrovendor.dbo.FI_Factura.UUID COLLATE SQL_Latin1_General_CP1_CI_AS,
    S_Documento_S3.IdDocumento
FROM Petrovendor.dbo.MM_AceptacionCartaPCN (NOLOCK)
    JOIN Adinco.dbo.FI_Factura FI_Factura_Adinco (NOLOCK)
        ON FI_Factura_Adinco.IdFactura = @IdFactura
    JOIN Petrovendor.dbo.S_Documento_S3 (NOLOCK)
        ON Petrovendor.dbo.MM_AceptacionCartaPCN.IdDocumento = S_Documento_S3.IdDocumento
           AND Petrovendor.dbo.MM_AceptacionCartaPCN.IdEstatus = 2
           AND ISNULL(Petrovendor.dbo.MM_AceptacionCartaPCN.IdEstatusEliminado, 0) <> 1
    JOIN Petrovendor.dbo.MM_AceptacionPedido (NOLOCK)
        ON Petrovendor.dbo.MM_AceptacionCartaPCN.IdAceptacionPedido = Petrovendor.dbo.MM_AceptacionPedido.IdAceptacionPedido
    JOIN Petrovendor.dbo.MM_Pedido (NOLOCK)
        ON Petrovendor.dbo.MM_AceptacionPedido.IdPedido = Petrovendor.dbo.MM_Pedido.IdPedido
           AND Petrovendor.dbo.MM_Pedido.IdContrato = @IdContrato
    JOIN Petrovendor.dbo.S_Proveedor (NOLOCK)
        ON Petrovendor.dbo.MM_Pedido.IdSubcontratista = Petrovendor.dbo.S_Proveedor.IdProveedor
    JOIN Petrovendor.dbo.S_TipoValidacionDoc (NOLOCK)
        ON Petrovendor.dbo.MM_AceptacionCartaPCN.IdEstatus = Petrovendor.dbo.S_TipoValidacionDoc.IdTipoValidacionDoc
    JOIN Petrovendor.dbo.MM_Pedidos (NOLOCK)
        ON Petrovendor.dbo.MM_Pedido.IdPedido = Petrovendor.dbo.MM_Pedidos.IdIdentificador
    LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura (NOLOCK)
        ON Petrovendor.dbo.MM_AceptacionPedido.IdAceptacionPedido = Petrovendor.dbo.MM_AceptacionFactura.IdAceptacionPedido
    LEFT JOIN Petrovendor.dbo.FI_Factura (NOLOCK)
        ON Petrovendor.dbo.MM_AceptacionFactura.IdFactura = Petrovendor.dbo.FI_Factura.IdFactura
           AND Petrovendor.dbo.FI_Factura.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FI_Factura_Adinco.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE Petrovendor.dbo.MM_AceptacionCartaPCN.IdEstatus = 2
      AND ISNULL(Petrovendor.dbo.MM_AceptacionCartaPCN.IdEstatusEliminado, 0) <> 1
      AND Petrovendor.dbo.MM_Pedido.IdContrato = @IdContrato
      AND Petrovendor.dbo.FI_Factura.UUID IS NOT NULL
      AND Petrovendor.dbo.FI_Factura.Activa = 1
      AND ISNULL(Petrovendor.dbo.FI_Factura.IsEliminado, 0) <> 1;