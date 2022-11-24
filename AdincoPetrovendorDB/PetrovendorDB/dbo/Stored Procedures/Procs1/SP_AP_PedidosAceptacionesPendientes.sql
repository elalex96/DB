
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <28/09/19>
-- Description:	<Consulta los pedidos aprobados,sin cerrar, no eliminados y con aceptaciones pendientes>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_PedidosAceptacionesPendientes] --420
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	create table #tb_solicitadas 
	(
		IdPedido		INT,
		IdPedidoDetalle INT, 
		Cantidad		FLOAT
	)
	
	create table #tb_aceptadas 
	(
		IdPedido		INT,
		IdPedidoDetalle INT, 
		Cantidad		FLOAT
	)

	create table #result 
	(
		IdPedido INT,
		IdSolicitudPedido INT,
		Proveedor VARCHAR(MAX),
		Version INT,
		IdPedidoGeneral INT,
		CreadoEl DATETIME,
		Asignado VARCHAR(MAX),
		ComentariosAsignado VARCHAR(MAX),
		Justificacion VARCHAR(MAX),
		IdContrato INT				
	)

	INSERT INTO #tb_solicitadas
	SELECT
				P.IdPedido,
				PD.IdPedidoDetalle,
				Solicitadas			=	ISNULL(PD.Cantidad,0)
	FROM		MM_Pedido					P	(NOLOCK)
	JOIN	TA_Operacion					O	(NOLOCK)
		ON		 P.IdSolicitudPedido			=	O.IdDocumento
				 AND P.Version						=	O.NoVersion
				 AND O.IdTipoOperacion			=	9 -->CTE 
				 AND O.IdEstatusOperacion		=	2 -- CTE Aprobados		
	LEFT JOIN	MM_PedidoDetalle			PD	(NOLOCK)
				ON P.IdPedido					=	PD.IdPedido			
	LEFT JOIN	MM_AceptacionPedidoDetalle	APD (NOLOCK)
				ON PD.IdPedidoDetalle			=	APD.IdPedidoDetalle	
	WHERE		
	O.IdProveedor					=	@IdProveedor				
	AND			ISNULL(P.Cerrado,0)				<>	1 -- Cerrados
	AND			ISNULL(P.IdEstatusEliminado,0)	<>	1 -- No eliminados
	AND			P.RecepcionServicio				=	1 --> CTE RECEPCIONADO
	GROUP BY	P.IdPedido,
				PD.IdPedidoDetalle,
				PD.Cantidad
	ORDER BY	P.IdPedido ASC

	INSERT INTO #tb_aceptadas
	SELECT
	P.IdPedido,
	PD.IdPedidoDetalle,
	SUM(ISNULL(APD.Cantidad,0)) AS Aceptadas
	FROM dbo.MM_Pedido P (NOLOCK)
	JOIN TA_Operacion AS O (NOLOCK)
		ON P.IdSolicitudPedido			=	O.IdDocumento 
		AND O.IdTipoOperacion			=	9  -->CTE
		AND P.Version					=	O.NoVersion 
		AND  O.IdEstatusOperacion=2 -->CTE PEDIDO APROBADO 
	LEFT JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
		ON P.IdPedido					=	PD.IdPedido 
	LEFT JOIN dbo.MM_AceptacionPedido AP (NOLOCK)
		ON P.IdPedido					=	AP.IdPedido 
		AND AP.IdEstatusEliminado IS NULL
	LEFT JOIN dbo.MM_AceptacionPedidoDetalle APD (NOLOCK)
		ON PD.IdPedidoDetalle			=	APD.IdPedidoDetalle 
		AND AP.IdAceptacionPedido		=	APD.IdAceptacionPedido
	WHERE 
	O.IdProveedor = @IdProveedor	
	AND ISNULL(P.Cerrado,0) <> 1 -- Cerrados
	AND ISNULL(P.IdEstatusEliminado,0)<>1 -- No eliminados
	AND P.RecepcionServicio = 1  	--> CTE RECEPCIONADO
	GROUP BY P.IdPedido,
			 PD.IdPedidoDetalle
	ORDER BY P.IdPedido ASC


	INSERT INTO #result 
	(
		IdPedido,
		IdSolicitudPedido,
		Proveedor,
		Version,
		IdPedidoGeneral,
		CreadoEl,
		Asignado,
		ComentariosAsignado,
		Justificacion,
		IdContrato				
	)
	SELECT 
	SO.IdPedido,
	P.IdSolicitudPedido,
	ISNULL(PR.RazonSocial,'') + ' ' + ISNULL(PR.RegimenCapital,'') AS Proveedor,
	P.Version,
	PG.IdPedido AS IdPedidoGeneral,
	P.CreadoEl,
	CASE 
		WHEN DPR.IdProveedor IS NOT NULL THEN ISNULL(P.AsignadoA,SPO.Solicitante)
		ELSE CASE 
				WHEN P.AsignadoA != 0 OR P.AsignadoA IS NOT NULL THEN P.AsignadoA
				ELSE NULL
			END
	END AS Asignado,
	ComentariosAsignado,
	ISNULL(SOT.Objeto,SPO.MotivoUrgencia) AS Justificacion,
	P.IdContrato	
	FROM #tb_solicitadas SO	
	JOIN dbo.MM_Pedido P (NOLOCK)
		ON SO.IdPedido				=	P.IdPedido 
	JOIN MM_Pedidos AS PG (NOLOCK)
		ON P.IdPedido				=	PG.IdIdentificador 
		AND PG.IdProveedorCliente	=	P.IdProveedorCompras 
		AND PG.IdTipoPedido				IN (2, 4, 6) -->ctes 
	LEFT JOIN #tb_aceptadas A 
		ON SO.IdPedidoDetalle		= A.IdPedidoDetalle
	LEFT JOIN dbo.S_Proveedor PR (NOLOCK)
		ON P.IdSubcontratista		=	PR.IdProveedor
	LEFT JOIN Adinco.dbo.OT_Estimacion AS OTS (NOLOCK)
		ON P.IdPedido				=	OTS.IdPedido
	LEFT JOIN Adinco.dbo.OT_Solicitud AS SOT (NOLOCK)
		ON OTS.IdOTSolicitud		=	SOT.IdOTSolicitud
	LEFT JOIN dbo.MM_SolicitudPedido AS SPO (NOLOCK)
		ON  P.IdSolicitudPedido			=	SPO.IdSolicitudPedido 
	LEFT JOIN dbo.S_Proveedor AS OPR (NOLOCK)
		ON SPO.IdProveedor				=	OPR.IdProveedor
	LEFT JOIN dbo.DEA_Proveedor AS DPR (NOLOCK)
		ON OPR.RFC					=	DPR.RFC
	GROUP BY SO.IdPedido,
			 SO.Cantidad,
			 A.Cantidad,
			 P.IdSolicitudPedido,
			 PR.RazonSocial,
			 PR.RegimenCapital,
			 P.Version,
			 PG.IdPedido,
			 P.CreadoEl,
			 P.AsignadoA,
			 P.ComentariosAsignado,
			 SOT.Objeto,
			 SPO.MotivoUrgencia,
			 p.IdContrato,
			 SPO.Solicitante,
			 DPR.IdProveedor
	HAVING SO.Cantidad > A.Cantidad -- Con aceptaciones pendientes o sin aceptaciones	
	

	SELECT		t1.IdPedido,
				t1.IdSolicitudPedido,
				t1.Proveedor,
				t1.[Version],
				t1.IdPedidoGeneral,
				t1.CreadoEl,
				t1.Asignado,
				t1.ComentariosAsignado,
				t1.Justificacion,
				t1.IdContrato,
				Contrato	=	c.NumeroContrato	
	FROM		#result		t1
	JOIN		Adinco.dbo.CO_Contrato	AS	C 	
				ON	t1.IdContrato	=	c.IdContrato		
	GROUP BY	t1.IdPedido,
				t1.IdSolicitudPedido,
				t1.Proveedor,
				t1.Version,
				t1.IdPedidoGeneral,
				t1.CreadoEl,
				t1.Asignado,
				t1.ComentariosAsignado,
				t1.Justificacion,
				t1.IdContrato,
				c.NumeroContrato
	ORDER BY CreadoEl DESC 
END
