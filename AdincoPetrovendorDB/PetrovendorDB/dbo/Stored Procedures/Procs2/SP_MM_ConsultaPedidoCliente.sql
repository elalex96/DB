
-- =============================================
-- Author:		Daniel AC
-- Update date: 08-09-2018
-- Description:	Consultar Pedidos por filtro POR SOLPED y removi condicion de tipo de pedido = 2
-- =============================================
-- Author:		Daniel AC
-- Update date: 01-06-2018
-- Description:	PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
-- =============================================
-- Author:		Jose Roman
-- Update date: 19-07-2018
-- Description:	Se agrega filtro para pedidos cerrados
-- =============================================
CREATE PROCEDURE SP_MM_ConsultaPedidoCliente
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@Filtro nvarchar(max),
	@IdSolicitudPedido int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @Filtro ='EN_APROBACION'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			 P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,			 
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepci�n' END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,P.RecepcionServicio,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2,4,6) ---(Mer, AD, OT)
			WHERE 
			O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.IdSolicitudPedido= @IdSolicitudPedido
			AND P.RecepcionServicio IS NULL  
			AND O.IdEstatusOperacion=1 
			AND HV.FechaVigencia IS NULL
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.CreadoEl, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto, P.FechaEnvioPedido,	PG.IdPedido
			ORDER BY  PG.IdPedido DESC
		END 

		IF @Filtro ='APROBADOS'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			 P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepci�n' END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.IdSolicitudPedido= @IdSolicitudPedido
			AND P.RecepcionServicio IS NULL  
			AND  E.IdEstatus=2 
			AND HV.FechaVigencia IS  NULL
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto, P.CreadoEl,	PG.IdPedido
			ORDER BY PG.IdPedido DESC
		END 


		IF @Filtro ='RECHAZADOS'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			 P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 --CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepci�n' END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.IdSolicitudPedido= @IdSolicitudPedido
			AND P.RecepcionServicio IS NULL  
			AND  E.IdEstatus=3
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.CreadoEl, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto, P.FechaEnvioPedido,	PG.IdPedido
			ORDER BY  PG.IdPedido DESC
		END 

		IF @Filtro ='EN_RECEPCION'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			  P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 'En Recepci�n'  AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.IdSolicitudPedido= @IdSolicitudPedido           
			AND P.RecepcionServicio IS NULL  
			AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  <= 0
			AND  E.IdEstatus=2 
			AND HV.FechaVigencia IS NOT NULL
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, P.CreadoEl,	PG.IdPedido
			ORDER BY  PG.IdPedido DESC
		END 

		IF @Filtro ='EN_RECEPCION_ACEPTADA'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			  P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepci�n' END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.IdSolicitudPedido= @IdSolicitudPedido
			AND P.RecepcionServicio = 1  
			AND  E.IdEstatus=2 
			AND HV.FechaVigencia IS NOT NULL 
			AND P.Version=O.NoVersion 
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto, P.CreadoEl,	PG.IdPedido
			ORDER BY  PG.IdPedido DESC
		END 


		IF @Filtro ='EN_RECEPCION_RECHAZADA'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			  P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 CASE ISNULL(P.RecepcionServicio,0) WHEN 1 THEN 'Confirmado' ELSE 'En Recepci�n' END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor
			AND P.IdSolicitudPedido= @IdSolicitudPedido 
			AND P.RecepcionServicio = 0  
			AND  E.IdEstatus=2 
			AND HV.FechaVigencia IS NOT NULL  
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto, P.CreadoEl,	PG.IdPedido
			ORDER BY  PG.IdPedido DESC
		END 

		IF @Filtro ='EN_RECEPCION_VENCIDA'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido, 
			 P.CreadoEl AS CreadoEl,
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 'Confirmaci�n Vencida'
			 AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor
			AND P.IdSolicitudPedido= @IdSolicitudPedido 
			AND P.RecepcionServicio IS NULL   
			AND  E.IdEstatus=2 
			AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0
			AND HV.FechaVigencia IS NOT NULL  
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 0 --> PEDIDOS NO CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, P.CreadoEl,	PG.IdPedido
			ORDER BY  PG.IdPedido DESC
		END 

		IF @Filtro ='CERRADOS'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido,
			 P.CreadoEl AS CreadoEl, 
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 CASE 
				WHEN P.RecepcionServicio = 1 THEN 'Confirmaci�n Aceptada' 
				WHEN P.RecepcionServicio  = 0 THEN 'Confirmaci�n Rechazada' 
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					 'Confirmaci�n Vencida '  
				ELSE 	  
					 'En confirmaci�n ' 
			   END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor
			AND P.IdSolicitudPedido= @IdSolicitudPedido 			 
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			AND ISNULL(p.Cerrado, 0) = 1 --> PEDIDOS CERRADOS
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, O.IdEstatusOperacion,P.CreadoEl,	PG.IdPedido
			ORDER BY PG.IdPedido DESC
		END 

		IF @Filtro ='TODOS'
		 BEGIN
			SELECT P.IdPedido,
			 P.IdSolicitudPedido,
			 P.CreadoEl AS CreadoEl, 
			 P.FechaEnvioPedido AS FechaEnvioPedido,
			 SUM(PD.Subtotal) AS TotalPedido,
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			 CASE 
				WHEN P.RecepcionServicio = 1 THEN 'Confirmaci�n Aceptada' 
				WHEN P.RecepcionServicio  = 0 THEN 'Confirmaci�n Rechazada' 
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					 'Confirmaci�n Vencida '  
				ELSE 	  
					 'En confirmaci�n ' 
			   END AS RecepcionServicio,
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral
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
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IdProveedor AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor
			AND P.IdSolicitudPedido= @IdSolicitudPedido 			 
			AND P.Version=O.NoVersion
			AND ISNULL(P.IdEstatusEliminado,0) <>1 --> PEDIDOS QUE NO ESTEN CON ESTATUS DE ELIMINACION <>1
			GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,+RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, O.IdEstatusOperacion,P.CreadoEl,	PG.IdPedido
			ORDER BY PG.IdPedido DESC
		END 

	--- IdTipoOperacion = 7--> Pedido

END







