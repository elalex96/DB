-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09/04/2018
-- Description:	ya que vencio la vigencia del pedido se deben de actualizar los materiales, que tenga disponibles y no la que solicito anteriormente
-- =============================================

CREATE PROCEDURE SP_ModificarPedidoDetalle
	( @IdSolicitudPedidoDetalle INT ,
	  @Cantidad FLOAT ,
	  @ASolicitar FLOAT ,
	  @IdPedido INT ,
	  @IdUsuario INT
)
AS
	BEGIN
		IF ( @Cantidad != @ASolicitar )
			BEGIN
				--se agrega al historico antes de modificar el registro de mmpedidodetalle
				INSERT INTO dbo.MM_PedidoDetalleHistorico
					( IdPedidoDetalle, IdPedido, IdMaterial, IdPeticionOfertaDetalle, Posicion, PrecioUnitario ,
					  Cantidad , PorcentajeIVA, Subtotal, Activo, ComentariosCompras, Entregado, AceptacionServicio ,
					  RecepcionPedido , FechaAceptacionServicio, IdUsuarioAceptacionServicio, FechaRecepcionPedido ,
					  IdUsuarioRecepcionServicio , ComentarioAceptacionServicio, PorcentajeContenidoNacional ,
					  PorcentajeContenidoExtranjero , IsBienServicioNacional, CreadoPor, CreadoEl, ModificadoPor ,
					  ModificadoEl , IdMoneda, IdMaterialVendedor, IdUnidad, IdUnidadProveedor
				)
				SELECT pedidoDetalle.IdPedidoDetalle, pedidoDetalle.IdPedido, pedidoDetalle.IdMaterial ,
					   pedidoDetalle.IdPeticionOfertaDetalle, pedidoDetalle.Posicion, pedidoDetalle.PrecioUnitario ,
					   pedidoDetalle.Cantidad, pedidoDetalle.PorcentajeIVA, pedidoDetalle.Subtotal ,
					   pedidoDetalle.Activo, pedidoDetalle.ComentariosCompras, pedidoDetalle.Entregado ,
					   pedidoDetalle.AceptacionServicio, pedidoDetalle.RecepcionPedido ,
					   pedidoDetalle.FechaAceptacionServicio, pedidoDetalle.IdUsuarioAceptacionServicio ,
					   pedidoDetalle.FechaRecepcionPedido, pedidoDetalle.IdUsuarioRecepcionServicio ,
					   pedidoDetalle.ComentarioAceptacionServicio, pedidoDetalle.PorcentajeContenidoNacional ,
					   pedidoDetalle.PorcentajeContenidoExtranjero, pedidoDetalle.IsBienServicioNacional ,
					   pedidoDetalle.CreadoPor, pedidoDetalle.CreadoEl, pedidoDetalle.ModificadoPor ,
					   pedidoDetalle.ModificadoEl, pedidoDetalle.IdMoneda, pedidoDetalle.IdMaterialVendedor ,
					   pedidoDetalle.IdUnidad, pedidoDetalle.IdUnidadProveedor
				FROM   dbo.MM_SolicitudPedidoDetalle solPedDetalle
				INNER JOIN dbo.MM_PedidoDetalle pedidoDetalle
					ON pedidoDetalle.IdMaterial = solPedDetalle.IdMaterial
				WHERE
					   solPedDetalle.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
					   AND pedidoDetalle.IdPedido = @IdPedido
					   AND pedidoDetalle.Activo = 1

				UPDATE pedidoDetalle
				SET	   pedidoDetalle.Cantidad = @ASolicitar ,
					   pedidoDetalle.Subtotal = @ASolicitar * pedidoDetalle.PrecioUnitario ,
					   pedidoDetalle.ModificadoEl = GETDATE (), pedidoDetalle.ModificadoPor = @IdUsuario
				FROM   dbo.MM_SolicitudPedidoDetalle solPedDetalle
				INNER JOIN dbo.MM_PedidoDetalle pedidoDetalle
					ON pedidoDetalle.IdMaterial = solPedDetalle.IdMaterial
				WHERE
					   solPedDetalle.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
					   AND pedidoDetalle.IdPedido = @IdPedido
					   AND pedidoDetalle.Activo = 1;
			END
	END