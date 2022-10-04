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
        CreadoEl DATETIME
    );
    CREATE TABLE #tmpOTUsuarios
    (
        UsuarioID INT,
        Usuario VARCHAR(500),
        FlujoAprobacionEstatusId INT,
        IdOTSolicitud INT
    );
    /*Obtencion Valores*/
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
        SELECT ot.IdOTSolicitud,
               otm.IdOTSolicitudMaterial,
               spc.Fecha,
               spc.IdOTSolicitudProgramaCaptura
        FROM OT_Solicitud OT (NOLOCK)
            INNER JOIN OT_SolicitudMaterial otm (NOLOCK)
                ON otm.IdOTSolicitud = ot.IdOTSolicitud
                   AND ot.IsActivo = 1
            INNER JOIN SC_Subcontrato sc (NOLOCK)
                ON sc.IdSubcontrato = ot.IdSubcontrato
                   AND SC.IDContrato = @pIdContrato
            INNER JOIN [OT_SolicitudProgramaCaptura] spc (NOLOCK)
                ON spc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
                   AND spc.VoBoSubcontratista = 1
        WHERE ot.IsActivo = 1
              AND SC.IDContrato = @pIdContrato
        GROUP BY ot.IdOTSolicitud,
                 otm.IdOTSolicitudMaterial,
                 spc.Fecha,
                 spc.IdOTSolicitudProgramaCaptura
        /*Se saca subquery que manejaba not exists*/
        DELETE #tmpCerrarSemanas
        FROM #tmpCerrarSemanas
            INNER JOIN OT_ProgramaSemanaCerrada e
                ON e.IdOTSolicitud = #tmpCerrarSemanas.IdOTSolicitud
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
        SELECT ot.IdOTSolicitud,
               otm.IdOTSolicitudMaterial,
               spc.Fecha,
               e.SemanaID
        FROM OT_Solicitud OT (NOLOCK)
            INNER JOIN OT_SolicitudMaterial otm (NOLOCK)
                ON otm.IdOTSolicitud = ot.IdOTSolicitud
                   AND ot.IsActivo = 1
            INNER JOIN SC_Subcontrato sc (NOLOCK)
                ON sc.IdSubcontrato = ot.IdSubcontrato
            INNER JOIN [OT_SolicitudProgramaCaptura] spc (NOLOCK)
                ON spc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
                   AND spc.VoBoSubcontratista = 1
                   AND SPC.VoBoContratista = 1
            INNER JOIN OT_ProgramaSemanaCerrada e (NOLOCK)
                ON e.IdOTSolicitud = ot.IdOTSolicitud
                   AND spc.Fecha
                   BETWEEN e.FechaSemanaIni AND e.FechaSemanaFin
                   AND e.isActivo = 1
        WHERE ot.IsActivo = 1
              AND SC.IDContrato = @pIdContrato
        GROUP BY ot.IdOTSolicitud,
                 otm.IdOTSolicitudMaterial,
                 spc.Fecha,
                 e.SemanaID
        /*Se saca subquery que manejaba not exists*/
        DELETE #tmpEstimacionPend
        FROM #tmpEstimacionPend
            INNER JOIN OT_Estimacion e
                ON e.IdOTSolicitud = #tmpEstimacionPend.IdOTSolicitud
                   AND #tmpEstimacionPend.Fecha
                   BETWEEN e.FechaCorteInicio AND e.FechaCorteFin
                   AND ISNULL(e.Cancelada, 0) = 0
        /*Estimaciones sin aceptacion*/
        INSERT INTO #tmpAceptacionesPend
        (
            IdOTEstimacion,
            IdOTSolicitud,
            IdPedido,
            IdPedidoGen
        )
        SELECT e.IdOTEstimacion,
               e.IdOTSolicitud,
               idPedido = e.IdPedido,
               idPedidoGen = e.IdPedidoGeneral
        FROM OT_Estimacion e (NOLOCK)
            INNER JOIN OT_Solicitud ot (NOLOCK)
                ON ot.IdOTSolicitud = e.IdOTSolicitud
            INNER JOIN SC_Subcontrato sc (NOLOCK)
                ON sc.IdSubcontrato = ot.IdSubcontrato
        WHERE sc.IdContrato = @pIdContrato
              AND ISNULL(e.cancelada, 0) = 0
        GROUP BY e.IdOTEstimacion,
                 e.IdPedido,
                 e.IdPedidoGeneral,
                 e.IdOTSolicitud
        /*Se saca subquery que manejaba not exists*/
        DELETE #tmpAceptacionesPend
        FROM #tmpAceptacionesPend
            INNER JOIN Petrovendor..MM_AceptacionPedido p
                ON p.IdPedido = #tmpAceptacionesPend.IdPedido
        /*Aceptaciones sin reclasificacion*/
        INSERT INTO #tmpAceptacionesSinRec
        (
            IdOTEstimacion,
            IdOTSolicitud,
            IdPedido,
            idPedidoGen,
            IdAceptacionPedido
        )
        SELECT e.IdOTEstimacion,
               e.IdOTSolicitud,
               idPedido = e.IdPedido,
               idPedidoGen = e.IdPedidoGeneral,
               ap.idAceptacionPedido
        FROM OT_Estimacion e (NOLOCK)
            INNER JOIN OT_Solicitud ot (NOLOCK)
                ON ot.IdOTSolicitud = e.IdOTSolicitud
            INNER JOIN SC_Subcontrato sc (NOLOCK)
                ON sc.IdSubcontrato = ot.IdSubcontrato
                   AND sc.IdContrato = @pIdContrato
            INNER JOIN petrovendor..MM_AceptacionPedido ap (NOLOCK)
                ON ap.IdPedido = e.IdPedido
                   AND ap.ModificadoPor IS NULL
        WHERE sc.IdContrato = @pIdContrato
              AND ISNULL(e.Cancelada, 0) = 0
        GROUP BY e.IdOTEstimacion,
                 e.IdPedido,
                 e.IdPedidoGeneral,
                 e.IdOTSolicitud,
                 ap.idAceptacionPedido
        /*Se saca subquery que manejaba not exists*/
        DELETE #tmpAceptacionesSinRec
        FROM #tmpAceptacionesSinRec
            INNER JOIN petrovendor..[MM_AceptacionPedidoDetalleEliminada] sae
                ON sae.IdAceptacionPedido = #tmpAceptacionesSinRec.idAceptacionPedido

        DELETE #tmpAceptacionesSinRec
        FROM #tmpAceptacionesSinRec
            INNER JOIN petrovendor..MM_AceptacionFactura saf
                ON saf.IdAceptacionPedido = #tmpAceptacionesSinRec.idAceptacionPedido
        /*ISSUE 1018. Generar info de Estimaciones sin PO*/
        INSERT INTO #tmpEstimacionSinPO
        (
            IdOTSolicitud,
            IdOTEstimacion,
            IdPedidoGeneral,
            CreadoEl
        )
        SELECT e.IdOTSolicitud,
               e.IdOTEstimacion,
               e.IdPedidoGeneral,
               e.CreadoEl
        FROM OT_Estimacion e (NOLOCK)
            INNER JOIN OT_Solicitud ot (NOLOCK)
                ON ot.IdOTSolicitud = E.IdOTSolicitud
                   AND ISNULL(e.Cancelada, 0) = 0
            INNER JOIN SC_SubContrato sc (NOLOCK)
                ON sc.IdSubContrato = ot.IdSubContrato
                   AND sc.IdContrato = @pIdContrato
            LEFT JOIN petrovendor..DEA_Relacion_PR_PO po (NOLOCK)
                ON po.IdPedido = e.IdPedido
        WHERE ISNULL(e.Cancelada, 0) = 0
              AND po.IdPedido IS NULL
        GROUP BY e.IdOTSolicitud,
                 e.IdOTEstimacion,
                 e.IdPedidoGeneral,
                 e.CreadoEl
        /*usuarios OT*/
        INSERT INTO #tmpOTUsuarios
        (
            UsuarioID,
            Usuario,
            FlujoAprobacionEstatusId,
            IdOTSolicitud
        )
        SELECT u.UsuarioID,
               u.Usuario,
               fu.FlujoAprobacionEstatusId,
               ot.IdOTSolicitud
        FROM OT_Solicitud ot (NOLOCK)
            INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK)
                ON ucc.IdCentroCosto = ot.IdCentroCosto
            INNER JOIN AP_Usuario u (NOLOCK)
                ON u.usuarioId = ucc.IdUsuario
            INNER JOIN [dbo].[AP_FlujoAprobacionEstatusUsuarios] fu (NOLOCK)
                ON fu.UsuarioId = u.usuarioId
        GROUP BY u.UsuarioID,
                 u.Usuario,
                 fu.FlujoAprobacionEstatusId,
                 ot.IdOTSolicitud
        /*OT's pendientes de aprobar*/
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
        SELECT 1,
               ot.Folio,
               ot.IdOTSolicitud,
               ot.CreadoEl,
               /*********ESTATUS TAREA***************/
               CASE
                   WHEN ot.IdOTEstatus = 1 THEN
                       CASE
                           WHEN ot.ProgIniPorProveedor = 0 THEN
                               'Operadora - Pendiente de Enviar a Manager'
                           WHEN ot.ProgIniPorProveedor = 1 THEN
                               'Operadora - Pendiente de Enviar a Proveedor'
                       END
                   WHEN ot.IdOTEstatus IN ( 2, 4 ) THEN
                       'Proveedor - Revisión de OT'
                   WHEN ot.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN aPendRec.IdOTSolicitud IS NOT NULL THEN
                               'Operadora - Reclasificar Aceptación ' + cast(aPendRec.idAceptacionPedido AS VARCHAR)
                               + ' en Procura '
                           WHEN aPend.IdOTSolicitud IS NOT NULL THEN
                               'Operadora - Generar Aceptación en Procura '
                           WHEN ePend.IdOTSolicitud IS NOT NULL THEN
                               'Operadora - Generar Estimación para semana ' + ePend.SemanaID
                           WHEN tmp2.Fecha IS NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               'Proveedor - Capturar Avance '
                           WHEN tmp2.Fecha IS NOT NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               'Operadora - Revisar y cerrar semana para fecha:' + convert(VARCHAR, tmp2.Fecha, 103)
                       END
                   WHEN ot.IdOTEstatus IN ( 9 ) THEN
                       'Operadora - Revisar convenio en Procura'
                   WHEN ot.IdOTEstatus IN ( 3, 11 ) THEN
                       'Operadora - Aprobar OT por Manager'
               END,
               'Pendiente',
               /************URL ACCIÓN**********/
               CASE
                   WHEN ot.IdOTEstatus = 1 THEN
                       @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                       + cast(ot.IdOTSolicitud AS VARCHAR)
                   WHEN ot.IdOTEstatus IN ( 2, 4 ) THEN
                       @dominioPetrovendor + '/02Proveedores/RegistrarOTSolicitudProv.aspx?id='
                       + cast(ot.IdOTSolicitud AS VARCHAR)
                   WHEN ot.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN aPendRec.IdOTSolicitud IS NOT NULL THEN
                               @dominioProcura + '/01Proveedores/APListaReclasificacion.aspx'
                           WHEN aPend.IdOTSolicitud IS NOT NULL THEN
                               @dominioProcura + '/02Proveedores/AceptacionPedido.aspx?ped='
                               + cast(aPend.IdPedido AS VARCHAR) + '&pedgral=' + cast(aPend.IdPedidoGen AS VARCHAR)
                               + '&ori=pedido'
                           WHEN ePend.IdOTSolicitud IS NOT NULL THEN
                               @dominioAdinco + '/2/OrdenTrabajo/GenerarEstimacionOT.aspx?id1='
                               + cast(ot.IdOTSolicitud AS VARCHAR)
                           WHEN tmp2.Fecha IS NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               @dominioPetrovendor + '/02Proveedores/CapturaProgramaOT.aspx?id='
                               + cast(ot.IdOTSolicitud AS VARCHAR)
                           WHEN tmp2.Fecha IS NOT NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               @dominioAdinco + '/2/OrdenTrabajo/CapturaProgramaOT.aspx?id='
                               + cast(ot.IdOTSolicitud AS VARCHAR)
                       END
                   WHEN ot.IdOTEstatus IN ( 9 ) THEN
                       @dominioProcura + '/02Proveedores/ActualizarSCOTConvenio.aspx?id='
                       + cast(ot.IdSubcontrato AS VARCHAR) + '&id2=' + cast(ot.IdOTSolicitud AS VARCHAR)
                   WHEN ot.IdOTEstatus IN ( 3, 11 ) THEN
                       @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                       + cast(ot.IdOTSolicitud AS VARCHAR)
               END,
               /**********Url Text*************/
               CASE
                   WHEN ot.IdOTEstatus = 1 THEN
                       CASE
                           WHEN @pUsuarioAdincoId > 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
                   WHEN ot.IdOTEstatus IN ( 2, 4 ) THEN
                       CASE
                           WHEN ISNULL(@pUsuarioAdincoId, 0) = 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
                   WHEN ot.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN aPendRec.IdOTSolicitud IS NOT NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN aPend.IdOTSolicitud IS NOT NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN ePend.IdOTSolicitud IS NOT NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN tmp2.Fecha IS NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) = 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN tmp2.Fecha IS NOT NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                       END
                   WHEN ot.IdOTEstatus IN ( 9 ) THEN
                       CASE
                           WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
                   WHEN ot.IdOTEstatus IN ( 3, 11 ) THEN
                       CASE
                           WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                               'Completar'
                           ELSE
                               ''
                       END
               END,
               getdate(),
               0,
               /*************USUARIO ASIGNADO***************/
               CASE
                   WHEN ot.IdOTEstatus = 1 THEN
                       [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 1, 0)
                   WHEN ot.IdOTEstatus IN ( 2, 4 ) THEN
                       pv.RazonSocial
                   WHEN ot.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN aPendRec.IdOTSolicitud IS NOT NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 5, 0)
                           WHEN aPend.IdOTSolicitud IS NOT NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 5, 0)
                           WHEN ePend.IdOTSolicitud IS NOT NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 4, 0)
                           WHEN tmp2.Fecha IS NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               pv.RazonSocial
                           WHEN tmp2.Fecha IS NOT NULL
                                AND ePend.IdOTSolicitud IS NULL
                                AND aPend.IdOTSolicitud IS NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 3, 0)
                       END
                   WHEN ot.IdOTEstatus IN ( 9 ) THEN
                       [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 6, 0)
                   WHEN ot.IdOTEstatus IN ( 3, 11 ) THEN
                       [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 2, 0)
               END,
               cc.CentroCosto
        FROM OT_Solicitud ot (NOLOCK)
            INNER JOIN petrovendor..CC_CentroCosto cc (NOLOCK)
                ON cc.IdCentroCosto = ot.IdCentroCosto
            INNER JOIN AP_Usuario uot (NOLOCK)
                ON uot.UsuarioId = ot.CreadoPor
                   AND ot.IsActivo = 1
                   AND @pPend_Comp = 1
                   AND (
                           (
                               ot.IdOTEstatus not IN ( 7, 8, 12 )
                               AND @pUsuarioAdincoId > 0
                           )
                           OR (
                                  ot.IdOTEstatus not IN ( 1, 7, 8, 12 )
                                  AND ISNULL(@pUsuarioAdincoId, 0) = 0
                              )
                           OR (
                                  ot.IdOTEstatus not IN ( 7, 8, 12 )
                                  AND @pUsuarioPetroId > 0
                              )
                       )
            INNER JOIN OT_SolicitudMaterial otm (NOLOCK)
                ON otm.IdOTSolicitud = ot.IdOTSolicitud
            INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc
                ON (
                       @pUsuarioAdincoId IN ( ucc.IdUsuario, 9999999 )
                       OR @pUsuarioPetroId > 0
                   )
                   AND ucc.IdCentroCosto IN ( ot.IdCentroCosto )
            INNER JOIN SC_Subcontrato sc (NOLOCK)
                ON sc.IdSubcontrato = ot.IdSubcontrato
            INNER JOIN PV_Subcontratista pv (NOLOCK)
                ON pv.IdSubcontratista = sc.IdSubcontratista
            INNER JOIN petrovendor..S_Proveedor prov (NOLOCK)
                ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = pv.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                   AND @pIdProveedor IN ( 0, prov.IdProveedor )
            LEFT JOIN #tmpOTUsuarios u
                ON u.IdOTSolicitud = ot.IdOTSolicitud
            LEFT JOIN #tmpCerrarSemanas tmp2
                ON tmp2.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
            LEFT JOIN #tmpEstimacionPend ePend
                ON ePend.IdOTSolicitud = ot.IdOTSolicitud
            LEFT JOIN #tmpAceptacionesPend aPend
                ON aPend.IdOTSolicitud = ot.IdOTSolicitud
            LEFT JOIN #tmpAceptacionesSinRec aPendRec
                ON aPendRec.IdOTSolicitud = ot.IdOTSolicitud
        WHERE @pIdContrato IN ( sc.IdContrato, 0 )
        GROUP BY ot.Folio,
                 ot.IdOTSolicitud,
                 ot.IdOTEstatus,
                 tmp2.Fecha,
                 ot.ProgIniPorProveedor,
                 uot.Usuario,
                 pv.RazonSocial,
                 ePend.IdOTSolicitud,
                 ePend.SemanaID,
                 aPend.IdOTSolicitud,
                 aPend.IdPedido,
                 aPend.IdPedidoGen,
                 ot.IdSubcontrato,
                 ot.CreadoEl,
                 aPendRec.idPedidoGen,
                 aPendRec.idOTSolicitud,
                 cc.CentroCosto,
                 aPendRec.idAceptacionPedido

        /*ISSUE 1018 OT's sin relación Pedido - PO. Se agrega tarea para Relacionar Pedido-PO*/
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
        SELECT 1,
               ot.Folio,
               ot.IdOTSolicitud,
               e.CreadoEl,
               'Operadora - Relacionar Pedido:' + cast(e.IdPedidoGeneral AS VARCHAR) + ' con PO en Procura',
               'Pendiente',
               @dominioProcura + '/DEA/Relacion_PR_PO.aspx',
               'Completar',
               NULL,
               0,
               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 6, 0),
               cc.CentroCosto
        FROM #tmpEstimacionSinPO e
            INNER JOIN OT_Solicitud ot
                ON ot.IdOTSolicitud = e.IdOTSolicitud
            INNER JOIN petrovendor..CC_CentroCosto cc
                ON cc.IdCentroCosto = ot.IdCentroCosto
        --ORDER BY ot.CreadoEl DESC
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
    SELECT sb.IdOTBitacora,
           ot.Folio,
           ot.IdOTSolicitud,
           ot.CreadoEl,
           CASE
               WHEN ISNULL(sb.Descripcion, '') = '' THEN
                   t.Descripcion
               ELSE
                   ISNULL(sb.Descripcion, '')
           END,
           'Completada',
           '',
           '',
           sb.CreadoEl,
           1,
           CASE
               WHEN ISNULL(sb.UsuarioAdincoId, 0) > 0 THEN
                   u.Usuario
               ELSE
                   pv.RazonSocial
           END,
           cc.CentroCosto
    FROM OT_Solicitud ot (NOLOCK)
        INNER JOIN petrovendor..CC_CentroCosto cc (NOLOCK)
            ON cc.IdCentroCosto = ot.IdCentroCosto
        INNER JOIN OT_SolicitudMaterial otm (NOLOCK)
            ON otm.IdOTSolicitud = ot.IdOTSolicitud
               AND @pPend_Comp = 2
        INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK)
            ON (@pUsuarioAdincoId IN ( ucc.IdUsuario, 0 ))
               AND ucc.IdCentroCosto IN ( ot.IdCentroCosto, 0 )
        INNER JOIN SC_Subcontrato sc (NOLOCK)
            ON sc.IdSubcontrato = ot.IdSubcontrato
        INNER JOIN PV_Subcontratista pv (NOLOCK)
            ON pv.IdSubcontratista = sc.IdSubcontratista
        INNER JOIN petrovendor..S_Proveedor prov (NOLOCK)
            ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = pv.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
               AND @pIdProveedor IN ( 0, prov.IdProveedor )
        INNER JOIN OT_SolicitudBitacora sb (NOLOCK)
            ON sb.IdOTSolicitud = ot.IdOTSolicitud
               AND sb.CreadoEl >= dateadd(day, -15, getdate())
        LEFT JOIN AP_Usuario u (NOLOCK)
            ON u.UsuarioId = sb.UsuarioAdincoId
        LEFT JOIN [AP_FlujoAprobacion_Tareas] t
            ON t.FlujoAprobacionTareaId = sb.FlujoAprobacionTareaId
    WHERE @pIdContrato IN ( sc.IdContrato, 0 )
          AND ot.IsActivo = 1
    GROUP BY sb.UsuarioAdincoId,
             pv.RazonSocial,
             ot.Folio,
             ot.IdOTSolicitud,
             ot.CreadoEl,
             sb.Descripcion,
             sb.CreadoEl,
             u.Usuario,
             t.Descripcion,
             sb.IdOTBitacora,
             cc.CentroCosto
    ORDER BY sb.CreadoEl DESC
    --UPDATE #tmpTareas
    --SET UsuarioAsignado = replace(replace(replace(UsuarioAsignado,'daniel.moreno@adinco.mx',''),'juventino.sanchez@wINTershalldea.com',''),'yazmin.gonzalez@ogss.com.mx','')
    SELECT *
    FROM #tmpTareas
    ORDER BY UrlText DESC,
             FechaRegistro DESC,
             FechaCompletada DESC,
             Folio
END