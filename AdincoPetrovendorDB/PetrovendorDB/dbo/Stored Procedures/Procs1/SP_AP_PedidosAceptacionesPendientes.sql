USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AP_PedidosAceptacionesPendientes]    Script Date: 01/03/2022 04:01:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <28/09/19>
-- Description:	<Consulta los pedidos aprobados,sin cerrar, no eliminados y con aceptaciones pendientes>
-- =============================================
ALTER PROCEDURE [dbo].[SP_AP_PedidosAceptacionesPendientes] --420
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

	--DROP TABLE #result

	INSERT INTO #tb_solicitadas
	SELECT
				P.IdPedido,
				PD.IdPedidoDetalle,
				Solicitadas			=	ISNULL(PD.Cantidad,0)
	FROM		dbo.MM_Pedido					P
	LEFT JOIN	dbo.MM_PedidoDetalle			PD	ON PD.IdPedido			= P.IdPedido
	LEFT JOIN	dbo.MM_AceptacionPedidoDetalle	APD ON APD.IdPedidoDetalle	= PD.IdPedidoDetalle
	INNER JOIN	TA_Operacion					O	ON O.IdDocumento		= P.IdSolicitudPedido
	INNER JOIN	TA_TipoOperacion				TTO ON TTO.IdTipoOperacion	= O.IdTipoOperacion
	INNER JOIN	TA_Estatus						E	ON E.IdEstatus			= O.IdEstatusOperacion
	WHERE		O.IdTipoOperacion				=	9 
	AND			O.IdProveedor					=	@IdProveedor
	AND			E.IdEstatus						=	2 -- Aprobados
	AND			ISNULL(P.Cerrado,0)				<>	1 -- Cerrados
	AND			ISNULL(P.IdEstatusEliminado,0)	<>	1 -- No eliminados
	AND			P.RecepcionServicio				=	1  
	AND			P.Version						=	O.NoVersion
	GROUP BY	P.IdPedido,
				PD.IdPedidoDetalle,
				PD.Cantidad
	ORDER BY	P.IdPedido ASC

	INSERT INTO #tb_aceptadas
	SELECT
	P.IdPedido,
	PD.IdPedidoDetalle,
	SUM(ISNULL(APD.Cantidad,0)) AS Aceptadas
	FROM dbo.MM_Pedido P
	LEFT JOIN dbo.MM_PedidoDetalle PD ON PD.IdPedido = P.IdPedido
	LEFT JOIN dbo.MM_AceptacionPedido AP ON AP.IdPedido = P.IdPedido AND AP.IdEstatusEliminado IS NULL
	LEFT JOIN dbo.MM_AceptacionPedidoDetalle APD ON APD.IdPedidoDetalle = PD.IdPedidoDetalle AND AP.IdAceptacionPedido=APD.IdAceptacionPedido
	INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	WHERE O.IdTipoOperacion = 9 
	AND O.IdProveedor = @IdProveedor
	AND  E.IdEstatus=2 -- Aprobados
	AND ISNULL(P.Cerrado,0) <> 1 -- Cerrados
	AND ISNULL(P.IdEstatusEliminado,0)<>1 -- No eliminados
	AND P.RecepcionServicio = 1  
	AND P.Version = O.NoVersion
	GROUP BY P.IdPedido,
			 PD.IdPedidoDetalle
	ORDER BY P.IdPedido ASC

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
				WHEN P.AsignadoA != 0 THEN P.AsignadoA
				ELSE NULL
			END
	END AS Asignado,
	ComentariosAsignado,
	ISNULL(SOT.Objeto,SPO.MotivoUrgencia) AS Justificacion,
	p.IdContrato
	--Contrato = c.NumeroContrato
	INTO #result
	FROM #tb_solicitadas SO
	LEFT JOIN #tb_aceptadas A ON SO.IdPedidoDetalle = A.IdPedidoDetalle
	LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = SO.IdPedido
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras AND PG.IdTipoPedido IN (2, 4, 6)
	LEFT JOIN dbo.S_Proveedor PR ON PR.IdProveedor = P.IdSubcontratista
	LEFT JOIN Adinco.dbo.OT_Estimacion AS OTS ON OTS.IdPedido = P.IdPedido
	LEFT JOIN Adinco.dbo.OT_Solicitud AS SOT ON SOT.IdOTSolicitud = OTS.IdOTSolicitud
	LEFT JOIN dbo.MM_SolicitudPedido AS SPO ON SPO.IdSolicitudPedido = P.IdSolicitudPedido
	LEFT JOIN dbo.S_Proveedor AS OPR ON SPO.IdProveedor = OPR.IdProveedor
	LEFT JOIN dbo.DEA_Proveedor AS DPR ON OPR.RFC = DPR.RFC
	--inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	P.IdContrato	=	C.IdContrato
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
				--Contrato,
				Contrato	=	c.NumeroContrato	
	FROM		#result		t1
	inner JOIN	Adinco.dbo.CO_Contrato	AS	C 	ON	c.IdContrato	=	t1.IdContrato
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

