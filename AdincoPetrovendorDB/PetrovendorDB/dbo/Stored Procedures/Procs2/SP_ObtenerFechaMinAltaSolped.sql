-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 23/01/2018
-- Description:	obtener la fehca minima de las solped para colocarla en el filtro
-- =============================================

CREATE PROCEDURE SP_ObtenerFechaMinAltaSolped @IdProveedor INT
AS
	BEGIN
		SELECT	MIN ( FechaAlta )
		FROM	dbo.MM_SolicitudPedido
		WHERE	IdProveedor = @IdProveedor
	END