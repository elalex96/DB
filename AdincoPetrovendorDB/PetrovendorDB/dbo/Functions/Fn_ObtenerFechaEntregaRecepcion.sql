-- =============================================
-- Author: Pedro Acu�a
-- Create date: 22/06/2018
-- Description: obtener la fecha de entrega recepcion de la operadora
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaEntregaRecepcion
	( @IdProveedor INT ,
	  @IdAceptacionPedido INT ,
	  @IdPeticionOferta INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaRetorno DATETIME

		SELECT		@FechaRetorno = AP.Creado
		FROM		MM_AceptacionPedido AS AP
		INNER JOIN	MM_Pedido AS MP
			ON MP.IdPedido = AP.IdPedido
		WHERE
					AP.IdProveedor = @IdProveedor
					AND AP.IdAceptacionPedido = @IdAceptacionPedido
					AND MP.IdPeticionOferta = @IdPeticionOferta

		RETURN @FechaRetorno
	END