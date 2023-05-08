
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudesPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int,
	@Estatus int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

      IF (@Estatus = 1) --En aprobación
   BEGIN
   	SELECT 
	SP.IdSolicitudPedido, 
	SP.MotivoUrgencia,
	TSP.TipoSolicitudPedido, 
	SP.FechaAlta,
	TE.Nombre	
	FROM MM_SolicitudPedido AS SP
	INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido 
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion 
	WHERE 
	SP.IdUsuarioSolicitante = @IdUsuario AND 
	SP.IdProveedor = @IdProveedor AND 
	TAO.IdTipoOperacion=2 AND
	TE.IdEstatus = 1
	ORDER BY SP.FechaAlta DESC
   END
      IF (@Estatus = 2) --Aprobada
   BEGIN
      	SELECT 
	SP.IdSolicitudPedido, 
	SP.MotivoUrgencia,
	TSP.TipoSolicitudPedido, 
	SP.FechaAlta,
	TE.Nombre	
	FROM MM_SolicitudPedido AS SP
	INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido 
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion 
	WHERE 
	SP.IdUsuarioSolicitante = @IdUsuario AND 
	SP.IdProveedor = @IdProveedor AND 
	TAO.IdTipoOperacion=2 AND
	TE.IdEstatus = 2
	ORDER BY SP.FechaAlta DESC
   END
      IF (@Estatus = 3) --Rechazada
   BEGIN
      	SELECT 
	SP.IdSolicitudPedido, 
	SP.MotivoUrgencia,
	TSP.TipoSolicitudPedido, 
	SP.FechaAlta,
	TE.Nombre	
	FROM MM_SolicitudPedido AS SP
	INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido 
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion 
	WHERE 
	SP.IdUsuarioSolicitante = @IdUsuario AND 
	SP.IdProveedor = @IdProveedor AND 
	TAO.IdTipoOperacion=2 AND
	TE.IdEstatus = 3
	ORDER BY SP.FechaAlta DESC
   END


  
  -- TipoOperacion --> 2 = Solicitud de Pedido

END

