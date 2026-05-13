-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_MM_FacturasPendientesProveedor]
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

         SELECT F.IdSubcontratista,
                S.RazonSocial,
                F.IdFactura,
                F.Fecha,
                F.MontoConIva,
                P.IdPedido
         FROM MM_PedidoFactura PF
              JOIN MM_Pedido P ON PF.IdPedido = P.IdPedido
                                       AND P.IdSubcontratista = @IdSubcontratista
              JOIN FI_Factura F ON PF.IdFactura = F.IdFactura
              JOIN MM_PedidoDetalle PD ON PF.IdPedido = PD.IdPedido
              LEFT JOIN FI_Documento D ON F.IdFactura = D.IdFactura
              JOIN PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
         WHERE PD.AceptacionServicio = 0
               AND D.Documento IS NULL
               OR D.Documento = ''


         --EXEC sp_MM_FacturasPendientesProveedor 10007
     END;
