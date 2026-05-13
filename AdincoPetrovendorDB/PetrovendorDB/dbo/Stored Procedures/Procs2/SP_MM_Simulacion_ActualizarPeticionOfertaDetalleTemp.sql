-- =============================================
-- Author:Daniel AC
-- Create date: 25/10/2019
-- Description:	Actualiza las condiciones de pago temporal de la cotización detalle  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Simulacion_ActualizarPeticionOfertaDetalleTemp]
    -- Add the parameters for the stored procedure here
    @IdSolicitudPedido INT,
    @IdUsuarioCompras INT,
    @IdProveedorCompras INT   
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
   UPDATE POD
   SET POD.DiasCreditoTemp=(CASE WHEN ISNULL(POD.IdCondicionPago,0) =0 THEN 0 ELSE POD.DiasCredito END),
   POD.IdCondicionPagoTemp=(CASE WHEN ISNULL(POD.IdCondicionPago,0) =0 THEN 2 ELSE POD.IdCondicionPago END) --> SI IdCondicionPago ES NULL ENTONCES DEFAULT A CONTADO  SELECT * FROM dbo.MM_CondicionPago WHERE IdCondicionPago=2
   FROM dbo.MM_PeticionOfertaDetalle POD 
   INNER JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta=POD.IdPeticionOferta
   WHERE 
    PO.IdSolicitudPedido=@IdSolicitudPedido	
	AND POD.AddPedidoTemp=1 ---> QUE ESTE EN EL CARRITO
    AND POD.AddValidado = 1 --> QUE ESTE VALIDO
    AND POD.Cotizado = 1     ---> QUE ESTE COTIZADO

END;

