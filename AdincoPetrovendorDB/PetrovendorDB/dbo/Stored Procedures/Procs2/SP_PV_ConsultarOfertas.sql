-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todas las ofertas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarOfertas] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  SELECT TAO.IdDocumento AS IdSolicitudOferta, TAO.Descripcion, TE.Nombre AS Estatus, US.Nombre AS Usuario, PR.RazonSocial AS Empresa, TAP.Nombre AS Prioridad, TAO.FechaRegistro, TAO.FechaFinalizacion
  FROM TA_Operacion AS TAO
	LEFT JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
	LEFT JOIN S_Usuario AS US ON US.IdUsuario = TAO.IdAsignador
	LEFT JOIN S_Proveedor AS PR ON PR.IdProveedor = TAO.IdProveedor
	LEFT JOIN TA_Prioridad AS TAP ON TAP.IdPrioridad = TAO.IdPrioridad
  WHERE IdTipoOperacion = 6

END

