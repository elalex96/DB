IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_SolicitudTareas_Grd'
    )
    DROP PROCEDURE p_OT_SolicitudTareas_Grd;
GO
--╔══════════════════════════════════════════╗
--║Uso de SP en Sistema de ADINCO            ║
--║Uso de SP en Sistema de PETROVENDOR       ║
--╚══════════════════════════════════════════╝
-- =============================================   
-- Modificado Por:	Neri Garcia
-- Fecha:			06 de Octubre del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), eliminación de subquerys,
--					se ajustan las tablas declaradas que se encuentran dispersas,
--					se eliminan tablas que no se encuentran en uso, se ajustan algunos left joins, 
--					se quita el uso de funciones, ajuste de orden de llamado en los joins (ON)
-- =============================================
CREATE PROCEDURE [p_OT_SolicitudTareas_Grd] --10038,10,0,1,0
    @pIdContrato      INT,
    @pUsuarioAdincoId INT,
    @pUsuarioPetroId  INT,
    @pPend_Comp       INT, --0 ambas, 1 pendientes, 2 completadas
    @pIdProveedor     INT = 0
AS
    BEGIN
        /*Tablas Temporales*/
        CREATE TABLE #tmpTareas
            (
                IdOTTarea       INT,
                Folio           VARCHAR(250),
                IdOTSolicitud   INT,
                FechaRegistro   DATETIME,
                Tarea           VARCHAR(300),
                Estatus         VARCHAR(50),
                Url             VARCHAR(500),
                UrlText         VARCHAR(100),
                FechaCompletada DATETIME,
                Completada      BIT,
                UsuarioAsignado VARCHAR(5000),
                CentroCosto     VARCHAR(250)
            );

        CREATE TABLE #tmpTareasPendientesDeAprobar
            (
                IdOTTarea                               INT,
                Folio                                   VARCHAR(250),
                IdOTSolicitud                           INT,
                FechaRegistro                           DATETIME,
                Tarea                                   VARCHAR(300),
                Estatus                                 VARCHAR(50),
                Url                                     VARCHAR(500),
                UrlText                                 VARCHAR(100),
                FechaCompletada                         DATETIME,
                Completada                              BIT,
                UsuarioAsignado                         VARCHAR(5000),
                CentroCosto                             VARCHAR(250),
                IdOTEstatus                             INT,
                tmpAceptacionesSinRecIdOTSolicitud      INT,
                tmpAceptacionesSinRecidAceptacionPedido INT,
                tmpAceptacionesPendIdOTSolicitud        INT,
                tmpEstimacionPendIdOTSolicitud          INT,
                tmpEstimacionPendSemanaID               VARCHAR(21),
                tmpCerrarSemanasFecha                   DATETIME,
                tmpAceptacionesPendIdPedido             INT,
                tmpAceptacionesPendIdPedidoGen          INT,
                Actualizado                             BIT
            );

        CREATE TABLE #tmpTareasPendientesDeAprobarUsuarios
            (
                IdOTSolicitud            INT,
                UsuarioAsignado          VARCHAR(1000),
                FlujoAprobacionEstatusId INT
            );

        CREATE TABLE #tmpTareasPendientesDeAprobarUsuariosMenbers
            (
                IdOTSolicitud            INT,
                FlujoAprobacionEstatusId INT,
                UsuarioAsignado          VARCHAR(5000)
            );

        CREATE TABLE #tmpTareasSinRelacionPedido
            (
                IdOTTarea       INT,
                Folio           VARCHAR(250),
                IdOTSolicitud   INT,
                FechaRegistro   DATETIME,
                Tarea           VARCHAR(300),
                Estatus         VARCHAR(50),
                Url             VARCHAR(500),
                UrlText         VARCHAR(100),
                FechaCompletada DATETIME,
                Completada      BIT,
                UsuarioAsignado VARCHAR(5000),
                CentroCosto     VARCHAR(250)
            );

        CREATE TABLE #tmpTareasCompletadas
            (
                IdOTTarea              INT,
                Folio                  VARCHAR(250),
                IdOTSolicitud          INT,
                FechaRegistro          DATETIME,
                Tarea                  VARCHAR(300),
                Estatus                VARCHAR(50),
                Url                    VARCHAR(500),
                UrlText                VARCHAR(100),
                FechaCompletada        DATETIME,
                Completada             BIT,
                UsuarioAsignado        VARCHAR(5000),
                CentroCosto            VARCHAR(250),
                UsuarioAdincoId        INT,
                FlujoAprobacionTareaId INT
            );

        CREATE TABLE #tmpCerrarSemanas
            (
                IdOTSolicitud                INT,
                IdOTSolicitudMaterial        INT,
                Fecha                        DATETIME,
                IdOTSolicitudProgramaCaptura INT
            );

        CREATE TABLE #tmpEstimacionPend
            (
                IdOTSolicitud         INT,
                IdOTSolicitudMaterial INT,
                Fecha                 DATETIME,
                SemanaID              VARCHAR(21)
            );

        CREATE TABLE #tmpAceptacionesPend
            (
                IdOTEstimacion INT,
                IdOTSolicitud  INT,
                IdPedido       INT,
                IdPedidoGen    INT
            );

        CREATE TABLE #tmpAceptacionesSinRec
            (
                IdOTEstimacion     INT,
                IdOTSolicitud      INT,
                IdPedido           INT,
                idPedidoGen        INT,
                IdAceptacionPedido INT
            );
        CREATE TABLE #tmpEstimacionSinPO
            (
                IdOTSolicitud   INT,
                IdOTEstimacion  INT,
                IdPedidoGeneral INT,
                CreadoEl        DATETIME,
                IdPedido        INT
            );

        CREATE TABLE #tmpOTEstatusPermitidos (IdOTEstatus INT);

        CREATE TABLE #OT_SolicitudDelContrato
            (
                IdOTSolicitud       INT PRIMARY KEY,
                IdOTEstatus         INT,
                IsActivo            bit,
                IdSubContrato       int,
                Folio               varchar(150),
                CreadoEl            datetime,
                ProgIniPorProveedor bit,
                IdCentroCosto       int
            );
        CREATE TABLE #SC_SubContratoDelContrato
            (
                IdSubcontrato    INT PRIMARY KEY,
                IDContrato       INT,
                IdSubcontratista int
            );

        CREATE TABLE #OT_SolicitudDelProveedor
            (
                IdOTSolicitud       INT PRIMARY KEY,
                IdOTEstatus         INT,
                IsActivo            bit,
                IdSubContrato       int,
                Folio               varchar(150),
                CreadoEl            datetime,
                ProgIniPorProveedor bit,
                IdCentroCosto       int,
                CreadoPor           INT
            );
        CREATE TABLE #SC_SubContratoDelProveedor
            (
                IdSubcontrato             INT PRIMARY KEY,
                IDContrato                INT,
                IdSubcontratista          int,
                SubcontratistaRazonSocial varchar(300)
            );

        DECLARE @emailUsuario VARCHAR(50);

        /*PRODUCCIÓN*/
        DECLARE
            @dominioAdinco      VARCHAR(100) = 'https://adinco.mx',
            @dominioPetrovendor VARCHAR(100) = 'https://petrovendor.com.mx',
            @dominioProcura     VARCHAR(100) = 'https://procura.adinco.mx'
        /*QA
	DECLARE @dominioAdinco VARCHAR(100)='http://mpyadinco.adinco.mx',
			@dominioPetrovendor VARCHAR(100)='http://mpypetrovendor.adinco.mx',
			@dominioProcura VARCHAR(100)= 'https://MPYprocura.adinco.mx'
	*/
        --DESARROLLO
        /*
	DECLARE @dominioAdinco VARCHAR(100)='http://desarrollo.adinco.mx',
			@dominioPetrovendor VARCHAR(100)='http://desarrollo.petrovendor.com.mx',
			@dominioProcura VARCHAR(100)= 'http://desarrolloprocura.adinco.mx'	
	*/
        --LOCALHOST
        /*
    DECLARE @dominioAdinco VARCHAR(100) = 'http://localhost:52692',      --https://adinco.mx
            @dominioPetrovendor VARCHAR(100) = 'http://localhost:58935', --https://petrovendor.com.mx
            @dominioProcura VARCHAR(100) = 'http://localhost:58936'      --https://procura.adinco.mx
	*/
        -------------------------------------
        INSERT INTO #SC_SubContratoDelContrato
            (
                IdSubcontrato,
                IDContrato,
                IdSubcontratista
            )
                    SELECT DISTINCT
                        IdSubcontrato,
                        IDContrato,
                        IdSubcontratista
                    FROM
                        SC_SubContrato (NOLOCK)
                    WHERE
                        IDContrato = @pIdContrato;

        INSERT INTO #OT_SolicitudDelContrato
            (
                IdOTSolicitud,
                IdOTEstatus,
                IsActivo,
                IdSubContrato,
                Folio,
                CreadoEl,
                ProgIniPorProveedor,
                IdCentroCosto
            )
                    SELECT DISTINCT
                        OT_Solicitud.IdOTSolicitud,
                        OT_Solicitud.IdOTEstatus,
                        OT_Solicitud.IsActivo,
                        OT_Solicitud.IdSubContrato,
                        OT_Solicitud.Folio,
                        OT_Solicitud.CreadoEl,
                        OT_Solicitud.ProgIniPorProveedor,
                        OT_Solicitud.IdCentroCosto
                    FROM
                        #SC_SubContratoDelContrato
                        JOIN
                            OT_Solicitud (NOLOCK)
                                ON #SC_SubContratoDelContrato.IdSubcontrato = OT_Solicitud.IdSubContrato;
        ----------------------------------------
        INSERT INTO #SC_SubContratoDelProveedor
            (
                IdSubcontrato,
                IDContrato,
                IdSubcontratista,
                SubcontratistaRazonSocial
            )
                    SELECT DISTINCT
                        SC_SubContrato.IdSubcontrato,
                        SC_SubContrato.IDContrato,
                        SC_SubContrato.IdSubcontratista,
                        PV_Subcontratista.RazonSocial
                    FROM
                        SC_SubContrato (NOLOCK)
                        INNER JOIN
                            PV_Subcontratista (NOLOCK)
                                ON SC_SubContrato.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                        INNER JOIN
                            petrovendor..S_Proveedor (NOLOCK)
                                ON PV_Subcontratista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = petrovendor..S_Proveedor.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
                                   AND @pIdProveedor IN (
                                                            0, petrovendor..S_Proveedor.IdProveedor
                                                        )
                    WHERE
                        @pIdContrato IN (
                                            SC_SubContrato.IdContrato, 0
                                        );

        INSERT INTO #OT_SolicitudDelProveedor
            (
                IdOTSolicitud,
                IdOTEstatus,
                IsActivo,
                IdSubContrato,
                Folio,
                CreadoEl,
                ProgIniPorProveedor,
                IdCentroCosto,
                CreadoPor
            )
                    SELECT DISTINCT
                        OT_Solicitud.IdOTSolicitud,
                        OT_Solicitud.IdOTEstatus,
                        OT_Solicitud.IsActivo,
                        OT_Solicitud.IdSubContrato,
                        OT_Solicitud.Folio,
                        OT_Solicitud.CreadoEl,
                        OT_Solicitud.ProgIniPorProveedor,
                        OT_Solicitud.IdCentroCosto,
                        OT_Solicitud.CreadoPor
                    FROM
                        #SC_SubContratoDelProveedor
                        JOIN
                            OT_Solicitud (NOLOCK)
                                ON #SC_SubContratoDelProveedor.IdSubcontrato = OT_Solicitud.IdSubContrato;
        ------------------------------
        /*Obtencion Valores*/
        INSERT INTO #tmpOTEstatusPermitidos
            (
                IdOTEstatus
            )
                    SELECT
                        IdOTEstatus
                    FROM
                        OT_Solicitud (NOLOCK)
                    GROUP BY
                        IdOTEstatus

        IF (
               @pUsuarioAdincoId > 0
               OR @pUsuarioPetroId > 0
           )
            BEGIN
                DELETE #tmpOTEstatusPermitidos
                WHERE
                    IdOTEstatus IN (
                                       7, 8, 12
                                   )
            END

        IF (ISNULL(@pUsuarioAdincoId, 0) = 0)
            BEGIN
                DELETE #tmpOTEstatusPermitidos
                WHERE
                    IdOTEstatus IN (
                                       1, 7, 8, 12
                                   )
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
                            SELECT
                                #OT_SolicitudDelContrato.IdOTSolicitud,
                                OT_SolicitudMaterial.IdOTSolicitudMaterial,
                                OT_SolicitudProgramaCaptura.Fecha,
                                OT_SolicitudProgramaCaptura.IdOTSolicitudProgramaCaptura
                            FROM
                                #OT_SolicitudDelContrato (NOLOCK)
                                INNER JOIN
                                    OT_SolicitudMaterial (NOLOCK)
                                        ON #OT_SolicitudDelContrato.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
                                           AND #OT_SolicitudDelContrato.IsActivo = 1
                                INNER JOIN
                                    OT_SolicitudProgramaCaptura (NOLOCK)
                                        ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                                           AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                            WHERE
                                #OT_SolicitudDelContrato.IsActivo = 1
                            GROUP BY
                                #OT_SolicitudDelContrato.IdOTSolicitud,
                                OT_SolicitudMaterial.IdOTSolicitudMaterial,
                                OT_SolicitudProgramaCaptura.Fecha,
                                OT_SolicitudProgramaCaptura.IdOTSolicitudProgramaCaptura;

                /*Se saca subquery que manejaba NOT exists*/
                DELETE #tmpCerrarSemanas
                FROM
                    #tmpCerrarSemanas
                    INNER JOIN
                        OT_ProgramaSemanaCerrada (NOLOCK)
                            ON #tmpCerrarSemanas.IdOTSolicitud = OT_ProgramaSemanaCerrada.IdOTSolicitud
                               AND #tmpCerrarSemanas.Fecha
                               BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
                               AND OT_ProgramaSemanaCerrada.isActivo = 1;

                /*SEMANAS QUE FALTAN ESTIMAR*/
                INSERT INTO #tmpEstimacionPend
                    (
                        IdOTSolicitud,
                        IdOTSolicitudMaterial,
                        Fecha,
                        SemanaID
                    )
                            SELECT
                                #OT_SolicitudDelContrato.IdOTSolicitud,
                                OT_SolicitudMaterial.IdOTSolicitudMaterial,
                                OT_SolicitudProgramaCaptura.Fecha,
                                OT_ProgramaSemanaCerrada.SemanaID
                            FROM
                                #OT_SolicitudDelContrato (NOLOCK)
                                INNER JOIN
                                    OT_SolicitudMaterial (NOLOCK)
                                        ON #OT_SolicitudDelContrato.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
                                           AND #OT_SolicitudDelContrato.IsActivo = 1
                                INNER JOIN
                                    OT_SolicitudProgramaCaptura (NOLOCK)
                                        ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                                           AND OT_SolicitudProgramaCaptura.VoBoSubcontratista = 1
                                           AND OT_SolicitudProgramaCaptura.VoBoContratista = 1
                                INNER JOIN
                                    OT_ProgramaSemanaCerrada (NOLOCK)
                                        ON #OT_SolicitudDelContrato.IdOTSolicitud = OT_ProgramaSemanaCerrada.IdOTSolicitud
                                           AND OT_SolicitudProgramaCaptura.Fecha
                                           BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
                                           AND OT_ProgramaSemanaCerrada.isActivo = 1
                            WHERE
                                #OT_SolicitudDelContrato.IsActivo = 1
                            GROUP BY
                                #OT_SolicitudDelContrato.IdOTSolicitud,
                                OT_SolicitudMaterial.IdOTSolicitudMaterial,
                                OT_SolicitudProgramaCaptura.Fecha,
                                OT_ProgramaSemanaCerrada.SemanaID

                /*Se saca subquery que manejaba NOT exists*/
                DELETE #tmpEstimacionPend
                FROM
                    #tmpEstimacionPend
                    INNER JOIN
                        OT_Estimacion (NOLOCK)
                            ON #tmpEstimacionPend.IdOTSolicitud = OT_Estimacion.IdOTSolicitud
                               AND #tmpEstimacionPend.Fecha
                               BETWEEN OT_Estimacion.FechaCorteInicio AND OT_Estimacion.FechaCorteFin
                               AND ISNULL(OT_Estimacion.Cancelada, 0) = 0;

                /*Estimaciones sin aceptacion*/
                INSERT INTO #tmpAceptacionesPend
                    (
                        IdOTEstimacion,
                        IdOTSolicitud,
                        IdPedido,
                        IdPedidoGen
                    )
                            SELECT
                                OT_Estimacion.IdOTEstimacion,
                                OT_Estimacion.IdOTSolicitud,
                                idPedido    = OT_Estimacion.IdPedido,
                                idPedidoGen = OT_Estimacion.IdPedidoGeneral
                            FROM
                                OT_Estimacion (NOLOCK)
                                INNER JOIN
                                    #OT_SolicitudDelContrato (NOLOCK)
                                        ON ISNULL(OT_Estimacion.cancelada, 0) = 0
                                           AND OT_Estimacion.IdOTSolicitud = #OT_SolicitudDelContrato.IdOTSolicitud
                            WHERE
                                ISNULL(OT_Estimacion.cancelada, 0) = 0
                            GROUP BY
                                OT_Estimacion.IdOTEstimacion,
                                OT_Estimacion.IdPedido,
                                OT_Estimacion.IdPedidoGeneral,
                                OT_Estimacion.IdOTSolicitud;

                /*Se saca subquery que manejaba NOT exists*/
                DELETE #tmpAceptacionesPend
                FROM
                    #tmpAceptacionesPend
                    INNER JOIN
                        Petrovendor..MM_AceptacionPedido (NOLOCK)
                            ON #tmpAceptacionesPend.IdPedido = #tmpAceptacionesPend.IdPedido;

                /*Aceptaciones sin reclasificacion*/
                INSERT INTO #tmpAceptacionesSinRec
                    (
                        IdOTEstimacion,
                        IdOTSolicitud,
                        IdPedido,
                        idPedidoGen,
                        IdAceptacionPedido
                    )
                            SELECT
                                OT_Estimacion.IdOTEstimacion,
                                OT_Estimacion.IdOTSolicitud,
                                idPedido     = OT_Estimacion.IdPedido,
                                idPedidoGen  = OT_Estimacion.IdPedidoGeneral,
                                petrovendor..MM_AceptacionPedido.idAceptacionPedido
                            FROM
                                OT_Estimacion (NOLOCK)
                                INNER JOIN
                                    #OT_SolicitudDelContrato (NOLOCK)
                                        ON ISNULL(OT_Estimacion.Cancelada, 0) = 0
                                           AND OT_Estimacion.IdOTSolicitud = #OT_SolicitudDelContrato.IdOTSolicitud
                                INNER JOIN
                                    petrovendor..MM_AceptacionPedido (NOLOCK)
                                        ON OT_Estimacion.IdPedido = petrovendor..MM_AceptacionPedido.IdPedido
                                           AND petrovendor..MM_AceptacionPedido.ModificadoPor IS NULL
                            WHERE
                                ISNULL(OT_Estimacion.Cancelada, 0) = 0
                            GROUP BY
                                OT_Estimacion.IdOTEstimacion,
                                OT_Estimacion.IdPedido,
                                OT_Estimacion.IdPedidoGeneral,
                                OT_Estimacion.IdOTSolicitud,
                                petrovendor..MM_AceptacionPedido.idAceptacionPedido;

                /*Se saca subquery que manejaba NOT exists*/
                DELETE #tmpAceptacionesSinRec
                FROM
                    #tmpAceptacionesSinRec
                    INNER JOIN
                        petrovendor..MM_AceptacionPedidoDetalleEliminada (NOLOCK)
                            ON #tmpAceptacionesSinRec.idAceptacionPedido = petrovendor..MM_AceptacionPedidoDetalleEliminada.IdAceptacionPedido

                DELETE #tmpAceptacionesSinRec
                FROM
                    #tmpAceptacionesSinRec
                    INNER JOIN
                        petrovendor..MM_AceptacionFactura (NOLOCK)
                            ON #tmpAceptacionesSinRec.idAceptacionPedido = petrovendor..MM_AceptacionFactura.IdAceptacionPedido;

                /*ISSUE 1018. Generar info de Estimaciones sin PO*/
                INSERT INTO #tmpEstimacionSinPO
                    (
                        IdOTSolicitud,
                        IdOTEstimacion,
                        IdPedidoGeneral,
                        CreadoEl,
                        IdPedido
                    )
                            SELECT
                                OT_Estimacion.IdOTSolicitud,
                                OT_Estimacion.IdOTEstimacion,
                                OT_Estimacion.IdPedidoGeneral,
                                OT_Estimacion.CreadoEl,
                                OT_Estimacion.IdPedido
                            FROM
                                OT_Estimacion (NOLOCK)
                                INNER JOIN
                                    #OT_SolicitudDelContrato (NOLOCK)
                                        ON OT_Estimacion.IdOTSolicitud = #OT_SolicitudDelContrato.IdOTSolicitud
                                           AND ISNULL(OT_Estimacion.Cancelada, 0) = 0
                            WHERE
                                ISNULL(OT_Estimacion.Cancelada, 0) = 0
                            GROUP BY
                                OT_Estimacion.IdOTSolicitud,
                                OT_Estimacion.IdOTEstimacion,
                                OT_Estimacion.IdPedidoGeneral,
                                OT_Estimacion.CreadoEl,
                                OT_Estimacion.IdPedido

                /*Se saca left join*/
                DELETE #tmpEstimacionSinPO
                FROm
                    #tmpEstimacionSinPO
                    INNER JOIN
                        petrovendor..DEA_Relacion_PR_PO (NOLOCK)
                            ON #tmpEstimacionSinPO.IdPedido = petrovendor..DEA_Relacion_PR_PO.IdPedido;

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
                        tmpAceptacionesPendIdPedidoGen,
                        Actualizado
                    )
                            SELECT
                                1,
                                #OT_SolicitudDelProveedor.Folio,
                                #OT_SolicitudDelProveedor.IdOTSolicitud,
                                #OT_SolicitudDelProveedor.CreadoEl,
                                /*********ESTATUS TAREA***************/
                                CASE
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus = 1
                                        THEN CASE
                                                 WHEN #OT_SolicitudDelProveedor.ProgIniPorProveedor = 0
                                                     THEN 'Operadora - Pendiente de Enviar a Manager'
                                                 WHEN #OT_SolicitudDelProveedor.ProgIniPorProveedor = 1
                                                     THEN 'Operadora - Pendiente de Enviar a Proveedor'
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      2, 4
                                                                                  )
                                        THEN 'Proveedor - Revisión de OT'
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      5, 6
                                                                                  )
                                        THEN CASE
                                                 WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL
                                                     THEN 'Operadora - Reclasificar Aceptación '
                                                          + CAST(#tmpAceptacionesSinRec.idAceptacionPedido AS VARCHAR)
                                                          + ' en Procura '
                                                 WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL
                                                     THEN 'Operadora - Generar Aceptación en Procura '
                                                 WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL
                                                     THEN 'Operadora - Generar Estimación para semana '
                                                          + #tmpEstimacionPend.SemanaID
                                                 WHEN #tmpCerrarSemanas.Fecha IS NULL
                                                      AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                     THEN 'Proveedor - Capturar Avance '
                                                 WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                                      AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                     THEN 'Operadora - Revisar y cerrar semana para fecha:'
                                                          + convert(varchar, #tmpCerrarSemanas.Fecha, 103)
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      9
                                                                                  )
                                        THEN 'Operadora - Revisar convenio en Procura'
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      3, 11
                                                                                  )
                                        THEN 'Operadora - Aprobar OT por Manager'
                                END,
                                'Pendiente',
                                /************URL ACCIÓN**********/
                                CASE
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus = 1
                                        THEN @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                                             + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      2, 4
                                                                                  )
                                        THEN @dominioPetrovendor + '/02Proveedores/RegistrarOTSolicitudProv.aspx?id='
                                             + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      5, 6
                                                                                  )
                                        THEN CASE
                                                 WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL
                                                     THEN @dominioProcura
                                                          + '/01Proveedores/APListaReclasificacion.aspx'
                                                 WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL
                                                     THEN @dominioProcura + '/02Proveedores/AceptacionPedido.aspx?ped='
                                                          + CAST(#tmpAceptacionesPend.IdPedido AS VARCHAR)
                                                          + '&pedgral='
                                                          + CAST(#tmpAceptacionesPend.IdPedidoGen AS VARCHAR)
                                                          + '&ori=pedido'
                                                 WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL
                                                     THEN @dominioAdinco
                                                          + '/2/OrdenTrabajo/GenerarEstimacionOT.aspx?id1='
                                                          + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                                 WHEN #tmpCerrarSemanas.Fecha IS NULL
                                                      AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                     THEN @dominioPetrovendor
                                                          + '/02Proveedores/CapturaProgramaOT.aspx?id='
                                                          + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                                 WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                                      AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                     THEN @dominioAdinco + '/2/OrdenTrabajo/CapturaProgramaOT.aspx?id='
                                                          + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      9
                                                                                  )
                                        THEN @dominioProcura + '/02Proveedores/ActualizarSCOTConvenio.aspx?id='
                                             + CAST(#OT_SolicitudDelProveedor.IdSubcontrato AS VARCHAR) + '&id2='
                                             + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      3, 11
                                                                                  )
                                        THEN @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                                             + CAST(#OT_SolicitudDelProveedor.IdOTSolicitud AS VARCHAR)
                                END,
                                /**********Url Text*************/
                                CASE
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus = 1
                                        THEN CASE
                                                 WHEN @pUsuarioAdincoId > 0
                                                     THEN 'Completar'
                                                 ELSE
                                                     ''
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      2, 4
                                                                                  )
                                        THEN CASE
                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) = 0
                                                     THEN 'Completar'
                                                 ELSE
                                                     ''
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      5, 6
                                                                                  )
                                        THEN CASE
                                                 WHEN #tmpAceptacionesSinRec.IdOTSolicitud IS NOT NULL
                                                     THEN CASE
                                                              WHEN isnull(@pUsuarioAdincoId, 0) > 0
                                                                  THEN 'Completar'
                                                              ELSE
                                                                  ''
                                                          END
                                                 WHEN #tmpAceptacionesPend.IdOTSolicitud IS NOT NULL
                                                     THEN CASE
                                                              WHEN isnull(@pUsuarioAdincoId, 0) > 0
                                                                  THEN 'Completar'
                                                              ELSE
                                                                  ''
                                                          END
                                                 WHEN #tmpEstimacionPend.IdOTSolicitud IS NOT NULL
                                                     THEN CASE
                                                              WHEN isnull(@pUsuarioAdincoId, 0) > 0
                                                                  THEN 'Completar'
                                                              ELSE
                                                                  ''
                                                          END
                                                 WHEN #tmpCerrarSemanas.Fecha IS NULL
                                                      AND #tmpEstimacionPend.IdOTSolicitud IS NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                     THEN CASE
                                                              WHEN isnull(@pUsuarioAdincoId, 0) = 0
                                                                  THEN 'Completar'
                                                              ELSE
                                                                  ''
                                                          END
                                                 WHEN #tmpCerrarSemanas.Fecha IS NOT NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                      AND #tmpAceptacionesPend.IdOTSolicitud IS NULL
                                                     THEN CASE
                                                              WHEN isnull(@pUsuarioAdincoId, 0) > 0
                                                                  THEN 'Completar'
                                                              ELSE
                                                                  ''
                                                          END
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      9
                                                                                  )
                                        THEN CASE
                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) > 0
                                                     THEN 'Completar'
                                                 ELSE
                                                     ''
                                             END
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      3, 11
                                                                                  )
                                        THEN CASE
                                                 WHEN ISNULL(@pUsuarioAdincoId, 0) > 0
                                                     THEN 'Completar'
                                                 ELSE
                                                     ''
                                             END
                                END,
                                GETDATE(),
                                0,
                                /*************USUARIO ASIGNADO***************/
                                CASE
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      1, 3, 9, 11
                                                                                  )
                                        THEN ''
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      2, 4
                                                                                  )
                                        THEN #SC_SubContratoDelProveedor.SubcontratistaRazonSocial
                                    WHEN #OT_SolicitudDelProveedor.IdOTEstatus IN (
                                                                                      5, 6
                                                                                  )
                                        THEN #SC_SubContratoDelProveedor.SubcontratistaRazonSocial
                                END,
                                petrovendor..CC_CentroCosto.CentroCosto,
                                #OT_SolicitudDelProveedor.IdOTEstatus,
                                #tmpAceptacionesSinRec.IdOTSolicitud,
                                #tmpAceptacionesSinRec.idAceptacionPedido,
                                #tmpAceptacionesPend.IdOTSolicitud,
                                #tmpEstimacionPend.IdOTSolicitud,
                                #tmpEstimacionPend.SemanaID,
                                #tmpCerrarSemanas.Fecha,
                                #tmpAceptacionesPend.IdPedido,
                                #tmpAceptacionesPend.IdPedidoGen,
                                0
                            FROM
                                #tmpOTEstatusPermitidos
                                JOIN
                                    #OT_SolicitudDelProveedor (NOLOCK)
                                        ON #tmpOTEstatusPermitidos.IdOTEstatus = #OT_SolicitudDelProveedor.IdOTEstatus
                                INNER JOIN
                                    petrovendor..CC_CentroCosto (NOLOCK)
                                        ON #OT_SolicitudDelProveedor.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto
                                INNER JOIN
                                    AP_Usuario (NOLOCK)
                                        ON #OT_SolicitudDelProveedor.CreadoPor = AP_Usuario.UsuarioId
                                           AND #OT_SolicitudDelProveedor.IsActivo = 1
                                           AND @pPend_Comp = 1
                                INNER JOIN
                                    OT_SolicitudMaterial (NOLOCK)
                                        ON #OT_SolicitudDelProveedor.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
                                INNER JOIN
                                    AP_UsuarioCentroCosto (NOLOCK)
                                        ON (
                                               @pUsuarioAdincoId IN (
                                                                        AP_UsuarioCentroCosto.IdUsuario, 9999999
                                                                    )
                                               OR @pUsuarioPetroId > 0
                                           )
                                           AND AP_UsuarioCentroCosto.IdCentroCosto IN (
                                                                                          #OT_SolicitudDelProveedor.IdCentroCosto
                                                                                      )
                                JOIN
                                    #SC_SubContratoDelProveedor
                                        ON #OT_SolicitudDelProveedor.IdSubcontrato = #SC_SubContratoDelProveedor.IdSubcontrato
                                LEFT JOIN
                                    #tmpCerrarSemanas
                                        ON OT_SolicitudMaterial.IdOTSolicitudMaterial = #tmpCerrarSemanas.IdOTSolicitudMaterial
                                LEFT JOIN
                                    #tmpEstimacionPend
                                        ON #OT_SolicitudDelProveedor.IdOTSolicitud = #tmpEstimacionPend.IdOTSolicitud
                                LEFT JOIN
                                    #tmpAceptacionesPend
                                        ON #OT_SolicitudDelProveedor.IdOTSolicitud = #tmpAceptacionesPend.IdOTSolicitud
                                LEFT JOIN
                                    #tmpAceptacionesSinRec
                                        ON #OT_SolicitudDelProveedor.IdOTSolicitud = #tmpAceptacionesSinRec.IdOTSolicitud
                            WHERE
                                @pIdContrato IN (
                                                    #SC_SubContratoDelProveedor.IdContrato, 0
                                                )
                            GROUP BY
                                #OT_SolicitudDelProveedor.Folio,
                                #OT_SolicitudDelProveedor.IdOTSolicitud,
                                #OT_SolicitudDelProveedor.IdOTEstatus,
                                #tmpCerrarSemanas.Fecha,
                                #OT_SolicitudDelProveedor.ProgIniPorProveedor,
                                AP_Usuario.Usuario,
                                #SC_SubContratoDelProveedor.SubcontratistaRazonSocial,
                                #tmpEstimacionPend.IdOTSolicitud,
                                #tmpEstimacionPend.SemanaID,
                                #tmpAceptacionesPend.IdOTSolicitud,
                                #tmpAceptacionesPend.IdPedido,
                                #tmpAceptacionesPend.IdPedidoGen,
                                #OT_SolicitudDelProveedor.IdSubcontrato,
                                #tmpAceptacionesSinRec.idPedidoGen,
                                #tmpAceptacionesSinRec.idOTSolicitud,
                                #OT_SolicitudDelProveedor.CreadoEl,
                                petrovendor..CC_CentroCosto.CentroCosto,
                                #tmpAceptacionesSinRec.idAceptacionPedido

                INSERT INTO #tmpTareasPendientesDeAprobarUsuarios
                    (
                        IdOTSolicitud,
                        UsuarioAsignado,
                        FlujoAprobacionEstatusId
                    )
                            SELECT
                                #tmpTareasPendientesDeAprobar.IdOTSolicitud,
                                ISNULL(AP_Usuario.Usuario, ''),
                                FlujoAprobacionEstatusId
                            FROM
                                #tmpTareasPendientesDeAprobar
                                INNER JOIN
                                    OT_Solicitud                      OT_Solicitud_STUFF (NOLOCK)
                                        ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                INNER JOIN
                                    AP_FlujoAprobacion (NOLOCK)
                                        ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                INNER JOIN
                                    AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios (NOLOCK)
                                        ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId IN (
                                                                                                             1, 2, 3,
                                                                                                             4, 5, 6
                                                                                                         )
                                INNER JOIN
                                    AP_Usuario (NOLOCK)
                                        ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                           AND AP_Usuario.IsActivo = 1
                                INNER JOIN
                                    AP_UsuarioCentroCosto (NOLOCK)
                                        ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                           AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                            WHERE
                                #tmpTareasPendientesDeAprobar.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                AND ISNULL(AP_Usuario.Usuario, '') <> ''
                                AND AP_Usuario.IsActivo = 1
                            GROUP BY
                                #tmpTareasPendientesDeAprobar.IdOTSolicitud,
                                AP_Usuario.Usuario,
                                FlujoAprobacionEstatusId

                INSERT INTO #tmpTareasPendientesDeAprobarUsuariosMenbers
                    (
                        IdOTSolicitud,
                        FlujoAprobacionEstatusId,
                        UsuarioAsignado
                    )
                            SELECT
                                IdOTsolicitud,
                                FlujoAprobacionEstatusId,
                                STUFF(
                                    (
                                        SELECT
                                            ', ' + UsuarioAsignado
                                        FROM
                                            #tmpTareasPendientesDeAprobarUsuarios A
                                        WHERE
                                            B.IdOTsolicitud = A.IdOTsolicitud
                                            AND B.FlujoAprobacionEstatusId = A.FlujoAprobacionEstatusId
                                        FOR XML PATH('')
                                    ), 1, 1, ''
                                     ) Members
                            FROM
                                #tmpTareasPendientesDeAprobarUsuarios B
                            GROUP BY
                                FlujoAprobacionEstatusId,
                                IdOTsolicitud

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus = 1
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 1
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus = 9
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 6
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus IN (
                                                                                    3, 11
                                                                                )
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 2
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus IN (
                                                                                    5, 6
                                                                                )
                               AND tmpAceptacionesSinRecIdOTSolicitud IS NOT NULL
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 5
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus IN (
                                                                                    5, 6
                                                                                )
                               AND tmpAceptacionesPendIdOTSolicitud IS NOT NULL
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 5
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus IN (
                                                                                    5, 6
                                                                                )
                               AND tmpEstimacionPendIdOTSolicitud IS NOT NULL
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 4
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0;

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobar.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus IN (
                                                                                    5, 6
                                                                                )
                               AND tmpCerrarSemanasFecha IS NULL
                               AND tmpEstimacionPendIdOTSolicitud IS NULL
                               AND tmpAceptacionesPendIdOTSolicitud IS NULL
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

                UPDATE
                    #tmpTareasPendientesDeAprobar
                SET
                    #tmpTareasPendientesDeAprobar.Actualizado = 1,
                    #tmpTareasPendientesDeAprobar.UsuarioAsignado = ISNULL(
                                                                              #tmpTareasPendientesDeAprobarUsuariosMenbers.UsuarioAsignado,
                                                                              ''
                                                                          )
                FROM
                    #tmpTareasPendientesDeAprobar
                    INNER JOIN
                        #tmpTareasPendientesDeAprobarUsuariosMenbers
                            ON #tmpTareasPendientesDeAprobar.IdOTSolicitud = #tmpTareasPendientesDeAprobarUsuariosMenbers.IdOTSolicitud
                               AND #tmpTareasPendientesDeAprobar.IdOTEstatus IN (
                                                                                    5, 6
                                                                                )
                               AND tmpCerrarSemanasFecha IS NOT NULL
                               AND tmpEstimacionPendIdOTSolicitud IS NULL
                               AND tmpAceptacionesPendIdOTSolicitud IS NULL
                               AND #tmpTareasPendientesDeAprobarUsuariosMenbers.FlujoAprobacionEstatusId = 3
                               AND #tmpTareasPendientesDeAprobar.Actualizado = 0

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
                            SELECT
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
                            FROM
                                #tmpTareasPendientesDeAprobar

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
                            SELECT
                                1,
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
                            FROM
                                #tmpEstimacionSinPO
                                INNER JOIN
                                    OT_Solicitud (NOLOCK)
                                        ON #tmpEstimacionSinPO.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
                                INNER JOIN
                                    petrovendor..CC_CentroCosto (NOLOCK)
                                        ON OT_Solicitud.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto

                UPDATE
                    #tmpTareasSinRelacionPedido
                SET
                    #tmpTareasSinRelacionPedido.UsuarioAsignado = ISNULL(
                                                                            STUFF(
                                                                                (
                                                                                    SELECT
                                                                                        '; '
                                                                                        + ISNULL(AP_Usuario.Usuario, '')
                                                                                    FROM
                                                                                        OT_Solicitud                          OT_Solicitud_STUFF (NOLOCK)
                                                                                        INNER JOIN
                                                                                            AP_FlujoAprobacion (NOLOCK)
                                                                                                ON AP_FlujoAprobacion.TipoFlujoAprobacionId = 1 -- Control de Obra             
                                                                                        INNER JOIN
                                                                                            AP_FlujoAprobacionEstatusUsuarios AP_FlujoAprobacionEstatusUsuarios (NOLOCK)
                                                                                                ON AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId = 6
                                                                                        INNER JOIN
                                                                                            AP_Usuario (NOLOCK)
                                                                                                ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_Usuario.UsuarioID
                                                                                                   AND AP_Usuario.Usuario IS NOT NULL
                                                                                                   AND AP_Usuario.IsActivo = 1
                                                                                        INNER JOIN
                                                                                            AP_UsuarioCentroCosto (NOLOCK)
                                                                                                ON AP_FlujoAprobacionEstatusUsuarios.UsuarioId = AP_UsuarioCentroCosto.IdUsuario
                                                                                                   AND OT_Solicitud_STUFF.IdCentroCosto = AP_UsuarioCentroCosto.IdCentroCosto
                                                                                    WHERE
                                                                                        #tmpTareasSinRelacionPedido.IdOTSolicitud = OT_Solicitud_STUFF.IdOTSolicitud
                                                                                    GROUP BY
                                                                                        AP_Usuario.Usuario
                                                                                    FOR XML PATH('')
                                                                                ), 1, 2, ''
                                                                                 ), ''
                                                                        )
                FROM
                    #tmpTareasSinRelacionPedido

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
                            SELECT
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
                            FROM
                                #tmpTareasSinRelacionPedido

                IF @pUsuarioAdincoId > 0
                    BEGIN
                        SELECT
                            @emailusuario = ISNULL(Usuario, '')
                        FROM
                            ap_usuario (NOLOCK)
                        WHERE
                            usuarioid = @pUsuarioAdincoId;

                        UPDATE
                            #tmpTareas
                        SET
                            UrlText = ''
                        WHERE
                            UsuarioAsignado NOT LIKE '%' + ISNULL(@emailusuario, '') + '%';
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
                    SELECT
                        OT_SolicitudBitacora.IdOTBitacora,
                        #OT_SolicitudDelProveedor.Folio,
                        #OT_SolicitudDelProveedor.IdOTSolicitud,
                        #OT_SolicitudDelProveedor.CreadoEl,
                        CASE
                            WHEN ISNULL(OT_SolicitudBitacora.Descripcion, '') = ''
                                THEN ''
                            ELSE
                                ISNULL(OT_SolicitudBitacora.Descripcion, '')
                        END,
                        'Completada',
                        '',
                        '',
                        OT_SolicitudBitacora.CreadoEl,
                        1,
                        CASE
                            WHEN ISNULL(OT_SolicitudBitacora.UsuarioAdincoId, 0) > 0
                                THEN ''
                            ELSE
                                #SC_SubContratoDelProveedor.SubcontratistaRazonSocial
                        END,
                        petrovendor..CC_CentroCosto.CentroCosto,
                        ISNULL(OT_SolicitudBitacora.UsuarioAdincoId, 0),
                        ISNULL(OT_SolicitudBitacora.FlujoAprobacionTareaId, 0)
                    FROM
                        #OT_SolicitudDelProveedor (NOLOCK)
                        INNER JOIN
                            petrovendor..CC_CentroCosto (NOLOCK)
                                ON #OT_SolicitudDelProveedor.IdCentroCosto = petrovendor..CC_CentroCosto.IdCentroCosto
                        INNER JOIN
                            OT_SolicitudMaterial (NOLOCK)
                                ON #OT_SolicitudDelProveedor.IdOTSolicitud = OT_SolicitudMaterial.IdOTSolicitud
                                   AND @pPend_Comp = 2
                        INNER JOIN
                            AP_UsuarioCentroCosto (NOLOCK)
                                ON (@pUsuarioAdincoId IN (
                                                             AP_UsuarioCentroCosto.IdUsuario, 0
                                                         )
                                   )
                                   AND AP_UsuarioCentroCosto.IdCentroCosto IN (
                                                                                  #OT_SolicitudDelProveedor.IdCentroCosto,
                                                                                  0
                                                                              )
                        JOIN
                            #SC_SubContratoDelProveedor
                                ON #OT_SolicitudDelProveedor.IdSubcontrato = #SC_SubContratoDelProveedor.IdSubcontrato
                        INNER JOIN
                            OT_SolicitudBitacora (NOLOCK)
                                ON #OT_SolicitudDelProveedor.IdOTSolicitud = OT_SolicitudBitacora.IdOTSolicitud
                                   AND OT_SolicitudBitacora.CreadoEl >= DATEADD(DAY, -15, GETDATE())
                    WHERE
                        @pIdContrato IN (
                                            #SC_SubContratoDelProveedor.IdContrato, 0
                                        )
                        AND #OT_SolicitudDelProveedor.IsActivo = 1
                    GROUP BY
                        OT_SolicitudBitacora.UsuarioAdincoId,
                        #SC_SubContratoDelProveedor.SubcontratistaRazonSocial,
                        #OT_SolicitudDelProveedor.Folio,
                        #OT_SolicitudDelProveedor.IdOTSolicitud,
                        #OT_SolicitudDelProveedor.CreadoEl,
                        OT_SolicitudBitacora.Descripcion,
                        OT_SolicitudBitacora.CreadoEl,
                        OT_SolicitudBitacora.IdOTBitacora,
                        petrovendor..CC_CentroCosto.CentroCosto,
                        ISNULL(OT_SolicitudBitacora.UsuarioAdincoId, 0),
                        ISNULL(OT_SolicitudBitacora.FlujoAprobacionTareaId, 0)
                    ORDER BY
                        OT_SolicitudBitacora.CreadoEl DESC
        /*Se sacaron los left joins*/
        UPDATE
            #tmpTareasCompletadas
        SET
            #tmpTareasCompletadas.UsuarioAsignado = AP_Usuario.Usuario
        FROM
            #tmpTareasCompletadas
            INNER JOIN
                AP_Usuario (NOLOCK)
                    ON ISNULL(#tmpTareasCompletadas.UsuarioAdincoId, 0) > 0
                       AND #tmpTareasCompletadas.UsuarioAdincoId = AP_Usuario.UsuarioId

        UPDATE
            #tmpTareasCompletadas
        SET
            #tmpTareasCompletadas.Tarea = AP_FlujoAprobacion_Tareas.Descripcion
        FROM
            #tmpTareasCompletadas
            INNER JOIN
                AP_FlujoAprobacion_Tareas (NOLOCK)
                    ON ISNULL(#tmpTareasCompletadas.FlujoAprobacionTareaId, 0) > 0
                       AND #tmpTareasCompletadas.Tarea = ''
                       AND #tmpTareasCompletadas.FlujoAprobacionTareaId = AP_FlujoAprobacion_Tareas.FlujoAprobacionTareaId;

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
                    SELECT
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
                    FROM
                        #tmpTareasCompletadas


        SELECT
            *
        FROM
            #tmpTareas
        ORDER BY
            UrlText DESC,
            FechaRegistro DESC,
            FechaCompletada DESC,
            Folio
    END
