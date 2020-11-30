-- =============================================
-- Author:		Pedro Acuña
-- Create date: 28/01/2019
-- Description:	 store para revisar que la aceptacion tenga materiales disponibles para agregar a la aceptacion
-- =============================================

CREATE PROCEDURE SP_RevisarAceptacionServicio @IdPedido INT, @IdProveedor INT, @IdPedidoDetalle INT
AS
	BEGIN
		SELECT	PD.IdPedidoDetalle, PD.IdMaterialVendedor, m.DescripcionCorta AS MaterialSolicitadoCorto ,
				m.DescripcionLarga AS MaterialSolicitadoLarga, spd.observaciones ,
				POD.MaterialCotizadoTextoC AS DescripcionCortaCotizado, ISNULL ( pd.Cantidad, 0 ) AS CantidadPedido ,
				SUM ( ISNULL ( apd.Cantidad, 0 )) AS CantidadAceptada ,
				ISNULL ( pd.Cantidad, 0 ) - SUM ( ISNULL ( apd.Cantidad, 0 )) AS CantidadRestante
		  FROM	MM_Pedido AS P
				INNER JOIN dbo.MM_PedidoDetalle AS pd
						   ON pd.IdPedido = P.IdPedido
				INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD
						   ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
				INNER JOIN dbo.MM_SolicitudPedidoDetalle AS spd
						   ON spd.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
				INNER JOIN dbo.MM_Material m
						   ON m.IdMaterial = spd.IdMaterial
				INNER JOIN dbo.MM_AceptacionPedido ap
						   ON ap.IdPedido = P.IdPedido
				LEFT JOIN dbo.MM_AceptacionPedidoDetalle apd
						  ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
							 AND apd.IdPedidoDetalle = pd.IdPedidoDetalle
		 WHERE
				P.IdPedido = @IdPedido
				AND P.IdProveedorCompras = @IdProveedor
				AND P.RecepcionServicio = 1
				AND PD.RecepcionPedido = 1
				AND ISNULL ( ap.IdEstatusEliminado, 0 ) <> 1
				AND pd.IdPedidoDetalle = @IdPedidoDetalle
		 GROUP BY pd.IdPedidoDetalle, pd.IdMaterialVendedor, m.DescripcionCorta, m.DescripcionLarga, spd.observaciones ,
				  POD.MaterialCotizadoTextoC, pd.Cantidad
	END