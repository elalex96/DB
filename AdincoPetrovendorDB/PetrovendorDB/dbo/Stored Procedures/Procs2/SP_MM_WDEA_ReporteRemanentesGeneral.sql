-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/02/2023
-- Description:	Consulta general de pedidos del reporte de remanentes
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_WDEA_ReporteRemanentesGeneral] 
	@FechaInicio DATE,
	@FechaFin DATE,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	CREATE TABLE #CABECERA_DETALLE_ACEPTACION(
		Contrato NVARCHAR(200),
		Solicitante NVARCHAR(100),
		PO NVARCHAR(20),
		TotalPedido FLOAT,
		SolicitudPedido INT,
		Proveedor NVARCHAR(500),
		WBS NVARCHAR(100),
		IdPedido INT,
		IdPedidoDetalle INT
	);

	CREATE TABLE #CABECERA_DETALLE_ACEPTACION_AGRUPADO(
		Contrato NVARCHAR(200),
		Solicitante NVARCHAR(100),
		PO NVARCHAR(20),
		TotalPedido FLOAT,
		SolicitudPedido INT,
		Proveedor NVARCHAR(500),
		WBS NVARCHAR(100),
		IdPedido INT,
	);

	INSERT INTO #CABECERA_DETALLE_ACEPTACION
	(
		Contrato,
		Solicitante,
		PO,
		TotalPedido,
		SolicitudPedido,
		Proveedor,
		WBS,
		IdPedido,
		IdPedidoDetalle
	)
	SELECT
		CON.NumeroContrato + '-' + ACON.NombreAreaContractual AS Contrato,
		US.Nombre AS Solicitante,
		ISNULL(PIM.PURCHASING_DOCUMENT,'N/A') AS PO,
		PD.PrecioUnitario * PD.Cantidad AS TotalPO,
		P.IdSolicitudPedido,
		PR.RazonSocial,
		ISNULL(PIM.WBS_ELEMENT,'N/A') AS WBS,
		P.IdPedido,
		PD.IdPedidoDetalle
	FROM MM_Pedido AS P (NOLOCK)
		JOIN MM_PedidoDetalle AS PD (NOLOCK)
			ON P.IdPedido = PD.IdPedido
			AND P.IdContrato = @IdContrato
			AND ISNULL(P.IdEstatusEliminado,0) = 0 --> CTE SOLO PEDIDOS NO ELIMINADOS
			AND CAST(P.CreadoEl AS DATE) BETWEEN @FechaInicio AND @FechaFin
		JOIN MM_PeticionOfertaDetalle AS POF (NOLOCK)
			ON PD.IdPeticionOfertaDetalle = POF.IdPeticionOfertaDetalle
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS PIM (NOLOCK)
			ON P.IdPedido = PIM.IdPedidoADINCO
			AND POF.IdMaterial = PIM.IDMATERIAL
		JOIN MM_AceptacionPedido AS AC (NOLOCK)
			ON P.IdPedido = AC.IdPedido
			AND ISNULL(AC.Activo,0) = 1
			AND ISNULL(AC.IdEliminado,0) = 0
			AND AC.IdAceptacionPedido IS NOT NULL
		JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON AC.IdAceptacionPedido = APD.IdAceptacionPedido
			AND PD.IdPedidoDetalle = APD.IdPedidoDetalle
			AND (PD.Cantidad <> APD.Cantidad)
			AND APD.IdAceptacionPedidoDetalle IS NOT NULL
		JOIN Adinco..CO_Contrato AS CON (NOLOCK)
			ON P.IdContrato = CON.IdContrato
		JOIN Adinco..CO_AreaContractual AS ACON (NOLOCK)
			ON CON.IdAreaContractual = ACON.IdAreaContractual
		JOIN MM_SolicitudPedido AS SP (NOLOCK)
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido
		JOIN S_Usuario AS US (NOLOCK)
			ON SP.Solicitante = US.IdUsuario
		JOIN S_Proveedor AS PR (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
	GROUP BY CON.NumeroContrato + '-' + ACON.NombreAreaContractual,
		US.Nombre,
		ISNULL(PIM.PURCHASING_DOCUMENT,'N/A'),
		P.IdSolicitudPedido,
		PR.RazonSocial,
		P.IdPedido,
		ISNULL(PIM.WBS_ELEMENT,'N/A'),
		PD.PrecioUnitario * PD.Cantidad,
		PD.IdPedidoDetalle;

	INSERT INTO #CABECERA_DETALLE_ACEPTACION_AGRUPADO
	(
		Contrato,
		Solicitante,
		PO,
		TotalPedido,
		SolicitudPedido,
		Proveedor,
		WBS,
		IdPedido
	)
	SELECT
		Contrato,
		Solicitante,
		PO,
		SUM(TotalPedido),
		SolicitudPedido,
		Proveedor,
		WBS,
		IdPedido
	FROM #CABECERA_DETALLE_ACEPTACION
	GROUP BY Contrato,
		Solicitante,
		PO,
		SolicitudPedido,
		Proveedor,
		WBS,
		IdPedido;

	SELECT
		CB.Contrato,
		CB.Solicitante,
		CB.PO,
		CB.TotalPedido,
		AP.IdAceptacionPedido,
		CB.SolicitudPedido,
		CB.Proveedor,
		POF.MaterialCotizadoTextoL AS Item,
		CAST(APD.Cantidad AS NVARCHAR) AS CantidadAceptada,
		CAST((PD.Cantidad - APD.Cantidad) AS NVARCHAR) AS CantidadDisponible,
		AP.Creado AS FechaAceptacion,
		AP.Comentario AS Comentario,
		CB.WBS,
		CB.IdPedido,
		APD.IdAceptacionPedidoDetalle
	FROM #CABECERA_DETALLE_ACEPTACION_AGRUPADO AS CB
	JOIN MM_AceptacionPedido AS AP (NOLOCK)
		ON CB.IdPedido = AP.IdPedido
	JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
	JOIN MM_PedidoDetalle AS PD (NOLOCK)
		ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
	JOIN MM_PeticionOfertaDetalle AS POF (NOLOCK)
		ON PD.IdPeticionOfertaDetalle = POF.IdPeticionOfertaDetalle
	GROUP BY CB.Contrato,
		CB.Solicitante,
		CB.PO,
		CB.TotalPedido,
		AP.IdAceptacionPedido,
		CB.SolicitudPedido,
		CB.Proveedor,
		POF.MaterialCotizadoTextoL,
		APD.Cantidad,
		PD.Cantidad,
		AP.Creado,
		AP.Comentario,
		CB.WBS,
		CB.IdPedido,
		APD.IdAceptacionPedidoDetalle
	ORDER BY AP.Creado DESC;
	
END
