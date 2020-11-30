-- =============================================
-- Author:		<Pedro Acu�a>
-- Create date: <07-09-2018>
-- Description:	<llenar el combo de solicitud de pedido de la consola para documentos S3>
-- =============================================

create PROCEDURE ADM_CmbSolicituPedidoDocumentosS3
AS
	BEGIN
		DECLARE @tablaAux TABLE (IdSolicitudPedido INT)

		INSERT INTO @tablaAux
			( IdSolicitudPedido )
		SELECT IdSolicitudPedido FROM dbo.MM_PeticionOfertaADAdjunto

		INSERT INTO @tablaAux
			( IdSolicitudPedido )
		SELECT IdSolicitudPedido FROM dbo.MM_SolicitudPedido WHERE IdSolicitudPedido NOT IN (SELECT IdSolicitudPedido FROM @tablaAux)

		SELECT DISTINCT IdSolicitudPedido, IdSolicitudPedido FROM @tablaAux
	END
