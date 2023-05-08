CREATE  Proc sp_IN_AL_ConsultaDocumentosGeneral
@pIdAlmacen int,
@pIdPedido int,
@pIdMovimiento int
As

	
	select pd.IdPedido,IdMaterial =pd.IdMaterial,CantidadRecibida = Sum(md.Cantidad)
	into #tmpRecepcionesAnt
	from IN_AL_MovimientoDetalle md
	inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = md.IdPedidoDetalle
	inner join IN_AL_Movimiento m on m.IdMovimiento = md.IdMovimiento
	where pd.IdPedido = @pIdPedido AND
	m.IsEliminado = 0 AND
	m.IdUsuarioAutorizo > 0
	group by  pd.IdPedido,pd.IdMaterial


	--select * from #tmpRecepcionesAnt

	select 
		ROW_NUMBER() OVER(ORDER BY p.IdPedido ASC) AS ID_ROW,
		IdMovimientoDetalle = isnull(md.IdMovimientoDetalle,0),
		p.IdPedido,
		pd.IdPedidoDetalle		
		INTO #IdesDocumentos
	from MM_Pedido p
	inner join MM_PedidoDetalle pd on pd.idPedido = p.idPedido
	inner join MM_Material m on m.IdMaterial = pd.IdMaterial
	left join [PV_MM_MaterialUnidad] u on u.IdUnidad = m.IdUnidad
	left join #tmpRecepcionesAnt recAnt on recAnt.IdMaterial =  pd.IdMaterial
	left join IN_AL_MovimientoDetalle md on md.IdMovimiento = @pIdMovimiento and
									md.IdPedidoDetalle = pd.IdPedidoDetalle
	where p.IdPedido = @pIdPedido
	order by p.IdPedido,pd.Posicion

	--SELECT IdMovimientoDetalle FROM #IdesDocumentos
	--sp_IN_AL_Det_ConsultarDocumentos

	select 
	awsd.UUIDAmazon
	, awsd.Folder
	, awsd.Bucket
	, awsd.NombreArchivo
	from IN_AL_MovimientoDetalleDoc as md
	join IN_AL_AWS_Documentos as awsd on md.IdDocumento = awsd.AWSDocumentoId
	where IdMovimientoDetalle in (SELECT IdMovimientoDetalle FROM #IdesDocumentos)