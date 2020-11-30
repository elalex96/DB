-- =============================================
-- Author:		Manuel CD
-- Create date: 14-09-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_PedimentosAsociadasTransfer] 
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
     WHERE T.IdTransferencia = @IdTran*/

--SELECT @CONTRATISTA

    -- Insert statements for procedure here
             SELECT PC.IdPedimentoComprobante AS IdPedimento,
                    PC.NumeroPedimento,
                    CP.Clave AS ClavePedimento,
                    PC.FolioComprobante,
                    PC.FechaPago,
                    PC.Regimen,
                    SI.RazonSocial AS Importador,
                    PC.AduanaES,
                    SE.RazonSocial AS Exportador,
                    PC.AcuseElectronico,
                    PCD.DescripcionMercancia,
                    TM.TipoMonedaCorto,
                    PCD.PrecioUnitario,
                    PCD.Cantidad,
                    TF.MontoPagado
             FROM FI_Transfer AS T
                  JOIN FI_TransferFactura AS TF ON T.IdTransferencia = TF.IdTransfer
                  LEFT JOIN FI_PedimentoComprobante AS PC ON TF.IdPedimentoComprobante = PC.IdPedimentoComprobante
                  LEFT JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                  JOIN PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
                  JOIN PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
                  --LEFT JOIN CO_Contrato AS C ON T.IdContrato = C.IdContrato
                  LEFT JOIN FI_ClavesPedimento CP ON PC.ClavePedimento = CP.IdPedimento
                  LEFT JOIN PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
             WHERE T.IdTransferencia = @IdTran
                   AND PC.CvTipoDocFacturacion = 2
				   AND T.IdContrato = @IdContrato
             GROUP BY PC.IdPedimentoComprobante,
                      PC.NumeroPedimento,
                      CP.Clave,
                      PC.FolioComprobante,
                      PC.FechaPago,
                      PC.Regimen,
                      SI.RazonSocial,
                      PC.AduanaES,
                      SE.RazonSocial,
                      PC.AcuseElectronico,
                      PCD.DescripcionMercancia,
                      TM.TipoMonedaCorto,
                      PCD.PrecioUnitario,
                      PCD.Cantidad,
                      TF.MontoPagado; --AND C.IdContratista = @CONTRATISTA

	    --SP_FI_PedimentosAsociadasTransfer 689,1,3
         END;
