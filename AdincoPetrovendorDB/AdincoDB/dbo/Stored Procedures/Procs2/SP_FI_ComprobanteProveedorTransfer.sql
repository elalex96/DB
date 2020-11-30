-- =============================================
--20180731: Reyna Olvera
--Modificado para mostrar los montos de dicha transferencia correctamente
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobanteProveedorTransfer]
-- Add the parameters for the stored procedure here
@IdContrato       INT, 
@IdSubcontratista INT, 
@IdUsuario        INT, 
@IdTransfer       INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

/*DECLARE @IdContratista INT;

	    SELECT @IdContratista = C.IdContratista FROM CO_Contrato C
	    JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
	    WHERE IdContrato = @IdContrato*/

         -- Insert statements for procedure here

         SELECT PC.IdPedimentoComprobante AS IdComprobante, 
                PC.FolioComprobante, 
                PC.FechaPago, 
                SE.RazonSocial AS Exportador, 
                PCD.NumeroSerieMercancia, 
                PCD.ClaseBienServicio, 
                MU.UMB+' - '+mu.Unidad AS UnidadMedida, 
                TM.TipoMonedaCorto, 
                ----------------------------------------------------------------------- 
				/*Se suma el importe total pero se deja con el nombre de PrecioUnitario para no afectar en codigo :
					<dx:GridViewDataTextColumn FieldName="PrecioUnitario" Caption="SubTotal" VisibleIndex="10">
				Cuando no hay importe total si se toma el precio unitario   ----------------------------------------------- DRS 04/08/2020    */

                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL --el importe total contempla el precion unitario por la cantidad DRS 04/08/2020 
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'PrecioUnitario', --SUBTOTAL
                ----------------------------------------------------------------------------  
                PCD.Cantidad, 
                ----------------------------------------------------------------------------
                -- Esta columna posiblemente no sea necesaria, pero se deja para no afectar en codigo
                --hace practicamente lo mismo que el subtotal---------------------------------------------------------------
                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'ImporteTotal', 
                -----------------------------------------------------------------------------
                L.Nombre AS FormaDePago, 
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
              LEFT JOIN dbo.AP_Lista L ON PC.IdFormaPago = L.IdClave
                                          AND IdGrupo = 10001
              LEFT JOIN dbo.PV_MM_MaterialUnidad MU ON PCD.IdUnidadMedida = MU.IdUnidad
              LEFT JOIN dbo.FI_Documento D ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
              LEFT JOIN dbo.CO_Contrato C ON PC.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_TransferFactura TR ON TR.IdPedimentoComprobante = PC.IdPedimentoComprobante
                                                     AND (TR.IdTransferFactura IS NULL
                                                          OR TR.IdTransfer = @IdTransfer)
         WHERE PC.CvTipoDocFacturacion = 3
               AND C.IdContrato = @IdContrato --10016--TM01
               AND PC.IdSubcontratistaExportador = @IdSubcontratista--12723 --DRL Engineering, LLC
         GROUP BY PC.IdPedimentoComprobante, 
                  PC.FolioComprobante, 
                  PC.FechaPago, 
                  SE.RazonSocial, 
                  PCD.NumeroSerieMercancia, 
                  PCD.ClaseBienServicio, 
                  MU.UMB+' - '+mu.Unidad, 
                  TM.TipoMonedaCorto, 
                  PCD.Cantidad, 
                  L.Nombre, 
                  UC.Nombre, 
                  PC.CreadoEn, 
                  TR.MontoPagado
         ORDER BY IdComprobante DESC;
     END;
