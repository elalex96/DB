
-- sp_IN_AL_AutorizarRecepcion 5,2326,''
create Proc [dbo].[sp_IN_AL_AutorizarRecepcion]
@pIdMovimiento int,
@pIdUsuario int,
@pCustomError varchar(250) out
as	



	/************VALIDACIONES******************/
	if  exists (
		select 1
		from IN_AL_movimiento
		where IdMovimiento = @pIdMovimiento and
		IdUsuarioAutorizo > 0
	)
	begin 
		set @pCustomError = 'El movimiento ya está autorizado'
		return
	end
	if not exists (
		select 1
		from IN_AL_movimientoDetalle 
		where IdMovimiento = @pIdMovimiento
	)
	begin 
		set @pCustomError = 'No es1 posible Autorizar un movimiento ID:'+cast(@pIdMovimiento as varchar)+' sin materiales'
		return
	end
	

	declare @IdProveedor int,
		@IdPedido int,
		@IdDomicilioEntrega int,
		@IdAceptacionPedido int

	select @IdProveedor = solP.IdProveedor,
		@IdPedido = ped.IdPedido,
		@IdDomicilioEntrega = dom.IdDomicilio
	from IN_AL_Movimiento mov
	inner join IN_AL_MovimientoDetalle md on md.IdMovimiento = mov.IdMovimiento
	inner join MM_PedidoDetalle pedD on pedD.IdPedidoDetalle = md.IdPedidoDetalle
	inner join MM_Pedido ped on ped.IdPedido = pedD.IdPedido
	inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = ped.IdSolicitudPedido
	inner join IN_AL_Domicilio dom on dom.idAlmacen = mov.idAlmacen
	where mov.IdMovimiento = @pIdMovimiento



	Begin tran

	update IN_AL_Movimiento
	set IdUsuarioAutorizo = @pIdUsuario,
		FechaAutoriza = getdate()
	where IdMovimiento =@pIdMovimiento and
	IdTipoMovimiento = 1--Recepción

	if @@error<> 0
	begin
		rollback tran
		goto fin
	end

	/*********Actualizar disponible***************/
	UPDATE IN_AL_MovimientoDetalle
	set Disponible = Cantidad
	from IN_AL_MovimientoDetalle t1
	inner join IN_AL_Movimiento t2 on t2.IdMovimiento = t1.IdMovimiento
	where t2.IdMovimiento = @pIdMovimiento

	if @@error<> 0
	begin
		rollback tran
		goto fin
	end

	

	
	/****************Es necesario agregar la aceptación de pedido para PORCURA*******************/
	INSERT INTO MM_AceptacionPedido	(	[IdProveedor],	[IdPedido],		[Comentario],			[NombreUsuarioEntrega],	[Activo],
									[Creado],			[CreadorPor],	[IdDomicilioEntrega],	[RecibidoPor],			[NombreRecibidoPor]	)
	select  @IdProveedor,@IdPedido,Comentarios,null,1,
		getdate(),@pIdUsuario,	@IdDomicilioEntrega,	IdUsuarioAutorizo,		s.Nombre
	from IN_AL_Movimiento mov
	inner join S_Usuario s on s.Idusuario = mov.IdUsuarioAutorizo
	where IdMovimiento = @pIdMovimiento

	if @@error<> 0
	begin
		rollback tran
		goto fin
	end

	select @IdAceptacionPedido=IDENT_CURRENT('MM_AceptacionPedido')


	INSERT INTO MM_AceptacionPedidoDetalle
	(
	[IdAceptacionPedido],
	[IdPedidoDetalle],
	[Cantidad],
	[Detalle],
	[CreadoPor],
	[Creado],
	[Excedente]
	)
	select @IdAceptacionPedido,movD.IdPedidoDetalle, movD.Cantidad,
	null,@pIdUsuario,getdate(),0
	from IN_AL_Movimiento mov
	inner join IN_AL_MovimientoDetalle movD on movD.IdMovimiento = mov.idMovimiento
	inner join MM_PedidoDetalle pedD on pedD.idPedidoDetalle = movD.IdPedidoDetalle
	where mov.IdMovimiento = @pIdMovimiento

	
	if @@error<> 0
	begin
		rollback tran
		goto fin
	end

	/*************Si el movimiento de recepción viene de una reserva, generar el registro para la reserva*************************/


	select  IdMovimientoDetReserva = movResD.IdMovimientoDetalle,
			IdMovimientoDetRecepcion = movD.IdMovimientoDetalle,
			CantidadReserva = movD.Cantidad
		into #tmpMovReservas
		from IN_AL_Movimiento mov
		inner join IN_AL_MovimientoDetalle movD on movD.IdMovimiento = mov.IdMovimiento
		inner join MM_PedidoDetalle pd on pd.IdPedidoDetalle = movd.IdPedidoDetalle
		inner join MM_Pedido ped on ped.IdPedido = pd.IdPedido
		inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = ped.IdSolicitudPedido
		inner join IN_AL_Movimiento movRes on movRes.IdSolicitudPedido = solP.IdSolicitudPedido and
								movRes.IsEliminado = 0 and
								movRes.IdUsuarioAutorizo > 0 and
								movRes.IdTipoMovimiento = 5 --Solo para mov de reserva
		inner join IN_AL_MovimientoDetalle movResD on movResD.IdMovimiento = movRes.IdMovimiento and
						movResD.IdMaterial = pd.IdMaterial

		where mov.IdMovimiento = @pIdMovimiento

	IF exists (
		select 1 from #tmpMovReservas
	)
	begin

		insert into IN_AL_ReservadETALLE(IdMovimientoDetReserva,IdMovimientoDetRecepcion,CantidadReserva,CreadoPor,CreadoEl)
		select IdMovimientoDetReserva,IdMovimientoDetRecepcion,CantidadReserva,@pIdUsuario,getdate()
		from #tmpMovReservas

		if @@error<> 0
		begin
			rollback tran
			goto fin
		end


		/*******Quitar lo disponible del movimiento de recepción******************/

		UPDATE IN_AL_MovimientoDetalle
		set Disponible = 0,
			ModificadoPor = @pIdUsuario,
			ModificadoEl = getdate()
		from IN_AL_MovimientoDetalle recD
		inner join #tmpMovReservas reserva on reserva.IdMovimientoDetRecepcion = recD.IdMovimientoDetalle


		if @@error<> 0
		begin
			rollback tran
			goto fin
		end


	End
	
	exec sp_IN_AL_ActualizarPrecioMovimiento @pIdMovimiento


	if @@error<> 0
	begin
		rollback tran
		goto fin
	end



	commit tran

	fin:

	
