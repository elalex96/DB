-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/07/2020>
-- Description:	<Consulta del historial de la operacion del pedimento/comprobante compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaHistorialPedimentoComprobante_CD] 
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		HFT.Descripcion,
		HFT.Fecha
	FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
		JOIN dbo.FI_PedimentoComprobante AS PC 
			ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
		JOIN dbo.TA_Operacion AS OP
			ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
			AND OP.IdTipoOperacion = 19
			AND OP.IdProveedor = APC.IdProveedor
		JOIN dbo.TA_HistorialFlujoTarea AS HFT
			ON HFT.IdOperacion = OP.IdOperacion
	WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante
	ORDER BY HFT.Fecha;
END
