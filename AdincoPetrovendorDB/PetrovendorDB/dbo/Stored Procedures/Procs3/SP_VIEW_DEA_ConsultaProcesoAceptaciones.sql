-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/05/2020>
-- Description:	<Consulta de las aceptaciones referentes a dea>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VIEW_DEA_ConsultaProcesoAceptaciones] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @IDCONTRATO INT = (10038);

DECLARE @CENTROSCOSTOS TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
DECLARE @ACEPTACIONESCN TABLE(IdAceptacionPedido INT, 
								FechaRecepcionCN DATETIME,
								FechaEvaluacionCN DATETIME,
								EstatusCartaCN NVARCHAR(100),
								UsuarioEvaluaCN NVARCHAR(100));

--SE OBTIENEN LOS CC POR CONTRATO Y SOLPED
INSERT INTO @CENTROSCOSTOS
SELECT DISTINCT
    SPC.IdSolicitudPedido,
    CC.CentroCosto
FROM dbo.MM_SolicitudPedido AS SPC
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
        ON SPD.IdSolicitudPedido = SPC.IdSolicitudPedido
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
        ON SPLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
    LEFT JOIN dbo.CC_CentroCosto AS CC
        ON CC.IdCentroCosto = SPLP.IdCentroCosto
WHERE SPC.IdContrato = @IDCONTRATO
    AND (CC.CentroCosto IS NOT NULL OR CC.CentroCosto <> '');


INSERT INTO @ACEPTACIONESCN
SELECT
	AP.IdAceptacionPedido,
	(SELECT TOP 1 CreadoEl FROM dbo.MM_AceptacionCartaPCN WHERE IdAceptacionPedido = AP.IdAceptacionPedido ORDER BY CreadoEl DESC),
	(SELECT TOP 1 FechaEvaluacion FROM dbo.MM_AceptacionCartaPCN WHERE IdAceptacionPedido = AP.IdAceptacionPedido ORDER BY CreadoEl DESC),
	(SELECT TOP 1 
		EST.Nombre 
	FROM dbo.MM_AceptacionCartaPCN AS APC 
		LEFT JOIN dbo.TA_Estatus AS EST
			ON EST.IdEstatus = APC.IdEstatus
	WHERE APC.IdAceptacionPedido = AP.IdAceptacionPedido 
	ORDER BY APC.CreadoEl DESC),
	(SELECT TOP 1 
		US.Nombre
	FROM dbo.MM_AceptacionCartaPCN AS APC 
		LEFT JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = APC.IdUsuarioEvaluador
	WHERE APC.IdAceptacionPedido = AP.IdAceptacionPedido ORDER BY APC.CreadoEl DESC)
FROM dbo.MM_AceptacionPedido AS AP
	INNER JOIN dbo.MM_Pedido AS P
		ON P.IdPedido = AP.IdPedido
WHERE P.IdContrato = @IDCONTRATO


SELECT
	SP.IdSolicitudPedido,
	ISNULL(ESOT.FolioEstimacion,'N/A') AS Folio,
	SP.MotivoUrgencia AS Descripcion,
	CC.CentroCosto,
	PS.IdPedido,
	PR.RazonSocial + '(' + PR.RFC + ')' AS Proveeedor,
	--'Concepto: ' + MA.DescripcionCorta + ' - Unidad:' + MU.Unidad + ' - Cantidad: ' + CAST(PD.Cantidad AS NVARCHAR(100)) AS DescripcionPedido,
	CASE
		WHEN ESOT.FolioEstimacion IS NOT NULL THEN P.CreadoEl
		ELSE P.FechaRecepcionServicio
	END AS FechaPedido,
	CASE
		WHEN SP.UnaSolaEntregaRequerida = 1 THEN 'Unica'
		ELSE 'Parcial'
	END AS TipoEntrega,
	USPR.Nombre AS UsuarioAceptaPedido,
	AP.Creado AS FechaAceptacionPedido,
	(CASE
		WHEN ESOT.FolioEstimacion IS NOT NULL THEN (dbo.CalcularTipoDEA(P.CreadoEl,AP.Creado))
		ELSE (dbo.CalcularTipoDEA(PRPO.FechaAltaRelacion,AP.Creado))										
	END) AS DiasAceptacionPedido,
	AP.IdAceptacionPedido AS NumeroAceptacionPedido,
	APCN.FechaRecepcionCN AS FechaRecepcionCartaCN,
	(dbo.CalcularTipoDEA(AP.Creado,APCN.FechaRecepcionCN)) AS DiasRecepcionCartaCartaCN,
	APCN.UsuarioEvaluaCN AS UsuarioApruebaCartaCN,
	APCN.FechaEvaluacionCN AS FechaAprobacionCartaCN,
	(dbo.CalcularTipoDEA(APCN.FechaRecepcionCN,APCN.FechaEvaluacionCN)) AS DiasAprobacionCartaCN,
	APCN.EstatusCartaCN,
	TOF.FechaRegistro AS FechaRecepcionFactura,
	(dbo.CalcularTipoDEA(APCN.FechaEvaluacionCN,TOF.FechaRegistro)) AS DiasRecepcionFactura,
	FI.Folio AS FolioFactura,
	UST1.Nombre AS Responsable1aAprobacion,
	TF1.FechaCambioEstatus AS Fecha1aAprobacion,
	(dbo.CalcularTipoDEA(TOF.FechaRegistro,TF1.FechaCambioEstatus)) AS DiasEspera1aAprobacion,
	EA1.Nombre AS Estatus1aAprobacion,
	UST2.Nombre AS Responsable2aAprobacion,
	TF2.FechaCambioEstatus AS Fecha2aAprobacion,
	(dbo.CalcularTipoDEA(TF1.FechaCambioEstatus,TF2.FechaCambioEstatus)) AS DiasEspera2aAprobacion,
	EA2.Nombre AS Estatus2aAprobacion,
	(dbo.CalcularTipoDEA(PRPO.FechaAltaRelacion,ISNULL(TF2.FechaCambioEstatus,TF1.FechaCambioEstatus))) AS DiasTotal,
	ESF.Nombre AS EstatusAprobacionFactura,
	POAD.ID_PO AS NumeroPO,
	POAD.CreadoEl AS FechaRegistroPO
INTO #DATOSACEPTACIONES
FROM dbo.MM_SolicitudPedido AS SP
	LEFT JOIN @CENTROSCOSTOS AS CC
		ON CC.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_Pedido AS P
		ON P.IdSolicitudPedido = SP.IdSolicitudPedido
	LEFT JOIN dbo.MM_Pedidos AS PS
		ON PS.IdIdentificador = P.IdPedido
		AND PS.IdProveedorCliente = P.IdProveedorCompras
	LEFT JOIN dbo.S_Proveedor AS PR
		ON PR.IdProveedor = P.IdSubcontratista
	LEFT JOIN dbo.MM_AceptacionPedido AS AP
		ON AP.IdPedido = P.IdPedido
	LEFT JOIN @ACEPTACIONESCN AS APCN
		ON APCN.IdAceptacionPedido = AP.IdAceptacionPedido
	LEFT JOIN dbo.MM_AceptacionFactura AS AF
		ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
	--LEFT JOIN dbo.TA_Estatus AS EPCN
	--	ON EPCN.IdEstatus = APCN.IdEstatus
	LEFT JOIN dbo.TA_Operacion AS TOF
		ON TOF.IdDocumento = AF.IdAceptacionFactura
		AND TOF.IdTipoOperacion = 10
	LEFT JOIN dbo.FI_Factura AS FI
		ON FI.IdFactura = AF.IdFactura
	LEFT JOIN dbo.TA_Estatus AS ESF
		ON ESF.IdEstatus = TOF.IdEstatusOperacion
	LEFT JOIN dbo.DEA_Relacion_PR_PO AS PRPO
		ON PRPO.IdPedido = P.IdPedido
	LEFT JOIN dbo.S_Usuario AS USPR
		ON USPR.IdUsuario = AP.CreadorPor
	LEFT JOIN dbo.DEA_AdjuntoPO AS POAD
		ON POAD.IdAdjuntoPO = PRPO.IdAdjuntoPO
	--LEFT JOIN dbo.S_Usuario AS USCN
	--	ON USCN.IdUsuario = APCN.IdUsuarioEvaluador
	LEFT JOIN dbo.TA_Tarea AS TF1
		ON TF1.IdOperacion = TOF.IdOperacion
		AND TF1.NoSecuencia = 1
		AND TF1.IdEstatus <> 12
	LEFT JOIN dbo.S_Usuario AS UST1
		ON UST1.IdUsuario = TF1.IdAprobador
	LEFT JOIN dbo.TA_Tarea AS TF2
		ON TF2.IdOperacion = TOF.IdOperacion
		AND TF2.NoSecuencia = 2
		AND TF2.IdEstatus <> 12
	LEFT JOIN dbo.S_Usuario AS UST2
		ON UST2.IdUsuario = TF2.IdAprobador
	LEFT JOIN dbo.TA_Estatus AS EA1
		ON EA1.IdEstatus = TF1.IdEstatus
	LEFT JOIN dbo.TA_Estatus AS EA2
		ON EA2.IdEstatus = TF2.IdEstatus
	--LEFT JOIN dbo.MM_PedidoDetalle AS PD
	--	ON PD.IdPedido = P.IdPedido
	--LEFT JOIN dbo.MM_Material AS MA
	--	ON MA.IdMaterial = PD.IdMaterial
	--LEFT JOIN dbo.PV_MM_MaterialUnidad AS MU
	-- ON MU.IdUnidad = PD.IdUnidadProveedor
	LEFT JOIN Adinco.dbo.OT_Estimacion AS ESOT
		ON ESOT.IdSolicitudPedido = SP.IdSolicitudPedido
WHERE SP.IdContrato = @IDCONTRATO
	AND P.IdPedido IS NOT NULL
	AND PRPO.ID_R_PR_PO IS NOT NULL
	AND AP.IdAceptacionPedido IS NOT NULL
	--AND SP.IdSolicitudPedido NOT IN (SELECT IdSolicitudPedido FROM Adinco.dbo.OT_Estimacion)
GROUP BY PR.RazonSocial,
		 PR.RFC,
		 SP.UnaSolaEntregaRequerida,
		 PRPO.FechaAltaRelacion,
		 AP.Creado,
		 TOF.FechaRegistro,
         SP.IdSolicitudPedido,
         SP.MotivoUrgencia,
         CC.CentroCosto,
         PS.IdPedido,
         P.Comentarios,
         PRPO.FechaAltaRelacion,
         USPR.Nombre,
         AP.Creado,
         AP.IdAceptacionPedido,
         --USCN.Nombre,
         TOF.FechaRegistro,
         FI.Folio,
         ESF.Nombre,
		 TF2.FechaCambioEstatus,
		 USPR.Nombre,
		 UST1.Nombre,
		 --TF1.FechaCambioEstatus,
		 UST2.Nombre,
		 EA1.Nombre,
		 EA2.Nombre,
		 FechaRecepcionCN,
		 FechaEvaluacionCN,
		 EstatusCartaCN,
		 UsuarioEvaluaCN,
		 --MA.DescripcionCorta,
		 --MU.Unidad,
		 --PD.Cantidad,
		 P.FechaRecepcionServicio,
		 ESOT.FolioEstimacion,
		 TF1.FechaCambioEstatus,
		 P.CreadoEl,
		 POAD.ID_PO,
		POAD.CreadoEl
ORDER BY PS.IdPedido DESC

DELETE FROM dbo.DEA_ProcesoAceptaciones;

INSERT INTO dbo.DEA_ProcesoAceptaciones
(
    IdSolicitudPedido,
    Folio,
    Descripcion,
    CentroCosto,
    NumeroPedido,
    Proveedor,
    FechaPedidoFechaConfirmacion,
    TipoEntrega,
    UsuarioAceptaPedido,
    FechaAceptacionPedido,
    DiasAceptacionPedido,
    NumeroAceptacionPedido,
    FechaRecepcionCartaCN,
    DiasRecepcionCartaCN,
    UsuarioApruebaCartaCN,
    FechaAprobacionCartaCN,
    DiasAprobacionCartaCN,
    EstatusCartaCN,
    FechaRecepcionFactura,
    DiasRecepcionFactura,
    FolioFactura,
    Responsable1aAprobacion,
    Fecha1aAprobacion,
    DiasEspera1aAprobacion,
    Estatus1aAprobacion,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    DiasEspera2aAprobacion,
    Estatus2aAprobacion,
    DiasEnAprobacion,
    DiasTotal,
    EstatusAprobacionFactura,
	NumeroPO,
	FechaRegistroPO
)
SELECT 
	IdSolicitudPedido AS IdSolicitudPedido,
	Folio AS Folio,
	Descripcion AS Descripcion,
	CentroCosto AS CentroCosto,
	IdPedido AS NumeroPedido,
	Proveeedor AS Proveedor,
	FechaPedido AS FechaPedidoFechaConfirmacionPedido,
	TipoEntrega AS TipoEntrega,
	UsuarioAceptaPedido AS UsuarioAceptaPedido,
	FechaAceptacionPedido AS FechaAceptacionPedido,
	CASE
		WHEN FechaAceptacionPedido IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasAceptacionPedido),0.00)
	END AS DiasAceptacionPedido,
	NumeroAceptacionPedido AS NumeroAceptacionPedido,
	FechaRecepcionCartaCN AS FechaRecepcionCartaCN,
	CASE
		WHEN FechaRecepcionCartaCN IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionCartaCartaCN),0.00)
	END AS DiasRecepcionCartaCartaCN,
	UsuarioApruebaCartaCN AS UsuarioApruebaCartaCN,
	FechaAprobacionCartaCN  AS FechaAprobacionCartaCN,
	CASE
		WHEN FechaAprobacionCartaCN IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasAprobacionCartaCN),0.00)
	END AS DiasAprobacionCartaCN,
	EstatusCartaCN AS EstatusCartaCN,
	FechaRecepcionFactura AS FechaRecepcionFactura,
	CASE
		WHEN FechaRecepcionFactura IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionFactura),0.00)
	END AS DiasRecepcionFactura,
	FolioFactura AS FolioFactura,
	Responsable1aAprobacion AS Responsable1aAprobacion,
	Fecha1aAprobacion AS Fecha1aAprobacion,
	CASE
		WHEN Fecha1aAprobacion IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasEspera1aAprobacion),0.00)
	END AS DiasEspera1aAprobacion,
	Estatus1aAprobacion AS Estatus1aAprobacion,
	Responsable2aAprobacion AS Responsable2aAprobacion,
	Fecha2aAprobacion AS Fecha2aAprobacion,
	CASE
		WHEN Fecha2aAprobacion IS NULL THEN NULL
		ELSE CONVERT(VARCHAR,ISNULL(CONVERT(DECIMAL(5,2),DiasEspera2aAprobacion),0))
	END AS DiasEspera2aAprobacion,
	Estatus2aAprobacion AS Estatus2aAprobacion,
	( 
		ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionFactura),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasEspera1aAprobacion),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasEspera2aAprobacion),0.00)
	) AS DiasEnAprobacion,
	(
		ISNULL(CONVERT(DECIMAL(5,2),DiasAceptacionPedido),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionCartaCartaCN),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasAprobacionCartaCN),0.00) +  
		ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionFactura),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasEspera1aAprobacion),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasEspera2aAprobacion),0.00)
	) AS DiasTotal,
	EstatusAprobacionFactura AS EstatusAprobacionFactura,
	NumeroPO AS NumeroPO,
	FechaRegistroPO AS FechaRegistroPO
FROM #DATOSACEPTACIONES
ORDER BY IdSolicitudPedido DESC

DROP TABLE #DATOSACEPTACIONES;

END
