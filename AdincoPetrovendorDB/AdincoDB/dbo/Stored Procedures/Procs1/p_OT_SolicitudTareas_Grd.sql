-- p_OT_SolicitudTareas_Grd 10038,10,0,1,1445
CREATE Proc [dbo].[p_OT_SolicitudTareas_Grd]
    @pIdContrato int,
    @pUsuarioAdincoId int,
    @pUsuarioPetroId int,
    @pPend_Comp int, --0 ambas, 1 pendientes, 2 completadas
    @pIdProveedor int = 0
as
BEGIN

    declare @emailUsuario varchar(50)

    create table #tmpTareas
    (
        IdOTTarea int,
        Folio varchar(250),
        IdOTSolicitud int,
        FechaRegistro datetime,
        Tarea varchar(300),
        Estatus varchar(50),
        Url varchar(500),
        UrlText varchar(100),
        FechaCompletada DateTime,
        Completada bit,
        UsuarioAsignado varchar(5000),
        CentroCosto varchar(250)
    )

    /*PRODUCCIÓN*/
    --declare @dominioAdinco varchar(100)='https://adinco.mx',
    --		@dominioPetrovendor varchar(100)='https://petrovendor.com.mx',
    --		@dominioProcura varchar(100)='https://procura.adinco.mx/'


    /*QA
	declare @dominioAdinco varchar(100)='http://mpyadinco.adinco.mx',
			@dominioPetrovendor varchar(100)='http://mpypetrovendor.adinco.mx',
			@dominioProcura varchar(100)= 'https://MPYprocura.adinco.mx'
*/


    /*DEV*/
    declare @dominioAdinco varchar(100) = 'http://localhost:52692/',      -- https://adinco.mx
            @dominioPetrovendor varchar(100) = 'http://localhost:58935/', --https://petrovendor.com.mx
            @dominioProcura varchar(100) = 'http://localhost:58936/'      -- https://procura.adinco.mx


    if @pPend_Comp = 1
    Begin

        create table #tmpCerrarSemanas
        (
            IdOTSolicitud int,
            IdOTSolicitudMaterial INT,
            Fecha datetime,
            IdOTSolicitudProgramaCaptura int
        )

        --SEMANAS QUE FALTAN CERRAR
        INSERT INTO #tmpCerrarSemanas
        (
            IdOTSolicitud,
            IdOTSolicitudMaterial,
            Fecha,
            IdOTSolicitudProgramaCaptura
        )
        select ot.IdOTSolicitud,
               otm.IdOTSolicitudMaterial,
               spc.Fecha,
               spc.IdOTSolicitudProgramaCaptura
        from OT_Solicitud OT (NOLOCK)
            inner join OT_SolicitudMaterial otm (NOLOCK)
                on otm.IdOTSolicitud = ot.IdOTSolicitud
                   AND ot.IsActivo = 1
            inner join SC_Subcontrato sc (NOLOCK)
                on sc.IdSubcontrato = ot.IdSubcontrato
                   AND SC.IDContrato = @pIdContrato
            inner join [dbo].[OT_SolicitudProgramaCaptura] spc (NOLOCK)
                on spc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
                   and spc.VoBoSubcontratista = 1
        where ot.IsActivo = 1
              AND SC.IDContrato = @pIdContrato
              and not exists
        (
            select 1
            from [dbo].OT_ProgramaSemanaCerrada e
            where e.IdOTSolicitud = ot.IdOTSolicitud
                  and spc.Fecha
                  between e.FechaSemanaIni and e.FechaSemanaFin
                  and e.isActivo = 1
        )
        group by ot.IdOTSolicitud,
                 otm.IdOTSolicitudMaterial,
                 spc.Fecha,
                 spc.IdOTSolicitudProgramaCaptura



        --SEMANAS QUE FALTAN ESTIMAR
        CREATE TABLE #tmpEstimacionPend
        (
            IdOTSolicitud INT,
            IdOTSolicitudMaterial INT,
            SemanaID VARCHAR(21)
        )

        INSERT INTO #tmpEstimacionPend
        (
            IdOTSolicitud,
            IdOTSolicitudMaterial,
            SemanaID
        )
        select ot.IdOTSolicitud,
               otm.IdOTSolicitudMaterial,
               e.SemanaID
        from OT_Solicitud OT (NOLOCK)
            inner join OT_SolicitudMaterial otm (NOLOCK)
                on otm.IdOTSolicitud = ot.IdOTSolicitud
                   AND ot.IsActivo = 1
            inner join SC_Subcontrato sc (NOLOCK)
                on sc.IdSubcontrato = ot.IdSubcontrato
            inner join [dbo].[OT_SolicitudProgramaCaptura] spc (NOLOCK)
                on spc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
                   and spc.VoBoSubcontratista = 1
                   AND SPC.VoBoContratista = 1
            inner join OT_ProgramaSemanaCerrada e (NOLOCK)
                on e.IdOTSolicitud = ot.IdOTSolicitud
                   and spc.Fecha
                   between e.FechaSemanaIni and e.FechaSemanaFin
                   and e.isActivo = 1
        where ot.IsActivo = 1
              AND SC.IDContrato = @pIdContrato
              and not exists
        (
            select 1
            from [dbo].OT_Estimacion e
            where e.IdOTSolicitud = ot.IdOTSolicitud
                  and spc.Fecha
                  between e.FechaCorteInicio and e.FechaCorteFin
                  and isnull(e.Cancelada, 0) = 0
        )
        group by ot.IdOTSolicitud,
                 otm.IdOTSolicitudMaterial,
                 e.SemanaID



        --Estimaciones sin aceptacion
        CREATE TABLE #tmpAceptacionesPend
        (
            IdOTEstimacion INT,
            IdOTSolicitud INT,
            IdPedido INT,
            IdPedidoGen INT
        )

        INSERT INTO #tmpAceptacionesPend
        (
            IdOTEstimacion,
            IdOTSolicitud,
            IdPedido,
            IdPedidoGen
        )
        select e.IdOTEstimacion,
               e.IdOTSolicitud,
               idPedido = e.IdPedido,
               idPedidoGen = e.IdPedidoGeneral
        from OT_Estimacion e (NOLOCK)
            inner join OT_Solicitud ot (NOLOCK)
                on ot.IdOTSolicitud = e.IdOTSolicitud
            inner join SC_Subcontrato sc (NOLOCK)
                on sc.IdSubcontrato = ot.IdSubcontrato
        where sc.IdContrato = @pIdContrato
              and not exists
        (
            select 1
            from Petrovendor..MM_AceptacionPedido p
            where p.IdPedido = e.IdPedido
        )
              and isnull(e.cancelada, 0) = 0
        group by e.IdOTEstimacion,
                 e.IdPedido,
                 e.IdPedidoGeneral,
                 e.IdOTSolicitud

        --Aceptaciones sin reclasificacion
        CREATE TABLE #tmpAceptacionesSinRec
        (
            IdOTEstimacion INT,
            IdOTSolicitud INT,
            IdPedido INT,
            idPedidoGen INT,
            IdAceptacionPedido INT
        )

        INSERT INTO #tmpAceptacionesSinRec
        (
            IdOTEstimacion,
            IdOTSolicitud,
            IdPedido,
            idPedidoGen,
            IdAceptacionPedido
        )
        select e.IdOTEstimacion,
               e.IdOTSolicitud,
               idPedido = e.IdPedido,
               idPedidoGen = e.IdPedidoGeneral,
               ap.idAceptacionPedido
        from OT_Estimacion e (NOLOCK)
            inner join OT_Solicitud ot (NOLOCK)
                on ot.IdOTSolicitud = e.IdOTSolicitud
            inner join SC_Subcontrato sc (NOLOCK)
                on sc.IdSubcontrato = ot.IdSubcontrato
                   AND sc.IdContrato = @pIdContrato
            inner join petrovendor..MM_AceptacionPedido ap (NOLOCK)
                on ap.IdPedido = e.IdPedido
                   and ap.ModificadoPor is null
        where sc.IdContrato = @pIdContrato
              and not exists
        (
            select 1
            from petrovendor..[MM_AceptacionPedidoDetalleEliminada] sae
            where sae.IdAceptacionPedido = ap.idAceptacionPedido
        )
              and not exists
        (
            select 1
            from petrovendor..MM_AceptacionFactura saf
            where saf.IdAceptacionPedido = ap.idAceptacionPedido
        )
              and isnull(e.Cancelada, 0) = 0
        group by e.IdOTEstimacion,
                 e.IdPedido,
                 e.IdPedidoGeneral,
                 e.IdOTSolicitud,
                 ap.idAceptacionPedido

        --ISSUE 1018. Generar info de Estimaciones sin PO
        CREATE TABLE #tmpEstimacionSinPO
        (
            IdOTSolicitud INT,
            IdOTEstimacion INT,
            IdPedidoGeneral INT,
            CreadoEl DATETIME
        )


        INSERT INTO #tmpEstimacionSinPO
        (
            IdOTSolicitud,
            IdOTEstimacion,
            IdPedidoGeneral,
            CreadoEl
        )
        select e.IdOTSolicitud,
               e.IdOTEstimacion,
               e.IdPedidoGeneral,
               e.CreadoEl
        from OT_Estimacion e (NOLOCK)
            inner join OT_Solicitud ot (NOLOCK)
                on ot.IdOTSolicitud = E.IdOTSolicitud
                   AND isnull(e.Cancelada, 0) = 0
            INNER JOIN SC_SubContrato sc (NOLOCK)
                on sc.IdSubContrato = ot.IdSubContrato
                   and sc.IdContrato = @pIdContrato
            left join petrovendor..DEA_Relacion_PR_PO po (NOLOCK)
                on po.IdPedido = e.IdPedido
        where isnull(e.Cancelada, 0) = 0
              and po.IdPedido is null
        group by e.IdOTSolicitud,
                 e.IdOTEstimacion,
                 e.IdPedidoGeneral,
                 e.CreadoEl


        --usuarios OT
        CREATE TABLE #tmpOTUsuarios
        (
            UsuarioID INT,
            Usuario VARCHAR(500),
            FlujoAprobacionEstatusId INT,
            IdOTSolicitud INT
        )


        INSERT INTO #tmpOTUsuarios
        (
            UsuarioID,
            Usuario,
            FlujoAprobacionEstatusId,
            IdOTSolicitud
        )
        select u.UsuarioID,
               u.Usuario,
               fu.FlujoAprobacionEstatusId,
               ot.IdOTSolicitud
        from OT_Solicitud ot (NOLOCK)
            inner join [dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK)
                on ucc.IdCentroCosto = ot.IdCentroCosto
            inner join AP_Usuario u (NOLOCK)
                on u.usuarioId = ucc.IdUsuario
            inner join [dbo].[AP_FlujoAprobacionEstatusUsuarios] fu (NOLOCK)
                on fu.UsuarioId = u.usuarioId
        group by u.UsuarioID,
                 u.Usuario,
                 fu.FlujoAprobacionEstatusId,
                 ot.IdOTSolicitud

        --OT's pendientes de aprobar
        insert into #tmpTareas
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
        select 1,
               ot.Folio,
               ot.IdOTSolicitud,
               ot.CreadoEl,
               /*********ESTATUS TAREA***************/
               case
                   when ot.IdOTEstatus = 1 then
                       case
                           when ot.ProgIniPorProveedor = 0 then
                               'Operadora - Pendiente de Enviar a Manager'
                           when ot.ProgIniPorProveedor = 1 then
                               'Operadora - Pendiente de Enviar a Proveedor'
                       end
                   when ot.IdOTEstatus in ( 2, 4 ) then
                       'Proveedor - Revisión de OT'
                   when ot.IdOTEstatus in ( 5, 6 ) then
                       case
                           when aPendRec.IdOTSolicitud is not null then
                               'Operadora - Reclasificar Aceptación ' + cast(aPendRec.idAceptacionPedido as varchar)
                               + ' en Procura '
                           when aPend.IdOTSolicitud is not null then
                               'Operadora - Generar Aceptación en Procura '
                           when ePend.IdOTSolicitud is not null then
                               'Operadora - Generar Estimación para semana ' + ePend.SemanaID
                           when tmp2.Fecha is null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               'Proveedor - Capturar Avance '
                           when tmp2.Fecha is not null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               'Operadora - Revisar y cerrar semana para fecha:' + convert(varchar, tmp2.Fecha, 103)
                       end
                   when ot.IdOTEstatus IN ( 9 ) then
                       'Operadora - Revisar convenio en Procura'
                   when ot.IdOTEstatus IN ( 3, 11 ) then
                       'Operadora - Aprobar OT por Manager'
               end,
               'Pendiente',
               /************URL ACCIÓN**********/
               case
                   when ot.IdOTEstatus = 1 then
                       @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                       + cast(ot.IdOTSolicitud as varchar)
                   when ot.IdOTEstatus in ( 2, 4 ) then
                       @dominioPetrovendor + '/02Proveedores/RegistrarOTSolicitudProv.aspx?id='
                       + cast(ot.IdOTSolicitud as varchar)
                   when ot.IdOTEstatus in ( 5, 6 ) then
                       case
                           when aPendRec.IdOTSolicitud is not null then
                               @dominioProcura + '/01Proveedores/APListaReclasificacion.aspx'
                           when aPend.IdOTSolicitud is not null then
                               @dominioProcura + '/02Proveedores/AceptacionPedido.aspx?ped='
                               + cast(aPend.IdPedido as varchar) + '&pedgral=' + cast(aPend.IdPedidoGen as varchar)
                               + '&ori=pedido'
                           when ePend.IdOTSolicitud is not null then
                               @dominioAdinco + '/2/OrdenTrabajo/GenerarEstimacionOT.aspx?id1='
                               + cast(ot.IdOTSolicitud as varchar)
                           when tmp2.Fecha is null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               @dominioPetrovendor + '/02Proveedores/CapturaProgramaOT.aspx?id='
                               + cast(ot.IdOTSolicitud as varchar)
                           when tmp2.Fecha is not null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               @dominioAdinco + '/2/OrdenTrabajo/CapturaProgramaOT.aspx?id='
                               + cast(ot.IdOTSolicitud as varchar)
                       end
                   when ot.IdOTEstatus IN ( 9 ) then
                       @dominioProcura + '/02Proveedores/ActualizarSCOTConvenio.aspx?id='
                       + cast(ot.IdSubcontrato as varchar) + '&id2=' + cast(ot.IdOTSolicitud as varchar)
                   when ot.IdOTEstatus IN ( 3, 11 ) then
                       @dominioAdinco + '/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id='
                       + cast(ot.IdOTSolicitud as varchar)
               end,
               /**********Url Text*************/
               case
                   when ot.IdOTEstatus = 1 then
                       case
                           when @pUsuarioAdincoId > 0 then
                               'Completar'
                           else
                               ''
                       end
                   when ot.IdOTEstatus in ( 2, 4 ) then
                       case
                           when isnull(@pUsuarioAdincoId, 0) = 0 then
                               'Completar'
                           else
                               ''
                       end
                   when ot.IdOTEstatus in ( 5, 6 ) then
                       case
                           when aPendRec.IdOTSolicitud is not null then
                               case
                                   when isnull(@pUsuarioAdincoId, 0) > 0 then
                                       'Completar'
                                   else
                                       ''
                               end
                           when aPend.IdOTSolicitud is not null then
                               case
                                   when isnull(@pUsuarioAdincoId, 0) > 0 then
                                       'Completar'
                                   else
                                       ''
                               end
                           when ePend.IdOTSolicitud is not null then
                               case
                                   when isnull(@pUsuarioAdincoId, 0) > 0 then
                                       'Completar'
                                   else
                                       ''
                               end
                           when tmp2.Fecha is null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               case
                                   when isnull(@pUsuarioAdincoId, 0) = 0 then
                                       'Completar'
                                   else
                                       ''
                               end
                           when tmp2.Fecha is not null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               case
                                   when isnull(@pUsuarioAdincoId, 0) > 0 then
                                       'Completar'
                                   else
                                       ''
                               end
                       end
                   when ot.IdOTEstatus IN ( 9 ) then
                       case
                           when isnull(@pUsuarioAdincoId, 0) > 0 then
                               'Completar'
                           else
                               ''
                       end
                   when ot.IdOTEstatus IN ( 3, 11 ) then
                       case
                           when isnull(@pUsuarioAdincoId, 0) > 0 then
                               'Completar'
                           else
                               ''
                       end
               end,
               getdate(),
               0,
               /*************USUARIO ASIGNADO***************/
               case
                   when ot.IdOTEstatus = 1 then
                       [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 1, 0)
                   when ot.IdOTEstatus in ( 2, 4 ) then
                       pv.RazonSocial
                   when ot.IdOTEstatus in ( 5, 6 ) then
                       case
                           when aPendRec.IdOTSolicitud is not null then
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 5, 0)
                           when aPend.IdOTSolicitud is not null then
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 5, 0)
                           when ePend.IdOTSolicitud is not null then
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 4, 0)
                           when tmp2.Fecha is null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               pv.RazonSocial
                           when tmp2.Fecha is not null
                                and ePend.IdOTSolicitud is null
                                and aPend.IdOTSolicitud is null then
                               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 3, 0)
                       end
                   when ot.IdOTEstatus IN ( 9 ) then
                       [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 6, 0)
                   when ot.IdOTEstatus IN ( 3, 11 ) then
                       [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 2, 0)
               end,
               cc.CentroCosto
        from OT_Solicitud ot (NOLOCK)
            inner join petrovendor..CC_CentroCosto cc (NOLOCK)
                on cc.IdCentroCosto = ot.IdCentroCosto
            inner join AP_Usuario uot (NOLOCK)
                on uot.UsuarioId = ot.CreadoPor
                   and ot.IsActivo = 1
                   aND @pPend_Comp = 1
                   and (
                           (
                               ot.IdOTEstatus not in ( 7, 8, 12 )
                               and @pUsuarioAdincoId > 0
                           )
                           OR (
                                  ot.IdOTEstatus not in ( 1, 7, 8, 12 )
                                  and isnull(@pUsuarioAdincoId, 0) = 0
                              )
                           OR (
                                  ot.IdOTEstatus not in ( 7, 8, 12 )
                                  and @pUsuarioPetroId > 0
                              )
                       )
            inner join OT_SolicitudMaterial otm (NOLOCK)
                on otm.IdOTSolicitud = ot.IdOTSolicitud
            inner join [dbo].[AP_UsuarioCentroCosto] ucc
                on (
                       @pUsuarioAdincoId in ( ucc.IdUsuario, 9999999 )
                       OR @pUsuarioPetroId > 0
                   )
                   and ucc.IdCentroCosto in ( ot.IdCentroCosto )
            inner join SC_Subcontrato sc (NOLOCK)
                on sc.IdSubcontrato = ot.IdSubcontrato
            inner join PV_Subcontratista pv (NOLOCK)
                on pv.IdSubcontratista = sc.IdSubcontratista
            inner join petrovendor..S_Proveedor prov (NOLOCK)
                on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = pv.RFC collate SQL_Latin1_General_CP1_CI_AS
                   and @pIdProveedor in ( 0, prov.IdProveedor )
            left join #tmpOTUsuarios u
                on u.IdOTSolicitud = ot.IdOTSolicitud
            left join #tmpCerrarSemanas tmp2
                on tmp2.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
            left join #tmpEstimacionPend ePend
                on ePend.IdOTSolicitud = ot.IdOTSolicitud
            left join #tmpAceptacionesPend aPend
                on aPend.IdOTSolicitud = ot.IdOTSolicitud
            left join #tmpAceptacionesSinRec aPendRec
                on aPendRec.IdOTSolicitud = ot.IdOTSolicitud
        where @pIdContrato in ( sc.IdContrato, 0 )
        group by ot.Folio,
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

        --ISSUE 1018 OT's sin relación Pedido - PO. Se agrega tarea para Relacionar Pedido-PO
        insert into #tmpTareas
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
        select 1,
               ot.Folio,
               ot.IdOTSolicitud,
               e.CreadoEl,
               'Operadora - Relacionar Pedido:' + cast(e.IdPedidoGeneral as varchar) + ' con PO en Procura',
               'Pendiente',
               @dominioProcura + '/DEA/Relacion_PR_PO.aspx',
               'Completar',
               null,
               0,
               [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud, 0, 6, 0),
               cc.CentroCosto
        from #tmpEstimacionSinPO e
            inner join OT_Solicitud ot
                on ot.IdOTSolicitud = e.IdOTSolicitud
            inner join petrovendor..CC_CentroCosto cc
                on cc.IdCentroCosto = ot.IdCentroCosto

        --order by ot.CreadoEl desc

        if @pUsuarioAdincoId > 0
        begin
            select @emailusuario = isnull(Usuario, '')
            from ap_usuario
            where usuarioid = @pUsuarioAdincoId

            update #tmpTareas
            set UrlText = ''
            where UsuarioAsignado not like '%' + isnull(@emailusuario, '') + '%'

        end
    End

    --OT's tareas completadas
    insert into #tmpTareas
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
    select sb.IdOTBitacora,
           ot.Folio,
           ot.IdOTSolicitud,
           ot.CreadoEl,
           case
               when isnull(sb.Descripcion, '') = '' then
                   t.Descripcion
               else
                   isnull(sb.Descripcion, '')
           end,
           'Completada',
           '',
           '',
           sb.CreadoEl,
           1,
           CASE
               WHEN isnull(sb.UsuarioAdincoId, 0) > 0 then
                   u.Usuario
               else
                   pv.RazonSocial
           end,
           cc.CentroCosto
    from OT_Solicitud ot (NOLOCK)
        inner join petrovendor..CC_CentroCosto cc (NOLOCK)
            on cc.IdCentroCosto = ot.IdCentroCosto
        inner join OT_SolicitudMaterial otm (NOLOCK)
            on otm.IdOTSolicitud = ot.IdOTSolicitud
               aND @pPend_Comp = 2
        inner join [dbo].[AP_UsuarioCentroCosto] ucc (NOLOCK)
            on (@pUsuarioAdincoId in ( ucc.IdUsuario, 0 ))
               and ucc.IdCentroCosto in ( ot.IdCentroCosto, 0 )
        inner join SC_Subcontrato sc (NOLOCK)
            on sc.IdSubcontrato = ot.IdSubcontrato
        inner join PV_Subcontratista pv (NOLOCK)
            on pv.IdSubcontratista = sc.IdSubcontratista
        inner join petrovendor..S_Proveedor prov (NOLOCK)
            on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = pv.RFC collate SQL_Latin1_General_CP1_CI_AS
               and @pIdProveedor in ( 0, prov.IdProveedor )
        inner join OT_SolicitudBitacora sb (NOLOCK)
            on sb.IdOTSolicitud = ot.IdOTSolicitud
               and sb.CreadoEl >= dateadd(day, -15, getdate())
        left join AP_Usuario u (NOLOCK)
            on u.UsuarioId = sb.UsuarioAdincoId
        left join [AP_FlujoAprobacion_Tareas] t
            on t.FlujoAprobacionTareaId = sb.FlujoAprobacionTareaId
    where @pIdContrato in ( sc.IdContrato, 0 )
          and ot.IsActivo = 1
    group by sb.UsuarioAdincoId,
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
    order by sb.CreadoEl desc

    --update #tmpTareas
    --set UsuarioAsignado = replace(replace(replace(UsuarioAsignado,'daniel.moreno@adinco.mx',''),'juventino.sanchez@wintershalldea.com',''),'yazmin.gonzalez@ogss.com.mx','')
	
    select *
    from #tmpTareas
    order by UrlText desc,
             FechaRegistro desc,
             FechaCompletada desc,
             Folio
END