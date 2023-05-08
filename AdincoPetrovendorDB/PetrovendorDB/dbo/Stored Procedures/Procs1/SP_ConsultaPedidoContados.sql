-- =============================================
-- Author:		Alexander G
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Oferta contados por estatus  
-- Author:		Alexander G
-- Create date: 02-03-18
-- Description:	Agrego no de version a todos los pedidos
CREATE PROCEDURE [dbo].[SP_ConsultaPedidoContados]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		


	DECLARE @TotalPedidos INT = (

	          SELECT COUNT(P.IdPedido)
			FROM MM_Pedido AS P		
	
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido AND O.NoVersion=P.Version
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia		
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			WHERE 
			O.IdTipoOperacion = 9 
			AND O.IdProveedor =@IdProveedor	
	)

	DECLARE @EnAprobacion INT = (
	SELECT COUNT(P.IdPedido)
			FROM MM_Pedido AS P		
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			WHERE 
			O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.RecepcionServicio IS NULL  
			AND O.IdEstatusOperacion=1 
			AND HV.FechaVigencia IS NULL
			AND P.Version=O.NoVersion
			--ORDER BY  P.IdPedido DESC
	)

	DECLARE @Aprovadas INT = (
	SELECT COUNT(P.IdPedido)
			FROM MM_Pedido AS P			
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor
			AND P.RecepcionServicio = 1  
			AND  E.IdEstatus=2 
			AND HV.FechaVigencia IS NOT NULL 
			AND P.Version=O.NoVersion 
			--ORDER BY  P.IdPedido DESC
	)

	DECLARE @Rechazada INT = (
	SELECT COUNT(P.IdPedido)
			FROM MM_Pedido AS P			
			INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
			INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor 
			AND P.RecepcionServicio IS NULL  
			AND  E.IdEstatus=3
			AND P.Version=O.NoVersion
			--ORDER BY  P.IdPedido DESC
			)

	SELECT
	@TotalPedidos AS TotalPedidos,
	@EnAprobacion AS Pendientes,
	@Aprovadas AS Aceptados,
	@Rechazada AS Vencidos
	--- IdTipoOperacion = 7--> Pedido

END
