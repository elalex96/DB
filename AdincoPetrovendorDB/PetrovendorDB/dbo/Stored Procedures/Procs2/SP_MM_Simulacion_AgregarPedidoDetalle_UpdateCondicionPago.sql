-- =============================================
-- Author:Daniel AC
-- Create date: 25/10/2019
-- Description:	Simula el pedido detalle, actualizar las referencias de la pod 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Simulacion_AgregarPedidoDetalle_UpdateCondicionPago]
    -- Add the parameters for the stored procedure here
    @IdSolicitudPedido INT,
    @IdUsuarioCompras INT,
    @IdProveedorCompras INT,
    @IdContrato INT, 
	@IdMoneda INT,
	@IdProveedorVenta INT,
	@IdPeticionOferta INT,
	@IdPeticionOfertaDetalle INT,	
	@IdCondicionPago INT,
	@DiasCredito INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
   UPDATE POD
   SET POD.DiasCreditoTemp=@DiasCredito,
   POD.IdCondicionPagoTemp =@IdCondicionPago
   FROM dbo.MM_PeticionOfertaDetalle POD 
	INNER JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta=POD.IdPeticionOferta
   WHERE PO.IdPeticionOferta=@IdPeticionOferta
	AND POD.IdMoneda=@IdMoneda
	AND PO.IdSubcontratista=@IdProveedorVenta
	AND PO.IdSolicitudPedido=@IdSolicitudPedido
	AND POD.IdPeticionOfertaDetalle=@IdPeticionOfertaDetalle
	AND POD.AddPedidoTemp=1 ---> QUE ESTE EN EL CARRITO
    AND POD.AddValidado = 1
    AND POD.Cotizado = 1    
 
END;

