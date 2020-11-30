-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todos los Pedidos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarPedidos] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT MP.IdPedido, TAO.Descripcion, MP.Comentarios, TAE.Nombre AS Estatus, US.Nombre AS Usuario, PR.RazonSocial AS SubContratista, MP.CreadoEl, MP.FechaRecepcionServicio
  FROM TA_Operacion AS TAO
	LEFT JOIN MM_Pedido AS MP ON MP.IdPedido = TAO.IdDocumento
	LEFT JOIN TA_Estatus AS TAE ON TAE.IdEstatus = TAO.IdEstatusOperacion
	LEFT JOIN S_Usuario AS US ON US.IdUsuario = MP.CreadoPor
	LEFT JOIN S_Proveedor AS PR ON PR.IdProveedor = MP.IdSubcontratista
  WHERE IdTipoOperacion = 9

END

