-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar PrePedido Detalle  Encabezado
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarEncabezadoPrePedido]
	-- Add the parameters for the stored procedure here
	 
	@IdAprobador int, 
	@IdPedido int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 	
	P.IdPedido,
	P.IdSolicitudPedido,
	SUM(PD.Subtotal) AS SubTotal,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	IdEstatusOperacion, 
	O.Descripcion, 
	PV.RazonSocial +' ' + PV.RegimenCapital AS Proveedor,
	PV.Municipio +' '+PV.Entidad AS LugarProveedor,
	E.Nombre, 
	O.FechaRegistro
	FROM MM_Pedido AS P
	INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdPedido
	INNER JOIN TA_Tarea AS TA ON TA.IdOperacion = O.IdOperacion 
	INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista 
	WHERE O.IdTipoOperacion = 9 AND TA.IdAprobador = @IdAprobador AND P.IdPedido = @IdPedido
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
	O.FechaRegistro

	--- IdTipoOperacion = 9--> Aprobación de pedido


END

