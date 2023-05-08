-- =============================================
-- Author:		Pedro Acuña
-- Create date: 27/03/2018
-- Description:	revisar si el proveedor ya ah sido agregado a la cotizacion
-- =============================================
CREATE PROCEDURE SP_RevisarExisteProveedorEnCotizacion @IdProveedor INT, @IdSolicitudPedido INT
AS
	BEGIN
		SELECT 1
		FROM   dbo.MM_PeticionOferta
		WHERE
			   IdSolicitudPedido = @IdSolicitudPedido
			   AND IdSubcontratista = @IdProveedor
	END