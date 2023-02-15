USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_WDEA_ReporteRemanentesCabecera'
)
    DROP PROCEDURE SP_MM_WDEA_ReporteRemanentesCabecera;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/01/2023
-- Description:	Consulta de cabecera de pedidos del reporte de remanentes
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_WDEA_ReporteRemanentesCabecera] 
	@FechaInicio DATE,
	@FechaFin DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	CREATE TABLE #CABECERA(
		PO NVARCHAR(20),
		Proveedor NVARCHAR(500),
		SolicitudPedido INT,
		IdPedido INT
	);

	CREATE TABLE #CABECERA_DETALLE_PEDIDO(
		PO NVARCHAR(20),
		TotalPedido FLOAT,
		Proveedor NVARCHAR(500),
		SolicitudPedido INT,
		IdPedido INT
	);

	CREATE TABLE #CABECERA_DETALLE_ACEPTACION(
		PO NVARCHAR(20),
		TotalPedido FLOAT,
		TotalPedidoAceptado FLOAT,
		Proveedor NVARCHAR(500),
		SolicitudPedido INT,
		IdPedido INT
	);

	INSERT INTO #CABECERA(
		PO,
		Proveedor,
		SolicitudPedido,
		IdPedido
	)
	SELECT
		ISNULL(PIM.PURCHASING_DOCUMENT,'N/A'),
		PR.RazonSocial,
		P.IdSolicitudPedido,
		P.IdPedido
	FROM MM_Pedido AS P (NOLOCK)
		JOIN MM_PedidoDetalle AS PD (NOLOCK)
			ON P.IdPedido = PD.IdPedido
			AND P.IdContrato IN (10045,10044,10046,10038,10144)--CONTRATOS DE WDEA
		JOIN MM_PeticionOfertaDetalle AS POF (NOLOCK)
			ON PD.IdPeticionOfertaDetalle = POF.IdPeticionOfertaDetalle
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS PIM (NOLOCK)
			ON P.IdPedido = PIM.IdPedidoADINCO
			AND POF.IdMaterial = PIM.IDMATERIAL
		JOIN MM_AceptacionPedido AS AP (NOLOCK)
			ON P.IdPedido = AP.IdPedido
			AND ISNULL(AP.Activo,0) = 1
			AND ISNULL(AP.IdEliminado,0) = 0
		JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
			AND PD.IdPedidoDetalle = APD.IdPedidoDetalle
		JOIN S_Proveedor AS PR (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
	WHERE IdAceptacionPedidoDetalle IS NOT NULL
		AND (PD.Cantidad <> APD.Cantidad)
		AND AP.IdAceptacionPedido IS NOT NULL
		AND CAST(P.CreadoEl AS DATE) BETWEEN @FechaInicio AND @FechaFin
	GROUP BY PIM.PURCHASING_DOCUMENT,
			PR.RazonSocial,
			P.IdSolicitudPedido,
			P.IdPedido;


	INSERT INTO #CABECERA_DETALLE_PEDIDO(
		PO,
		TotalPedido,
		Proveedor,
		SolicitudPedido,
		IdPedido
	)
	SELECT
		C.PO,
		SUM(PD.Cantidad * PD.PrecioUnitario),
		C.Proveedor,
		C.SolicitudPedido,
		C.IdPedido
	FROM #CABECERA AS C
	JOIN MM_PedidoDetalle AS PD (NOLOCK)
		ON C.IdPedido = PD.IdPedido
	GROUP BY C.PO,
			C.Proveedor,
			C.SolicitudPedido,
			C.IdPedido;

	INSERT INTO #CABECERA_DETALLE_ACEPTACION(
		PO,
		TotalPedido,
		TotalPedidoAceptado,
		Proveedor,
		SolicitudPedido,
		IdPedido
	)
	SELECT
		C.PO,
		C.TotalPedido,
		SUM(ISNULL(APD.Cantidad,0) * ISNULL(APD.PrecioUnitario,PD.PrecioUnitario)),
		C.Proveedor,
		C.SolicitudPedido,
		C.IdPedido
	FROM #CABECERA_DETALLE_PEDIDO AS C
	JOIN MM_PedidoDetalle AS PD (NOLOCK)
		ON C.IdPedido = PD.IdPedido
	JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
	JOIN MM_AceptacionPedido AS AP (NOLOCK)
		ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
		AND ISNULL(AP.Activo,0) = 1
		AND ISNULL(AP.IdEliminado,0) = 0
	GROUP BY C.PO,
			C.Proveedor,
			C.SolicitudPedido,
			C.IdPedido,
			C.TotalPedido;


	SELECT
		PO,
		TotalPedido,
		TotalPedidoAceptado,
		(TotalPedido - TotalPedidoAceptado) AS TotalPedidoDisponible,
		Proveedor,
		SolicitudPedido,
		IdPedido
	FROM #CABECERA_DETALLE_ACEPTACION
	GROUP BY PO,
		TotalPedido,
		TotalPedidoAceptado,
		Proveedor,
		SolicitudPedido,
		IdPedido;
	
END
