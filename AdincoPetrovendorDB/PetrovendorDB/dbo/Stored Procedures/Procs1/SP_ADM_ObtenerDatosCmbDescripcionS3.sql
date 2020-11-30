-- =============================================
-- Author:		Pedro Acuña
-- Create date: 14/09/2018
-- Description:	obtener los materiales del combo de descripcion ya que es dinamico dependiente del tipo de documento y la solicitud de pedido son los materiales que se van a cargar
-- =============================================

CREATE PROCEDURE SP_ADM_ObtenerDatosCmbDescripcionS3 @TipoDocumento INT, @IdSolicitudPedido INT
AS
	BEGIN
		IF ( @TipoDocumento = 1 OR @TipoDocumento  = 8 )
			BEGIN
				SELECT		det.IdSolicitudPedidoDetalle ,
							CONVERT ( NVARCHAR(50), det.Cantidad ) + ' - ' + m.DescripcionCorta + ' - ' + m.Modelo AS descripcion
				FROM		dbo.MM_SolicitudPedidoDetalle det
				LEFT JOIN	dbo.MM_Material m
					ON m.IdMaterial = det.IdMaterial
				WHERE
							det.IdSolicitudPedido = @IdSolicitudPedido
							AND ISNULL ( det.IdEstatusEliminado, 0 ) = 0
				GROUP BY	CONVERT ( NVARCHAR(50), det.Cantidad ) + ' - ' + m.DescripcionCorta + ' - ' + m.Modelo ,
							det.IdSolicitudPedidoDetalle
			END

		IF ( @TipoDocumento = 7 )
			BEGIN
				SELECT		APD.IdAceptacionPedidoDetalle,
							LTRIM ( APD.Cantidad ) + ' - ' + pod.MaterialCotizadoTextoL + ' - ' + pod.UnidadProveedor AS descripcion
				FROM		MM_AceptacionPedidoDetalle AS APD
				INNER JOIN	MM_AceptacionPedido AS A
					ON A.IdAceptacionPedido = APD.IdAceptacionPedido
				INNER JOIN	MM_PedidoDetalle AS PD
					ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
				INNER JOIN	dbo.MM_PeticionOfertaDetalle AS POD
					ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
				INNER JOIN	MM_Pedido AS P
					ON P.IdPedido = A.IdPedido
				INNER JOIN	PV_TipoMoneda AS TM
					ON TM.IdMoneda = PD.IdMoneda
				WHERE
							p.IdSolicitudPedido = @IdSolicitudPedido
							AND ISNULL ( A.IdEstatusEliminado, 0 ) = 0
				GROUP BY	APD.IdAceptacionPedidoDetalle, APD.Cantidad, pod.MaterialCotizadoTextoL, pod.UnidadProveedor
			END
	END
