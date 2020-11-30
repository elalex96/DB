-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Complementos de Pago
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VariosComplementosPPDPorUUID] 
-- ============================================= 
--[SP_FI_VariosComplementosPPDPorUUID] 
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT, 
@UUID       NVARCHAR(MAX)
AS
     BEGIN
         -- =============================================  
         SELECT CDP.IdFactura, 
                F.UUID
         FROM dbo.FI_ComplementoDePago AS CDP
              JOIN dbo.FI_CPDocRelacionado AS CDPR ON CDPR.IdComplementoDePago = CDP.IdComplementoDePago
              JOIN dbo.FI_Factura AS F ON F.IdFactura = CDP.IdFactura
         WHERE CDPR.IdDocumento = @UUID
         GROUP BY CDP.IdFactura, 
                  F.UUID
         ORDER BY CDP.IdFactura DESC;   
         -- =============================================
     END;