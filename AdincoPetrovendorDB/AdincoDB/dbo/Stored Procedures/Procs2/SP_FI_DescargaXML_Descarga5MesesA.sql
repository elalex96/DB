-- =============================================
-- Author:RO
-- Create date: 03-07-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_DescargaXML_Descarga5MesesA]
-- Add the parameters for the stored procedure here
@IdContrato   INT, 
@Facturas     VARCHAR(MAX), 
@FactTransfer INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         IF @FactTransfer = 1
             BEGIN
                 --=========================================================
                 --Para facturas XML
                 --=========================================================
                 --SELECT F.XML, 
                 --       CONCAT('A10-OC-', PS.IdPedido, '-CDFI-', F.UUID, '.xml') AS ArchivoXML
                 --FROM dbo.FI_Factura F
                 --     LEFT OUTER JOIN Petrovendor.dbo.FI_Factura AS FP WITH(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
                 --                                                                      AND FP.UUID IS NOT NULL
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF WITH(NOLOCK) ON AF.IdFactura = FP.IdFactura
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP WITH(NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_Pedido AS PP WITH(NOLOCK) ON PP.IdPedido = AP.IdPedido
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP WITH(NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido
                 --                                                                                  AND ACP.IdEstatus = 2
                 --                                                                                  AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_Pedidos PS ON PS.IdIdentificador = PP.IdPedido
                 --WHERE F.IdFactura IN
                 --(
                 --    SELECT *
                 --    FROM [fn_FI_StringList2Table](@Facturas)
                 --);
				 
                 SELECT F.XML, 
                        CONCAT(F.IdFactura, '.xml') AS ArchivoXML
                 FROM dbo.FI_Factura F
                 WHERE F.IdFactura IN
                 (
                     SELECT *
                     FROM [fn_FI_StringList2Table](@Facturas)
                 );
				 

             END;
         IF @FactTransfer = 3
             BEGIN
                 --=========================================================
                 --Para facturas PDF
                 --=========================================================
                 --SELECT DocumentoByte, 
                 --       CONCAT('A10-OC-', PS.IdPedido, '-CDFI-', F.UUID, '.pdf') AS ArchivoXML
                 --FROM dbo.FI_Documento D
                 --     JOIN FI_Factura F ON F.IdFactura = D.IdFactura
                 --     LEFT OUTER JOIN Petrovendor.dbo.FI_Factura AS FP WITH(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
                 --                                                                      AND FP.UUID IS NOT NULL
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF WITH(NOLOCK) ON AF.IdFactura = FP.IdFactura
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP WITH(NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_Pedido AS PP WITH(NOLOCK) ON PP.IdPedido = AP.IdPedido
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP WITH(NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido
                 --                                                                                  AND ACP.IdEstatus = 2
                 --                                                                                  AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                 --     LEFT OUTER JOIN Petrovendor.dbo.MM_Pedidos PS ON PS.IdIdentificador = PP.IdPedido
                 --WHERE D.IdFactura IN
                 --(
                 --    SELECT *
                 --    FROM [fn_FI_StringList2Table](@Facturas)
                 --);
                 SELECT DocumentoByte, 
                        CONCAT(F.IdFactura, '.pdf') AS ArchivoXML
                 FROM dbo.FI_Factura F
                      JOIN dbo.FI_Documento D ON D.IdFactura = F.IdFactura
                 WHERE F.IdFactura IN
                 (
                     SELECT *
                     FROM [fn_FI_StringList2Table](@Facturas)
                 );
             END;
         IF @FactTransfer = 2
             BEGIN
                 --=========================================================
                 --Para transferencias PDF
                 --=========================================================
                 SELECT T.PDF, 
                        CONCAT(T.IdTransferencia, '.pdf') AS ArchivoXML
                 --CONCAT('A10-OC-', PS.IdPedido, '-CDFI-', F.uuid, '-PAGO.pdf') AS ArchivoXML
                 FROM dbo.FI_Transfer T
                      JOIN FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
                      JOIN FI_Factura F ON F.IdFactura = TF.IdFactura
                      LEFT OUTER JOIN Petrovendor.dbo.FI_Factura AS FP WITH(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
                                                                                       AND FP.UUID IS NOT NULL
                      LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionFactura AS AF WITH(NOLOCK) ON AF.IdFactura = FP.IdFactura
                      LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP WITH(NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                      LEFT OUTER JOIN Petrovendor.dbo.MM_Pedido AS PP WITH(NOLOCK) ON PP.IdPedido = AP.IdPedido
                      LEFT OUTER JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP WITH(NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                                                   AND ACP.IdEstatus = 2
                                                                                                   AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                      LEFT OUTER JOIN Petrovendor.dbo.MM_Pedidos PS ON PS.IdIdentificador = PP.IdPedido
                 WHERE IdTransferencia IN
                 (
                     SELECT *
                     FROM [fn_FI_StringList2Table](@Facturas)
                 );
             END;
         IF @FactTransfer IN(4, 5)
             BEGIN
                 SELECT DocumentoByte, 
                        CONCAT(PD.IdPedimentoComprobante, '.pdf') AS ArchivoXML
                 FROM dbo.FI_PedimentoComprobante PD
                      JOIN dbo.FI_Documento D ON D.IdPedimentoComprobante = PD.IdPedimentoComprobante
                 WHERE PD.IdPedimentoComprobante IN
                 (
                     SELECT *
                     FROM [fn_FI_StringList2Table](@Facturas)
                 );
             END;
     END;

