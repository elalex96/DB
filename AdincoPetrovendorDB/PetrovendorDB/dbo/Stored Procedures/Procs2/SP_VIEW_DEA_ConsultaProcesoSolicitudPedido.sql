use petrovendor
go
drop procedure if exists SP_VIEW_DEA_ConsultaProcesoSolicitudPedido
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <18/05/2020>
-- Description:	<Consulta de proceso de solicitud de pedido>
-- =============================================
-- Author:		<David De La Cruz>
-- Create date: <15/12/2021>
-- Description:	<Se optimiza el procedimiento para issue 430 (AdincoPetrovendorBD)>
-- =============================================
CREATE PROCEDURE [dbo].[SP_VIEW_DEA_ConsultaProcesoSolicitudPedido]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DROP TABLE IF EXISTS #PROCESOSOLPED2
CREATE TABLE #PROCESOSOLPED2
(
	IdSolicitudPedido Int null,
	Folio varchar(300),
	Descripcion varchar(max),
	CentroCosto varchar(300),
	Requisitor varchar(500),
	FechaRegistro datetime,
	Responsable1aAprobacion varchar(500),
	Fecha1aAprobacion datetime,
	Estatus1aAprobacion varchar(300),
	ResponsableReasignado varchar(500),
	FechaAprobacionReasignado datetime,
	EstatusAprobacionReasignado varchar(500),
	Responsable2aAprobacion varchar(500),
    Fecha2aAprobacion datetime,
    Estatus2aAprobacion varchar(500),
	Responsable2daReasigacion varchar(500),
	FechaAprobacion2daReasignacion datetime,
	EstatusAprobacion2daReasignacion varchar(500),
	FechaUltimaAprobacion datetime,
    UsuarioCargaPR varchar(500),
    FechaCargaPR datetime,
    NumeroPR varchar(100),
    EstatusFinal varchar(500)
)
DROP TABLE IF EXISTS #tmpOTManagerNot
CREATE TABLE #tmpOTManagerNot
(
	IdOTSolicitud INT PRIMARY KEY NOT NULL,
	Usuario VARCHAR(500),
	Fecha DATETIME
)
DECLARE @IDCONTRATO INT = (10038);
DECLARE @CENTROSCOSTOS TABLE(IdSolicitudPedido INT, CentroCosto NVARCHAR(100));
DECLARE @USUARIOAPROBADOR1 TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100));
DECLARE @USUARIOAPROBADOR2 TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100), IdEstatus INT);
DECLARE @USUARIOREASIGNADO TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100));
DECLARE @USUARIOREASIGNADO2 TABLE(IdSolicitudPedido INT, Nombre NVARCHAR(100), FechaRegistro DATETIME, FechaCambioEstatus DATETIME, Dias INT, Estatus NVARCHAR(100));
DECLARE @IDSOLITUDOT2 TABLE(IdSolicitud INT,Responsable2aAprobacion NVARCHAR(500),Fecha2aAprobacion DATETIME,Estatus2aAprobacion NVARCHAR(100));
DECLARE @IDSOLITUDOT1 TABLE(IdSolicitud INT,Responsable1aAprobacion NVARCHAR(500),Fecha1aAprobacion DATETIME,Estatus1aAprobacion NVARCHAR(100));
DECLARE @PROCESOSOLPED TABLE(
                            IdSolicitudPedido INT, 
                            Folio NVARCHAR(100),
                            Descripcion NVARCHAR(1000), 
                            CentroCosto NVARCHAR(500), 
                            Requisitor NVARCHAR(500), 
                            FechaRegistro DATETIME, 
                            Responsable1aAprobacion NVARCHAR(500),
                            Fecha1aAprobacion DATETIME,
                            Estatus1aAprobacion NVARCHAR(500),
                            ResponsableReasignado NVARCHAR(500),
                            FechaAprobacionReasignado DATETIME,
                            EstatusAprobacionReasignado NVARCHAR(500),
                            Responsable2aAprobacion NVARCHAR(500),
                            Fecha2aAprobacion DATETIME,
                            Estatus2aAprobacion NVARCHAR(500),
							Responsable2daReasigacion NVARCHAR(500),
                            FechaAprobacion2daReasignacion DATETIME,
                            EstatusAprobacion2daReasignacion NVARCHAR(500),
                            UsuarioCargaPR NVARCHAR(500),
                            FechaCargaPR DATETIME,
                            NumeroPR NVARCHAR(100),
                            EstatusFinal NVARCHAR(100),
                            FechaRegistroTareaReasignado DATETIME
);

DECLARE @DATOSSOLPEDFIN TABLE(
                            IdSolicitudPedido INT, 
                            Folio NVARCHAR(100),
                            Descripcion NVARCHAR(1000), 
                            CentroCosto NVARCHAR(500), 
                            Requisitor NVARCHAR(500), 
                            FechaRegistro DATETIME, 
                            Responsable1aAprobacion NVARCHAR(500),
                            Fecha1aAprobacion DATETIME,
                            Estatus1aAprobacion NVARCHAR(500),
							Dias1apro NVARCHAR(100),
                            ResponsableReasignado NVARCHAR(500),
                            FechaAprobacionReasignado DATETIME,
                            EstatusAprobacionReasignado NVARCHAR(500),
							Dias1asig NVARCHAR(100),
                            Responsable2aAprobacion NVARCHAR(500),
                            Fecha2aAprobacion DATETIME,
                            Estatus2aAprobacion NVARCHAR(500),
							Dias2aprob NVARCHAR(100),
							Responsable2daReasigacion NVARCHAR(500),
                            FechaAprobacion2daReasignacion DATETIME,
                            EstatusAprobacion2daReasignacion NVARCHAR(500),
							Dias2aprobreasig NVARCHAR(100),
                            UsuarioCargaPR NVARCHAR(500),
                            FechaCargaPR DATETIME,
                            NumeroPR NVARCHAR(100),
							DiasCargaPR NVARCHAR(100),
							DiasAprobGral NVARCHAR(100),
                            EstatusFinal NVARCHAR(100),
                            FechaRegistroTareaReasignado DATETIME
                            );
-- PARA OTS SIN BITACORA, BUSCAR ACCIONES DEL MANAGER EN BASE A LAS NOTIFICACIONES
INSERT INTO #tmpOTManagerNot
(
	IdOTSolicitud,
	Usuario,
	Fecha 
)
SELECT OT.IdOTSolicitud,
		u.Usuario,
		Fecha = MIN(n.CreadoEl)
FROM Adinco..OT_SolicitudBitacora sb 
inner join Adinco..OT_Solicitud ot 
on sb.IdOTSolicitud = ot.IdOTSolicitud
inner join Adinco..s_notificacion n 
on n.Asunto like '%'+ot.Folio+'%' 
inner join Adinco..AP_Usuario u 
on n.CreadoPor = u.UsuarioID
where n.Asunto like '%Control de Obra%' 
AND (
	n.Mensaje like '%La OT ha sido aprobada%' OR
	n.Mensaje like '%La OT ha sido rechazada%' OR
	n.Mensaje like '%Es necesario revisar la programacion inicial%'  OR
	n.Mensaje like '%Es necesario aprobar/rechazar%' 
)
group by OT.IdOTSolicitud,
		u.Usuario

--SE OBTIENEN LOS CC POR CONTRATO Y SOLPED
INSERT INTO @CENTROSCOSTOS
SELECT 
    SPC.IdSolicitudPedido,
    CC.CentroCosto
FROM dbo.MM_SolicitudPedido AS SPC
    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
        ON SPC.IdSolicitudPedido = SPD.IdSolicitudPedido
    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPLP
        ON SPD.IdSolicitudPedidoDetalle = SPLP.IdSolicitudPedidoDetalle
    LEFT JOIN dbo.CC_CentroCosto (NOLOCK) AS CC
        ON SPLP.IdCentroCosto = CC.IdCentroCosto
WHERE SPC.IdContrato = @IDCONTRATO
    AND (CC.CentroCosto IS NOT NULL OR CC.CentroCosto <> '')
	GROUP BY SPC.IdSolicitudPedido,CC.CentroCosto;
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
        ON OP.IdOperacion = T.IdOperacion
        AND 1 = T.NoSecuencia
    LEFT JOIN dbo.S_Usuario AS USFA
        ON T.IdAprobador = USFA.IdUsuario
    LEFT JOIN dbo.TA_Estatus (NOLOCK) AS ET1
        ON T.IdEstatus = ET1.IdEstatus
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
        ON OP.IdOperacion = T.IdOperacion
        AND 2 = T.NoSecuencia
    LEFT JOIN dbo.S_Usuario AS USFA
        ON T.IdAprobador = USFA.IdUsuario
    LEFT JOIN dbo.TA_Estatus (NOLOCK) AS ET1
        ON T.IdEstatus = ET1.IdEstatus
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
        ON OP.IdOperacion = T.IdOperacion
        AND 1 = T.NoSecuencia
        AND 7 <> T.IdEstatus
    LEFT JOIN dbo.S_Usuario AS USFA
        ON T.IdAprobador = USFA.IdUsuario
    LEFT JOIN dbo.TA_Estatus (NOLOCK) AS ET1
        ON T.IdEstatus = ET1.IdEstatus
    LEFT JOIN dbo.MM_SolicitudPedido AS SP
        ON OP.IdDocumento = SP.IdSolicitudPedido
        AND OP.IdProveedor = SP.IdProveedor
        AND 2 = OP.IdTipoOperacion
	inner join @USUARIOAPROBADOR2 TMPU
		on 
		(ET1.Nombre) <> TMPU.Nombre
		and 
		SP.IdSolicitudPedido = TMPU.IdSolicitudPedido
WHERE SP.IdContrato = @IDCONTRATO
		group by SP.IdSolicitudPedido,
		USFA.Nombre,
		T.FechaRegistro,
		T.FechaCambioEstatus,
		SP.FechaAlta,
		T.FechaCambioEstatus,
		ET1.Nombre

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
        ON T.IdAprobador = USFA.IdUsuario
    LEFT JOIN dbo.TA_Estatus (NOLOCK) AS ET1
        ON T.IdEstatus = ET1.IdEstatus
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
		WHEN ST.ProgIniPorProveedor = 1 THEN /*ISNULL(AP1.Nombre,'') +*/ ' (' + (SELECT STUFF ((SELECT CAST(',' AS VARCHAR(500)) + 
																							ISNULL(
																									case when US.Nombre = AP1.Nombre then ''
																										 else	US.Nombre
																								    end
																								,'')
																				FROM Adinco.dbo.OT_Solicitud AS OTSI 
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacion AS FA 
																					ON 1 = FA.TipoFlujoAprobacionId
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatus AS FAE
																					ON 2 = FAE.FlujoAprobacionEstatusId
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatusUsuarios AS FAEU
																					ON FAE.FlujoAprobacionEstatusId = FAEU.FlujoAprobacionEstatusId
																				LEFT JOIN Adinco.dbo.AP_Usuario (NOLOCK) AS US 
																					ON FAEU.UsuarioId = US.UsuarioID
																					AND 1 = US.IsActivo
																				WHERE       
																					OTSI.IdOTSolicitud = ST.IdOTSolicitud
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
        ON ST.IdOTSolicitud = SBO.IdOTSolicitud
        AND (SBO.IdTipoMovimiento = 2 
			OR SBO.Descripcion = 'Rechazada Operador'
			OR SBO.Descripcion like '%Aprobada%Operador%'
			OR SBO.Descripcion = 'Aprobada Operador'
			OR SBO.Descripcion = 'Enviada a Subcontratista')
LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBP
        ON ST.IdOTSolicitud = SBP.IdOTSolicitud
        AND (SBP.IdTipoMovimiento = 4 
				OR SBP.Descripcion = 'Rechazada Subcontratista' 
				OR SBP.Descripcion = 'Propuesta por Subcontratista')
LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT
		ON ST.IdSubContrato = SUBOT.IdSubContrato
	LEFT JOIN Adinco.dbo.PV_Subcontratista (NOLOCK) AS SUCIT
		ON SUBOT.IdSubContratista = SUCIT.IdSubcontratista
LEFT JOIN Adinco.dbo.AP_Usuario AS AP1
        ON SBO.UsuarioAdincoId = AP1.UsuarioID
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
																								(SELECT CAST(',' AS VARCHAR(500)) + ISNULL(US.Nombre,'')
																				FROM Adinco.dbo.OT_Solicitud AS OTSI 
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacion AS FA 
																					ON 1 = FA.TipoFlujoAprobacionId
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatus AS FAE
																					ON 2 = FAE.FlujoAprobacionEstatusId
																				LEFT JOIN Adinco.dbo.AP_FlujoAprobacionEstatusUsuarios AS FAEU
																					ON FAE.FlujoAprobacionEstatusId = FAEU.FlujoAprobacionEstatusId
																				LEFT JOIN Adinco.dbo.AP_Usuario AS US 
																					ON FAEU.UsuarioId = US.UsuarioID
																					AND 1 = US.IsActivo
																				WHERE       
																					OTSI.IdOTSolicitud = ST.IdOTSolicitud
																						AND US.UsuarioID <> AP1.UsuarioID
																						AND US.Usuario not like '%@adinco.mx%'
																						AND US.Usuario not like '%@ogss.com.mx%'
																						AND US.Usuario not like '%@smps-sp.com%'
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
        ON ST.IdOTSolicitud = SBO.IdOTSolicitud
        AND (SBO.IdTipoMovimiento = 2 
			OR SBO.Descripcion = 'Rechazada Operador'
			OR SBO.Descripcion like '%Aprobada%Operador%'
			OR SBO.Descripcion = 'Aprobada Operador'
			OR SBO.Descripcion = 'Enviada a Subcontratista')
LEFT JOIN Adinco.dbo.OT_SolicitudBitacora AS SBP
        ON ST.IdOTSolicitud = SBP.IdOTSolicitud
        AND (SBP.IdTipoMovimiento = 4 
				OR SBP.Descripcion = 'Rechazada Subcontratista' 
				OR SBP.Descripcion = 'Propuesta por Subcontratista')
LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT
		ON ST.IdSubContrato = SUBOT.IdSubContrato
	LEFT JOIN Adinco.dbo.PV_Subcontratista (NOLOCK) AS SUCIT
		ON SUBOT.IdSubContratista = SUCIT.IdSubcontratista
LEFT JOIN Adinco.dbo.AP_Usuario AS AP1
        ON SBO.UsuarioAdincoId = AP1.UsuarioID
LEFT JOIN #tmpOTManagerNot otN1 
		ON ST.IdOTSolicitud = otN1.IdOTSolicitud
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
        ON SP.IdUsuarioSolicitante = US.IdUsuario
    -- SE LIGA A CENTROS DE COSTO POR SOLPED
    LEFT JOIN @CENTROSCOSTOS AS CC2
        ON SP.IdSolicitudPedido = CC2.IdSolicitudPedido
    LEFT JOIN dbo.TA_Operacion AS OP
        ON SP.IdSolicitudPedido = OP.IdDocumento
        AND SP.IdProveedor = OP.IdProveedor
        AND 2 = OP.IdTipoOperacion
    LEFT JOIN dbo.TA_FlujoTarea AS FT
        ON OP.IdFlujoTarea = FT.IdFlujoTarea
    --ESTATUS GENERAL DE LA OPERACION
    LEFT JOIN dbo.TA_Estatus (NOLOCK) AS EG
        ON OP.IdEstatusOperacion = EG.IdEstatus
    --CARGA DE PR 
    LEFT JOIN dbo.DEA_AdjuntoPR AS PR
        ON SP.IdSolicitudPedido = PR.IdSolicitudPedido
        AND 1 = PR.Activo
        AND 0 = ISNULL(PR.IsEliminado,0)
    LEFT JOIN dbo.S_Usuario AS USPR
        ON PR.CreadoPor = USPR.IdUsuario
    LEFT JOIN dbo.MM_Pedido AS P
        ON SP.IdSolicitudPedido = P.IdSolicitudPedido
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
		ON SOOT.IdOTSolicitud  = ESOT.IdOTSolicitud
    LEFT JOIN dbo.MM_Pedido AS POT
        ON ESOT.IdPedido = POT.IdPedido
    LEFT JOIN dbo.MM_SolicitudPedido AS SPOT
        ON ESOT.IdSolicitudPedido = SPOT.IdSolicitudPedido
    LEFT JOIN dbo.CC_CentroCosto (NOLOCK) AS CCOT
        ON SOOT.IdCentroCosto = CCOT.IdCentroCosto
    LEFT JOIN Petrovendor.dbo.S_Usuario AS USOT
        ON SPOT.IdUsuarioSolicitante = USOT.IdUsuario
	LEFT JOIN Adinco.dbo.OT_Estatus (NOLOCK) AS OTE
		ON SOOT.IdOTEstatus = OTE.IdOtEstatus
	LEFT JOIN Adinco.dbo.SC_SubContrato AS SUBOT
		ON SOOT.IdSubContrato = SUBOT.IdSubContrato
	LEFT JOIN Adinco.dbo.PV_Subcontratista (NOLOCK) AS SUCIT
		ON SUBOT.IdSubContratista = SUCIT.IdSubcontratista
	LEFT JOIN Adinco.dbo.AP_Usuario AS APPR
        ON SOOT.ModificadoPor = APPR.UsuarioID
	LEFT JOIN dbo.DEA_AdjuntoPR AS PR
		ON SPOT.IdSolicitudPedido = PR.IdSolicitudPedido
		AND PR.Activo = 1
	LEFT JOIN dbo.S_Usuario AS USPROT
		ON PR.CreadoPor = USPROT.IdUsuario
WHERE SUBOT.IdContrato = @IDCONTRATO 
GROUP BY SPOT.IdSolicitudPedido,
		SOOT.Folio,
		SPOT.MotivoUrgencia,
		CCOT.CentroCosto,
		USOT.Nombre,
		OTE.Descripcion,
		APPR.Nombre,
		SOOT.FechaAprobacionSAPPR,
		SOOT.SAPPR,
		SOOT.IsActivo,
		SOOT.CreadoEl,
		SOOT.IdOTSolicitud,
		SOOT.ProgIniPorProveedor,
		SUCIT.RazonSocial,
		SUCIT.RFC,
		SOOT.IsEliminado,
		SOOT.ModificadoEl,
		PR.IdAjuntoPr,
		USPROT.Nombre,
		PR.CreadoEl,
		PR.ID_PR;
INSERT INTO #PROCESOSOLPED2(
	IdSolicitudPedido ,
	Folio ,
	Descripcion ,
	CentroCosto ,
	Requisitor ,
	FechaRegistro ,
	Responsable1aAprobacion ,
	Fecha1aAprobacion ,
	Estatus1aAprobacion ,
	ResponsableReasignado ,
	FechaAprobacionReasignado ,
	EstatusAprobacionReasignado ,
	Responsable2aAprobacion ,
    Fecha2aAprobacion ,
    Estatus2aAprobacion ,
	Responsable2daReasigacion ,
	FechaAprobacion2daReasignacion ,
	EstatusAprobacion2daReasignacion ,
	FechaUltimaAprobacion ,
    UsuarioCargaPR ,
    FechaCargaPR ,
    NumeroPR ,
    EstatusFinal )	
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
END
