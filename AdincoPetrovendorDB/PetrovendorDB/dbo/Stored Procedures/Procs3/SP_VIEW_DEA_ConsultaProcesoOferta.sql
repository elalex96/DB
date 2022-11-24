-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/05/2020>
-- Description:	<Consulta de proceso de oferta para DEA>
-- =============================================
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <25/01/2021>
-- Description:	<Se cambio referencia de fecha de cotización de pet oferda a ta_operacion donde sea de tipo cotización>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VIEW_DEA_ConsultaProcesoOferta]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @IDCONTRATO INT = (10038);

DECLARE @CENTROSCOSTOS TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
DECLARE @COMPRADORASIGNADO1 TABLE(IdSolicitudPedido INT, CompradorAsignado NVARCHAR(100), IdAsigando INT, FechaAsignado DATETIME);
DECLARE @PROCURA TABLE(
                        IdSolicitudPedido INT,
						Folio NVARCHAR(MAX),
                        Descripcion NVARCHAR(MAX),
                        CentroCosto NVARCHAR(MAX),
                        CompradorAsignado1 NVARCHAR(MAX),
                        Fecha1raAsignacion DATETIME,
						Comprador NVARCHAR(100),
                        NumeroProveedores INT,
                        FechaEnvioCotizacion DATETIME,
                        --FechaVigenciaCotizacion DATETIME,
                        FechaRecepcion1raCotizacion DATETIME,
                        FechaRecepcionUltimaCotizacion DATETIME,
                        FechaEnvioPedido DATETIME,
						FechaConfirmacionPedido DATETIME,
                        FechaAprobacionPedido DATETIME,
						EstatusAprobacionPedido NVARCHAR(100),
                        NumeroPedido INT,
                        FechaRecepcionPOSAP DATETIME,
                        NumeroPOSAP NVARCHAR(100),
                        FechaRelacionPOSAP DATETIME,
                        EstatusFinal NVARCHAR(100),
                        FechaRegistroAprobacion DATETIME,
                        NumeroProveedoresCotizaron INT
                        );

DECLARE @CENTROSCOSTOSOT TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
INSERT INTO @CENTROSCOSTOSOT
SELECT DISTINCT
    SPC.IdSolicitudPedido,
    CC.CentroCosto
FROM dbo.MM_SolicitudPedido AS SPC
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
        ON SPD.IdSolicitudPedido = SPC.IdSolicitudPedido
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
        ON SPD.IdSolicitudPedidoDetalle=SPLP.IdSolicitudPedidoDetalle
    LEFT JOIN dbo.CC_CentroCosto AS CC
        ON SPLP.IdCentroCosto =CC.IdCentroCosto 
WHERE SPC.IdContrato = @IDCONTRATO
    AND (CC.CentroCosto IS NOT NULL OR CC.CentroCosto <> '');

--SE OBTIENEN LOS CC POR CONTRATO Y SOLPED
INSERT INTO @CENTROSCOSTOS
SELECT DISTINCT
    SPC.IdSolicitudPedido,
    CC.CentroCosto
FROM dbo.MM_SolicitudPedido AS SPC
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
        ON SPC.IdSolicitudPedido=SPD.IdSolicitudPedido 
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
        ON SPD.IdSolicitudPedidoDetalle=SPLP.IdSolicitudPedidoDetalle 
    LEFT JOIN dbo.CC_CentroCosto AS CC
        ON SPLP.IdCentroCosto= CC.IdCentroCosto
WHERE SPC.IdContrato = @IDCONTRATO
	AND (CC.CentroCosto IS NOT NULL OR CC.CentroCosto <> '');

INSERT INTO @COMPRADORASIGNADO1
SELECT 
    SP.IdSolicitudPedido, 
    U.Nombre,
    SPC.IdSolicitudPedidoComprador,
	SPC.CreadoEl
FROM dbo.MM_SolicitudPedidoComprador SPC 
INNER JOIN dbo.S_Usuario U 
    ON SPC.IdAsignadoA=U.IdUsuario 
LEFT JOIN dbo.MM_SolicitudPedido AS SP
    ON SPC.IdSolicitudPedido=SP.IdSolicitudPedido 
WHERE SP.IdContrato = @IDCONTRATO
ORDER BY SPC.IdSolicitudPedidoComprador ASC;

INSERT INTO @PROCURA
(
    IdSolicitudPedido,
    Descripcion,
    CentroCosto,
    CompradorAsignado1,
    Fecha1raAsignacion,
	Comprador,
    NumeroProveedores,
    FechaEnvioCotizacion,
    --FechaVigenciaCotizacion,
    FechaRecepcion1raCotizacion,
    FechaRecepcionUltimaCotizacion,
    FechaEnvioPedido,
    FechaAprobacionPedido,
	EstatusAprobacionPedido,
    NumeroPedido,
    FechaRecepcionPOSAP,
    NumeroPOSAP,
    FechaRelacionPOSAP,
    EstatusFinal,
    FechaRegistroAprobacion,
    NumeroProveedoresCotizaron,
	FechaConfirmacionPedido
)
SELECT
    IdSolicitudPedido=SP.IdSolicitudPedido,
    Descripcion=SP.MotivoUrgencia,
    CentroCosto=CC.CentroCosto,
	CompradorAsignado1=ISNULL((SELECT TOP 1 CompradorAsignado FROM @COMPRADORASIGNADO1 WHERE IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY IdAsigando ASC),USPED.Nombre),
    Fecha1raAsignacion=ISNULL(PRA.CreadoEl,(SELECT TOP 1 Fecha FROM dbo.TA_HistorialFlujoTarea WHERE IdOperacion = OPSP.IdOperacion AND IdEstadoFlujo = 7 ORDER BY Fecha DESC)),
	Comprador=USPED.Nombre,
    NumeroProveedores=(SELECT COUNT(IdPeticionOferta) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEliminado,0) = 0),
    FechaEnvioCotizacion=OPF.FechaRegistro,
    --OPF.FechaFinalizacion,
    FechaRecepcion1raCotizacion=(SELECT TOP 1 FechaFinalizado FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEliminado,0) = 0 AND Cotizado = 1 ORDER BY FechaFinalizado ASC),
    FechaRecepcionUltimaCotizacion=(SELECT TOP 1 FechaFinalizado FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEliminado,0) = 0 AND Cotizado = 1 ORDER BY FechaFinalizado DESC),
    FechaEnvioPedido=P.CreadoEl,
    FechaAprobacionPedido=(SELECT TOP 1 Fecha FROM dbo.TA_HistorialFlujoTarea WHERE IdOperacion = OP.IdOperacion AND IdEstadoFlujo = 2 ORDER BY Fecha DESC),
	EstatusAprobacionPedido=ES.Nombre,
    NumeroPedido=PS.IdPedido,
    FechaRecepcionPOSAP=PO.CreadoEl,
    NumeroPOSAP=PO.ID_PO,
    FechaRelacionPOSAP=PRPO.FechaAltaRelacion,
	EstatusFinal=ES.Nombre,
    FechaRegistroAprobacion=OP.FechaRegistro,
    NumeroProveedoresCotizaron=(SELECT COUNT(IdPeticionOferta) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEliminado,0) = 0 AND Cotizado = 1),
	FechaConfirmacionPedido=P.FechaRecepcionServicio
FROM dbo.MM_SolicitudPedido AS SP
    LEFT JOIN @CENTROSCOSTOS AS CC
        ON SP.IdSolicitudPedido=CC.IdSolicitudPedido 
    LEFT JOIN dbo.MM_Pedido AS P
        ON SP.IdSolicitudPedido=P.IdSolicitudPedido 
        AND ISNULL(P.IdEliminado,0) = 0
    LEFT JOIN dbo.TA_Operacion AS OP
        ON SP.IdSolicitudPedido= OP.IdDocumento
        AND OP.IdTipoOperacion = 9 -->APROBACION DE PEDIDO
        AND OP.NoVersion = P.Version
    --LEFT JOIN dbo.TA_HistorialFlujoTarea AS HFT
    --    ON HFT.IdOperacion = OP.IdOperacion
    --    AND HFT.IdEstadoFlujo = 7
    LEFT JOIN dbo.MM_Pedidos AS PS
        ON  P.IdPedido=PS.IdIdentificador
        AND P.IdProveedorCompras=PS.IdProveedorCliente 
    LEFT JOIN dbo.DEA_Relacion_PR_PO AS PRPO
        ON P.IdPedido =PRPO.IdPedido
        AND PRPO.Activo = 1
    LEFT JOIN dbo.DEA_AdjuntoPO AS PO
        ON PRPO.IdAdjuntoPO =PO.IdAdjuntoPO 
    LEFT JOIN dbo.TA_Estatus AS ES
        ON OP.IdEstatusOperacion=ES.IdEstatus 
    LEFT JOIN dbo.TA_Operacion AS OPF
        ON SP.IdSolicitudPedido= OPF.IdDocumento
        AND OPF.IdTipoOperacion = 6  --> COTIZACIÓN
    LEFT JOIN dbo.TA_Operacion AS OPPR
        ON SP.IdSolicitudPedido = OPPR.IdDocumento 
        AND SP.IdProveedor =OPPR.IdProveedor 
        AND OPPR.IdTipoOperacion = 2 --> APRO SOLPED         
    LEFT JOIN dbo.TA_HistorialFlujoTarea AS HFTPR
        ON OPPR.IdOperacion = HFTPR.IdOperacion 
        AND HFTPR.IdEstadoFlujo = 11
	LEFT JOIN dbo.DEA_AdjuntoPR AS PRA
		ON SP.IdSolicitudPedido = PRA.IdSolicitudPedido 
	LEFT JOIN dbo.S_Usuario AS USPED
		ON P.CreadoPor= USPED.IdUsuario
	LEFT JOIN dbo.MM_PeticionOferta AS POF
		ON SP.IdSolicitudPedido=POF.IdSolicitudPedido
	LEFT JOIN dbo.TA_Operacion AS OPSP
		ON SP.IdSolicitudPedido=OPSP.IdDocumento
		AND OPSP.IdTipoOperacion = 2 --> APROBACION DE PEDIDO
	LEFT JOIN dbo.S_Usuario AS USRE
		ON SP.IdUsuarioSolicitante = USRE.IdUsuario 
WHERE SP.IdContrato = @IDCONTRATO
   AND POF.IdPeticionOferta IS NOT NULL
   AND P.IdPedido NOT IN (SELECT IdPedido FROM Adinco.dbo.OT_Estimacion);

	

SELECT
    PROCU.IdSolicitudPedido,
	ISNULL(PROCU.Folio,'N/A') AS Folio,
    PROCU.Descripcion,
    PROCU.CentroCosto,
    PROCU.CompradorAsignado1,
    PROCU.Fecha1raAsignacion AS Fecha1aAsignacion,
    (SELECT STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'')  --+ CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA )
            FROM dbo.MM_SolicitudPedidoComprador SPC 
            INNER JOIN dbo.S_Usuario U ON U.IdUsuario =SPC.IdAsignadoA
            LEFT JOIN dbo.S_TipoUsuario TU ON U.IdTipoUsuario  =TU.IdTipoUsuario          
            WHERE       
            SPC.IdSolicitudPedido = PROCU.IdSolicitudPedido
            AND U.Nombre <> CompradorAsignado1
            AND SPC.Activo=1
            GROUP BY U.Nombre,
                TU.NombreTipoUsuario
            FOR XML PATH ( '' )), 1, 1, '' )) AS CompradorAsignado2,
	(SELECT TOP 1 FechaAsignado FROM @COMPRADORASIGNADO1 WHERE IdSolicitudPedido = PROCU.IdSolicitudPedido AND CompradorAsignado <> PROCU.CompradorAsignado1 ORDER BY IdAsigando ASC) AS Fecha2Asignacion,
    PROCU.Comprador,
	PROCU.NumeroProveedores,
    PROCU.FechaEnvioCotizacion,
	PROCU.NumeroProveedoresCotizaron,
    PROCU.FechaRecepcion1raCotizacion,
    CASE
        WHEN PROCU.NumeroProveedores = 1  AND PROCU.FechaRecepcion1raCotizacion IS NOT NULL THEN FechaRecepcion1raCotizacion
        ELSE PROCU.FechaRecepcionUltimaCotizacion
    END AS FechaRecepcionUltimaCotizacion,
	(CASE
		WHEN FechaRecepcionUltimaCotizacion IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaEnvioCotizacion,FechaRecepcionUltimaCotizacion))
		ELSE 0
	END) AS DiasRecepcionCotizacion,
    PROCU.FechaEnvioPedido,
	PROCU.NumeroPedido,
    PROCU.FechaAprobacionPedido,
	(CASE
		WHEN FechaAprobacionPedido IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaEnvioPedido,FechaAprobacionPedido))
		ELSE 0
	END) AS DiasAprobacionPedido,
	PROCU.FechaConfirmacionPedido,
	(CASE
		WHEN FechaConfirmacionPedido IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaAprobacionPedido,FechaConfirmacionPedido))
		ELSE 0
	END) AS DiasConfirmacionPedido,
	PROCU.EstatusAprobacionPedido,
    PROCU.FechaRecepcionPOSAP,
    REPLACE((REPLACE((REPLACE(PROCU.NumeroPOSAP,'Fwd: Orden de Compra','')),'SAP PO ','')),'FW: Orden de Compra  ','') AS NumeroPOSAP,
	(CASE
		WHEN FechaRecepcionPOSAP IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaRecepcionPOSAP,FechaAprobacionPedido))
		ELSE 0
	END) AS DiasRecepcionPOSAP,
    PROCU.FechaRelacionPOSAP,
	(CASE
		WHEN FechaRelacionPOSAP IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaRecepcionPOSAP,FechaRelacionPOSAP))
		ELSE 0
	END) AS DiasRelacionPOSAP,
	(CASE
		WHEN FechaRelacionPOSAP IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaEnvioCotizacion,FechaRelacionPOSAP))
		ELSE 0
	END) AS DiasTotal,
    PROCU.EstatusFinal
INTO #DATOSOFERTA
FROM @PROCURA AS PROCU
ORDER BY PROCU.IdSolicitudPedido DESC;

DELETE FROM dbo.DEA_ProcesoOferta;

INSERT INTO dbo.DEA_ProcesoOferta
(
    IdSolicitudPedido,
    Folio,
    Descripcion,
    CentroCosto,
    Fecha1aAsignacionFechaCargaPR,
    CompradorAsignado1,
    Fecha2aAsignacion,
    CompradorAsignado2,
    Dias2aAsignacion,
    Comprador,
    NumeroProveedores,
    FechaEnvioCotizacion,
    DiasEnvioCotizacion,
    DiasSolicitudOferta,
    NumeroProveedoresCotizaron,
    FechaRecepcionUltimaCotizacion,
    DiasRecepcionUltimaCotizacion,
    FechaEnvioPedido,
    NumeroPedido,
    DiasEnvioPedido,
    FechaAprobacionPedido,
    DiasAprobacionPedido,
    EstatusAprobacionPedido,
    DiasAsignacionProveedor,
    NumeroPOSAP,
    FechaRelacionPOSAP,
    DiasRelacionPOSAP,
    FechaConfirmacionPedido,
    DiasConfirmacionPedido,
    DiasTotal,
    EstatusFinal
)
SELECT
	IdSolicitudPedido AS IdSolicitudPedido,
	Folio,
	Descripcion AS Descripcion,
	CentroCosto AS CentroCosto,
	Fecha1aAsignacion AS Fecha1aAsignacionFechaCargaPR,
	CompradorAsignado1 AS CompradorAsignado1,
	Fecha2Asignacion AS Fecha2aAsignacion,
	CompradorAsignado2 AS CompradorAsignado2,
	(CASE
		WHEN Fecha2Asignacion IS NOT NULL THEN (dbo.CalcularTipoDEA(Fecha1aAsignacion,Fecha2Asignacion))
		ELSE NULL
	END) AS Dias2aAsignacion,--
	Comprador AS Comprador,
	(CASE
		WHEN FechaEnvioCotizacion IS NOT NULL THEN NumeroProveedores
		ELSE NULL
	END) AS NumeroProveedores,
	FechaEnvioCotizacion AS FechaEnvioCotizacion,
	(CASE
		WHEN FechaEnvioCotizacion IS NOT NULL THEN (dbo.CalcularTipoDEA(Fecha2Asignacion,FechaEnvioCotizacion))
		ELSE NULL
	END) AS DiasEnvioCotizacion,--
	(CASE
		WHEN FechaEnvioCotizacion IS NOT NULL THEN (dbo.CalcularTipoDEA(Fecha1aAsignacion,FechaEnvioCotizacion))
		ELSE NULL
	END) AS DiasSolicitudOferta,
	(CASE
		WHEN FechaEnvioCotizacion IS NOT NULL THEN NumeroProveedoresCotizaron
		ELSE NULL
	END) AS NumeroProveedoresCotizaron,
	FechaRecepcionUltimaCotizacion AS FechaRecepcionUltimaCotizacion,
	(CASE
		WHEN FechaRecepcionUltimaCotizacion IS NOT NULL THEN (dbo.CalcularTipoDEA(FechaEnvioCotizacion,FechaRecepcionUltimaCotizacion))
		ELSE NULL
	END) AS DiasRecepcionCotizacion,
	FechaEnvioPedido AS FechaEnvioPedido,
	NumeroPedido AS NumeroPedido,
	(CASE
		WHEN FechaEnvioPedido IS NOT NULL THEN (dbo.CalcularTipoDEA(FechaRecepcionUltimaCotizacion,FechaEnvioPedido))
		ELSE NULL
	END) AS DiasEnvioPedido,
	FechaAprobacionPedido AS FechaAprobacionPedido,
	(CASE
		WHEN FechaAprobacionPedido IS NOT NULL THEN (dbo.CalcularTipoDEA(FechaEnvioPedido,FechaAprobacionPedido))
		ELSE NULL
	END) AS DiasAprobacionPedido,
	EstatusAprobacionPedido AS EstatusAprobacionPedido,
	CASE
		WHEN FechaEnvioPedido IS NOT NULL AND FechaAprobacionPedido IS NOT NULL THEN CONVERT(DECIMAL(5,2),
																								(CASE
																									WHEN FechaEnvioPedido IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaRecepcionUltimaCotizacion,FechaEnvioPedido))
																									ELSE 0.00
																								END) + 
																								(CASE
																									WHEN FechaAprobacionPedido IS NOT NULL THEN CONVERT(DECIMAL(5,2),dbo.CalcularTipoDEA(FechaEnvioPedido,FechaAprobacionPedido))
																									ELSE 0.00
																								END)
																							)
		ELSE NULL
	END AS DiasAsignacionProveedor,
	NumeroPOSAP AS NumeroPOSAP,
	FechaRelacionPOSAP AS FechaRelacionPOSAP,
	(CASE
		WHEN FechaRelacionPOSAP IS NOT NULL THEN (dbo.CalcularTipoDEA(FechaAprobacionPedido,FechaRelacionPOSAP))
		ELSE NULL
	END) AS DiasRelacionPOSAP,
	FechaConfirmacionPedido AS FechaConfirmacionPedido,
	(CASE
		WHEN FechaConfirmacionPedido IS NOT NULL THEN (dbo.CalcularTipoDEA(FechaAprobacionPedido,FechaConfirmacionPedido))
		ELSE NULL
	END) AS DiasConfirmacionPedido,
	(
		ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionCotizacion),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasAprobacionPedido),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasConfirmacionPedido),0.00) +
		ISNULL(CONVERT(DECIMAL(5,2),DiasRelacionPOSAP),0.00) + 
		ISNULL(CONVERT(DECIMAL(5,2),DiasRecepcionPOSAP),0.00) 

	) AS DiasTotal,
	EstatusFinal AS EstatusFinal
FROM #DATOSOFERTA
ORDER BY IdSolicitudPedido DESC;

DROP TABLE #DATOSOFERTA;

END
