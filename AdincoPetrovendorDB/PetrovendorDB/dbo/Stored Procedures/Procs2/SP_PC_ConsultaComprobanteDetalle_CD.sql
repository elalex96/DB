-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/10/2020>
-- Description:	<COnsulta del detalle del comprobante para su edicion>
-- =============================================
CREATE PROCEDURE SP_PC_ConsultaComprobanteDetalle_CD --1179,420,0
	-- Add the parameters for the stored procedure here
	@IdComprobante INT,
	@IdProveedor INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		PC.IdPedimentoComprobante,
		PC.FolioComprobante,
		PC.FechaPago,
		PC.IdSubcontratistaExportador,
		PC.IdMoneda,
		PC.CvTipoDocFacturacion,
		ISNULL(PC.EsnotaCredito,0) AS EsnotaCredito,
		PC.IdCentroCosto,
		PC.IdCuentaContable,
		PC.NumFacturaC,
		PCD.IdUnidadMedida,
		PCD.ClaseBienServicio,
		PCD.PrecioUnitario,
		TA.IdFlujoTarea
	FROM dbo.FI_PedimentoComprobante AS PC
		JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD
			ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
			ON APC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
		JOIN dbo.TA_Operacion AS TA
			ON TA.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
			AND TA.IdProveedor = APC.IdProveedor
			AND TA.IdTipoOperacion = 19
	WHERE PC.IdPedimentoComprobante = @IdComprobante;

END