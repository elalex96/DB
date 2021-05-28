-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Facturas PPD con Varios Complementos de Pago
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VariosComplementosPPD] 
-- ============================================= 
--[SP_FI_VariosComplementosPPD] 3,0
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         IF OBJECT_ID('tempdb..#TemporalCDP', 'U') IS NOT NULL
             DROP TABLE #TemporalCDP;
         -- ============================================= 
         CREATE TABLE #TemporalCDP
         (IdFacturaComplementoDePago INT, 
          UUIDComplementoDePago      NVARCHAR(MAX), 
          UUIDDocRelacionado         NVARCHAR(MAX), 
          IdFacturaDoCRelacionado    INT
         );
         --===================================== 
         INSERT INTO #TemporalCDP
         (IdFacturaComplementoDePago, 
          UUIDComplementoDePago, 
          UUIDDocRelacionado, 
          IdFacturaDoCRelacionado
         )
                SELECT CDP.IdFactura, 
                       F.UUID, 
                       CDPR.IdDocumento, 
                       FDR.IdFactura
                FROM dbo.FI_ComplementoDePago AS CDP
                     JOIN dbo.FI_CPDocRelacionado AS CDPR ON CDPR.IdComplementoDePago = CDP.IdComplementoDePago
                     JOIN dbo.FI_Factura AS F ON F.IdFactura = CDP.IdFactura AND F.IdContrato = @IdContrato
                     LEFT JOIN dbo.FI_Factura AS FDR ON CDPR.IdDocumento = FDR.UUID
               
                GROUP BY CDP.IdFactura, 
                         F.UUID, 
                         CDPR.IdDocumento, 
                         FDR.IdFactura
                ORDER BY CDP.IdFactura DESC;
         -- =============================================        
         SELECT T.UUIDDocRelacionado AS UUID,
                CASE
                    WHEN T.IdFacturaDoCRelacionado IS NULL
                    THEN 'UUID de Factura: ['+CONVERT(NVARCHAR(MAX), T.UUIDDocRelacionado)+']'
                    ELSE 'Id Factura: '+CONVERT(NVARCHAR(MAX), T.IdFacturaDoCRelacionado)+', UUID: ['+CONVERT(NVARCHAR(MAX), UPPER(T.UUIDDocRelacionado))+']'
                END AS PPD
         FROM #TemporalCDP AS T
         GROUP BY T.UUIDDocRelacionado, 
                  T.IdFacturaDoCRelacionado
         HAVING COUNT(T.UUIDDocRelacionado) >= 2
         ORDER BY T.IdFacturaDoCRelacionado DESC;
         -- =============================================

     END;