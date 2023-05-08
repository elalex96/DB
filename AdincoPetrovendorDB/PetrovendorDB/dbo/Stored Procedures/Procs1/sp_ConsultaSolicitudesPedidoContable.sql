-- =============================================
-- Author:		Alexander G
-- Create date: 27-06-17
-- Description:	Consultar Solicitudes de Pedido para contar sus estatus 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaSolicitudesPedidoContable]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	COUNT(*) AS TotalSolicitudPEstatus,
	COUNT(CASE TE.IdEstatus WHEN '2' THEN 1 ELSE NULL END) AS DocAprovados,
	COUNT(CASE TE.IdEstatus WHEN '3' THEN 1 ELSE NULL END) AS DocCancelados
	FROM MM_SolicitudPedido AS SP
	INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido 
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion 
	WHERE 
	SP.IdUsuarioSolicitante = @IdUsuario AND 
	SP.IdProveedor = @IdProveedor AND 
	TAO.IdTipoOperacion=2

  
  -- TipoOperacion --> 2 = Solicitud de Pedido

END

