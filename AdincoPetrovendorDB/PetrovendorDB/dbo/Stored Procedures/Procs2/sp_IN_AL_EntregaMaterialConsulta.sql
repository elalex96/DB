

-- sp_IN_AL_EntregaMaterialConsulta 1,1,'1134,1140'
Create Proc [dbo].[sp_IN_AL_EntregaMaterialConsulta]
@pIdAlmacen int,
@pIdMovimiento int,
@pIdsPedido varchar(250)
as

	create table #tmpPedidos
	(
		 IdPedido int
	)

	insert into #tmpPedidos
	select splitdata
	from [dbo].[fnSplitString](@pIdsPedido,',') 

	select pd.IdPedidoDetalle,
		pd.IdPedido,
		pd.IdMaterial,
		IdUnidad=isnull(u.IdUnidad,0),
		NombreUnidad = isnull(u.NombreUnidad,'SIN ESPECIFICAR'),
		pd.IdPeticionOfertaDetalle,
		pd.Posicion,
		pd.PrecioUnitario,
		pd.Cantidad,
		pd.PorcentajeIVA,
		pd.Subtotal,
		pd.Activo,
		pd.ComentariosCompras,
		pd.Entregado,
		pd.AceptacionServicio,
		pd.RecepcionPedido,
		pd.FechaAceptacionServicio,
		pd.IdUsuarioAceptacionServicio,
		pd.FechaRecepcionPedido,
		pd.IdUsuarioRecepcionServicio,
		pd.ComentarioAceptacionServicio,
		pd.PorcentajeContenidoNacional,
		pd.PorcentajeContenidoExtranjero,
		pd.IsBienServicioNacional,
		pd.CreadoPor,
		pd.CreadoEl,
		pd.ModificadoPor,
		pd.ModificadoEl,
		pd.IdMoneda,
		pd.IdMaterialVendedor
	from MM_Pedido ped
	inner join MM_PedidoDetalle pd on pd.IdPedido = ped.IdPedido
	inner join MM_Material m on m.IdMaterial = pd.IdMaterialVendedor
	left join MM_Unidad u on u.IdUnidad = m.IdUnidad
	inner join #tmpPedidos tmp on tmp.IdPedido = pd.IdPedido
	order by pd.IdPedido,pd.Posicion




