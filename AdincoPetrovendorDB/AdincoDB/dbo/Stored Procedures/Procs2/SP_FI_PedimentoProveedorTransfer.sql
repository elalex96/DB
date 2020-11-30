-- =============================================
-- Author:		Manuel CD
-- Create date: 04-12-17
-- Description:	
-- =============================================
--20180731: Reyna Olvera
--Modificado para mostrar los montos de dicha transferencia correctamente
-- =============================================

CREATE PROCEDURE [dbo].[SP_FI_PedimentoProveedorTransfer] 
-- Add the parameters for the stored procedure here
@IdContrato       INT, 
@IdSubcontratista INT, 
@IdUsuario        INT,
@IdTransfer INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

/*DECLARE @IdContratista INT;

	    SELECT @IdContratista = C.IdContratista FROM CO_Contrato C
	    JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
	    WHERE IdContrato = @IdContrato*/

         --SELECT @IdContratista
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
                UC.Nombre AS CreadoPor, 
                PC.CreadoEn, 
                TR.MontoPagado AS MontoPagado
         FROM FI_PedimentoComprobante AS PC
              LEFT JOIN FI_PedimentoComprobanteDetalle AS PCD ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
              LEFT JOIN dbo.PV_Subcontratista SI ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
              LEFT JOIN dbo.PV_Subcontratista SE ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
              LEFT JOIN dbo.PV_TipoMoneda TM ON PC.IdMoneda = TM.IdMoneda
              LEFT JOIN dbo.AP_Usuario UC ON PC.CreadoPor = UC.UsuarioID
              LEFT JOIN dbo.AP_Usuario UM ON PC.ModificadoPor = UM.UsuarioID
              LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
              LEFT JOIN dbo.FI_ClavesPedimento CP ON PC.ClavePedimento = CP.IdPedimento
              LEFT JOIN dbo.CO_Contrato C ON PC.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_TransferFactura TR ON TR.IdPedimentoComprobante = PC.IdPedimentoComprobante AND (TR.IdTransferFactura IS NULL OR TR.IdTransfer=@IdTransfer)
         WHERE PC.CvTipoDocFacturacion = 2
               AND C.IdContrato = @IdContrato --@IdContratista
               AND PC.IdSubcontratistaExportador = @IdSubcontratista
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
                  UC.Nombre, 
                  PC.CreadoEn, 
                  TR.MontoPagado
         ORDER BY IdPedimento DESC;
         --SP_FI_PedimentoProveedorTransfer 3,10058,1
         --SP_FI_PedimentoProveedorTransfer 10003,10802,1
     END;