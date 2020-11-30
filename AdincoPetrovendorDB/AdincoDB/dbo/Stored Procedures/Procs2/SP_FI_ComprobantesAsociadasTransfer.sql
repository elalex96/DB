-- =============================================
-- Author:		Manuel CD
-- Create date: 14-09-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobantesAsociadasTransfer] 
-- Add the parameters for the stored procedure here
@IdTran     INT, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

/*DECLARE @CONTRATISTA INT;
             SELECT @CONTRATISTA = C.IdContratista
             FROM FI_Transfer T
                  JOIN CO_Contrato C ON T.IdContrato = C.IdContrato
                  JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
             WHERE T.IdTransferencia = @IdTran;*/

         --SELECT @CONTRATISTA
         -- Insert statements for procedure here
         SELECT PC.IdPedimentoComprobante AS IdComprobante, 
                PC.FolioComprobante, 
                PC.FechaPago, 
                SE.RazonSocial AS Exportador, 
                PCD.NumeroSerieMercancia, 
                PCD.ClaseBienServicio, 
                MU.UMB+' - '+MU.Unidad AS UnidadMedida, 
                TM.TipoMonedaCorto, 
                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'PrecioUnitario', --SUBTOTAL
                PCD.Cantidad, 
                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'ImporteTotal', 
                L.Nombre AS FormaDePago, 
                TF.MontoPagado
         FROM FI_Transfer T
              JOIN FI_TransferFactura TF ON T.IdTransferencia = TF.IdTransfer
              JOIN FI_PedimentoComprobante PC ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
              LEFT JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
              LEFT JOIN PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
              LEFT JOIN PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
              LEFT JOIN AP_Lista L ON PC.IdFormaPago = L.IdClave
                                      AND IdGrupo = 10001
              LEFT JOIN PV_MM_MaterialUnidad MU ON PCD.IdUnidadMedida = MU.IdUnidad
         --LEFT JOIN CO_Contrato C ON PC.IdContrato = C.IdContrato
         WHERE T.IdTransferencia = @IdTran   --21682 
               AND PC.CvTipoDocFacturacion = 3
               AND T.IdContrato = @IdContrato   --10016--TM01
         GROUP BY PC.IdPedimentoComprobante, 
                  PC.FolioComprobante, 
                  PC.FechaPago, 
                  SE.RazonSocial, 
                  PCD.NumeroSerieMercancia, 
                  PCD.ClaseBienServicio, 
                  MU.UMB+' - '+MU.Unidad, 
                  TM.TipoMonedaCorto, 
                  PCD.Cantidad, 
                  L.Nombre, 
                  TF.MontoPagado; --AND C.IdContratista = @CONTRATISTA
         --SP_FI_ComprobantesAsociadasTransfer 686,1,3
     END;
