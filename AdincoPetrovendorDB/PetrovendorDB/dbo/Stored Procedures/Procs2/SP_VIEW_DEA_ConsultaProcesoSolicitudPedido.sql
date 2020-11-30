-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <18/05/2020>
-- Description:	<Cosnulta de proceso de solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VIEW_DEA_ConsultaProcesoSolicitudPedido]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @IDCONTRATO INT = (10038);
--USE Petrovendor;

--DROP TABLE #PROCESOSOLPED2

-- PARA OTS SIN BITACORA, BUSCAR ACCIONES DEL MANAGER EN BASE A LAS NOTIFICACIONES
SELECT OT.IdOTSolicitud,
		u.Usuario,
		Fecha = MIN(n.CreadoEl)
into #tmpOTManagerNot
FROM Adinco..OT_SolicitudBitacora sb 
inner join Adinco..OT_Solicitud ot on ot.IdOTSolicitud = sb.IdOTSolicitud
inner join Adinco..s_notificacion n on n.Asunto like '%'+ot.Folio+'%' 
inner join Adinco..AP_Usuario u on u.UsuarioID = n.CreadoPor
where n.Asunto like '%Control de Obra%' 
 --AND NOT (sb.IdTipoMovimiento = 2 
	--		OR sb.Descripcion = 'Rechazada Operador'
	--		OR sb.Descripcion like '%Aprobada%Operador%'
	--		OR sb.Descripcion = 'Aprobada Operador'
	--		OR sb.Descripcion = 'Enviada a Subcontratista')

AND (
	n.Mensaje like '%La OT ha sido aprobada%' OR
	n.Mensaje like '%La OT ha sido rechazada%' OR
	n.Mensaje like '%Es necesario revisar la programacion inicial%'  OR
	n.Mensaje like '%Es necesario aprobar/rechazar%' 

	
)

group by OT.IdOTSolicitud,
		u.Usuario

DECLARE @CENTROSCOSTOS TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
DECLARE @USUARIOAPROBADOR1 TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100));
DECLARE @USUARIOAPROBADOR2 TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100), IdEstatus INT);
DECLARE @USUARIOREASIGNADO TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100));
DECLARE @USUARIOREASIGNADO2 TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100));
DECLARE @PROCESOSOLPED TABLE(
                            IdSolicitudPedido INT, 
                            Folio NVARCHAR(100),
                            Descripcion NVARCHAR(MAX), 
                            CentroCosto NVARCHAR(MAX), 
                            Requisitor NVARCHAR(MAX), 
                            FechaRegistro DATETIME, 
                            Responsable1aAprobacion NVARCHAR(MAX),
                            Fecha1aAprobacion DATETIME,
                            Estatus1aAprobacion NVARCHAR(MAX),
                            ResponsableReasignado NVARCHAR(MAX),
                            FechaAprobacionReasignado DATETIME,
                            EstatusAprobacionReasignado NVARCHAR(MAX),
                            Responsable2aAprobacion NVARCHAR(MAX),
                            Fecha2aAprobacion DATETIME,
                            Estatus2aAprobacion NVARCHAR(MAX),
							Responsable2daReasigacion NVARCHAR(MAX),
                            FechaAprobacion2daReasignacion DATETIME,
                            EstatusAprobacion2daReasignacion NVARCHAR(MAX),
                            UsuarioCargaPR NVARCHAR(MAX),
                            FechaCargaPR DATETIME,
                            NumeroPR NVARCHAR(100),
                            EstatusFinal NVARCHAR(100),
                            FechaRegistroTareaReasignado DATETIME
                            );

DECLARE @DATOSSOLPEDFIN TABLE(
                            IdSolicitudPedido INT, 
                            Folio NVARCHAR(100),
                            Descripcion NVARCHAR(MAX), 
                            CentroCosto NVARCHAR(MAX), 
                            Requisitor NVARCHAR(MAX), 
                            FechaRegistro DATETIME, 
                            Responsable1aAprobacion NVARCHAR(MAX),
                            Fecha1aAprobacion DATETIME,
                            Estatus1aAprobacion NVARCHAR(MAX),
							Dias1apro NVARCHAR(100),
                            ResponsableReasignado NVARCHAR(MAX),
                            FechaAprobacionReasignado DATETIME,
                            EstatusAprobacionReasignado NVARCHAR(MAX),
							Dias1asig NVARCHAR(100),
                            Responsable2aAprobacion NVARCHAR(MAX),
                            Fecha2aAprobacion DATETIME,
                            Estatus2aAprobacion NVARCHAR(MAX),
							Dias2aprob NVARCHAR(100),
							Responsable2daReasigacion NVARCHAR(MAX),
                            FechaAprobacion2daReasignacion DATETIME,
                            EstatusAprobacion2daReasignacion NVARCHAR(MAX),
							Dias2aprobreasig NVARCHAR(100),
                            UsuarioCargaPR NVARCHAR(MAX),
                            FechaCargaPR DATETIME,
                            NumeroPR NVARCHAR(100),
							DiasCargaPR NVARCHAR(100),
							DiasAprobGral NVARCHAR(100),
                            EstatusFinal NVARCHAR(100),
                            FechaRegistroTareaReasignado DATETIME
                            );

DECLARE @IDSOLITUDOT2 TABLE(
	IdSolicitud INT,
	Responsable2aAprobacion NVARCHAR(MAX),
	Fecha2aAprobacion DATETIME,
	Estatus2aAprobacion NVARCHAR(100)
);

DECLARE @IDSOLITUDOT1 TABLE(
	IdSolicitud INT,
	Responsable1aAprobacion NVARCHAR(MAX),
	Fecha1aAprobacion DATETIME,
	Estatus1aAprobacion NVARCHAR(100)
);

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

DECLARE @CENTROSCOSTOSOT TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
INSERT INTO @CENTROSCOSTOSOT
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
INSERT INTO @USUARIOAPROBADOR1
SELECT
    SP.IdSolicitudPedido,
    USFA.Nombre,
    T.FechaRegistro,
    T.FechaCambioEstatus,
    DATEDIFF(DAY,SP.FechaAlta,T.FechaCambioEstatus),
    ET1.Nombre
FROM dbo.TA_Operacion AS OP
    LEFT JOIN dbo.TA_Tarea AS T
        ON T.IdOperacion = OP.IdOperacion
        AND T.NoSecuencia = 1
    LEFT JOIN dbo.S_Usuario AS USFA
        ON USFA.IdUsuario = T.IdAprobador
    LEFT JOIN dbo.TA_Estatus AS ET1
        ON ET1.IdEstatus = T.IdEstatus
    LEFT JOIN dbo.MM_SolicitudPedido AS SP
        ON OP.IdDocumento = SP.IdSolicitudPedido
        AND OP.IdProveedor = SP.IdProveedor
        AND OP.IdTipoOperacion = 2
WHERE SP.IdContrato = @IDCONTRATO;

INSERT INTO @USUARIOAPROBADOR2
SELECT
    SP.IdSolicitudPedido,
    USFA.Nombre,
    T.FechaRegistro,
    T.FechaCambioEstatus,
    DATEDIFF(DAY,SP.FechaAlta,T.FechaCambioEstatus),
    ET1.Nombre,
	T.IdEstatus
FROM dbo.TA_Operacion AS OP
    LEFT JOIN dbo.TA_Tarea AS T
        ON T.IdOperacion = OP.IdOperacion
        AND T.NoSecuencia = 2
    LEFT JOIN dbo.S_Usuario AS USFA
        ON USFA.IdUsuario = T.IdAprobador
    LEFT JOIN dbo.TA_Estatus AS ET1
        ON ET1.IdEstatus = T.IdEstatus
    LEFT JOIN dbo.MM_SolicitudPedido AS SP
        ON OP.IdDocumento = SP.IdSolicitudPedido
        AND OP.IdProveedor = SP.IdProveedor
        AND OP.IdTipoOperacion = 2
WHERE SP.IdContrato = @IDCONTRATO;

INSERT INTO @USUARIOREASIGNADO
SELECT
    SP.IdSolicitudPedido,
    USFA.Nombre,
    T.FechaRegistro,
    T.FechaCambioEstatus,
    DATEDIFF(DAY,SP.FechaAlta,T.FechaCambioEstatus),
    ET1.Nombre
FROM dbo.TA_Operacion AS OP
    LEFT JOIN dbo.TA_Tarea AS T
        ON T.IdOperacion = OP.IdOperacion
        AND T.NoSecuencia = 1
        AND T.IdEstatus <> 7
    LEFT JOIN dbo.S_Usuario AS USFA
        ON USFA.IdUsuario = T.IdAprobador
    LEFT JOIN dbo.TA_Estatus AS ET1
        ON ET1.IdEstatus = T.IdEstatus
    LEFT JOIN dbo.MM_SolicitudPedido AS SP
        ON OP.IdDocumento = SP.IdSolicitudPedido
        AND OP.IdProveedor = SP.IdProveedor
        AND OP.IdTipoOperacion = 2
WHERE SP.IdContrato = @IDCONTRATO
	AND ET1.Nombre NOT IN (SELECT Nombre FROM @USUARIOAPROBADOR2 WHERE IdSolicitudPedido = SP.IdSolicitudPedido);

INSERT INTO @USUARIOREASIGNADO2
SELECT
    SP.IdSolicitudPedido,
    USFA.Nombre,
    T.FechaRegistro,
    T.FechaCambioEstatus,
    DATEDIFF(DAY,SP.FechaAlta,T.FechaCambioEstatus),
    ET1.Nombre
FROM dbo.TA_Operacion AS OP
    LEFT JOIN dbo.TA_Tarea AS T
        ON T.IdOperacion = OP.IdOperacion
        AND T.NoSecuencia = 2
        AND T.IdEstatus <> 7
		AND T.Activo = 1
    LEFT JOIN dbo.S_Usuario AS USFA
        ON USFA.IdUsuario = T.IdAprobador
    LEFT JOIN dbo.TA_Estatus AS ET1
        ON ET1.IdEstatus = T.IdEstatus
    LEFT JOIN dbo.MM_SolicitudPedido AS SP
        ON OP.IdDocumento = SP.IdSolicitudPedido
        AND OP.IdProveedor = SP.IdProveedor
        AND OP.IdTipoOperacion = 2
WHERE SP.IdContrato = @IDCONTRATO;


INSERT INTO @IDSOLITUDOT2
(
    IdSolicitud,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    Estatus2aAprobacion
)
SELECT
	ST.IdOTSolicitud,
	CASE
		WHEN ST.ProgIniPorProveedor = 1 THEN /*ISNULL(AP1.Nombre,'') +*/ ' (' + (SELECT STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + 
																							ISNULL(
																									case when US.Nombre = AP1.Nombre then ''
																										 else	US.Nombre
																								    end
																								,'')
																				FROM Adinco.dbo.OT_Solicitud AS OTSI 
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacion AS FA 
																					ON FA.TipoFlujoAprobacionId = 1
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatus AS FAE
																					ON FAE.FlujoAprobacionEstatusId = 2
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatusUsuarios AS FAEU
																					ON FAEU.FlujoAprobacionEstatusId = FAE.FlujoAprobacionEstatusId
																				LEFT JOIN Adinco.dbo.AP_Usuario AS US 
																					ON US.UsuarioID = FAEU.UsuarioId
																					AND US.IsActivo = 1
																				LEFT JOIN Adinco.dbo.AP_UsuarioCentroCosto AS UCC
																					ON UCC.IdCentroCosto = OTSI.IdCentroCosto
																				WHERE       
																					OTSI.IdOTSolicitud = ST.IdOTSolicitud
																					--AND US.UsuarioID NOT IN ( AP1.UsuarioID)
																						--AND US.UsuarioID <> AP1.UsuarioID
																						--AND US.UsuarioID IN (10752,10505)
																				GROUP BY US.Nombre
																				FOR XML PATH ( '' )), 1, 1, '' )) + ')'
		WHEN ST.ProgIniPorProveedor = 0 THEN SUCIT.RazonSocial + '(' + SUCIT.RFC + ')'
	END,
	CASE
		WHEN ST.ProgIniPorProveedor = 1 THEN SBO.CreadoEl
		WHEN ST.ProgIniPorProveedor = 0 THEN SBP.CreadoEl
	END,
    CASE
		WHEN ST.ProgIniPorProveedor = 1 THEN SBO.Descripcion
		WHEN ST.ProgIniPorProveedor = 0 THEN SBP.Descripcion
	END
FROM Adinco.dbo.OT_Solicitud AS ST
LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBO
        ON SBO.IdOTSolicitud = ST.IdOTSolicitud
        AND (SBO.IdTipoMovimiento = 2 
			OR SBO.Descripcion = 'Rechazada Operador'
			OR SBO.Descripcion like '%Aprobada%Operador%'
			OR SBO.Descripcion = 'Aprobada Operador'
			OR SBO.Descripcion = 'Enviada a Subcontratista')
LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBP
        ON SBP.IdOTSolicitud = ST.IdOTSolicitud
        AND (SBP.IdTipoMovimiento = 4 
				OR SBP.Descripcion = 'Rechazada Subcontratista' 
				OR SBP.Descripcion = 'Propuesta por Subcontratista')
LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT
		ON SUBOT.IdSubContrato = ST.IdSubContrato
	LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUCIT
		ON SUCIT.IdSubcontratista = SUBOT.IdSubContratista
LEFT JOIN Adinco.dbo.AP_Usuario AS AP1
        ON AP1.UsuarioID = SBO.UsuarioAdincoId
WHERE SUBOT.IdContrato = @IDCONTRATO
GROUP BY ST.IdOTSolicitud,
			SBP.Descripcion,
			SBO.Descripcion,
			SBO.CreadoEl,
			SBP.CreadoEl,
			AP1.Nombre,
			ST.ProgIniPorProveedor,
			SUCIT.RazonSocial,
			SUCIT.RFC

INSERT INTO @IDSOLITUDOT1
(
    IdSolicitud,
    Responsable1aAprobacion,
    Fecha1aAprobacion,
    Estatus1aAprobacion
)
SELECT
	ST.IdOTSolicitud,
	CASE
		WHEN ST.ProgIniPorProveedor = 1 THEN SUCIT.RazonSocial + '(' + SUCIT.RFC + ')'
		WHEN ST.ProgIniPorProveedor = 0 THEN ISNULL(AP1.Nombre,isnull(otN1.usuario,'')) + ' (' + isnull((SELECT STUFF (
																								(SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(US.Nombre,'')
																				FROM Adinco.dbo.OT_Solicitud AS OTSI 
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacion AS FA 
																					ON FA.TipoFlujoAprobacionId = 1
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatus AS FAE
																					ON FAE.FlujoAprobacionEstatusId = 2
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatusUsuarios AS FAEU
																					ON FAEU.FlujoAprobacionEstatusId = FAE.FlujoAprobacionEstatusId
																				LEFT JOIN Adinco.dbo.AP_Usuario AS US 
																					ON US.UsuarioID = FAEU.UsuarioId
																					AND US.IsActivo = 1
																				LEFT JOIN Adinco.dbo.AP_UsuarioCentroCosto AS UCC
																					ON UCC.IdCentroCosto = OTSI.IdCentroCosto
																				WHERE       
																					OTSI.IdOTSolicitud = ST.IdOTSolicitud
																						AND US.UsuarioID <> AP1.UsuarioID
																						AND US.Usuario not like '%@adinco.mx%'
																						AND US.Usuario not like '%@ogss.com.mx%'
																						AND US.Usuario not like '%@smps-sp.com%'
																						--AND US.UsuarioID IN (10752,10505)
																				GROUP BY US.Nombre
																				FOR XML PATH ( '' )), 1, 1, '' )),'') + ')'
	END,
	CASE
		WHEN ST.ProgIniPorProveedor = 1 THEN SBP.CreadoEl
		WHEN ST.ProgIniPorProveedor = 0 THEN isnull(SBO.CreadoEl,otN1.fecha)
	END,
	CASE
		WHEN ST.ProgIniPorProveedor = 1 THEN SBP.Descripcion
		WHEN ST.ProgIniPorProveedor = 0 THEN SBO.Descripcion
	END
FROM Adinco.dbo.OT_Solicitud AS ST
LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBO
        ON SBO.IdOTSolicitud = ST.IdOTSolicitud
        AND (SBO.IdTipoMovimiento = 2 
			OR SBO.Descripcion = 'Rechazada Operador'
			OR SBO.Descripcion like '%Aprobada%Operador%'
			OR SBO.Descripcion = 'Aprobada Operador'
			OR SBO.Descripcion = 'Enviada a Subcontratista')
LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBP
        ON SBP.IdOTSolicitud = ST.IdOTSolicitud
        AND (SBP.IdTipoMovimiento = 4 
				OR SBP.Descripcion = 'Rechazada Subcontratista' 
				OR SBP.Descripcion = 'Propuesta por Subcontratista')
LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT
		ON SUBOT.IdSubContrato = ST.IdSubContrato
	LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUCIT
		ON SUCIT.IdSubcontratista = SUBOT.IdSubContratista
LEFT JOIN Adinco.dbo.AP_Usuario AS AP1
        ON AP1.UsuarioID = SBO.UsuarioAdincoId
LEFT JOIN #tmpOTManagerNot otN1 on otN1.IdOTSolicitud = ST.IdOTSolicitud
WHERE SUBOT.IdContrato = @IDCONTRATO
GROUP BY ST.IdOTSolicitud,
			SBP.Descripcion,
			SBO.Descripcion,
			SBO.CreadoEl,
			SBP.CreadoEl,
			AP1.Nombre,
			ST.ProgIniPorProveedor,
			SUCIT.RazonSocial,
			SUCIT.RFC,
			AP1.UsuarioID,
			otN1.usuario,
			otN1.fecha;

INSERT INTO @PROCESOSOLPED
(
    IdSolicitudPedido,
    Descripcion,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    Responsable1aAprobacion,
    Fecha1aAprobacion,
    Estatus1aAprobacion,
    ResponsableReasignado,
    FechaAprobacionReasignado,
    EstatusAprobacionReasignado,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    Estatus2aAprobacion,
	Responsable2daReasigacion,
	FechaAprobacion2daReasignacion,
	EstatusAprobacion2daReasignacion,
    UsuarioCargaPR,
    FechaCargaPR,
    NumeroPR,
    EstatusFinal,
    FechaRegistroTareaReasignado
)
SELECT --TOP 20
    SP.IdSolicitudPedido,
    SP.MotivoUrgencia AS Descripcion,
    CC2.CentroCosto,
    US.Nombre AS Requisitor,
    SP.FechaAlta AS FechaRegistro,
    (SELECT TOP 1 APUS1.Nombre FROM @USUARIOAPROBADOR1 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC),--Responsable1Aprobacion
    (SELECT TOP 1 APUS1.FechaCambioEstatus FROM @USUARIOAPROBADOR1 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC) ,--Fecha1Aprobacion
    (SELECT TOP 1 APUS1.Estatus FROM @USUARIOAPROBADOR1 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC),--Estatus1Aprobacion
    (SELECT TOP 1 APUS1.Nombre FROM @USUARIOREASIGNADO AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC),--ResponsableReasignacion
    (SELECT TOP 1 APUS1.FechaCambioEstatus FROM @USUARIOREASIGNADO AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC),--FechaAprobacionReasignacion
    (SELECT TOP 1 APUS1.Estatus FROM @USUARIOREASIGNADO AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC),--EstatusReasignacion
    (SELECT TOP 1 APUS1.Nombre FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC),--Responsable2Aprobacion
	CASE 
		WHEN (SELECT TOP 1 APUS1.Estatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC) = 'Cancelado por Reasignacion' THEN CASE 
																																																	WHEN (SELECT TOP 1 APUS1.IdEstatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC) = 7 THEN (SELECT TOP 1 APUS1.FechaRegistro FROM @USUARIOREASIGNADO2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC)
																																																	ELSE NULL
																																																END
		ELSE (SELECT TOP 1 APUS1.FechaCambioEstatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC)
	END,--Fecha2Aprobacion
    (SELECT TOP 1 APUS1.Estatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC),--Estatus2Aprobacion
	CASE 
		WHEN (SELECT TOP 1 APUS1.IdEstatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC) = 7 THEN (SELECT TOP 1 APUS1.Nombre FROM @USUARIOREASIGNADO2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC)
		ELSE NULL
	END,
	CASE 
		WHEN (SELECT TOP 1 APUS1.IdEstatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC) = 7 THEN (SELECT TOP 1 APUS1.FechaCambioEstatus FROM @USUARIOREASIGNADO2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC)
		ELSE NULL
	END,
	CASE 
		WHEN (SELECT TOP 1 APUS1.IdEstatus FROM @USUARIOAPROBADOR2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro ASC) = 7 THEN (SELECT TOP 1 APUS1.Estatus FROM @USUARIOREASIGNADO2 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC)
		ELSE NULL
	END,
    USPR.Nombre AS UsuarioCargaPR,
    PR.CreadoEl AS FechaCargaPR,
	PR.ID_PR AS NumberPR,
    EG.Nombre AS EstatusGeneral,
    (SELECT TOP 1 APUS1.FechaRegistro FROM @USUARIOAPROBADOR1 AS APUS1 WHERE APUS1.IdSolicitudPedido = SP.IdSolicitudPedido ORDER BY FechaRegistro DESC)--FechaRegistroTareaReasignado
FROM dbo.MM_SolicitudPedido AS SP
    LEFT JOIN dbo.S_Usuario AS US
        ON US.IdUsuario = SP.IdUsuarioSolicitante
    -- SE LIGA A CENTROS DE COSTO POR SOLPED
    LEFT JOIN @CENTROSCOSTOS AS CC2
        ON CC2.IdSolicitudPedido = SP.IdSolicitudPedido
    LEFT JOIN dbo.TA_Operacion AS OP
        ON OP.IdDocumento = SP.IdSolicitudPedido
        AND OP.IdProveedor = SP.IdProveedor
        AND OP.IdTipoOperacion = 2
    LEFT JOIN dbo.TA_FlujoTarea AS FT
        ON FT.IdFlujoTarea = OP.IdFlujoTarea
    --ESTATUS GENERAL DE LA OPERACION
    LEFT JOIN dbo.TA_Estatus AS EG
        ON EG.IdEstatus = OP.IdEstatusOperacion
    --CARGA DE PR 
    LEFT JOIN dbo.DEA_AdjuntoPR AS PR
        ON PR.IdSolicitudPedido = SP.IdSolicitudPedido
        AND PR.Activo = 1
        AND ISNULL(PR.IsEliminado,0) = 0
    LEFT JOIN dbo.S_Usuario AS USPR
        ON USPR.IdUsuario = PR.CreadoPor
    LEFT JOIN dbo.MM_Pedido AS P
        ON P.IdSolicitudPedido = SP.IdSolicitudPedido
WHERE SP.IdContrato = @IDCONTRATO
    AND SP.IdUsuarioSolicitante IS NOT NULL
    AND OP.IdFlujoTarea IS NOT NULL
    AND SP.IdSolicitudPedido NOT IN (SELECT IdSolicitudPedido FROM Adinco.dbo.OT_Estimacion)
GROUP BY SP.IdSolicitudPedido,
         SP.MotivoUrgencia,
         CC2.CentroCosto,
         US.Nombre,
         SP.FechaAlta,
         PR.ID_PR,
         PR.CreadoEl,
         USPR.Nombre,
         EG.Nombre
ORDER BY SP.IdSolicitudPedido DESC;

INSERT INTO @PROCESOSOLPED
(
    IdSolicitudPedido,
    Folio,
    Descripcion,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    Responsable1aAprobacion,
    Fecha1aAprobacion,
    Estatus1aAprobacion,
    ResponsableReasignado,
    FechaAprobacionReasignado,
    EstatusAprobacionReasignado,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    Estatus2aAprobacion,
    UsuarioCargaPR,
    FechaCargaPR,
    NumeroPR,
    EstatusFinal
)
SELECT
    SPOT.IdSolicitudPedido,
    SOOT.Folio,
    SPOT.MotivoUrgencia,
    CCOT.CentroCosto,
    CASE
		WHEN USOT.Nombre = 'Tareas automáticas Control de Obra' THEN 'Usuario (Sistema)'
		ELSE USOT.Nombre
	END,
    SOOT.CreadoEl,
	(SELECT TOP 1 Responsable1aAprobacion FROM @IDSOLITUDOT1 WHERE IdSolicitud = SOOT.IdOTSolicitud ORDER BY Fecha1aAprobacion DESC),
	(SELECT TOP 1 Fecha1aAprobacion FROM @IDSOLITUDOT1 WHERE IdSolicitud = SOOT.IdOTSolicitud ORDER BY Fecha1aAprobacion DESC),
	(SELECT TOP 1 Estatus1aAprobacion FROM @IDSOLITUDOT1 WHERE IdSolicitud = SOOT.IdOTSolicitud ORDER BY Fecha1aAprobacion DESC),
    NULL,
    NULL,
    NULL,
    (SELECT TOP 1 Responsable2aAprobacion FROM @IDSOLITUDOT2 WHERE IdSolicitud = SOOT.IdOTSolicitud ORDER BY Fecha2aAprobacion DESC),
    (SELECT TOP 1 Fecha2aAprobacion FROM @IDSOLITUDOT2 WHERE IdSolicitud = SOOT.IdOTSolicitud ORDER BY Fecha2aAprobacion DESC),
    (SELECT TOP 1 Estatus2aAprobacion FROM @IDSOLITUDOT2 WHERE IdSolicitud = SOOT.IdOTSolicitud ORDER BY Fecha2aAprobacion DESC),
	CASE 
		WHEN SOOT.IsActivo = 0 OR SOOT.IsEliminado = 1 THEN NULL
		WHEN PR.IdAjuntoPr IS NOT NULL THEN USPROT.Nombre
		ELSE APPR.Nombre
	END AS UsuarioCargaPR,
	CASE
		WHEN SOOT.IsActivo = 0 OR SOOT.IsEliminado = 1 THEN NULL
		WHEN PR.IdAjuntoPr IS NOT NULL THEN PR.CreadoEl
		ELSE ISNULL(SOOT.FechaAprobacionSAPPR,SOOT.ModificadoEl) 
	END AS FechaCargaPR,
    ISNULL(SOOT.SAPPR,PR.ID_PR) AS NumeroPR,
	CASE 
		WHEN SOOT.IsActivo = 0 OR SOOT.IsEliminado = 1 THEN 'Baja de OT'
		ELSE OTE.Descripcion
    END
FROM Adinco.dbo.OT_Solicitud AS SOOT
	LEFT JOIN Adinco.dbo.OT_Estimacion AS ESOT
		ON ESOT.IdOTSolicitud = SOOT.IdOTSolicitud 
    LEFT JOIN dbo.MM_Pedido AS POT
        ON POT.IdPedido = ESOT.IdPedido
    LEFT JOIN dbo.MM_SolicitudPedido AS SPOT
        ON SPOT.IdSolicitudPedido = ESOT.IdSolicitudPedido
    LEFT JOIN dbo.CC_CentroCosto AS CCOT
        ON CCOT.IdCentroCosto = SOOT.IdCentroCosto
    LEFT JOIN Petrovendor.dbo.S_Usuario AS USOT
        ON USOT.IdUsuario = SPOT.IdUsuarioSolicitante 
	LEFT JOIN Adinco.dbo.OT_Estatus AS OTE
		ON OTE.IdOtEstatus = SOOT.IdOTEstatus
	LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT
		ON SUBOT.IdSubContrato = SOOT.IdSubContrato
	LEFT JOIN Adinco.dbo.PV_Subcontratista AS SUCIT
		ON SUCIT.IdSubcontratista = SUBOT.IdSubContratista
	LEFT JOIN Adinco.dbo.AP_Usuario AS APPR
        ON APPR.UsuarioID = SOOT.ModificadoPor
	LEFT JOIN dbo.DEA_AdjuntoPR AS PR
		ON PR.IdSolicitudPedido = SPOT.IdSolicitudPedido
		AND PR.Activo = 1
	LEFT JOIN dbo.S_Usuario AS USPROT
		ON USPROT.IdUsuario = PR.CreadoPor
WHERE SUBOT.IdContrato = @IDCONTRATO 
GROUP BY SPOT.IdSolicitudPedido,
		SOOT.Folio,
		SPOT.MotivoUrgencia,
		CCOT.CentroCosto,
		USOT.Nombre,
		OTE.Descripcion,
		--AP1.UsuarioID,
		APPR.Nombre,
		SOOT.FechaAprobacionSAPPR,
		SOOT.SAPPR,
		SOOT.IsActivo,
		SOOT.CreadoEl,
		SOOT.IdOTSolicitud,
		SOOT.ProgIniPorProveedor,
		SUCIT.RazonSocial,
		SUCIT.RFC,
		--AP1.Nombre,
		--SBP.CreadoEl,
		SOOT.IsEliminado,
		--SBO.CreadoEl,
		--SBP.Descripcion,
		--SBO.Descripcion,
		SOOT.ModificadoEl,
		PR.IdAjuntoPr,
		USPROT.Nombre,
		PR.CreadoEl,
		PR.ID_PR;
		--otN1.usuario,
		--otN1.fecha;

	
SELECT
    IdSolicitudPedido,
    ISNULL(Folio,'N/A') AS Folio,
    Descripcion,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    Responsable1aAprobacion,
    CASE
        WHEN Estatus1aAprobacion = 'Cancelado por Reasignacion' THEN FechaRegistroTareaReasignado
        ELSE Fecha1aAprobacion
    END AS Fecha1aAprobacion,
    Estatus1aAprobacion,
    CASE
        WHEN Estatus1aAprobacion <> 'Cancelado por Reasignacion' THEN NULL
        ELSE ResponsableReasignado
    END AS ResponsableReasignado,
    CASE
        WHEN Estatus1aAprobacion <> 'Cancelado por Reasignacion' THEN NULL
        ELSE FechaAprobacionReasignado
    END AS FechaAprobacionReasignado,
    CASE
        WHEN Estatus1aAprobacion <> 'Cancelado por Reasignacion' THEN NULL
        ELSE EstatusAprobacionReasignado
    END AS EstatusAprobacionReasignado,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    Estatus2aAprobacion,
	Responsable2daReasigacion,
	FechaAprobacion2daReasignacion,
	EstatusAprobacion2daReasignacion,
	CASE
		WHEN FechaAprobacion2daReasignacion IS NOT NULL THEN FechaAprobacion2daReasignacion
		WHEN Fecha2aAprobacion IS NOT NULL THEN Fecha2aAprobacion
		WHEN FechaAprobacionReasignado IS NOT NULL THEN FechaAprobacionReasignado
		WHEN Fecha1aAprobacion IS NOT NULL THEN Fecha1aAprobacion
		WHEN Folio IS NOT NULL AND Fecha1aAprobacion IS NOT NULL THEN Fecha1aAprobacion
    END AS FechaUltimaAprobacion,
    UsuarioCargaPR,
    FechaCargaPR,
    NumeroPR,
    EstatusFinal
INTO #PROCESOSOLPED2
FROM @PROCESOSOLPED
ORDER BY IdSolicitudPedido DESC;

INSERT INTO @DATOSSOLPEDFIN
(
    IdSolicitudPedido,
    Folio,
    Descripcion,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    Responsable1aAprobacion,
    Fecha1aAprobacion,
    Estatus1aAprobacion,
    Dias1apro,
    ResponsableReasignado,
    FechaAprobacionReasignado,
    EstatusAprobacionReasignado,
    Dias1asig,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    Estatus2aAprobacion,
    Dias2aprob,
    Responsable2daReasigacion,
    FechaAprobacion2daReasignacion,
    EstatusAprobacion2daReasignacion,
    Dias2aprobreasig,
    UsuarioCargaPR,
    FechaCargaPR,
    NumeroPR,
    DiasCargaPR,
    DiasAprobGral,
    EstatusFinal
    --FechaRegistroTareaReasignado
)
SELECT
	IdSolicitudPedido,
    Folio,
    Descripcion,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    Responsable1aAprobacion,
	Fecha1aAprobacion,
	Estatus1aAprobacion,
	dbo.CalcularTipoDEA(FechaRegistro,Fecha1aAprobacion),
	ResponsableReasignado,
	FechaAprobacionReasignado,
	EstatusAprobacionReasignado,
	dbo.CalcularTipoDEA(Fecha1aAprobacion,FechaAprobacionReasignado),
	Responsable2aAprobacion,
	Fecha2aAprobacion,
	Estatus2aAprobacion,
	(CASE
		WHEN FechaAprobacionReasignado IS NOT NULL THEN dbo.CalcularTipoDEA(FechaAprobacionReasignado,Fecha2aAprobacion)
		ELSE dbo.CalcularTipoDEA(Fecha1aAprobacion,Fecha2aAprobacion)
	END),
	Responsable2daReasigacion,
	FechaAprobacion2daReasignacion,
	EstatusAprobacion2daReasignacion,
	dbo.CalcularTipoDEA(Fecha2aAprobacion,FechaAprobacion2daReasignacion),
	UsuarioCargaPR,
	FechaCargaPR,
	NumeroPR,
	dbo.CalcularTipoDEA(FechaUltimaAprobacion,FechaCargaPR),
	dbo.CalcularTipoDEA(FechaRegistro,FechaUltimaAprobacion),
	EstatusFinal
	--FechaRegistroTareaReasignado
FROM #PROCESOSOLPED2
ORDER BY IdSolicitudPedido DESC;

DELETE FROM dbo.DEA_ProcesoSolicitudPedido;

INSERT INTO dbo.DEA_ProcesoSolicitudPedido
(
    IdSolicitudPedido,
    Folio,
    Descripcion,
    CentroCosto,
    Requisitor,
    FechaRegistro,
    Responsable1aAprobacion,
    Fecha1aAprobacion,
    DiasEspera1aAprobacion,
    Estatus1aAprobacion,
    Responsable1aReasignacion,
    FechaAprobacion1aReasignacion,
    DiasEspera1aReasignacion,
    EstatusAprobacion1aReasignacionn,
    Responsable2aAprobacion,
    Fecha2aAprobacion,
    DiasEspera2aAprobacion,
    Estatus2aAprobacion,
    Responsable2aReasignacion,
    FechaAprobacion2aReasignacion,
    DiasEspera2aReasignacion,
    EstatusAprobacion2aReasignacion,
    DiasEnAprobacionGeneral,
    UsuarioCargaPR,
    FechaCargaPR,
    DiasCargaPR,
    NumeroPR,
    DiasTotal,
    EstatusFinal
)
SELECT
	IdSolicitudPedido AS IdSolicitudPedido,
	Folio AS Folio,
	Descripcion AS Descripcion,
	CentroCosto AS CentroCosto,
	Requisitor AS Requisitor,
	FechaRegistro AS FechaRegistro,
	REPLACE(Responsable1aAprobacion,'()','') AS Responsable1aAprobacion,
	Fecha1aAprobacion AS Fecha1aAprobacion,
	CASE
		WHEN Estatus1aAprobacion = 'En Aprobación' OR Estatus1aAprobacion IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias1apro),0)
	END AS DiasEspera1aAprobacion,
	ISNULL(Estatus1aAprobacion,'') AS Estatus1aAprobacion,
	ISNULL(ResponsableReasignado,'') AS Responsable1aReasignacion,
	FechaAprobacionReasignado AS FechaAprobacionReasignado,
	CASE
		WHEN EstatusAprobacionReasignado = 'En Aprobación' OR EstatusAprobacionReasignado IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias1asig),0.00)
	END AS DiasEspera1aReasignacion,
	EstatusAprobacionReasignado AS EstatusAprobacion1aReasignacion,
	CASE
		WHEN Estatus1aAprobacion = 'Rechazada' OR EstatusAprobacionReasignado = 'Rechazada' THEN NULL
		ELSE Responsable2aAprobacion
	END AS Responsable2aAprobacion,
	CASE 
		WHEN Fecha2aAprobacion IS NULL THEN NULL
		WHEN Estatus1aAprobacion = 'Rechazada' OR EstatusAprobacionReasignado = 'Rechazada' THEN NULL
		ELSE Fecha2aAprobacion
	END AS Fecha2aAprobacion,
	CASE
		WHEN Estatus2aAprobacion = 'En Aprobación' OR Estatus2aAprobacion IS NULL THEN NULL
		WHEN Estatus1aAprobacion = 'Rechazada' OR EstatusAprobacionReasignado = 'Rechazada' THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias2aprob),0.00)
	END AS DiasEspera2aAprobacion,
	CASE
		WHEN Estatus2aAprobacion = 'Cancelado por Rechazo' THEN NULL
		ELSE Estatus2aAprobacion
	END AS Estatus2aAprobacion,
	Responsable2daReasigacion AS Responsable2aReasignacion,
	FechaAprobacion2daReasignacion AS FechaAprobacion2daReasignacion,
	CASE
		WHEN EstatusAprobacion2daReasignacion = 'En Aprobación' OR EstatusAprobacion2daReasignacion IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias2aprobreasig),0.00)
	END AS DiasEspera2aReasignacion,
	EstatusAprobacion2daReasignacion AS EstatusAprobacion2aReasignacion,
	ISNULL(CONVERT(DECIMAL(5,2),DiasAprobGral),0.00) AS DiasEnAprobacionGeneral,
	UsuarioCargaPR AS UsuarioCargaPR,
	FechaCargaPR AS FechaCargaPR,
	CASE
		WHEN UsuarioCargaPR IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasCargaPR),0.00)
	END AS DiasCargaPR,
	NumeroPR AS NumeroPR,
	ISNULL(CONVERT(DECIMAL(5,2),DiasAprobGral),0.00) + ISNULL(CONVERT(DECIMAL(5,2),DiasCargaPR),0.00) AS DiasTotal,
	EstatusFinal AS EstatusFinal
FROM @DATOSSOLPEDFIN
ORDER BY IdSolicitudPedido DESC;

DROP TABLE #PROCESOSOLPED2
DROP TABLE #tmpOTManagerNot

END
