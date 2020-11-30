-- =============================================
-- Author:		Daniel AC
-- Create date: 13-09-17
-- Description:	Consulta la información de cabecera de una aprobación de pedido 
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
		INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
		INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido 
		INNER JOIN TA_Tarea AS TA ON TA.IdOperacion = O.IdOperacion 
		INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN S_Usuario AS U ON U.IdUsuario = O.IdAsignador
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


