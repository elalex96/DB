-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-17
-- Description:	Consulta información cabecera Pedido mediante un IdSolicitudPedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaCabeceraPedidoSolPed]
	-- Add the parameters for the stored procedure here
		@IdSolicitudPedido INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

	   
         SELECT 
		 DISTINCT (PV.RazonSocial),
		 PV.RegimenCapital, 
		 PV.Municipio,
		 PV.Entidad,
		 O.Descripcion, 
		 O.FechaRegistro, 
		 SP.IdSolicitudPedido,
		 CONCAT(
		 DE.Calle , ' ' ,
		 DE.NoExterior , ' ' ,
		 DE.NoInterior , ' ' ,
		 DE.Colonia , ' ' ,
		 DE.Municipio , ' ' ,
		 DE.Estado , ' ' ,
		 DE.CP , ' ' ,
		 DE.Referencia )AS DomicilioEntrega,
		 o.IdOperacion
		 FROM MM_Pedido AS P
         INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
         INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = SP.IdProveedor
         INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido 
		 INNER JOIN MM_DomicilioEntregaPedido AS DE ON DE.IdDomicilioEntrega = P.IdDomicilioEntrega
         WHERE  O.IdTipoOperacion = 7 AND SP.IdSolicitudPedido=@IdSolicitudPedido;

     END;

