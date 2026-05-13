-- =============================================
-- Author: Pedro Acuña
-- Create date: 31/08/2018
-- Description: obtener la fecha de finalizacion de la cotizacion
-- =============================================

create FUNCTION Fn_ObtenerFechaFinalizacionCotizacionPorSolPed
	( @IdSolicitudPedido INT ,
	  @IdProveedor INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @retorno DATETIME

		SELECT		@retorno = TAO.FechaFinalizacion
		FROM		MM_SolicitudPedido AS SP
		INNER JOIN	TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
		WHERE
					SP.IdSolicitudPedido = @IdSolicitudPedido
					AND TAO.IdTipoOperacion = 6
					AND TAO.IdProveedor = @IdProveedor

		RETURN @retorno
	END