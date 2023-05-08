-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/01/2023
-- Description:	consulta de los detalles de PO para reporte de remanentes
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_DetalleReporteRemanentes] --28414
	-- Add the parameters for the stored procedure here
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE TABLE #DETALLES_PEDIDO(
		Item NVARCHAR(3000),
		CantidadPedido FLOAT,
		Valor FLOAT,
		Moneda NVARCHAR(100),
		WBS NVARCHAR(100),
		CentroCosto NVARCHAR(100),
		IdPedidoDetalle INT
	);

	INSERT INTO #DETALLES_PEDIDO(
		Item,
		CantidadPedido,
		Valor,
		Moneda,
		WBS,
		CentroCosto,
		IdPedidoDetalle
	)
	SELECT
		POF.MaterialCotizadoTextoC,
		PD.Cantidad,
		PD.PrecioUnitario,
		PM.TipoMonedaCorto,
		ISNULL(PIM.WBS_ELEMENT,'N/A') AS WBS_ELEMENT,
		ISNULL(CC.CentroCosto,C.CentroCosto) AS CentroCosto,
		PD.IdPedidoDetalle
	FROM MM_Pedido AS P (NOLOCK)
		JOIN MM_PedidoDetalle AS PD (NOLOCK)
			ON P.IdPedido = PD.IdPedido
			AND PD.IdPedido = @IdPedido
		JOIN MM_PeticionOfertaDetalle AS POF (NOLOCK)
			ON PD.IdPeticionOfertaDetalle = POF.IdPeticionOfertaDetalle
		JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		JOIN PV_TipoMoneda AS PM (NOLOCK)
			ON P.IdMoneda = PM.IdMoneda
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS PIM (NOLOCK)
			ON P.IdPedido = PIM.IdPedidoADINCO
			AND POF.IdMaterial = PIM.IDMATERIAL
		LEFT JOIN CC_CentroCosto AS CC (NOLOCK)
			ON PIM.COST_CENTER = CC.IdCentroCosto
		LEFT JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
			ON POF.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
		LEFT JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK)
			ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle
		LEFT JOIN CC_CentroCosto AS C (NOLOCK)
			ON SPDLP.IdCentroCosto = C.IdCentroCosto
	GROUP BY POF.MaterialCotizadoTextoC,
		PD.Cantidad,
		PD.PrecioUnitario,
		PM.TipoMonedaCorto,
		PIM.WBS_ELEMENT,
		CC.CentroCosto,
		PD.IdPedidoDetalle,
		C.CentroCosto;

	SELECT
		PD.Item,
		PD.CantidadPedido,
		PD.Valor,
		SUM(APD.Cantidad) AS CantidadAceptado,
		(PD.CantidadPedido - SUM(APD.Cantidad)) AS CantidadDisponible,
		PD.Moneda,
		PD.WBS,
		PD.CentroCosto,
		PD.IdPedidoDetalle
	FROM #DETALLES_PEDIDO AS PD
	JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
	JOIN MM_AceptacionPedido AS AP (NOLOCK)
		ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
		AND ISNULL(AP.Activo,0) = 1
		AND ISNULL(AP.IdEliminado,0) = 0
	GROUP BY PD.Item,
		PD.CantidadPedido,
		PD.Valor,
		PD.Moneda,
		PD.WBS,
		PD.CentroCosto,
		PD.IdPedidoDetalle;

END
