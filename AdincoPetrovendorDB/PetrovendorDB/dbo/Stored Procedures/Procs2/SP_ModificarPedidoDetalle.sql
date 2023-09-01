USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ModificarPedidoDetalle'
)
    DROP PROCEDURE SP_ModificarPedidoDetalle;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09/04/2018
-- Description:	ya que vencio la vigencia del pedido se deben de actualizar los materiales, que tenga disponibles y no la que solicito anteriormente
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 31/08/2023
-- Description:	se guarda el historico de la nueva cantidad modificada, la anterior, cuando y quien modifico el detalle del pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_ModificarPedidoDetalle]
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
					  ModificadoEl , IdMoneda, IdMaterialVendedor, IdUnidad, IdUnidadProveedor, NuevaCantidad
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
					   pedidoDetalle.CreadoPor, pedidoDetalle.CreadoEl, @IdUsuario ,
					   GETDATE(), pedidoDetalle.IdMoneda, pedidoDetalle.IdMaterialVendedor ,
					   pedidoDetalle.IdUnidad, pedidoDetalle.IdUnidadProveedor, @ASolicitar
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