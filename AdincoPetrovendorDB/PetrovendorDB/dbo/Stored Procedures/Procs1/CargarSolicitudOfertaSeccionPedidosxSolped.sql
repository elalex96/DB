-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 07/02/2020
-- Description:	al darle click en pedidos de la solicitud de oferta se trae la informacion de ese pedido
-- =============================================
CREATE PROCEDURE [dbo].[CargarSolicitudOfertaSeccionPedidosxSolped] --20251,420
@IdSolicitudPedido INT, @IdProveedor INT
AS
	BEGIN
		DECLARE @TablaPedido TABLE(IdPedido int	, IdPedidoGral INT, IdPedidoDetalle INT, RazonSocial NVARCHAR(MAX), Nombre NVARCHAR(MAX), Subtotal FLOAT, TipoMoneda NVARCHAR(100),DescripcionCorta NVARCHAR(MAX), Unidad NVARCHAR(500), Cantidad FLOAT, PrecioUnitario FLOAT,IdSolicitudPedido INT) 
		DECLARE @SumaPedido TABLE(IdPedido INT, TotalPedido FLOAT)

		INSERT INTO @TablaPedido
		SELECT	p.IdPedido,ps.IdPedido AS IdPedidoGeneral, pd.IdPedidoDetalle, prov.RazonSocial, e.Nombre, pd.Subtotal, mon.TipoMonedaCorto ,
				m.DescripcionCorta, u.Unidad, pd.Cantidad, pd.PrecioUnitario,p.IdSolicitudPedido
		FROM	dbo.MM_PedidoDetalle pd
				LEFT JOIN dbo.MM_Pedido p ON p.IdPedido=pd.IdPedido AND ISNULL(p.IdEstatusEliminado, 0)=0
				LEFT JOIN dbo.MM_Material m ON m.IdMaterial=pd.IdMaterial
				LEFT JOIN dbo.PV_MM_MaterialUnidad u ON u.IdUnidad=m.IdUnidad
				LEFT JOIN dbo.PV_TipoMoneda mon ON mon.IdMoneda=pd.IdMoneda
				LEFT JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle=pd.IdPeticionOfertaDetalle
				LEFT JOIN dbo.MM_PeticionOferta po ON po.IdPeticionOferta=p.IdPeticionOferta
													  AND	po.IdPeticionOferta=pod.IdPeticionOferta
				LEFT JOIN dbo.S_Proveedor prov ON po.IdSubcontratista=prov.IdProveedor
				LEFT JOIN dbo.TA_Operacion tao ON tao.IdDocumento=p.IdSolicitudPedido AND  p.Version=tao.NoVersion
				LEFT JOIN dbo.TA_Estatus e ON tao.IdEstatusOperacion=e.IdEstatus
				LEFT JOIN dbo.MM_Pedidos ps ON ps.IdIdentificador=p.IdPedido
											   AND	 ps.IdProveedorCliente = p.IdProveedorCompras
											   AND   ps.IdTipoPedido IN (2, 4, 6) --- Mer, AD, OT
		WHERE	p.IdSolicitudPedido=@IdSolicitudPedido  AND	p.IdProveedorCompras=@IdProveedor
				AND	  ISNULL(pd.IdEstatusEliminado, 0)=0 AND  tao.IdTipoOperacion=9
		ORDER BY p.IdPedido

		INSERT INTO @SumaPedido (IdPedido, TotalPedido)
		SELECT IdPedido, SUM(Subtotal) FROM @TablaPedido
		GROUP BY IdPedido

		SELECT p.IdPedido,
               p.IdPedidoGral,
               p.IdPedidoDetalle,
               p.RazonSocial,
               p.Nombre,
               p.Subtotal,
               p.TipoMoneda,
               p.DescripcionCorta,
               p.Unidad,
               p.Cantidad,
               p.PrecioUnitario,
			   p.IdSolicitudPedido,
               s.TotalPedido FROM @TablaPedido p INNER JOIN @SumaPedido s ON s.IdPedido = p.IdPedido
	END ;



