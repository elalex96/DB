-- =============================================
-- Author: Pedro Acuña
-- Create date: 22/06/2018
-- Description: obtener la fecha de la aceptacion del pedido del proveedor
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAceptacionProveedor
	( @IdProveedor INT ,
	  @IdPedido INT ,
	  @IdPeticionOferta INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaRetorno DATETIME

		SELECT		@FechaRetorno = P.FechaRecepcionServicio
		FROM		MM_Pedido AS P
		INNER JOIN	MM_PeticionOferta AS PO
			ON PO.IdPeticionOFerta = P.IdPeticionOferta
		INNER JOIN	S_Proveedor AS PV
			ON PV.IdProveedor = P.IdSubcontratista
		INNER JOIN	TA_Operacion AS O
			ON O.IdDocumento = P.IdSolicitudPedido
			   AND	p.Version = o.NoVersion
		WHERE
					O.IdProveedor = @IdProveedor
					AND P.IdPedido = @IdPedido
					AND O.IdTipoOperacion = 9
					AND PO.IdPeticionOferta = @IdPeticionOferta

		RETURN @FechaRetorno
	END