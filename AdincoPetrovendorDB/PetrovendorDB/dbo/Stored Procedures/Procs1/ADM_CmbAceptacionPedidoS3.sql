-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <24-09-2018>
-- Description:	<llenar el combo de aceptacion de pedido filtrado por el material seleccionado>
-- =============================================

CREATE PROCEDURE ADM_CmbAceptacionPedidoS3 @IdPedidoDetalle INT, @TipoDocumento INT
AS
	BEGIN
		IF ( @TipoDocumento = 7 )
			BEGIN
				SELECT		ap.IdAceptacionPedido ,
							CONVERT ( NVARCHAR(100), AP.IdAceptacionPedido ) + ' - ' + AP.Comentario AS AceptacionPedido
				FROM		dbo.MM_AceptacionPedido ap
				INNER JOIN	dbo.MM_Pedido p
					ON p.IdPedido = ap.IdPedido
				INNER JOIN	dbo.MM_PedidoDetalle pd
					ON pd.IdMaterial = pd.IdMaterial
				INNER JOIN	dbo.MM_AceptacionPedidoDetalle apd
					ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
					   AND	apd.IdPedidoDetalle = pd.IdPedidoDetalle
				WHERE		apd.IdAceptacionPedidoDetalle = @IdPedidoDetalle
				GROUP BY	AP.IdAceptacionPedido, AP.Comentario
			END
	END