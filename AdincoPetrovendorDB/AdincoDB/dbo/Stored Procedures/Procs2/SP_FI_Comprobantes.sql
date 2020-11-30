-- =============================================  
-- Author:  Manuel CD  
-- Create date: 15-11-17  
-- Description:   
-- =============================================  
CREATE PROCEDURE [dbo].[SP_FI_Comprobantes]  
-- Add the parameters for the stored procedure here  
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN  
         -- SET NOCOUNT ON added to prevent extra result sets from  
         -- interfering with SELECT statements.  
         SET NOCOUNT ON;

         -- Insert statements for procedure here  

         SELECT PC.IdPedimentoComprobante AS IdComprobante, 
                PC.FolioComprobante, 
                PC.FechaPago, 
                SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador, 
                PCD.NumeroSerieMercancia, 
                PCD.ClaseBienServicio, 
                SUBSTRING(MU.UMB, 0, 30) AS UnidadMedida, 
                TM.TipoMonedaCorto,
                ----------------------------------------------------------------------- 
					/*Se suma el importe total pero se deja con el nombre de PrecioUnitario para no afectar en codigo :
					<dx:GridViewDataTextColumn FieldName="PrecioUnitario" VisibleIndex="9" Caption="Subtotal"> 
					Cuando no hay importe total si se toma el precio unitario*/

                ----------------------------------------------- DR 03/08/2020
                SUM(CASE
                        WHEN PCD.ImporteTotal IS NOT NULL
                        THEN PCD.ImporteTotal
                        ELSE PCD.PrecioUnitario
                    END) AS 'PrecioUnitario', 
                ----------------------------------------------------------------------------  
                PCD.Cantidad,  
                ----------------------------------------------------------------------------
					/*Se envía como nulo ya que no se ocupa y para no afectar en codigo:
					<dx:GridViewDataTextColumn FieldName="ImporteTotal" VisibleIndex="11" Visible="false">*/

                ---------------------- DR 03/08/2020
                NULL AS 'ImporteTotal', 
                L.Nombre AS FormaDePago,
                CASE
                    WHEN D.DocumentoByte IS NULL
                         OR D.DocumentoByte LIKE 0x
                    THEN 'NO CARGADO'
                    ELSE 'Cargado'
                END AS 'Archivo', 
                UC.Nombre AS CreadoPor, 
                PC.CreadoEn, 
                UM.Nombre AS ModificadoPor, 
                PC.ModificadoEn, 
                PC.NumFacturaC,
                CASE
                    WHEN ISNULL(PC.EsnotaCredito, 0) = 0
                    THEN 'No'
                    ELSE 'Si'
                END AS EsnotaCredito
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
         WHERE PC.CvTipoDocFacturacion = 3
               AND PC.IdContrato = @IdContrato
         GROUP BY PC.IdPedimentoComprobante, 
                  PC.FolioComprobante, 
                  PC.FechaPago, 
                  SUBSTRING(SE.RazonSocial, 0, 30), 
                  PCD.NumeroSerieMercancia, 
                  PCD.ClaseBienServicio, 
                  SUBSTRING(MU.UMB, 0, 30), 
                  TM.TipoMonedaCorto, 
                  PCD.Cantidad, 
                  L.Nombre,
                  CASE
                      WHEN D.DocumentoByte IS NULL
                           OR D.DocumentoByte LIKE 0x
                      THEN 'NO CARGADO'
                      ELSE 'Cargado'
                  END, 
                  UC.Nombre, 
                  PC.CreadoEn, 
                  UM.Nombre, 
                  PC.ModificadoEn, 
                  PC.NumFacturaC,
                  CASE
                      WHEN ISNULL(PC.EsnotaCredito, 0) = 0
                      THEN 'No'
                      ELSE 'Si'
                  END
         ORDER BY IdComprobante DESC;
     END;