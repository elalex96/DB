
-- p_INV_ValidarConfirmacionRecepcion '1'
create Proc [dbo].[p_INV_ValidarConfirmacionRecepcion]
@pIds varchar(500)
as

	declare @toleranciaSobrePedido decimal(14,2)

	select @toleranciaSobrePedido = isnull(LimiteExcesoEntrada,0)
	from IN_AL_VariablesSistema

	SELECT @toleranciaSobrePedido = CASE WHEN @toleranciaSobrePedido IS NULL THEN 0 ELSE @toleranciaSobrePedido END

	select IdMovimiento = splitdata
	into #tmpRecepciones
	from dbo.fnSplitString(@pIds,',')


	/*************Obtener los movimientos que exederían el pedido**********************/
	SELECT ped.IdPedido,
			pd.IdMaterial,
			CantidadPedido = CAST(isnull(SUM(pd.Cantidad),0) AS DECIMAL(14,2)),
			CantidadPendiente = CAST(isnull(SUM(pd.Cantidad),0) -
						(
							select isnull(SUM(smovD.Cantidad),0)
							from IN_AL_Movimiento smov
							inner join IN_AL_MovimientoDetalle smovD on smovD.IdMovimiento = smov.IdMovimiento							
							where smov.IdPedido = ped.IdPedido and
							smovD.IdMaterial = pd.idMaterial and
							smov.IdUsuarioAutorizo > 0 and
							smov.IsEliminado = 0
						)  AS DECIMAL(14,2)),
			CantidadPorAutorizar = 
						(
							select isnull(SUM(smovD.Cantidad),0)
							from IN_AL_Movimiento smov
							inner join IN_AL_MovimientoDetalle smovD on smovD.IdMovimiento = smov.IdMovimiento							
							inner join #tmpRecepciones st1 on st1.IdMovimiento = smov.idMovimiento
							where smov.IdPedido = ped.IdPedido and
							smovD.IdMaterial = pd.idMaterial 
						),
			ExcesoUnaVezAutorizado = 0,
			PermitirAutorizar = cast(0 as bit)
	into #tmpPedidoCantidades
	FROM  MM_Pedido ped 
	inner join MM_PedidoDetalle pd on pd.IdPedido = ped.IdPedido 
	where ped.IdPedido in (
		select IdPEDIDO FROM IN_AL_Movimiento st1
		inner join #tmpRecepciones st2 on st2.IdMovimiento = st1.idMovimiento
	)	
	group  by ped.IdPedido,
			pd.IdMaterial

		

	update #tmpPedidoCantidades
	set ExcesoUnaVezAutorizado =case when ( CantidadPendiente - CantidadPorAutorizar) < 0.0 then abs(CantidadPendiente - CantidadPorAutorizar) else 0 end

	update #tmpPedidoCantidades
	set PermitirAutorizar = case when (ExcesoUnaVezAutorizado / CantidadPedido) <= (@toleranciaSobrePedido /100) then 1 else 0 end

		
	select distinct Result = 'No es posible autorizar ya que se excedería el límite de material para el pedido:'+ cast(idPedido as varchar)
	from #tmpPedidoCantidades
	WHERE PermitirAutorizar = 0
	

	
	
	

