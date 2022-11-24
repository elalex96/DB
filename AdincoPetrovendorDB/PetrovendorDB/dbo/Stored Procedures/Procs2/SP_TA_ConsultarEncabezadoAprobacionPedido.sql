-- =============================================
-- Author:		Daniel AC
-- Create date: 13-09-17
-- Description:	Consulta la información de cabecera de una aprobación de pedido 
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 20/03/2021
-- Description:	Se optimiza la consulta para la pantalla detalle_pedido del issue 984
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarEncabezadoAprobacionPedido]  
	-- Add the parameters for the stored procedure here
	
	@IdAprobador int, 
	@IdSolicitudPedido int, 
	@Version int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT 	
		P.IdSolicitudPedido,		
		SUM(PD.Subtotal) AS SubTotal,
		O.IdFlujoTarea, 
		O.IdOperacion, 
		IdEstatusOperacion, 
		O.Descripcion, 
		E.Nombre, 
		O.FechaRegistro,
		p.Version,
		U.Nombre,
		U.IdUsuario
		FROM MM_Pedido AS P
		INNER JOIN MM_PedidoDetalle AS PD 
		ON P.IdPedido = PD.IdPedido 
		INNER JOIN MM_SolicitudPedido AS SP 
		ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
		INNER JOIN TA_Operacion AS O 
		ON SP.IdSolicitudPedido  = O.IdDocumento 
		INNER JOIN TA_Tarea AS TA 
		ON O.IdOperacion = TA.IdOperacion
		INNER JOIN TA_TipoOperacion AS TTO 
		ON O.IdTipoOperacion = TTO.IdTipoOperacion
		INNER JOIN TA_Estatus AS E 
		ON O.IdEstatusOperacion = E.IdEstatus 
		INNER JOIN S_Usuario AS U 
		ON O.IdAsignador = U.IdUsuario 
		WHERE O.IdTipoOperacion = 9 
		AND TA.IdAprobador = @IdAprobador 
		AND P.IdSolicitudPedido = @IdSolicitudPedido 
		AND P.Version=O.NoVersion
		AND P.Version= @Version
		GROUP BY 
		P.IdSolicitudPedido,
		O.IdFlujoTarea, 
		O.IdOperacion, 
		O.IdEstatusOperacion, 
		O.Descripcion,		
		E.Nombre,
		O.FechaRegistro,
		p.Version,
		U.Nombre,
		U.IdUsuario
	--- IdTipoOperacion = 9--> Aprobación de pedido
END