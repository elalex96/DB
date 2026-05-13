-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Create date: 20/01/2021
-- Description:	Optimización para correción de issue 920/ detalle pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarEstatusPedido]
@IdPedido INT,
@IdProveedor INT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdSolped INT = (SELECT P.IdSolicitudPedido 
								FROM MM_SolicitudPedido SP 
	                         INNER JOIN MM_Pedido P ON SP.IdSolicitudPedido = P.IdSolicitudPedido
							 WHERE P.IdPedido = @IdPedido 
							 )


	SELECT E.Nombre FROM TA_Operacion O
			INNER JOIN TA_Estatus AS E 
			ON O.IdEstatusOperacion = E.IdEstatus
	WHERE O.IdTipoOperacion = 9 
	AND O.IdProveedor = @IdProveedor 
	AND O.IdDocumento = @IdSolped 





	--SELECT E.Nombre ,P.IdSolicitudPedido
	--FROM MM_Pedido AS P
	--		INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	--		INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	--		INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	--		INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	--		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	--		INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	--		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	--		WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = 477 AND P.RecepcionServicio = 1   AND P.IdPedido = 1156
			


END