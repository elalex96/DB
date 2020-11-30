-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_ActualizarPCN_PedidoDetalle]

@PCN float,
@IdAceptacionPedidoDetalle int, 
@CreadoPor int
 
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 

	UPDATE MM_AceptacionPedidoDetalle
	SET PCN = @PCN,
	PCN_Agregado = 1
	WHERE IdAceptacionPedidoDetalle= @IdAceptacionPedidoDetalle


	----Actualizar Estatus de PCN_Agregado de MM_AceptacionPedido si todos los detalles tiene 
	---- Su PCN_Agregado en 1
	DECLARE @IdAceptacionPedido INT = (SELECT AP.IdAceptacionPedido
									FROM MM_AceptacionPedido AS AP
									INNER JOIN MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido =		   AP.IdAceptacionPedido
									WHERE APD.IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle )

	DECLARE @TOTAL_MM_PCN INT  = (SELECT COUNT(APD.IdAceptacionPedido)
									FROM MM_AceptacionPedidoDetalle AS APD
									INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido=					   APD.IdAceptacionPedido
									WHERE APD.IdAceptacionPedido =@IdAceptacionPedido )

	DECLARE @TOTAL_MM_PCN_ADD INT  = (SELECT COUNT(APD.IdAceptacionPedido)
									FROM MM_AceptacionPedidoDetalle AS APD
									INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido=					   APD.IdAceptacionPedido
									WHERE APD.IdAceptacionPedido =@IdAceptacionPedido AND APD.PCN_Agregado = 1)


	IF @TOTAL_MM_PCN = @TOTAL_MM_PCN_ADD
	BEGIN 
		UPDATE MM_AceptacionPedido
		SET PCN_Agregado = 1
		WHERE IdAceptacionPedido = @IdAceptacionPedido

	END 


	SELECT 'SUCCESS' AS RESPONSE

END

