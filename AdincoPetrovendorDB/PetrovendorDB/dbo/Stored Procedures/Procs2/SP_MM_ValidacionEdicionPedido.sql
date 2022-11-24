-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/10/2022
-- Description: Validacion de edicion de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidacionEdicionPedido]
	-- Add the parameters for the stored procedure here
	 @IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @PROCESOS_EN_CURSO INT = 0;

	--SE OBTIENEN LA CANTIDAD DE CARTAS CN RELACIONADAS AL PEDIDO
	DECLARE @CN INT = (SELECT
							COUNT(ACN.IdAceptacionCartaPCN)
						FROM MM_AceptacionCartaPCN AS ACN
							JOIN MM_AceptacionPedido AS AP
								ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido
							JOIN MM_Pedido AS P
								ON AP.IdPedido = P.IdPedido
						WHERE P.IdPedido = @IdPedido
						GROUP BY ACN.IdAceptacionCartaPCN);

	--SE OBTIENE LA CANTIDAD DE FACTURAS ASOCIADAS AL PEDIDO
	DECLARE @FACTURAS INT = (SELECT
								COUNT(AF.IdAceptacionFactura)
							FROM MM_AceptacionFactura AS AF
								JOIN MM_AceptacionPedido AS AP
									ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
								JOIN MM_Pedido AS P
									ON AP.IdPedido = P.IdPedido
							WHERE P.IdPedido = @IdPedido
							GROUP BY AF.IdAceptacionFactura);

	--SE OBTIENE LA CANTIDAD DE COMPROBANTES EXTRANJEROS
	DECLARE @COMPROBANTES INT = (SELECT
								COUNT(AF.IdAceptacionPedidoPedimentoComprobante)
							FROM FI_AceptacionPedido_PedimentoComprobante AS AF
								JOIN MM_AceptacionPedido AS AP
									ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
								JOIN MM_Pedido AS P
									ON AP.IdPedido = P.IdPedido
							WHERE P.IdPedido = @IdPedido
							GROUP BY AF.IdAceptacionPedidoPedimentoComprobante);

	SET @PROCESOS_EN_CURSO = ISNULL(@CN,0) + ISNULL(@FACTURAS,0) + ISNULL(@COMPROBANTES,0);

	IF @PROCESOS_EN_CURSO > 0
	BEGIN

		SELECT 0 AS EDICION_DISPONIBLE

	END
	ELSE
	BEGIN

		SELECT 1 AS EDICION_DISPONIBLE

	END

END
