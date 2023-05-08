-- =============================================
-- Author: Pedro Acuña
-- Create date: 22/06/2018
-- Description: filtrar el idaceptacion por peticion oferta
-- =============================================

CREATE FUNCTION Fn_ObtenerIdAceptacionPedido
	( @IdProveedor INT ,
	  @IdAceptacionPedido INT ,
	  @IdPeticionOferta INT )
RETURNS INT
AS
	BEGIN
		DECLARE @IdAceptacion INT

		SELECT		@IdAceptacion = AP.IdAceptacionPedido
		FROM		MM_AceptacionPedido AS AP
		INNER JOIN	MM_Pedido AS MP
			ON MP.IdPedido = AP.IdPedido
		WHERE
					AP.IdProveedor = @IdProveedor
					AND AP.IdAceptacionPedido = @IdAceptacionPedido
					AND MP.IdPeticionOferta = @IdPeticionOferta

		RETURN @IdAceptacion
	END