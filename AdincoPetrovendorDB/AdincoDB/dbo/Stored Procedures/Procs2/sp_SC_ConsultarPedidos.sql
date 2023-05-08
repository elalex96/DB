-- [sp_SC_ConsultarPedidos] 2,10982
CREATE Proc [dbo].[sp_SC_ConsultarPedidos]
@pIdContratista int,
@pIdSubcontratista int,
@pIdContrato int
As


			SELECT P.IdPedido,
			P.IdSolicitudPedido,
			P.FechaEnvioPedido AS FechaEnvioPedido,
			SUM(PD.Subtotal) AS TotalPedido,
			pv.RazonSocial + ' '+pv.RegimenCapital AS Proveedor,	
			--E.Nombre,
			P.Version,
			Descripcion = 	RTRIM(ISNULL(serv.NombreServicio,'')) COLLATE DATABASE_DEFAULT +' '+ 
						ISNULL(p.comentarios,''),
			C.IdContratista,
			Folio = folio.IdPedido
			FROM Petrovendor.dbo.MM_Pedido AS P
			inner join Petrovendor.dbo.MM_Pedidos folio on folio.IdIdentificador = p.IdPedido
			INNER JOIN Petrovendor.dbo.MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedido solPed ON solPed.IdSolicitudPedido = P.IdSolicitudPedido 																	
			INNER JOIN Petrovendor.dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN Petrovendor.dbo.S_Proveedor AS PV ON PV.IdProveedor = po.IdSubcontratista					
			INNER JOIN dbo.CO_Contrato c ON c.IdContrato = p.IdContrato		AND	
									c.IdContratista = @pIdContratista	 and
									p.IdContrato = c.IdContrato
			inner join CO_Contratista co on c.IdContratista  = c.IdContratista
			inner join Petrovendor.dbo.S_Proveedor provC on provC.RFC collate SQL_Latin1_General_CP1_CI_AS = co.RFC collate SQL_Latin1_General_CP1_CI_AS  and
													provC.IdProveedor= solPed.idProveedor

			
			/****************/
			inner join Petrovendor.dbo.MM_SolicitudPedidoDetalle spd on spd.IdSolicitudPedido = solPed.IdSolicitudPedido
			inner join PV_Subcontratista  subContratista on LTRIM(RTRIM(subContratista.RFC)) collate Modern_Spanish_CI_AS= LTRIM(RTRIM(PV.RFC)) collate Modern_Spanish_CI_AS and
												 subContratista.IdSubcontratista = @pIdSubcontratista
			inner join Petrovendor.dbo.[MM_SolicitudPedidoDetalleLineaPresupuesto] splp on splp.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
			inner JOIN CO_LineaPresupuestoMes lp ON lp.IdLineaPresupuestoMes = splp.IdLineaPresupuesto			
			inner JOIN dbo.CO_Servicio serv ON serv.IdServicio = LP.IdServicio				
	
																		
			WHERE 			
			 NOT EXISTS(
				select 1
				from SC_Subcontrato sc
				where sc.IdPedido = p.IdPedido
				and sc.IsActivo = 1
			)
			
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, pv.RazonSocial,pv.RegimenCapital, 
			P.RecepcionServicio, P.Version,P.Comentarios,c.IdContratista,serv.NombreServicio,folio.IdPedido
			ORDER BY P.IdPedido DESC
	






