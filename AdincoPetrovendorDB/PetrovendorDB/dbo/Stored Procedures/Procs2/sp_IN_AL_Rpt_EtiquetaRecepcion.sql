

-- sp_IN_AL_Rpt_EtiquetaRecepcion 16
Create proc [dbo].[sp_IN_AL_Rpt_EtiquetaRecepcion]
@pIdMovimiento int
as

		declare @IdAlmacen int,
				@dominio varchar(200)

		select @IdAlmacen = IdAlmacen
		from IN_AL_Movimiento 
		where IdMovimiento = @pIdMovimiento

		select @dominio = isnull(DominioAlmacen,'')
		from IN_AL_VariablesSistema
		where IdAlmacen = @IdAlmacen


		select IdMovimiento,	IdAlmacen,		Almacen,	IdPedido,	Folio,			IdTipoMovimiento,	Tipo,
		RecibidoEn,	EntregadoEn,EntregadoA,		IdUsuarioAtendio,	Atendio,
		Comentarios,			PrecioTotal,	IdUsuarioAutorizo,Autorizo,FechaAutoriza,IdMovimientoDetalle,IdMaterial,
		MaterialDes,			MaterialDesLarga,IdUnidad,	Unidad,		PrecioUnitario,		Cantidad,		PrecioMovimiento,
		Disponible,				IdMovimientoEntregaDetalle,DisponibleTotalAlmacen,Reserva,	TotalMaterial,	IdSolicitudPedido
		EsReingresoSinRef,		
		QRURL ='http://'+  upper(rtrim(@dominio) + '/EtiquetaConsulta.aspx?param='+ 
				dbo.fnEncriptar(cast(IdMovimientoDetalle as varchar))) 
		from [dbo].[vw_IN_AL_Movimientos]
		where IdMovimiento = @pIdMovimiento
