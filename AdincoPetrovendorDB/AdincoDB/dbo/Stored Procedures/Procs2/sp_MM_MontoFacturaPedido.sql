-- =============================================
-- Author:		Manuel Cruz
-- Create date: 22-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_MM_MontoFacturaPedido]
	-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

         DECLARE @IdSubcontratista INT;
         SELECT @IdSubcontratista = Ca.IdProveedor
         FROM CO_Contrato Co
              JOIN CO_Contratista Ca ON Co.IdContratista = Ca.IdContratista
         WHERE Co.IdContrato = @IdContrato;

    -- Insert statements for procedure here

         SELECT PF.IdPedido,
			 P.IdSubcontratista AS IdSubContratistaPedido,
                P.TotalPedido,
                SUM(MontoConIva) AS TotalFacturasPedido,
                F.IdSubcontratista AS IdSubContratistaFactura,
                S.RazonSocial
         FROM FI_Factura F
              JOIN MM_PedidoFactura PF ON F.IdFactura = PF.IdFactura
              JOIN MM_Pedido P ON P.IdPedido = PF.IdPedido
                                  AND P.IdSubcontratista = @IdSubcontratista
              JOIN PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN MM_PedidoDetalle PD ON PF.IdPedido = PD.IdPedido
         WHERE PD.AceptacionServicio = 0
         GROUP BY PF.IdPedido,
			   P.IdSubcontratista,
                  P.TotalPedido,
                  F.IdSubcontratista,
                  S.RazonSocial
         HAVING SUM(MontoConIva) < P.TotalPedido
	

	--EXEC sp_MM_MontoFacturaPedido 10007
     END;