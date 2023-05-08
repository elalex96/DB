-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <24-09-2018>
-- Description:	<reemplazar el texto del combo para que se muestre el texto personalizado>
-- =============================================

CREATE PROCEDURE SP_ADM_ReemplazarTextoCmbAceptacionPedidoS3 @IdAceptacionPedido INT
AS
	BEGIN
		SELECT	CONVERT ( NVARCHAR(100), IdAceptacionPedido ) + ' - ' + Comentario
		FROM	dbo.MM_AceptacionPedido
		WHERE	IdAceptacionPedido = @IdAceptacionPedido
	END