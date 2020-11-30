-- =============================================
-- Author:		Pedro Acuña
-- Create date: 20/09/2018
-- Description:	reemplzar el texto del combo en cascada para que no se quede el id del combo
-- =============================================

CREATE PROCEDURE SP_ADM_ReemplazarTextoCmbDescripcionS3 @IdSolicitudPedidoDetalle INT, @TipoDocumento INT
AS
	BEGIN
		IF ( @TipoDocumento = 1 OR @TipoDocumento  = 8 )
			BEGIN
				SELECT		CONVERT ( NVARCHAR(50), det.Cantidad ) + ' - ' + m.DescripcionCorta + ' - ' + m.Modelo AS descripcion
				FROM		dbo.MM_SolicitudPedidoDetalle det
				LEFT JOIN	dbo.MM_Material m
					ON m.IdMaterial = det.IdMaterial
				WHERE		det.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
			END

		IF ( @TipoDocumento = 7 )
			BEGIN
				SELECT		LTRIM ( APD.Cantidad ) + ' - ' + pod.MaterialCotizadoTextoL + ' - ' + pod.UnidadProveedor AS descripcion
				FROM		dbo.MM_AceptacionPedidoDetalle apd
				INNER JOIN	dbo.MM_PedidoDetalle pd
					ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
				INNER JOIN	dbo.MM_PeticionOfertaDetalle pod
					ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
				WHERE		apd.IdAceptacionPedidoDetalle = @IdSolicitudPedidoDetalle -- aki en esta variable en realidad es el IdAceptacionPedidoDetalle
			END
	END