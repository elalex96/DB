-- =============================================
-- Author:		DANIEL
-- Create date: 03/SEP/2017
-- Description:	Validar que la existencia de una petición de oferta con el id solicitud pedido entrante 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarExistenciaRecuperacionProveedor]
@IdSolicitudPedido int,
@IdProveedorVenta int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT IdPeticionOferta, P.Razonsocial +'' +P.RegimenCapital
	FROM MM_PeticionOferta AS PO
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido=PO.IdSolicitudPedido
	INNER JOIN S_Proveedor AS P ON P.IdProveedor=SP.[IdProveedor]
	WHERE PO.IdSolicitudPedido= @IdSolicitudPedido AND PO.IdSubcontratista=@IdProveedorVenta

END

