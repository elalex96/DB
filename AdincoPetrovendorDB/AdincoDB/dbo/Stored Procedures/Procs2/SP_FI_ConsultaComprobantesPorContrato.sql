-- =============================================
-- Author:		Manuel CD
-- Create date: 05-12-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaComprobantesPorContrato] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish;

         --DECLARE @IdContratista INT;
         --SELECT @IdContratista = CA.IdContratista
         --FROM CO_Contrato C
         --     JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
         --WHERE C.IdContrato = 10016;
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
					Cuando no hay importe total si se toma el precio unitario*/

                --------------------------------------------- DR 06/08/2020
                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'PrecioUnitario', --SUBTOTAL
                PCD.Cantidad,

/*Esta columna posiblemente no sea necesaria, pero se deja para no afectar en codigo
Hace practicamente lo mismo que el subtotal--------------------------------------------------------  DR 06/08/2020    */

                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'ImporteTotal', 
                L.Nombre AS FormaDePago
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
              LEFT JOIN dbo.CO_Contrato C ON PC.IdContrato = C.IdContrato
         WHERE PC.CvTipoDocFacturacion = 3
               --AND C.IdContratista = @IdContratista -- 10005
               AND C.IdContrato = @IdContrato
         GROUP BY PC.IdPedimentoComprobante, 
                  PC.FolioComprobante, 
                  PC.FechaPago, 
                  SE.RazonSocial, 
                  PCD.NumeroSerieMercancia, 
                  PCD.ClaseBienServicio, 
                  MU.UMB+' - '+mu.Unidad, 
                  TM.TipoMonedaCorto, 
                  PCD.Cantidad, 
                  L.Nombre
         ORDER BY IdComprobante DESC;
     END;
