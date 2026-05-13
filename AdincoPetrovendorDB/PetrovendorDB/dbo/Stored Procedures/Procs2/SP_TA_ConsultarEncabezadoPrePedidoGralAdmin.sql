
-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-17
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Update date: 07-02-18
-- Description:	Agregue consulta para saberl el tipo del pedido 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarEncabezadoPrePedidoGralAdmin]
	-- Add the parameters for the stored procedure here
	---execute  SP_TA_ConsultarEncabezadoPrePedidoGral 420, 1343
	@IdPedido int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
    -- Insert statements for procedure here
	
	----- IdTipoOperacion = 9--> Aprobación de pedido

	SELECT 	
	P.IdPedido,
	P.IdSolicitudPedido,
	SUM(PD.Subtotal) AS SubTotal,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	IdEstatusOperacion, 
	O.Descripcion, 
	ISNULL(PV.RazonSocial,'') +' ' + ISNULL(PV.RegimenCapital,'') AS Proveedor,
	PV.Municipio +' '+PV.Entidad AS LugarProveedor,
	E.Nombre, 
	O.FechaRegistro,
	U.Nombre,
	H.FechaVigencia,
	P.Version,
	CASE P.RecepcionServicio WHEN 1 THEN 'CONFIRMADA_ACEPTADA' WHEN 0 THEN 'CONFIRMACION_RECHAZADA' ELSE 'EN_RECEPCION' END,
	PG.IdPedido AS IdPedidoGeneral,
	TP.TipoPedido,
	TP.IdTipoPedido
	FROM MM_Pedido AS P
	LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	LEFT JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	LEFT JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	LEFT JOIN S_Usuario AS U  ON U.IdUsuario = O.IdAsignador
	LEFT JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	LEFT JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	LEFT JOIN dbo.MM_HorasVigenciaPedido AS H ON H.IdPedido = P.IdPedido
	LEFT JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador
	LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	WHERE O.IdTipoOperacion = 9 AND P.IdPedido = @IdPedido AND p.Version=o.NoVersion
	GROUP BY 
	P.IdPedido, 
	P.IdSolicitudPedido,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	O.IdEstatusOperacion, 
	O.Descripcion, 
	PV.RazonSocial,	
	PV.RegimenCapital,
	Pv.Municipio,
	PV.Entidad, 
	E.Nombre,
	O.FechaRegistro,
	U.Nombre,
	H.FechaVigencia,
	P.Version,
	P.RecepcionServicio,
	PG.IdPedido,
	TP.TipoPedido,
    TP.IdTipoPedido
  ---AND O.IdEstatusOperacion = 2
END



