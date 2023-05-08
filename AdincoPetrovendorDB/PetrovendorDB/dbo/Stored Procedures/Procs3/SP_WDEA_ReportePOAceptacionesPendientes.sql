-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <14/12/2022>
-- Description:	<consulta de aceptaciones con remaSP_WDEA_ReportePOAceptacionesPendientesnentes>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WDEA_ReportePOAceptacionesPendientes]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATE,
	@FechaFin DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		PR.RazonSocial AS Suplier,
		PIM.PURCHASING_DOCUMENT AS POReference,
		P.IdSolicitudPedido AS SolPed,
		AP.IdAceptacionPedido AS AcceptanceNumber,
		CC.CentroCosto AS CostCenter,
		PIM.WBS_ELEMENT AS WBS,
		POF.MaterialCotizadoTextoC AS POITEM,
		PD.Cantidad AS Units,
		PD.PrecioUnitario AS UnitPrice,
		PM.TipoMonedaCorto AS Currency,
		(PD.PrecioUnitario * PD.Cantidad) AS TotalPrice,
		(PD.Cantidad - APD.Cantidad) AS POLineRemainingQty,
		((PD.Cantidad - APD.Cantidad) * PD.PrecioUnitario) AS POLineRemainingValue,
		PIM.TERMINOS_DE_PAGO AS TerminosPago,
		C.NumeroContrato + '-' + AC.NombreAreaContractual AS Contrato,
		P.CreadoEl
	FROM MM_Pedido AS P 
		JOIN MM_PedidoDetalle AS PD
			ON P.IdPedido = PD.IdPedido
		JOIN MM_PeticionOfertaDetalle AS POF
			ON PD.IdPeticionOfertaDetalle = POF.IdPeticionOfertaDetalle
		JOIN WDEA_PurchasingDocumentsImportados AS PIM
			ON P.IdPedido = PIM.IdPedidoADINCO
			AND POF.IdMaterial = PIM.IDMATERIAL
		JOIN MM_AceptacionPedido AS AP
			ON P.IdPedido = AP.IdPedido
		JOIN MM_AceptacionPedidoDetalle AS APD	
			ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
			AND PD.IdPedidoDetalle = APD.IdPedidoDetalle
		JOIN S_Proveedor AS PR
			ON P.IdSubcontratista = PR.IdProveedor
		JOIN PV_TipoMoneda AS PM
			ON P.IdMoneda = PM.IdMoneda
		JOIN Adinco..CO_Contrato AS C
			ON P.IdContrato = C.IdContrato
		JOIN Adinco..CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual
		JOIN CC_CentroCosto AS CC
			ON PIM.COST_CENTER = CC.IdCentroCosto
	WHERE IdAceptacionPedidoDetalle IS NOT NULL
		AND (PD.Cantidad <> APD.Cantidad)
		AND CAST(P.CreadoEl AS DATE) BETWEEN @FechaInicio AND @FechaFin
	GROUP BY PR.RazonSocial,
		PIM.PURCHASING_DOCUMENT,
		P.IdSolicitudPedido,
		AP.IdAceptacionPedido,
		CC.CentroCosto,
		PIM.WBS_ELEMENT,
		POF.MaterialCotizadoTextoC,
		PD.Cantidad,
		PD.PrecioUnitario,
		PM.TipoMonedaCorto,
		PD.PrecioUnitario,
		PD.Cantidad,
		APD.Cantidad,
		PIM.TERMINOS_DE_PAGO,
		C.NumeroContrato,
		AC.NombreAreaContractual,
		P.CreadoEl;

END