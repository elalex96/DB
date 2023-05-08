-- =============================================
-- Author:		<Pedro Acu�a>
-- Create date: <30-09-2018>
-- Description:	<obtener el tipo de compra>
-- =============================================

CREATE PROCEDURE SP_ObtenerTipoMetodoCompra @IdSolicitudPedido INT
AS
	BEGIN
		SELECT	IdTipoProceso
		FROM	dbo.MM_SolicitudPedido
		WHERE	IdSolicitudPedido = @IdSolicitudPedido
	END