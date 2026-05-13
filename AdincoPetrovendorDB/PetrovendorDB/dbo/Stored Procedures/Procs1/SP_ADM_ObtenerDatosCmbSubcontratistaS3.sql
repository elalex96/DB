-- =============================================
-- Author:		Pedro Acuña
-- Create date: 20/09/2018
-- Description:	obtener los proveedores de esta solicitud
-- =============================================

CREATE PROCEDURE SP_ADM_ObtenerDatosCmbSubcontratistaS3 @TipoDocumento INT, @IdSolicitudPedido INT, @IdSolicitudPedidoDetalle INT
AS
	BEGIN
		IF ( @TipoDocumento = 8)
			BEGIN
				SELECT		PO.IdSubcontratista, prov.RazonSocial
				FROM		dbo.MM_PeticionOferta PO
				LEFT JOIN	dbo.S_Proveedor prov
					ON prov.IdProveedor = PO.IdSubcontratista
				INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOferta = PO.IdPeticionOferta
				WHERE
							po.IdSolicitudPedido = @IdSolicitudPedido
							AND ISNULL ( po.IdEstatusEliminado, 0 ) = 0
							AND pod.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
							AND pod.Cotizado = 1
							GROUP BY PO.IdSubcontratista, prov.RazonSocial
			END

			IF ( @TipoDocumento  = 9 )
			BEGIN
				SELECT		PO.IdSubcontratista, prov.RazonSocial
				FROM		dbo.MM_PeticionOferta PO
				LEFT JOIN	dbo.S_Proveedor prov
					ON prov.IdProveedor = PO.IdSubcontratista
				WHERE
							po.IdSolicitudPedido = @IdSolicitudPedido
							AND ISNULL ( po.IdEstatusEliminado, 0 ) = 0
							GROUP BY PO.IdSubcontratista, prov.RazonSocial
			END	
	END
