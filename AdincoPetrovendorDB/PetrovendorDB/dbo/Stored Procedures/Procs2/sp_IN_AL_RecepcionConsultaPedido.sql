CREATE Proc [dbo].[sp_IN_AL_RecepcionConsultaPedido]
@pIdAlmacen int
As


			SELECT P.IdPedido,
			P.IdSolicitudPedido,
			P.FechaEnvioPedido AS FechaEnvioPedido,
			SUM(PD.Subtotal) AS TotalPedido,
			pv.RazonSocial + ' '+pv.RegimenCapital AS Proveedor,	
			E.Nombre,
			P.Version,
			Descripcion = cast(p.idPedido as varchar) +' '+ isnull(p.comentarios,'')
			FROM MM_Pedido AS P
			INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			inner join IN_ContratoAlmacen c on c.IdContrato = p.IdContrato
			WHERE 
			O.IdTipoOperacion = 9 AND 			
			P.RecepcionServicio IS NULL AND E.IdEstatus=2 
			--AND HV.FechaVigencia IS NULL 
			AND	c.IdAlmacen = @pIdAlmacen 
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio, E.Nombre,P.Version,P.Comentarios

			ORDER BY P.IdPedido DESC
	

