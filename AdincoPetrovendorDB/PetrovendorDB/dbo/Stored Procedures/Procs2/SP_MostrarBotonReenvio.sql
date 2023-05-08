-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26-03-18
-- Description: saber si se debe mostrar o no el boton  (Cuando al menos haya enviado anteriormente una solicitud de oferta y la fecha de vigencia de la oferta no haya terminado)
--				Si encuentra un registro debe mostrar el boton en caso contrario no 
-- =============================================

CREATE PROCEDURE [dbo].[SP_MostrarBotonReenvio] @IdProveedor INT, @IdTipoProceso INT, @IdSolicitudPedido INT
AS
	BEGIN
		SELECT	 SP.IdSolicitudPedido, TAO.IdOperacion, TAO.FechaFinalizacion
		FROM	 MM_SolicitudPedido AS SP
		INNER JOIN TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
		WHERE
				 SP.IdProveedor = @IdProveedor
				 AND TAO.IdTipoOperacion = 6
				 AND SP.Activo = 1
				 AND (	 SP.PeticionEnviada = 1
						 OR SP.PeticionEnviada IS NOT NULL
				 )
				 AND ( SP.IdTipoProceso = 2 )
				 AND ISNULL ( SP.Visible, 1 ) = 1
				 AND DATEDIFF ( SECOND, GETDATE (), TAO.FechaFinalizacion) > 0
				 AND SP.IdSolicitudPedido = @IdSolicitudPedido
		ORDER BY SP.IdSolicitudPedido DESC
	END
