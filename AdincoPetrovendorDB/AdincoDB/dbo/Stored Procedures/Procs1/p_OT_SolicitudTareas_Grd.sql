-- p_OT_SolicitudTareas_Grd 10038,10,0,1,1445
CREATE PROC [p_OT_SolicitudTareas_Grd]
    @pIdContrato INT,
    @pUsuarioAdincoId INT,
    @pUsuarioPetroId INT,
    @pPend_Comp INT, --0 ambas, 1 pendientes, 2 completadas
    @pIdProveedor INT = 0
AS
BEGIN
    DECLARE @emailUsuario VARCHAR(50)
    /*PRODUCCIÓN
    DECLARE @dominioAdinco VARCHAR(100)='https://adinco.mx',
    		@dominioPetrovendor VARCHAR(100)='https://petrovendor.com.mx',
    		@dominioProcura VARCHAR(100)='https://procura.adinco.mx/'
	*/
    /*QA
	DECLARE @dominioAdinco VARCHAR(100)='http://mpyadinco.adinco.mx',
			@dominioPetrovendor VARCHAR(100)='http://mpypetrovendor.adinco.mx',
			@dominioProcura VARCHAR(100)= 'https://MPYprocura.adinco.mx'
	*/
    /*DEV*/
    DECLARE @dominioAdinco VARCHAR(100) = 'http://localhost:52692/',      --https://adinco.mx
            @dominioPetrovendor VARCHAR(100) = 'http://localhost:58935/', --https://petrovendor.com.mx
            @dominioProcura VARCHAR(100) = 'http://localhost:58936/'      --https://procura.adinco.mx
    /*Tablas Temporales*/
    CREATE TABLE #tmpTareas
    (
        IdOTTarea INT,
        Folio VARCHAR(250),
        IdOTSolicitud INT,
        FechaRegistro DATETIME,
        Tarea VARCHAR(300),
        Estatus VARCHAR(50),
        Url VARCHAR(500),
        UrlText VARCHAR(100),
        FechaCompletada DATETIME,
        Completada BIT,
        UsuarioAsignado VARCHAR(5000),
        CentroCosto VARCHAR(250)
    );
    CREATE TABLE #tmpTareasPendientesDeAprobar
    (
        IdOTTarea INT,
        Folio VARCHAR(250),
        IdOTSolicitud INT,
        FechaRegistro DATETIME,
        Tarea VARCHAR(300),
        Estatus VARCHAR(50),
        Url VARCHAR(500),
        UrlText VARCHAR(100),
        FechaCompletada DATETIME,
        Completada BIT,
        UsuarioAsignado VARCHAR(5000),
        CentroCosto VARCHAR(250),
        IdOTEstatus INT,
        tmpAceptacionesSinRecIdOTSolicitud INT,
        tmpAceptacionesSinRecidAceptacionPedido INT,
        tmpAceptacionesPendIdOTSolicitud INT,
        tmpEstimacionPendIdOTSolicitud INT,
        tmpEstimacionPendSemanaID VARCHAR(21),
        tmpCerrarSemanasFecha DATETIME,
        tmpAceptacionesPendIdPedido INT,
        tmpAceptacionesPendIdPedidoGen INT,
        OT_GetMailUsuariosEstatus1 VARCHAR(5000),
        OT_GetMailUsuariosEstatus2 VARCHAR(5000),
        OT_GetMailUsuariosEstatus3 VARCHAR(5000),
        OT_GetMailUsuariosEstatus4 VARCHAR(5000),
        OT_GetMailUsuariosEstatus5 VARCHAR(5000),
        OT_GetMailUsuariosEstatus6 VARCHAR(5000)
    );
    CREATE TABLE #tmpTareasSinRelacionPedido
    (
        IdOTTarea INT,
        Folio VARCHAR(250),
        IdOTSolicitud INT,
        FechaRegistro DATETIME,
        Tarea VARCHAR(300),
        Estatus VARCHAR(50),
        Url VARCHAR(500),
        UrlText VARCHAR(100),
        FechaCompletada DATETIME,
        Completada BIT,
        UsuarioAsignado VARCHAR(5000),
        CentroCosto VARCHAR(250)
    );
    CREATE TABLE #tmpTareasCompletadas
    (
        IdOTTarea INT,
        Folio VARCHAR(250),
        IdOTSolicitud INT,
        FechaRegistro DATETIME,
        Tarea VARCHAR(300),
        Estatus VARCHAR(50),
        Url VARCHAR(500),
        UrlText VARCHAR(100),
        FechaCompletada DATETIME,
        Completada BIT,
        UsuarioAsignado VARCHAR(5000),
        CentroCosto VARCHAR(250),
        UsuarioAdincoId INT,
        FlujoAprobacionTareaId INT
    );
    CREATE TABLE #tmpCerrarSemanas
    (
        IdOTSolicitud INT,
        IdOTSolicitudMaterial INT,
        Fecha DATETIME,
        IdOTSolicitudProgramaCaptura INT
    );
    CREATE TABLE #tmpEstimacionPend
    (
        IdOTSolicitud INT,
        IdOTSolicitudMaterial INT,
        Fecha DATETIME,
        SemanaID VARCHAR(21)
    );
    CREATE TABLE #tmpAceptacionesPend
    (
        IdOTEstimacion INT,
        IdOTSolicitud INT,
        IdPedido INT,
        IdPedidoGen INT
    );
    CREATE TABLE #tmpAceptacionesSinRec
    (
        IdOTEstimacion INT,
        IdOTSolicitud INT,
        IdPedido INT,
        idPedidoGen INT,
        IdAceptacionPedido INT
    );
    CREATE TABLE #tmpEstimacionSinPO
    (
        IdOTSolicitud INT,
        IdOTEstimacion INT,
        IdPedidoGeneral INT,
        CreadoEl DATETIME,
        IdPedido INT
    );
    CREATE TABLE #tmpOTUsuarios
    (
        UsuarioID INT,
        Usuario VARCHAR(500),
        FlujoAprobacionEstatusId INT,
        IdOTSolicitud INT
    );
    CREATE TABLE #tmpOTEstatusPermitidos (IdOTEstatus INT);
    /*Obtencion Valores*/
    INSERT INTO #tmpOTEstatusPermitidos
    (
        IdOTEstatus
    )
    SELECT IdOTEstatus
    FROM OT_Solicitud
    GROUP BY IdOTEstatus

    IF (@pUsuarioAdincoId > 0)
    BEGIN
        DELETE #tmpOTEstatusPermitidos
        WHERE IdOTEstatus IN ( 7, 8, 12 )
    END

    IF (@pUsuarioPetroId > 0)
    BEGIN
        DELETE #tmpOTEstatusPermitidos
        WHERE IdOTEstatus IN ( 7, 8, 12 )
    END

    IF (ISNULL(@pUsuarioAdincoId, 0) = 0)
    BEGIN
        DELETE #tmpOTEstatusPermitidos
        WHERE IdOTEstatus IN ( 1, 7, 8, 12 )
    END

    IF @pPend_Comp = 1
    BEGIN
        /*SEMANAS QUE FALTAN CERRAR*/
        INSERT INTO #tmpCerrarSemanas
        (
            IdOTSolicitud,
            IdOTSolicitudMaterial,
            Fecha,
            IdOTSolicitudProgramaCaptura
        )
        SELECT OT_Solicitud.IdOTSolicitud,
               OT_SolicitudMaterial.IdOTSolicitudMaterial,
               OT_SolicitudProgramaCaptura.Fecha,
               OT_SolicitudProgramaCaptura.IdOTSolicitudProgramaCaptura
        FROM OT_Solicitud (NOLOCK)
            INNER JOIN OT_SolicitudMaterial (NOLOCK)
                ON OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
                   AND OT_Solicitud.IsActivo = 1
            INNER JOIN SC_SubContrato (NOLOCK)
                ON OT_Solicitud.IdSubcontrato = SC_SubContrato.IdSubcontrato
                   AND SC_SubContrato.IDContrato = @pIdContrato
            INNER JOIN OT_SolicitudProgramaCaptura (NOLOCK)
                ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                   AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
        WHERE OT_Solicitud.IsActivo = 1
              AND SC_SubContrato.IDContrato = @pIdContrato
        GROUP BY OT_Solicitud.IdOTSolicitud,
                 OT_SolicitudMaterial.IdOTSolicitudMaterial,
                 OT_SolicitudProgramaCaptura.Fecha,
                 OT_SolicitudProgramaCaptura.IdOTSolicitudProgramaCaptura
        /*Se saca subquery que manejaba NOT exists*/
        DELETE #tmpCerrarSemanas
        FROM #tmpCerrarSemanas
            INNER JOIN OT_ProgramaSemanaCerrada e
                ON #tmpCerrarSemanas.IdOTSolicitud = e.IdOTSolicitud
                   AND #tmpCerrarSemanas.Fecha
                   BETWEEN e.FechaSemanaIni AND e.FechaSemanaFin
                   AND e.isActivo = 1
        /*SEMANAS QUE FALTAN ESTIMAR*/
        INSERT INTO #tmpEstimacionPend
        (
            IdOTSolicitud,
            IdOTSolicitudMaterial,
            Fecha,
            SemanaID
        )
        SELECT OT_Solicitud.IdOTSolicitud,
               OT_SolicitudMaterial.IdOTSolicitudMaterial,
               OT_SolicitudProgramaCaptura.Fecha,
               OT_ProgramaSemanaCerrada.SemanaID
        FROM OT_Solicitud (NOLOCK)
            INNER JOIN OT_SolicitudMaterial (NOLOCK)
                ON OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
                   AND OT_Solicitud.IsActivo = 1
            INNER JOIN SC_SubContrato (NOLOCK)
                ON OT_Solicitud.IdSubcontrato = SC_SubContrato.IdSubcontrato
            INNER JOIN OT_SolicitudProgramaCaptura (NOLOCK)
                ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                   AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                   AND OT_SolicitudProgramaCaptura.VoBoContratista = 1
            INNER JOIN OT_ProgramaSemanaCerrada (NOLOCK)
                ON OT_Solicitud.IdOTSolicitud = OT_ProgramaSemanaCerrada.IdOTSolicitud
                   AND OT_SolicitudProgramaCaptura.Fecha
                   BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
                   AND OT_ProgramaSemanaCerrada.isActivo = 1
        WHERE OT_Solicitud.IsActivo = 1
              AND SC_SubContrato.IDContrato = @pIdContrato
        GROUP BY OT_Solicitud.IdOTSolicitud,
                 OT_SolicitudMaterial.IdOTSolicitudMaterial,
                 OT_SolicitudProgramaCaptura.Fecha,
                 OT_ProgramaSemanaCerrada.SemanaID
        /*Se saca subquery que manejaba NOT exists*/
        DELETE #tmpEstimacionPend
        FROM #tmpEstimacionPend
            INNER JOIN OT_Estimacion
                ON #tmpEstimacionPend.IdOTSolicitud = OT_Estimacion.IdOTSolicitud
                   AND #tmpEstimacionPend.Fecha
                   BETWEEN OT_Estimacion.FechaCorteInicio AND OT_Estimacion.FechaCorteFin
                   AND ISNULL(OT_Estimacion.Cancelada, 0) = 0
        /*Estimaciones sin aceptacion*/
        INSERT INTO #tmpAceptacionesPend
        (
            IdOTEstimacion,
            IdOTSolicitud,
            IdPedido,
            IdPedidoGen
        )
        SELECT OT_Estimacion.IdOTEstimacion,
               OT_Estimacion.IdOTSolicitud,
               idPedido = OT_Estimacion.IdPedido,
               idPedidoGen = OT_Estimacion.IdPedidoGeneral
        FROM OT_Estimacion (NOLOCK)
            INNER JOIN OT_Solicitud (NOLOCK)
                ON ISNULL(OT_Estimacion.cancelada, 0) = 0
                   AND OT_Estimacion.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
            INNER JOIN SC_SubContrato (NOLOCK)
                ON OT_Solicitud.IdSubcontrato = SC_SubContrato.IdSubcontrato
        WHERE SC_SubContrato.IdContrato = @pIdContrato
              AND ISNULL(OT_Estimacion.cancelada, 0) = 0
        GROUP BY OT_Estimacion.IdOTEstimacion,
                 OT_Estimacion.IdPedido,
                 OT_Estimacion.IdPedidoGeneral,
                 OT_Estimacion.IdOTSolicitud
        /*Se saca subquery que manejaba NOT exists*/
        DELETE #tmpAceptacionesPend
        FROM #tmpAceptacionesPend
            INNER JOIN Petrovendor..MM_AceptacionPedido p
                ON #tmpAceptacionesPend.IdPedido = p.IdPedido
        /*Aceptaciones sin reclasificacion*/
        INSERT INTO #tmpAceptacionesSinRec
        (
            IdOTEstimacion,
            IdOTSolicitud,
            IdPedido,
            idPedidoGen,
            IdAceptacionPedido
        )
        SELECT OT_Estimacion.IdOTEstimacion,
               OT_Estimacion.IdOTSolicitud,
               idPedido = OT_Estimacion.IdPedido,
               idPedidoGen = OT_Estimacion.IdPedidoGeneral,
               petrovendor..MM_AceptacionPedido.idAceptacionPedido
        FROM OT_Estimacion (NOLOCK)
            INNER JOIN OT_Solicitud (NOLOCK)
                ON ISNULL(OT_Estimacion.Cancelada, 0) = 0
                   AND OT_Estimacion.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
            INNER JOIN SC_SubContrato (NOLOCK)
                ON OT_Solicitud.IdSubcontrato = SC_SubContrato.IdSubcontrato
                   AND SC_SubContrato.IdContrato = @pIdContrato
            INNER JOIN petrovendor..MM_AceptacionPedido (NOLOCK)
                ON OT_Estimacion.IdPedido = petrovendor..MM_AceptacionPedido.IdPedido
                   AND petrovendor..MM_AceptacionPedido.ModificadoPor IS NULL
        WHERE SC_SubContrato.IdContrato = @pIdContrato
              AND ISNULL(OT_Estimacion.Cancelada, 0) = 0
        GROUP BY OT_Estimacion.IdOTEstimacion,
                 OT_Estimacion.IdPedido,
                 OT_Estimacion.IdPedidoGeneral,
                 OT_Estimacion.IdOTSolicitud,
                 petrovendor..MM_AceptacionPedido.idAceptacionPedido
        /*Se saca subquery que manejaba NOT exists*/
        DELETE #tmpAceptacionesSinRec
        FROM #tmpAceptacionesSinRec
            INNER JOIN petrovendor..MM_AceptacionPedidoDetalleEliminada
                ON #tmpAceptacionesSinRec.idAceptacionPedido = petrovendor..MM_AceptacionPedidoDetalleEliminada.IdAceptacionPedido

        DELETE #tmpAceptacionesSinRec
        FROM #tmpAceptacionesSinRec
            INNER JOIN petrovendor..MM_AceptacionFactura saf
                ON #tmpAceptacionesSinRec.idAceptacionPedido = saf.IdAceptacionPedido
        /*ISSUE 1018. Generar info de Estimaciones sin PO*/
        INSERT INTO #tmpEstimacionSinPO
        (
            IdOTSolicitud,
            IdOTEstimacion,
            IdPedidoGeneral,
            CreadoEl,
            IdPedido
        )
        SELECT OT_Estimacion.IdOTSolicitud,
               OT_Estimacion.IdOTEstimacion,
               OT_Estimacion.IdPedidoGeneral,
               OT_Estimacion.CreadoEl,
               OT_Estimacion.IdPedido
        FROM OT_Estimacion (NOLOCK)
            INNER JOIN OT_Solicitud (NOLOCK)
                ON OT_Estimacion.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
                   AND ISNULL(OT_Estimacion.Cancelada, 0) = 0
            INNER JOIN SC_SubContrato (NOLOCK)
                ON OT_Solicitud.IdSubContrato = SC_SubContrato.IdSubContrato
                   AND SC_SubContrato.IdContrato = @pIdContrato
        WHERE ISNULL(OT_Estimacion.Cancelada, 0) = 0
        GROUP BY OT_Estimacion.IdOTSolicitud,
                 OT_Estimacion.IdOTEstimacion,
                 OT_Estimacion.IdPedidoGeneral,
                 OT_Estimacion.CreadoEl,
                 OT_Estimacion.IdPedido
        /*Se saca left join*/
        DELETE #tmpEstimacionSinPO
        FROm #tmpEstimacionSinPO
            INNER JOIN petrovendor..DEA_Relacion_PR_PO
                ON #tmpEstimacionSinPO.IdPedido = petrovendor..DEA_Relacion_PR_PO.IdPedido
        /*usuarios OT*/
        INSERT INTO #tmpOTUsuarios
        (
            UsuarioID,
            Usuario,
            FlujoAprobacionEstatusId,
            IdOTSolicitud
        )
        SELECT AP_Usuario.UsuarioID,
               AP_Usuario.Usuario,
               AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId,
               OT_Solicitud.IdOTSolicitud
        FROM OT_Solicitud (NOLOCK)
            INNER JOIN AP_UsuarioCentroCosto (NOLOCK)
                ON OT_Solicitud.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
            INNER JOIN AP_Usuario (NOLOCK)
                ON AP_UsuarioCentroCosto.IdUsuario = AP_Usuario.usuarioId
            INNER JOIN AP_FlujoAprobacionEstatusUsuarios (NOLOCK)
                ON AP_Usuario.usuarioId = AP_FlujoAprobacionEstatusUsuarios.UsuarioId
        GROUP BY AP_Usuario.UsuarioID,
                 AP_Usuario.Usuario,
                 AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId,
                 OT_Solicitud.IdOTSolicitud
        /*OT's pendientes de aprobar*/
        INSERT INTO #tmpTareasPendientesDeAprobar
        (
            IdOTTarea,
            Folio,
            IdOTSolicitud,
            FechaRegistro,
            Tarea,
            Estatus,
            Url,
            UrlText,
            FechaCompletada,
            Completada,
            UsuarioAsignado,
            CentroCosto,
            IdOTEstatus,
            tmpAceptacionesSinRecIdOTSolicitud,
            tmpAceptacionesSinRecidAceptacionPedido,
            tmpAceptacionesPendIdOTSolicitud,
            tmpEstimacionPendIdOTSolicitud,
            tmpEstimacionPendSemanaID,
            tmpCerrarSemanasFecha,
            tmpAceptacionesPendIdPedido,
            tmpAceptacionesPendIdPedidoGen
        )
        SELECT 1,
               OT_Solicitud.Folio,
               OT_Solicitud.IdOTSolicitud,
               OT_Solicitud.CreadoEl,
               /*********ESTATUS TAREA***************/
               CASE
                   WHEN OT_Solicitud.IdOTEstatus = 1 THEN
                       CASE
                           WHEN OT_Solicitud.ProgIniPorProveedor = 0 THEN
                               'Operadora - Pendiente de Enviar a Manager'
                           WHEN OT_Solicitud.ProgIniPorProveedor = 1 THEN
                               'Operadora - Pendiente de Enviar a Proveedor'
                       END
                   WHEN OT_Solicitud.IdOTEstatus IN ( 2, 4 ) THEN
                       'Proveedor - Revisión de OT'
                   WHEN OT_Solicitud.IdOTEstatus IN ( 9 ) THEN
                       'Operadora - Revisar convenio en Procura'
                   WHEN OT_Solicitud.IdOTEstatus IN ( 3, 11 ) THEN
                       'Operadora - Aprobar OT por Manager'
               END,
               'Pendiente',
               /************URL ACCIÓN**********/
               CASE
                   WHEN OT_Solicitud.IdOTEstatus = 1 THEN
                       @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                       + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
                   WHEN OT_Solicitud.IdOTEstatus IN ( 2, 4 ) THEN
                       @dominioPetrovendor + '/02Proveedores/RegistrarOTSolicitudpetrovendor..S_Proveedor.aspx?id='
                       + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
                   WHEN OT_Solicitud.IdOTEstatus IN ( 9 ) THEN
                       @dominioProcura + '/02Proveedores/ActualizarSCOTConvenio.aspx?id='
                       + CAST(OT_Solicitud.IdSubcontrato AS VARCHAR) + '&id2='
                       + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
                   WHEN OT_Solicitud.IdOTEstatus IN ( 3, 11 ) THEN
                       @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                       + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
               END,
               /**********Url Text*************/
               CASE
                   WHEN OT_Solicitud.IdOTEstatus = 1 THEN
                       CASE
                           WHEN @pUsuarioAdincoId > 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
                   WHEN OT_Solicitud.IdOTEstatus IN ( 2, 4 ) THEN
                       CASE
                           WHEN ISNULL(@pUsuarioAdincoId, 0) = 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
                   WHEN OT_Solicitud.IdOTEstatus IN ( 9 ) THEN
                       CASE
                           WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
                   WHEN OT_Solicitud.IdOTEstatus IN ( 3, 11 ) THEN
                       CASE
                           WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
               END,
               GETDATE(),
               0,
               /*************USUARIO ASIGNADO***************/
               CASE
                   WHEN OT_Solicitud.IdOTEstatus IN ( 2, 4 ) THEN
                       PV_Subcontratista.RazonSocial
                   WHEN OT_Solicitud.IdOTEstatus IN ( 5, 6 ) THEN
                       PV_Subcontratista.RazonSocial
               END,
               petrovendor..CC_CentroCosto.CentroCosto,
               OT_Solicitud.IdOTEstatus,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL
        FROM OT_Solicitud (NOLOCK)
            INNER JOIN petrovendor..CC_CentroCosto (NOLOCK)
                ON OT_Solicitud.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto
            INNER JOIN #tmpOTEstatusPermitidos
                ON OT_Solicitud.IdOTEstatus = #tmpOTEstatusPermitidos.IdOTEstatus
            INNER JOIN AP_Usuario (NOLOCK)
                ON OT_Solicitud.CreadoPor = AP_Usuario.UsuarioId
                   AND OT_Solicitud.IsActivo = 1
                   AND @pPend_Comp = 1
            INNER JOIN OT_SolicitudMaterial (NOLOCK)
                ON OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
            INNER JOIN AP_UsuarioCentroCosto
                ON (
                       @pUsuarioAdincoId IN ( AP_UsuarioCentroCosto.IdUsuario, 9999999 )
                       OR @pUsuarioPetroId > 0
                   )
                   AND AP_UsuarioCentroCosto.IdCentroCosto IN ( OT_Solicitud.IdCentroCosto )
            INNER JOIN SC_SubContrato (NOLOCK)
                ON OT_Solicitud.IdSubcontrato = SC_SubContrato.IdSubcontrato
            INNER JOIN PV_Subcontratista (NOLOCK)
                ON SC_SubContrato.IdSubcontratista = PV_Subcontratista.IdSubcontratista
            INNER JOIN petrovendor..S_Proveedor (NOLOCK)
                ON PV_Subcontratista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = petrovendor..S_Proveedor.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                   AND @pIdProveedor IN ( 0, petrovendor..S_Proveedor.IdProveedor )
        WHERE @pIdContrato IN ( SC_SubContrato.IdContrato, 0 )
        GROUP BY OT_Solicitud.Folio,
                 OT_Solicitud.IdOTSolicitud,
                 OT_Solicitud.IdOTEstatus,
                 OT_Solicitud.ProgIniPorProveedor,
                 AP_Usuario.Usuario,
                 PV_Subcontratista.RazonSocial,
                 OT_Solicitud.IdSubcontrato,
                 OT_Solicitud.CreadoEl,
                 petrovendor..CC_CentroCosto.CentroCosto

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.tmpAceptacionesSinRecIdOTSolicitud = #tmpAceptacionesSinRec.IdOTSolicitud,
            #tmpTareasPendientesDeAprobar.tmpAceptacionesSinRecidAceptacionPedido = #tmpAceptacionesSinRec.idAceptacionPedido
        FROM #tmpTareasPendientesDeAprobar
            INNER JOIN #tmpAceptacionesSinRec
                ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpAceptacionesSinRec.IdOTSolicitud

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.tmpAceptacionesPendIdOTSolicitud = #tmpAceptacionesPend.IdOTSolicitud,
            #tmpTareasPendientesDeAprobar.tmpAceptacionesPendIdPedido = #tmpAceptacionesPend.IdPedido,
            #tmpTareasPendientesDeAprobar.tmpAceptacionesPendIdPedidoGen = #tmpAceptacionesPend.IdPedidoGen
        FROM #tmpTareasPendientesDeAprobar
            INNER JOIN #tmpAceptacionesPend
                ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpAceptacionesPend.IdOTSolicitud

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.tmpEstimacionPendIdOTSolicitud = #tmpEstimacionPend.IdOTSolicitud,
            #tmpTareasPendientesDeAprobar.tmpEstimacionPendSemanaID = #tmpEstimacionPend.SemanaID
        FROM #tmpTareasPendientesDeAprobar
            INNER JOIN #tmpEstimacionPend
                ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpEstimacionPend.IdOTSolicitud

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.tmpCerrarSemanasFecha = #tmpCerrarSemanas.Fecha
        FROM #tmpTareasPendientesDeAprobar
            INNER JOIN OT_SolicitudMaterial (NOLOCK)
                ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
            INNER JOIN #tmpCerrarSemanas
                ON OT_SolicitudMaterial.IdOTSolicitudMaterial = #tmpCerrarSemanas.IdOTSolicitudMaterial

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus1 = ISNULL(
                                                                                 STUFF(
                                                                                 (
                                                                                     SELECT '; '
                                                                                            + ISNULL(
                                                                                                        AP_Usuario.Usuario,
                                                                                                        ''
                                                                                                    )
                                                                                     FROM OT_Solicitud OT_Solicitud_STUFF
                                                                                         INNER JOIN AP_FlujoAprobacion
                                                                                             ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                         INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 1
                                                                                         INNER JOIN AP_Usuario
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                AND AP_Usuario.Usuario IS NOT NULL
                                                                                                AND AP_Usuario.IsActivo = 1
                                                                                         INNER JOIN AP_UsuarioCentroCosto
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                     WHERE #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                     GROUP BY AP_Usuario.Usuario
                                                                                     FOR XML PATH('')
                                                                                 ),
                                                                                 1,
                                                                                 2,
                                                                                 ''
                                                                                      ),
                                                                                 ''
                                                                             )
        FROM #tmpTareasPendientesDeAprobar

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus2 = ISNULL(
                                                                                 STUFF(
                                                                                 (
                                                                                     SELECT '; '
                                                                                            + ISNULL(
                                                                                                        AP_Usuario.Usuario,
                                                                                                        ''
                                                                                                    )
                                                                                     FROM OT_Solicitud OT_Solicitud_STUFF
                                                                                         INNER JOIN AP_FlujoAprobacion
                                                                                             ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                         INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 2
                                                                                         INNER JOIN AP_Usuario
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                AND AP_Usuario.Usuario IS NOT NULL
                                                                                                AND AP_Usuario.IsActivo = 1
                                                                                         INNER JOIN AP_UsuarioCentroCosto
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                     WHERE #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                     GROUP BY AP_Usuario.Usuario
                                                                                     FOR XML PATH('')
                                                                                 ),
                                                                                 1,
                                                                                 2,
                                                                                 ''
                                                                                      ),
                                                                                 ''
                                                                             )
        FROM #tmpTareasPendientesDeAprobar

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus3 = ISNULL(
                                                                                 STUFF(
                                                                                 (
                                                                                     SELECT '; '
                                                                                            + ISNULL(
                                                                                                        AP_Usuario.Usuario,
                                                                                                        ''
                                                                                                    )
                                                                                     FROM OT_Solicitud OT_Solicitud_STUFF
                                                                                         INNER JOIN AP_FlujoAprobacion
                                                                                             ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                         INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 3
                                                                                         INNER JOIN AP_Usuario
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                AND AP_Usuario.Usuario IS NOT NULL
                                                                                                AND AP_Usuario.IsActivo = 1
                                                                                         INNER JOIN AP_UsuarioCentroCosto
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                     WHERE #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                     GROUP BY AP_Usuario.Usuario
                                                                                     FOR XML PATH('')
                                                                                 ),
                                                                                 1,
                                                                                 2,
                                                                                 ''
                                                                                      ),
                                                                                 ''
                                                                             )
        FROM #tmpTareasPendientesDeAprobar

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus4 = ISNULL(
                                                                                 STUFF(
                                                                                 (
                                                                                     SELECT '; '
                                                                                            + ISNULL(
                                                                                                        AP_Usuario.Usuario,
                                                                                                        ''
                                                                                                    )
                                                                                     FROM OT_Solicitud OT_Solicitud_STUFF
                                                                                         INNER JOIN AP_FlujoAprobacion
                                                                                             ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                         INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 4
                                                                                         INNER JOIN AP_Usuario
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                AND AP_Usuario.Usuario IS NOT NULL
                                                                                                AND AP_Usuario.IsActivo = 1
                                                                                         INNER JOIN AP_UsuarioCentroCosto
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                     WHERE #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                     GROUP BY AP_Usuario.Usuario
                                                                                     FOR XML PATH('')
                                                                                 ),
                                                                                 1,
                                                                                 2,
                                                                                 ''
                                                                                      ),
                                                                                 ''
                                                                             )
        FROM #tmpTareasPendientesDeAprobar

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus5 = ISNULL(
                                                                                 STUFF(
                                                                                 (
                                                                                     SELECT '; '
                                                                                            + ISNULL(
                                                                                                        AP_Usuario.Usuario,
                                                                                                        ''
                                                                                                    )
                                                                                     FROM OT_Solicitud OT_Solicitud_STUFF
                                                                                         INNER JOIN AP_FlujoAprobacion
                                                                                             ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                         INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 5
                                                                                         INNER JOIN AP_Usuario
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                AND AP_Usuario.Usuario IS NOT NULL
                                                                                                AND AP_Usuario.IsActivo = 1
                                                                                         INNER JOIN AP_UsuarioCentroCosto
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                     WHERE #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                     GROUP BY AP_Usuario.Usuario
                                                                                     FOR XML PATH('')
                                                                                 ),
                                                                                 1,
                                                                                 2,
                                                                                 ''
                                                                                      ),
                                                                                 ''
                                                                             )
        FROM #tmpTareasPendientesDeAprobar

        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus6 = ISNULL(
                                                                                 STUFF(
                                                                                 (
                                                                                     SELECT '; '
                                                                                            + ISNULL(
                                                                                                        AP_Usuario.Usuario,
                                                                                                        ''
                                                                                                    )
                                                                                     FROM OT_Solicitud OT_Solicitud_STUFF
                                                                                         INNER JOIN AP_FlujoAprobacion
                                                                                             ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                         INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 6
                                                                                         INNER JOIN AP_Usuario
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                AND AP_Usuario.Usuario IS NOT NULL
                                                                                                AND AP_Usuario.IsActivo = 1
                                                                                         INNER JOIN AP_UsuarioCentroCosto
                                                                                             ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                     WHERE #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                     GROUP BY AP_Usuario.Usuario
                                                                                     FOR XML PATH('')
                                                                                 ),
                                                                                 1,
                                                                                 2,
                                                                                 ''
                                                                                      ),
                                                                                 ''
                                                                             )
        FROM #tmpTareasPendientesDeAprobar
        /*Tarea*/
        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.Tarea = (CASE
                                                       WHEN tmpAceptacionesSinRecIdOTSolicitud IS NOT NULL THEN
                                                           'Operadora - Reclasificar Aceptación '
                                                           + CAST(tmpAceptacionesSinRecidAceptacionPedido AS VARCHAR)
                                                           + ' en Procura '
                                                       WHEN tmpAceptacionesPendIdOTSolicitud IS NOT NULL THEN
                                                           'Operadora - Generar Aceptación en Procura '
                                                       WHEN tmpEstimacionPendIdOTSolicitud IS NOT NULL THEN
                                                           'Operadora - Generar Estimación para semana '
                                                           + tmpEstimacionPendSemanaID
                                                       WHEN tmpCerrarSemanasFecha IS NULL
                                                            AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                            AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                           'Proveedor - Capturar Avance '
                                                       WHEN tmpCerrarSemanasFecha IS NOT NULL
                                                            AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                            AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                           'Operadora - Revisar y cerrar semana para fecha:'
                                                           + CONVERT(VARCHAR, tmpCerrarSemanasFecha, 103)
                                                   END
                                                  )
        FROM #tmpTareasPendientesDeAprobar
        WHERE #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 5, 6 )
        /*URL*/
        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.Url = (CASE
                                                     WHEN tmpAceptacionesSinRecIdOTSolicitud IS NOT NULL THEN
                                                         @dominioProcura + '/01Proveedores/APListaReclasificacion.aspx'
                                                     WHEN tmpAceptacionesPendIdOTSolicitud IS NOT NULL THEN
                                                         @dominioProcura + '/02Proveedores/AceptacionPedido.aspx?ped='
                                                         + CAST(tmpAceptacionesPendIdPedido AS VARCHAR) + '&pedgral='
                                                         + CAST(tmpAceptacionesPendIdPedidoGen AS VARCHAR)
                                                         + '&ori=pedido'
                                                     WHEN tmpEstimacionPendIdOTSolicitud IS NOT NULL THEN
                                                         @dominioAdinco
                                                         + '/2/OrdenTrabajo/GenerarEstimacionOT_Solicitud.aspx?id1='
                                                         + CAST(#tmpTareasPendientesDeAprobar.IdOTSolicitud AS VARCHAR)
                                                     WHEN tmpCerrarSemanasFecha IS NULL
                                                          AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                          AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                         @dominioPetrovendor
                                                         + '/02Proveedores/CapturaProgramaOT_Solicitud.aspx?id='
                                                         + CAST(#tmpTareasPendientesDeAprobar.IdOTSolicitud AS VARCHAR)
                                                     WHEN tmpCerrarSemanasFecha IS NOT NULL
                                                          AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                          AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                         @dominioAdinco
                                                         + '/2/OrdenTrabajo/CapturaProgramaOT_Solicitud.aspx?id='
                                                         + CAST(#tmpTareasPendientesDeAprobar.IdOTSolicitud AS VARCHAR)
                                                 END
                                                )
        FROM #tmpTareasPendientesDeAprobar
        WHERE #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 5, 6 )

        /*URL Text*/
        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.UrlText = (CASE
                                                         WHEN tmpAceptacionesSinRecIdOTSolicitud IS NOT NULL THEN
                                                             CASE
                                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                                                     'Completar'
                                                                 ELSE
                                                                     ''
                                                             END
                                                         WHEN tmpAceptacionesPendIdOTSolicitud IS NOT NULL THEN
                                                             CASE
                                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                                                     'Completar'
                                                                 ELSE
                                                                     ''
                                                             END
                                                         WHEN tmpEstimacionPendIdOTSolicitud IS NOT NULL THEN
                                                             CASE
                                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                                                     'Completar'
                                                                 ELSE
                                                                     ''
                                                             END
                                                         WHEN tmpCerrarSemanasFecha IS NULL
                                                              AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                              AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                             CASE
                                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) = 0 THEN
                                                                     'Completar'
                                                                 ELSE
                                                                     ''
                                                             END
                                                         WHEN tmpCerrarSemanasFecha IS NOT NULL
                                                              AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                              AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                             CASE
                                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                                                     'Completar'
                                                                 ELSE
                                                                     ''
                                                             END
                                                     END
                                                    )
        FROM #tmpTareasPendientesDeAprobar
        WHERE #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 5, 6 )

        /*USUARIO ASIGNADO*/
        UPDATE #tmpTareasPendientesDeAprobar
        SET #tmpTareasPendientesDeAprobar.UsuarioAsignado = (CASE
                                                                 WHEN #tmpTareasPendientesDeAprobar.IdOTEstatus = 1 THEN
                                                                     ISNULL(
                                                                               #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus1,
                                                                               ''
                                                                           )
                                                                 WHEN #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 2,
                                                                                                                     4
                                                                                                                   ) THEN
                                                                     #tmpTareasPendientesDeAprobar.UsuarioAsignado
                                                                 WHEN #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 5,
                                                                                                                     6
                                                                                                                   ) THEN
                                                                     CASE
                                                                         WHEN tmpAceptacionesSinRecIdOTSolicitud IS NOT NULL THEN
                                                                             ISNULL(
                                                                                       #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus5,
                                                                                       ''
                                                                                   )
                                                                         WHEN tmpAceptacionesPendIdOTSolicitud IS NOT NULL THEN
                                                                             ISNULL(
                                                                                       #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus5,
                                                                                       ''
                                                                                   )
                                                                         WHEN tmpEstimacionPendIdOTSolicitud IS NOT NULL THEN
                                                                             ISNULL(
                                                                                       #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus4,
                                                                                       ''
                                                                                   )
                                                                         WHEN tmpCerrarSemanasFecha IS NULL
                                                                              AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                                              AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                                             #tmpTareasPendientesDeAprobar.UsuarioAsignado
                                                                         WHEN tmpCerrarSemanasFecha IS NOT NULL
                                                                              AND tmpEstimacionPendIdOTSolicitud IS NULL
                                                                              AND tmpAceptacionesPendIdOTSolicitud IS NULL THEN
                                                                             ISNULL(
                                                                                       #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus3,
                                                                                       ''
                                                                                   )
                                                                     END
                                                                 WHEN #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 9 ) THEN
                                                                     ISNULL(
                                                                               #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus6,
                                                                               ''
                                                                           )
                                                                 WHEN #tmpTareasPendientesDeAprobar.IdOTEstatus IN ( 3,
                                                                                                                     11
                                                                                                                   ) THEN
                                                                     ISNULL(
                                                                               #tmpTareasPendientesDeAprobar.OT_GetMailUsuariosEstatus2,
                                                                               ''
                                                                           )
                                                             END
                                                            )
        FROM #tmpTareasPendientesDeAprobar

        INSERT INTO #tmpTareas
        (
            IdOTTarea,
            Folio,
            IdOTSolicitud,
            FechaRegistro,
            Tarea,
            Estatus,
            Url,
            UrlText,
            FechaCompletada,
            Completada,
            UsuarioAsignado,
            CentroCosto
        )
        SELECT IdOTTarea,
               Folio,
               IdOTSolicitud,
               FechaRegistro,
               Tarea,
               Estatus,
               Url,
               UrlText,
               FechaCompletada,
               Completada,
               UsuarioAsignado,
               CentroCosto
        FROM #tmpTareasPendientesDeAprobar

        /*ISSUE 1018 OT's sin relación Pedido - PO. Se agrega tarea para Relacionar Pedido-PO*/
        INSERT INTO #tmpTareasSinRelacionPedido
        (
            IdOTTarea,
            Folio,
            IdOTSolicitud,
            FechaRegistro,
            Tarea,
            Estatus,
            Url,
            UrlText,
            FechaCompletada,
            Completada,
            UsuarioAsignado,
            CentroCosto
        )
        SELECT 1,
               OT_Solicitud.Folio,
               OT_Solicitud.IdOTSolicitud,
               #tmpEstimacionSinPO.CreadoEl,
               'Operadora - Relacionar Pedido:' + CAST(#tmpEstimacionSinPO.IdPedidoGeneral AS VARCHAR)
               + ' con PO en Procura',
               'Pendiente',
               @dominioProcura + '/DEA/Relacion_PR_PO.aspx',
               'Completar',
               NULL,
               0,
               '',
               petrovendor..CC_CentroCosto.CentroCosto
        FROM #tmpEstimacionSinPO
            INNER JOIN OT_Solicitud
                ON #tmpEstimacionSinPO.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
            INNER JOIN petrovendor..CC_CentroCosto
                ON OT_Solicitud.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto

        UPDATE #tmpTareasSinRelacionPedido
        SET #tmpTareasSinRelacionPedido.UsuarioAsignado = ISNULL(
                                                                    STUFF(
                                                                    (
                                                                        SELECT '; ' + ISNULL(AP_Usuario.Usuario, '')
                                                                        FROM OT_Solicitud OT_Solicitud_STUFF
                                                                            INNER JOIN AP_FlujoAprobacion
                                                                                ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                            INNER JOIN AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios
                                                                                ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 6
                                                                            INNER JOIN AP_Usuario
                                                                                ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                   AND AP_Usuario.Usuario IS NOT NULL
                                                                                   AND AP_Usuario.IsActivo = 1
                                                                            INNER JOIN AP_UsuarioCentroCosto
                                                                                ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                   AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                        WHERE #tmpTareasSinRelacionPedido.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                        GROUP BY AP_Usuario.Usuario
                                                                        FOR XML PATH('')
                                                                    ),
                                                                    1,
                                                                    2,
                                                                    ''
                                                                         ),
                                                                    ''
                                                                )
        FROM #tmpTareasSinRelacionPedido

        INSERT INTO #tmpTareas
        (
            IdOTTarea,
            Folio,
            IdOTSolicitud,
            FechaRegistro,
            Tarea,
            Estatus,
            Url,
            UrlText,
            FechaCompletada,
            Completada,
            UsuarioAsignado,
            CentroCosto
        )
        SELECT IdOTTarea,
               Folio,
               IdOTSolicitud,
               FechaRegistro,
               Tarea,
               Estatus,
               Url,
               UrlText,
               FechaCompletada,
               Completada,
               UsuarioAsignado,
               CentroCosto
        FROM #tmpTareasSinRelacionPedido

        IF @pUsuarioAdincoId > 0
        BEGIN
            SELECT @emailusuario = ISNULL(Usuario, '')
            FROM ap_usuario
            WHERE usuarioid = @pUsuarioAdincoId
            UPDATE #tmpTareas
            SET UrlText = ''
            WHERE UsuarioAsignado NOT LIKE '%' + ISNULL(@emailusuario, '') + '%'
        END
    END
    /*OT's tareas completadas*/
    INSERT INTO #tmpTareasCompletadas
    (
        IdOTTarea,
        Folio,
        IdOTSolicitud,
        FechaRegistro,
        Tarea,
        Estatus,
        Url,
        UrlText,
        FechaCompletada,
        Completada,
        UsuarioAsignado,
        CentroCosto,
        UsuarioAdincoId,
        FlujoAprobacionTareaId
    )
    SELECT OT_SolicitudBitacora.IdOTBitacora,
           OT_Solicitud.Folio,
           OT_Solicitud.IdOTSolicitud,
           OT_Solicitud.CreadoEl,
           CASE
               WHEN ISNULL(OT_SolicitudBitacora.Descripcion, '') = '' THEN
                   ''
               ELSE
                   ISNULL(OT_SolicitudBitacora.Descripcion, '')
           END,
           'Completada',
           '',
           '',
           OT_SolicitudBitacora.CreadoEl,
           1,
           CASE
               WHEN ISNULL(OT_SolicitudBitacora.UsuarioAdincoId, 0) > 0 THEN
                   ''
               ELSE
                   PV_Subcontratista.RazonSocial
           END,
           petrovendor..CC_CentroCosto.CentroCosto,
           ISNULL(OT_SolicitudBitacora.UsuarioAdincoId, 0),
           ISNULL(OT_SolicitudBitacora.FlujoAprobacionTareaId, 0)
    FROM OT_Solicitud (NOLOCK)
        INNER JOIN petrovendor..CC_CentroCosto (NOLOCK)
            ON OT_Solicitud.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto
        INNER JOIN OT_SolicitudMaterial (NOLOCK)
            ON OT_Solicitud.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
               AND @pPend_Comp = 2
        INNER JOIN AP_UsuarioCentroCosto (NOLOCK)
            ON (@pUsuarioAdincoId IN ( AP_UsuarioCentroCosto.IdUsuario, 0 ))
               AND AP_UsuarioCentroCosto.IdCentroCosto IN ( OT_Solicitud.IdCentroCosto, 0 )
        INNER JOIN SC_SubContrato (NOLOCK)
            ON OT_Solicitud.IdSubcontrato = SC_SubContrato.IdSubcontrato
        INNER JOIN PV_Subcontratista (NOLOCK)
            ON SC_SubContrato.IdSubcontratista = PV_Subcontratista.IdSubcontratista
        INNER JOIN petrovendor..S_Proveedor (NOLOCK)
            ON PV_Subcontratista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = petrovendor..S_Proveedor.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
               AND @pIdProveedor IN ( 0, petrovendor..S_Proveedor.IdProveedor )
        INNER JOIN OT_SolicitudBitacora (NOLOCK)
            ON OT_Solicitud.IdOTSolicitud = OT_SolicitudBitacora.IdOTSolicitud
               AND OT_SolicitudBitacora.CreadoEl >= DATEADD(DAY, -15, GETDATE())
    WHERE @pIdContrato IN ( SC_SubContrato.IdContrato, 0 )
          AND OT_Solicitud.IsActivo = 1
    GROUP BY OT_SolicitudBitacora.UsuarioAdincoId,
             PV_Subcontratista.RazonSocial,
             OT_Solicitud.Folio,
             OT_Solicitud.IdOTSolicitud,
             OT_Solicitud.CreadoEl,
             OT_SolicitudBitacora.Descripcion,
             OT_SolicitudBitacora.CreadoEl,
             OT_SolicitudBitacora.IdOTBitacora,
             petrovendor..CC_CentroCosto.CentroCosto,
             ISNULL(OT_SolicitudBitacora.UsuarioAdincoId, 0),
             ISNULL(OT_SolicitudBitacora.FlujoAprobacionTareaId, 0)
    ORDER BY OT_SolicitudBitacora.CreadoEl DESC
    /*Se sacaron los left joins*/
    UPDATE #tmpTareasCompletadas
    SET #tmpTareasCompletadas.UsuarioAsignado = AP_Usuario.Usuario
    FROM #tmpTareasCompletadas
        INNER JOIN AP_Usuario (NOLOCK)
            ON ISNULL(#tmpTareasCompletadas.UsuarioAdincoId, 0) > 0
               AND #tmpTareasCompletadas.UsuarioAdincoId = AP_Usuario.UsuarioId

    UPDATE #tmpTareasCompletadas
    SET #tmpTareasCompletadas.Tarea = AP_FlujoAprobacion_Tareas.Descripcion
    FROM #tmpTareasCompletadas
        INNER JOIN AP_FlujoAprobacion_Tareas (NOLOCK)
            ON ISNULL(#tmpTareasCompletadas.FlujoAprobacionTareaId, 0) > 0
               AND #tmpTareasCompletadas.Tarea = ''
               AND #tmpTareasCompletadas.FlujoAprobacionTareaId = AP_FlujoAprobacion_Tareas.FlujoAprobacionTareaId
    /*Inserción directa a la tabla temporal final #tmpTareas*/
    INSERT INTO #tmpTareas
    (
        IdOTTarea,
        Folio,
        IdOTSolicitud,
        FechaRegistro,
        Tarea,
        Estatus,
        Url,
        UrlText,
        FechaCompletada,
        Completada,
        UsuarioAsignado,
        CentroCosto
    )
    SELECT IdOTTarea,
           Folio,
           IdOTSolicitud,
           FechaRegistro,
           Tarea,
           Estatus,
           Url,
           UrlText,
           FechaCompletada,
           Completada,
           UsuarioAsignado,
           CentroCosto
    FROM #tmpTareasCompletadas
    --UPDATE #tmpTareas
    --SET UsuarioAsignado = replace(replace(replace(UsuarioAsignado,'daniel.moreno@adinco.mx',''),'juventino.sanchez@wINTershalldea.com',''),'yazmin.gonzalez@ogss.com.mx','')
    SELECT *
    FROM #tmpTareas
    ORDER BY UrlText DESC,
             FechaRegistro DESC,
             FechaCompletada DESC,
             Folio
END