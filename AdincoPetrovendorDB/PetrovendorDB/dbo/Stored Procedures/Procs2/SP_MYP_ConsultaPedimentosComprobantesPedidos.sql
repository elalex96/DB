-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/12/2018
-- Description:	Consultar los pedimentos comprobantes de un pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MYP_ConsultaPedimentosComprobantesPedidos]
	-- Add the parameters for the stored procedure here
	@IdPedido NVARCHAR(50),
	@IdProveedor NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		PCP.FolioComprobante,
		PCP.NumeroPedimento,
		PCP.FechaPago,
		PCPD.PrecioUnitario,
		CASE
			WHEN PCPD.IdUnidadMedida = 1 THEN 'Material'
			WHEN PCPD.IdUnidadMedida = 2 THEN 'Service'
		END AS Unidad,
		TM.TipoMonedaCorto,
		PCPD.DescripcionMercancia,
		RPCP.IdRelacionPedimentoComprobante
	FROM dbo.MPY_FI_RelacionPedimentoComprobantePedido AS RPCP
		LEFT JOIN Adinco.dbo.FI_PedimentoComprobante AS PCA ON PCA.IdPedimentoComprobante = RPCP.IdPedimentoComprobanteADINCO
		LEFT JOIN dbo.FI_PedimentoComprobante AS PCP ON PCP.IdPedimentoComprobante = PCA.IdPedimentoComprobantePetrovendor
		LEFT JOIN dbo.FI_PedimentoComprobanteDetalle AS PCPD ON PCPD.IdPedimentoComprobante = PCP.IdPedimentoComprobante
		--LEFT JOIN dbo.PV_MM_MaterialUnidad AS UN ON UN.IdUnidad = PCPD.IdUnidadMedida
		LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PCP.IdMoneda
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = PCP.IdSubcontratistaExportador
		LEFT JOIN dbo.S_Proveedor AS OP ON OP.IdProveedor = PCP.IdSubcontratistaImportador
	WHERE RPCP.IdPedido = @IdPedido
	AND RPCP.IdProveedorVenta = @IdProveedor

END
