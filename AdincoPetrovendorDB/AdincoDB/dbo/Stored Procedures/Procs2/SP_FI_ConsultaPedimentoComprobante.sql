-- =============================================
-- Author:		Marcos Garcia
-- Create date: 14-03-2020
-- Description:	Selecion de Datos de Pedimento o Comprobante
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaPedimentoComprobante] 
--[SP_FI_ConsultaPedimentoComprobante] 1159,0,0,0
-- Add the parameters for the stored procedure here
@IdPedimentoComprobante INT, 
@Accion                 INT, 
@IdContrato             INT, 
@IdUsuario              INT
AS
     BEGIN
         --1 Es Comprobante 0 es Pedimento
         IF(@Accion = 1)
             BEGIN
                 SELECT PC.IdSubcontratistaExportador AS IdSubcontratista, 
                        PC.FolioComprobante, 
                        PC.NumFacturaC, 
                        PC.FechaPago, 
                        PCD.ClaseBienServicio, 
                        PC.IdMoneda, 
                        PCD.PrecioUnitario, 
                        PCD.IdUnidadMedida,
						ISNULL(PC.EsnotaCredito,0) AS EsnotaCredito
                 FROM dbo.FI_PedimentoComprobante PC WITH(NOLOCK)
                      LEFT JOIN dbo.FI_PedimentoComprobanteDetalle PCD WITH(NOLOCK) ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                 WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;
             END;
         IF(@Accion = 0)
             BEGIN
                 SELECT PC.IdSubcontratistaExportador, 
                        PC.IdFiscalP, 
                        PC.RazonSocialP, 
                        PC.NumeroPedimento, 
                        PC.ClavePedimento, 
                        PC.FechaPago, 
                        PC.Regimen, 
                        PC.AduanaES, 
                        PCD.DescripcionMercancia, 
                        PC.IdMoneda, 
                        PCD.PrecioUnitario, 
                        PCD.ImporteTotal, 
                        PC.AcuseElectronico,                        
                        PC.FolioComprobante,
						ISNULL(PC.CuentaBancaria,'') CuentaBancaria
                 FROM dbo.FI_PedimentoComprobante PC
                      INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
                 WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;
             END;
     END;