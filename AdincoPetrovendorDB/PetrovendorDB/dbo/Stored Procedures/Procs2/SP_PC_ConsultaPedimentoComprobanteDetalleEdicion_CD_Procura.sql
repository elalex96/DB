-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/09/2020>
-- Description:	<Consulta a detalle de un Pedimento/Comprobante de Procura>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/11/2020>
-- Description:	<se agrega a la consulta los dias de credito>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaPedimentoComprobanteDetalleEdicion_CD_Procura] --1161,420,0

	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT,
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
		PC.NumeroPedimento,
		PC.FolioComprobante,
		PC.ClavePedimento AS ClavePedimento,
		PC.Regimen,
		PC.AduanaES,
		PC.AcuseElectronico,
		PCD.DescripcionMercancia,
		PCD.Cantidad,
		PC.FechaPago,
		PC.CuentaBancaria,
		PC.NumFacturaC,
		PC.IdMoneda AS Moneda,
		PCD.PrecioUnitario AS SubTotal,
		US.Nombre AS CargadoPor,
		PC.CreadoEn,
		PCD.IdUnidadMedida,
		PC.IdSubcontratistaExportador AS Exportador,
		PCD.ClaseBienServicio,
		PCD.DescripcionMercancia,
		ISNULL(PC.EsnotaCredito,0) AS EsnotaCredito,
		PC.RazonSocialP,
		PCD.ImporteTotal,
		OP.IdFlujoTarea,
		PC.IdFiscalP,
		PC.IdCentroCosto,
		PC.IdCuentaContable,
		PC.DiasCredito
	FROM dbo.FI_PedimentoComprobante AS PC
		JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD
			ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN dbo.TA_Operacion AS OP
			ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
			AND OP.IdTipoOperacion = 19
			AND OP.IdProveedor = APC.IdProveedor
		JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = PC.CreadoPor
		LEFT JOIN Adinco.dbo.PV_TipoMoneda AS TM
			ON TM.IdMoneda = PC.IdMoneda
		LEFT JOIN Adinco.dbo.PV_MM_MaterialUnidad AS UN
			ON UN.IdUnidad = PCD.IdUnidadMedida
		LEFT JOIN Adinco.dbo.PV_Subcontratista AS SC
			ON SC.IdSubcontratista = PC.IdSubcontratistaExportador
		LEFT JOIN Adinco.dbo.PV_Subcontratista AS SI
			ON SI.IdSubcontratista = PC.IdSubcontratistaImportador
		LEFT JOIN Adinco.dbo.FI_ClavesPedimento AS CP 
			ON PC.ClavePedimento = CP.IdPedimento
	WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante


END
