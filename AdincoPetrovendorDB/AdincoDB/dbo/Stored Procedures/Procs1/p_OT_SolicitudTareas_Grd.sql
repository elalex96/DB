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
                   WHEN OT_Solicitud.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL THEN
                               'Operadora - Reclasificar Aceptación '
                               + CAST(#tmpAceptacionesSinRec.idAceptacionPedido AS VARCHAR) + ' en Procura '
                           WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL THEN
                               'Operadora - Generar Aceptación en Procura '
                           WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL THEN
                               'Operadora - Generar Estimación para semana ' + #tmpEstimacionPend.SemanaID
                           WHEN #tmpCerrarSemanas.Fecha IS NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               'Proveedor - Capturar Avance '
                           WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               'Operadora - Revisar y cerrar semana para fecha:'
                               + CONVERT(VARCHAR, #tmpCerrarSemanas.Fecha, 103)
                       END
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
                   WHEN OT_Solicitud.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL THEN
                               @dominioProcura + '/01Proveedores/APListaReclasificacion.aspx'
                           WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL THEN
                               @dominioProcura + '/02Proveedores/AceptacionPedido.aspx?ped='
                               + CAST(#tmpAceptacionesPend.IdPedido AS VARCHAR) + '&pedgral='
                               + CAST(#tmpAceptacionesPend.IdPedidoGen AS VARCHAR) + '&ori=pedido'
                           WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL THEN
                               @dominioAdinco + '/2/OrdenTrabajo/GenerarEstimacionOT_Solicitud.aspx?id1='
                               + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
                           WHEN #tmpCerrarSemanas.Fecha IS NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               @dominioPetrovendor + '/02Proveedores/CapturaProgramaOT_Solicitud.aspx?id='
                               + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
                           WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               @dominioAdinco + '/2/OrdenTrabajo/CapturaProgramaOT_Solicitud.aspx?id='
                               + CAST(OT_Solicitud.IdOTSolicitud AS VARCHAR)
                       END
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
                   WHEN OT_Solicitud.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN #tmpCerrarSemanas.Fecha IS NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) = 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
                           WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               CASE
                                   WHEN ISNULL(@pUsuarioAdincoId, 0) > 0 THEN
                                       'Completar'
                                   ELSE
                                       ''
                               END
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
                   WHEN OT_Solicitud.IdOTEstatus = 1 THEN
                       [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 1, 0)
                   WHEN OT_Solicitud.IdOTEstatus IN ( 2, 4 ) THEN
                       PV_Subcontratista.RazonSocial
                   WHEN OT_Solicitud.IdOTEstatus IN ( 5, 6 ) THEN
                       CASE
                           WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 5, 0)
                           WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 5, 0)
                           WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 4, 0)
                           WHEN #tmpCerrarSemanas.Fecha IS NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               PV_Subcontratista.RazonSocial
                           WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                AND #tmpAceptacionesPend.IdOTSolicitud IS NULL THEN
                               [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 3, 0)
                       END
                   WHEN OT_Solicitud.IdOTEstatus IN ( 9 ) THEN
                       [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 6, 0)
                   WHEN OT_Solicitud.IdOTEstatus IN ( 3, 11 ) THEN
                       [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 2, 0)
               END,
               petrovendor..CC_CentroCosto.CentroCosto
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
            LEFT JOIN #tmpCerrarSemanas
                ON OT_SolicitudMaterial.IdOTSolicitudMaterial = #tmpCerrarSemanas.IdOTSolicitudMaterial
            LEFT JOIN #tmpEstimacionPend
                ON OT_Solicitud.IdOTSolicitud = #tmpEstimacionPend.IdOTSolicitud
            LEFT JOIN #tmpAceptacionesPend
                ON OT_Solicitud.IdOTSolicitud = #tmpAceptacionesPend.IdOTSolicitud
            LEFT JOIN #tmpAceptacionesSinRec
                ON OT_Solicitud.IdOTSolicitud = #tmpAceptacionesSinRec.IdOTSolicitud
        WHERE @pIdContrato IN ( SC_SubContrato.IdContrato, 0 )
        GROUP BY OT_Solicitud.Folio,
                 OT_Solicitud.IdOTSolicitud,
                 OT_Solicitud.IdOTEstatus,
                 #tmpCerrarSemanas.Fecha,
                 OT_Solicitud.ProgIniPorProveedor,
                 AP_Usuario.Usuario,
                 PV_Subcontratista.RazonSocial,
                 #tmpEstimacionPend.IdOTSolicitud,
                 #tmpEstimacionPend.SemanaID,
                 #tmpAceptacionesPend.IdOTSolicitud,
                 #tmpAceptacionesPend.IdPedido,
                 #tmpAceptacionesPend.IdPedidoGen,
                 OT_Solicitud.IdSubcontrato,
                 OT_Solicitud.CreadoEl,
                 #tmpAceptacionesSinRec.idPedidoGen,
                 #tmpAceptacionesSinRec.idOTSolicitud,
                 petrovendor..CC_CentroCosto.CentroCosto,
                 #tmpAceptacionesSinRec.idAceptacionPedido

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
               [dbo].[fn_OT_GetMailUsuariosEstatus](OT_Solicitud.IdOTSolicitud, 0, 6, 0),
               petrovendor..CC_CentroCosto.CentroCosto
        FROM #tmpEstimacionSinPO
            INNER JOIN OT_Solicitud
                ON #tmpEstimacionSinPO.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
            INNER JOIN petrovendor..CC_CentroCosto
                ON OT_Solicitud.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto
        --ORDER BY OT_Solicitud.CreadoEl DESC
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
    SELECT OT_SolicitudBitacora.IdOTBitacora,
           OT_Solicitud.Folio,
           OT_Solicitud.IdOTSolicitud,
           OT_Solicitud.CreadoEl,
           CASE
               WHEN ISNULL(OT_SolicitudBitacora.Descripcion, '') = '' THEN
                   AP_FlujoAprobacion_Tareas.Descripcion
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
                   AP_Usuario.Usuario
               ELSE
                   PV_Subcontratista.RazonSocial
           END,
           petrovendor..CC_CentroCosto.CentroCosto
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
        LEFT JOIN AP_Usuario (NOLOCK)
            ON OT_SolicitudBitacora.UsuarioAdincoId = AP_Usuario.UsuarioId
        LEFT JOIN AP_FlujoAprobacion_Tareas
            ON OT_SolicitudBitacora.FlujoAprobacionTareaId = AP_FlujoAprobacion_Tareas.FlujoAprobacionTareaId
    WHERE @pIdContrato IN ( SC_SubContrato.IdContrato, 0 )
          AND OT_Solicitud.IsActivo = 1
    GROUP BY OT_SolicitudBitacora.UsuarioAdincoId,
             PV_Subcontratista.RazonSocial,
             OT_Solicitud.Folio,
             OT_Solicitud.IdOTSolicitud,
             OT_Solicitud.CreadoEl,
             OT_SolicitudBitacora.Descripcion,
             OT_SolicitudBitacora.CreadoEl,
             AP_Usuario.Usuario,
             AP_FlujoAprobacion_Tareas.Descripcion,
             OT_SolicitudBitacora.IdOTBitacora,
             petrovendor..CC_CentroCosto.CentroCosto
    ORDER BY OT_SolicitudBitacora.CreadoEl DESC
    --UPDATE #tmpTareas
    --SET UsuarioAsignado = replace(replace(replace(UsuarioAsignado,'daniel.moreno@adinco.mx',''),'juventino.sanchez@wINTershalldea.com',''),'yazmin.gonzalez@ogss.com.mx','')
    SELECT *
    FROM #tmpTareas
    ORDER BY UrlText DESC,
             FechaRegistro DESC,
             FechaCompletada DESC,
             Folio
END