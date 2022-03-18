-- =============================================
-- Author:		Daniel Moreno
-- Create date: 2022-03-16
-- Description:	Procedimiento almacenado que obtiene la información de la carta CN ligada a una factura
-- =============================================
-- SP_FI_CCNFactura_CartaCN_Sel 10038,10,140033
CREATE PROC SP_FI_CCNFactura_CartaCN_Sel
@IdContrato INT, 
@IdUsuario  INT, 
@IdFactura  VARCHAR(500)
AS

	
	SELECT DISTINCT 
                       FP.IdFactura, 
                       FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS,
					   D.IdDocumento
                FROM Petrovendor.dbo.MM_AceptacionCartaPCN	AS AC (NOLOCK)
					 JOIN FI_Factura FAdinco ON FAdinco.IdFactura = @IdFactura
                     JOIN Petrovendor.dbo.S_Documento_S3	AS D (NOLOCK)
						 ON D.IdDocumento = AC.IdDocumento
						 AND AC.IdEstatus = 2
						 AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                     JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK)
						ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                     JOIN Petrovendor.dbo.MM_Pedido			AS P (NOLOCK)
						ON P.IdPedido = AP.IdPedido
						AND P.IdContrato = @IdContrato
                     JOIN Petrovendor.dbo.S_Proveedor AS PR (NOLOCK)
						ON PR.IdProveedor = P.IdSubcontratista
					 JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD (NOLOCK)
						ON TD.IdTipoValidacionDoc = AC.IdEstatus
                     JOIN Petrovendor.dbo.MM_Pedidos AS PG (NOLOCK)
						ON P.IdPedido = PG.IdIdentificador
                     LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP (NOLOCK)
						ON TP.IdTipoPedido = PG.IdTipoPedido
                     LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
						ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                     LEFT JOIN Petrovendor.dbo.FI_Factura FP (NOLOCK)
						ON FP.IdFactura = AF.IdFactura AND
						   FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FAdinco.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
                WHERE AC.IdEstatus = 2
                      AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                      AND P.IdContrato = @IdContrato
                      AND FP.UUID IS NOT NULL
                      AND FP.Activa = 1
                      AND ISNULL(FP.IsEliminado, 0) <> 1;--*******
