
-- p_IN_AL_Existencias 2,0,0
create proc p_IN_AL_Existencias
@pIdAlmacen int,
@pIdMaterial int,
@pIdEstatus int -- 1. Libres, 2.Reserva , 0.Todos
as
	

	WITH tExistencias(ID,IdAlmacen,IdMaterial,Cantidad,Estatus)
	as
	(
			/***********MATERIAL LIBRE****************/

			select 
				ID='C1',
				IdAlmacen,
				IdMaterial,
				DisponibleTotalAlmacen,
				'LIBRE'
			from [vw_IN_AL_Movimientos]
			where DisponibleTotalAlmacen > 0 and
			IdAlmacen = @pIdAlmacen and
			@pIdMaterial in(0,IdMaterial)


			union

			/***********MATERIAL reserva****************/

			select 
				ID='C2',
				IdAlmacen,
				IdMaterial,
				Reserva,
				'RESERVA'
			from [vw_IN_AL_Movimientos]
			where Reserva > 0 and
			IdAlmacen = @pIdAlmacen and
			@pIdMaterial in(0,IdMaterial)


			UNION

			/******************************SOLICITUDES DE PEDIDO PARA MRP****************************/
			SELECT
				ID='C3',
				IdAlmacen,
				solPD.IdMaterial,
				Cantidad = ISNULL(SUM(solPD.Cantidad),0),
				Estatus = 'SOLP'		
			FROM [IN_AL_MRP_SolicitudPedido] mov	
			inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = mov.IdSolicitudPedido
			inner join MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solp.IdSolicitudPedido
			inner join MM_Maestro mat on mat.IdMaestro = solPD.IdMaterial	
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = solP.IdSolicitudPedido and
										--Asegurarse que no este cancelada o vencida
										O.IdEstatusOperacion not in (3,4,5,6,7)
			where 			
			isnull(mov.IdSolicitudPedido,0) > 0 and
			--NO EXISTE EL PEDIDO
			not exists(
				select 1
				from MM_Pedido ped
				where ped.IdSolicitudPedido = solP.IdSolicitudPedido
			) 
			AND o.IdTipoOperacion  = 2
			and mov.IdAlmacen = @pIdAlmacen
			and	@pIdMaterial in(0,solPD.IdMaterial)
			group by IdAlmacen,solPD.IdMaterial

			UNION
            
			/*********************OBTENER MATERIALES QUE ESTEN YA TENGAN EL PEDIDO EN PROCESO, PERO AUN NO ESTÉ APROBADO*********************/
			SELECT
				ID='C4',
				IdAlmacen,
				solPD.IdMaterial,
				Cantidad = ISNULL(SUM(solPD.Cantidad),0),
				Estatus = 'PEDI'		
			FROM [IN_AL_MRP_SolicitudPedido] mov	
			inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = mov.IdSolicitudPedido
			inner join MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solp.IdSolicitudPedido
			inner join MM_Pedido ped on ped.IdSolicitudPedido = solPD.IdSolicitudPedido
			inner join MM_Maestro mat on mat.IdMaestro = solPD.IdMaterial	
			inner JOIN TA_Operacion AS O ON O.IdDocumento = solPD.IdSolicitudPedido AND
										--EN APROBACIÓN, ENVIADA, SIN INICIAR APROBACIÓN								
										O.IdEstatusOperacion  in (1,8,9)
			where 			
			isnull(mov.IdSolicitudPedido,0) > 0 	
			AND o.IdTipoOperacion  = 9
			and mov.IdAlmacen = @pIdAlmacen
			and	@pIdMaterial in(0,solPD.IdMaterial)
			group by IdAlmacen,solPD.IdMaterial

			UNION
            
			/*********************OBTENER MATERIALES QUE ESTEN EN TRANSITO, PEDIDOS APROBADOS Y AUN SIN REGISTRO DE RECEPCIÓN*********************/
			SELECT
				ID='C5',
				MOV.IdAlmacen,
				solPD.IdMaterial,
				Cantidad = ISNULL(SUM(solPD.Cantidad),0)- ISNULL(SUM(movDRec.Cantidad),0),
				Estatus = 'TRAN'		
			FROM [IN_AL_MRP_SolicitudPedido] mov	
			inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = mov.IdSolicitudPedido
			inner join MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solp.IdSolicitudPedido
			inner join MM_Pedido ped on ped.IdSolicitudPedido = solPD.IdSolicitudPedido
			inner join MM_Maestro mat on mat.IdMaestro = solPD.IdMaterial	
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = solPD.IdSolicitudPedido AND
										--APROBADA							
										O.IdEstatusOperacion  in (2)
			LEFT JOIN dbo.IN_AL_Movimiento movRec ON movRec.IdPedido = PED.IdPedido AND
													movRec.IsEliminado = 0 AND
                                                    movRec.IdUsuarioAutorizo > 0 AND
                                                    movrec.IdTipoMovimiento = 1
			LEFT JOIN dbo.IN_AL_MovimientoDetalle movDRec ON movDRec.IdMovimiento = movRec.IdMovimiento AND+
												movDRec.IdMaterial = solPD.IdMaterial
			where
			isnull(mov.IdSolicitudPedido,0) > 0 				
			AND o.IdTipoOperacion  = 9
			and mov.IdAlmacen = @pIdAlmacen
			and	@pIdMaterial in(0,solPD.IdMaterial)
			group by MOV.IdAlmacen,solPD.IdMaterial

			UNION
			/******************************SOLICITUDES DE PEDIDO PARA RESERVA************************/

			SELECT
				ID='C6',
				IdAlmacen,
				solPD.IdMaterial,
				Cantidad = ISNULL(SUM(solPD.Cantidad),0),
				Estatus = 'SOLP'		
			FROM IN_AL_Movimiento mov	
			inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = mov.IdSolicitudPedido
			inner join MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solp.IdSolicitudPedido
			inner join MM_Maestro mat on mat.IdMaestro = solPD.IdMaterial	
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = solP.IdSolicitudPedido and
										--Asegurarse que no este cancelada o vencida
										O.IdEstatusOperacion not in (3,4,5,6,7)
			where 
			mov.IdUsuarioAutorizo > 0 and
			isnull(mov.IdSolicitudPedido,0) > 0 and
			--NO EXISTE EL PEDIDO
			not exists(
				select 1
				from MM_Pedido ped
				where ped.IdSolicitudPedido = solP.IdSolicitudPedido
			) 
			AND o.IdTipoOperacion  = 2
			and mov.IdAlmacen = @pIdAlmacen
			and	@pIdMaterial in(0,solPD.IdMaterial)
			group by IdAlmacen,solPD.IdMaterial

			union


			/*********************OBTENER MATERIALES QUE ESTEN YA TENGAN EL PEDIDO EN PROCESO, PERO AUN NO ESTÉ APROBADO*********************/
			SELECT
				ID='C7',
				IdAlmacen,
				solPD.IdMaterial,
				Cantidad = ISNULL(SUM(solPD.Cantidad),0),
				Estatus = 'PEDI'		
			FROM IN_AL_Movimiento mov	
			inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = mov.IdSolicitudPedido
			inner join MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solp.IdSolicitudPedido
			inner join MM_Pedido ped on ped.IdSolicitudPedido = solPD.IdSolicitudPedido
			inner join MM_Maestro mat on mat.IdMaestro = solPD.IdMaterial	
			inner JOIN TA_Operacion AS O ON O.IdDocumento = solPD.IdSolicitudPedido AND
										--EN APROBACIÓN, ENVIADA, SIN INICIAR APROBACIÓN								
										O.IdEstatusOperacion  in (1,8,9)
			where 
			mov.IdUsuarioAutorizo > 0 and
			isnull(mov.IdSolicitudPedido,0) > 0 	
			AND o.IdTipoOperacion  = 9
			and mov.IdAlmacen = @pIdAlmacen
			and	@pIdMaterial in(0,solPD.IdMaterial)
			group by IdAlmacen,solPD.IdMaterial

			union

			/*********************OBTENER MATERIALES QUE ESTEN EN TRANSITO, PEDIDOS APROBADOS Y AUN SIN REGISTRO DE RECEPCIÓN*********************/
			SELECT
				ID='C8',
				MOV.IdAlmacen,
				solPD.IdMaterial,
				Cantidad = ISNULL(SUM(solPD.Cantidad),0)- ISNULL(SUM(movDRec.Cantidad),0),
				Estatus = 'TRAN'		
			FROM IN_AL_Movimiento mov	
			inner join MM_SolicitudPedido solP on solP.IdSolicitudPedido = mov.IdSolicitudPedido
			inner join MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solp.IdSolicitudPedido
			inner join MM_Pedido ped on ped.IdSolicitudPedido = solPD.IdSolicitudPedido
			inner join MM_Maestro mat on mat.IdMaestro = solPD.IdMaterial	
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = solPD.IdSolicitudPedido AND
										--APROBADA							
										O.IdEstatusOperacion  in (2)
			LEFT JOIN dbo.IN_AL_Movimiento movRec ON movRec.IdPedido = PED.IdPedido AND
													movRec.IsEliminado = 0 AND
                                                    movRec.IdUsuarioAutorizo > 0 AND
                                                    movrec.IdTipoMovimiento = 1
			LEFT JOIN dbo.IN_AL_MovimientoDetalle movDRec ON movDRec.IdMovimiento = movRec.IdMovimiento AND+
												movDRec.IdMaterial = solPD.IdMaterial
			where
			mov.IdUsuarioAutorizo > 0 and
			isnull(mov.IdSolicitudPedido,0) > 0 				
			AND o.IdTipoOperacion  = 9
			and mov.IdAlmacen = @pIdAlmacen
			and	@pIdMaterial in(0,solPD.IdMaterial)
			group by MOV.IdAlmacen,solPD.IdMaterial
	)

	select  exs.IdAlmacen,
			Almacen = al.Nombre,
			exs.IdMaterial,
			MaterialDes = mat.DescripcionCorta,
			MaterialDesLarga = mat.DescripcionLarga,
			Unidad = isnull(u.Unidad,'SIN ESPECIFICAR'),
			CantidadLibre = sum( case when exs.Estatus = 'LIBRE' then exs.cantidad else 0 end),
			CantidadReserva = sum( case when exs.Estatus = 'RESERVA' then exs.cantidad else 0 end),
			CantidadEnAlmacen = sum( case when exs.Estatus IN( 'LIBRE','RESERVA') then exs.cantidad else 0 end),								
			CantidadSolPed = sum( case when exs.Estatus = 'SOLP' then exs.cantidad else 0 end),
			CantidadPed = sum( case when exs.Estatus = 'PEDI' then exs.cantidad else 0 end),
			CantidadTra = sum( case when exs.Estatus = 'TRAN' then 
											CASE WHEN exs.cantidad < 0 
													THEN 0 
													ELSE exs.cantidad 
											END 
								ELSE 0 
							END)	
							
	into #tmpResult		   
	from tExistencias exs
	inner join IN_Almacen al on al.IdAlmacen = exs.IdAlmacen
	inner join MM_Material mat on mat.IdMaterial = exs.IdMaterial
	left join [dbo].[PV_MM_MaterialUnidad] u on u.IdUnidad = mat.idUnidad
	where exs.IdAlmacen = @pIdAlmacen
	and	@pIdMaterial in(0,exs.IdMaterial)
	
	group by al.Nombre,exs.IdAlmacen,exs.IdMaterial,mat.DescripcionCorta,mat.DescripcionLarga,u.Unidad


	select *
	from #tmpResult
	where (
		@pIdEstatus = 0 OR
		(
			@pIdEstatus = 1 and 
			(CantidadLibre > 0 OR CantidadSolPed > 0 OR CantidadPed > 0 OR CantidadTra > 0) 
		)
		OR
		(
			@pIdEstatus = 2 and 
			CantidadReserva > 0 
		)
		or @pIdEstatus = 0
	)


