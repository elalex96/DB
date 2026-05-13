-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consulta todas las solicitudes de pedido y sus detalles>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarSolicitudesPedido] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SP.IdSolicitudPedido,TAO.Descripcion, SP.MotivoUrgencia, TAE.Nombre AS Estatus, US.Nombre AS UsuarioSolicitante, PR.RazonSocial AS Empresa
	FROM TA_Operacion AS TAO 
		LEFT JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = TAO.IdDocumento
		LEFT JOIN TA_Estatus AS TAE ON TAE.IdEstatus = TAO.IdEstatusOperacion
		LEFT JOIN S_Proveedor AS PR ON SP.IdProveedor= PR.IdProveedor
		LEFT JOIN S_Usuario AS US ON US.IdUsuario = SP.IdUsuarioSolicitante				
		LEFT JOIN S_UsuarioProveedor AS SUP ON SUP.IdUsuario = US.IdUsuario AND SUP.IdProveedor = PR.IdProveedor			
    WHERE IdTipoOperacion = 2 
END
