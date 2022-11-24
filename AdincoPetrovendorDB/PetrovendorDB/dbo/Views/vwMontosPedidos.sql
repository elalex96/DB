
create view vwMontosPedidos

as
	select	t1.IdPedido,
			MontoPedido		=	sum(t1.MontoPedido),
			MontoAceptado	=	sum(t1.MontoAceptado)
	from
	(
		select		IdPedido, 
					MontoPedido = sum(Subtotal), 
					MontoAceptado = 0
		from		MM_PedidoDetalle 			
		--where		IdPedido			= IdPedido			
		group by	IdPedido

		union

		SELECT		t1.IdPedido,
					MontoPedido =	 0, 
					MontoAceptado = SUM(t2.Cantidad) * t1.PrecioUnitario
																
		FROM		dbo.MM_PedidoDetalle t1
		JOIN		dbo.MM_AceptacionPedidoDetalle t2
		ON			t1.IdPedidoDetalle = t2.IdPedidoDetalle
		JOIN		dbo.MM_AceptacionPedido t3
		ON			t2.IdAceptacionPedido = t3.IdAceptacionPedido
		WHERE		ISNULL(t3.IdEstatusEliminado, 0) = 0
		GROUP BY	t2.IdPedidoDetalle,
					t1.PrecioUnitario,
					t1.IdPedido
	) as t1
	group by t1.IdPedido
