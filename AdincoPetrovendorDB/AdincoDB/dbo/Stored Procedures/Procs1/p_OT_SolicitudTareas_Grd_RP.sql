-- p_OT_SolicitudTareas_Grd 10038,10,0,1,0
CREATE Proc p_OT_SolicitudTareas_Grd_RP
@pIdContrato int = 0,
@pUsuarioAdincoId int =0,
@pUsuarioPetroId int =2520,
@pPend_Comp int =1, --0 ambas, 1 pendientes, 2 completadas
@pIdProveedor int=3435
as
begin
	print 'being p_OT_SolicitudTareas_Grd'
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
	declare @dominioAdinco varchar(100)='https://adinco.mx',
			@dominioPetrovendor varchar(100)='https://petrovendor.com.mx',
			@dominioProcura varchar(100)='https://procura.adinco.mx/'


	/*QA
	declare @dominioAdinco varchar(100)='http://mpyadinco.adinco.mx',
			@dominioPetrovendor varchar(100)='http://mpypetrovendor.adinco.mx',
			@dominioProcura varchar(100)= 'https://MPYprocura.adinco.mx'
*/
			

	/*DEV
	declare @dominioAdinco varchar(100)='http://localhost:52692/', -- https://adinco.mx
			@dominioPetrovendor varchar(100)='http://localhost:58935/', --https://petrovendor.com.mx
			@dominioProcura varchar(100)='http://localhost:58936/' -- https://procura.adinco.mx
*/

	if @pPend_Comp = 1
	Begin

	--SEMANAS QUE FALTAN CERRAR
	select		ot.IdOTSolicitud,
				otm.IdOTSolicitudMaterial, 
				spc.Fecha,
				spc.IdOTSolicitudProgramaCaptura
	into		#tmpCerrarSemanas
	from		OT_Solicitud OT
	inner join	OT_SolicitudMaterial				otm on	otm.IdOTSolicitud			= ot.IdOTSolicitud	
	inner join	SC_Subcontrato						sc	on	sc.IdSubcontrato			= ot.IdSubcontrato	
	inner join	[dbo].[OT_SolicitudProgramaCaptura] spc on	spc.IdOTSolicitudMaterial	= otm.IdOTSolicitudMaterial and
															spc.VoBoSubcontratista		=	1 
	where		ot.IsActivo		=	1 
	AND			SC.IDContrato	=	@pIdContrato 
	and
				not exists (
					select 1
					from [dbo].OT_ProgramaSemanaCerrada e
					where e.IdOTSolicitud = ot.IdOTSolicitud and
					spc.Fecha between e.FechaSemanaIni and e.FechaSemanaFin and e.isActivo = 1
				)
	group by	ot.IdOTSolicitud,
				otm.IdOTSolicitudMaterial, 
				spc.Fecha,
				spc.IdOTSolicitudProgramaCaptura

	declare @countmpCerrarSemanas int  select @countmpCerrarSemanas = count(*) from #tmpCerrarSemanas  print '#tmpCerrarSemanas = ' + cast( @countmpCerrarSemanas as varchar(10) )

	--SEMANAS QUE FALTAN ESTIMAR

	select ot.IdOTSolicitud,otm.IdOTSolicitudMaterial, e.SemanaID
	into #tmpEstimacionPend
	from OT_Solicitud OT
	inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud	
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato	
	inner join [dbo].[OT_SolicitudProgramaCaptura] spc on spc.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial and
												spc.VoBoSubcontratista = 1 AND SPC.VoBoContratista = 1
	inner join OT_ProgramaSemanaCerrada e on  e.IdOTSolicitud = ot.IdOTSolicitud and
												spc.Fecha between e.FechaSemanaIni and e.FechaSemanaFin and e.isActivo = 1
	where ot.IsActivo = 1 AND
	SC.IDContrato = @pIdContrato and
	not exists (
		select 1
		from [dbo].OT_Estimacion e
		where e.IdOTSolicitud = ot.IdOTSolicitud and
		spc.Fecha between e.FechaCorteInicio and e.FechaCorteFin and
		isnull(e.Cancelada,0) = 0
	)
	group by  ot.IdOTSolicitud,otm.IdOTSolicitudMaterial, e.SemanaID

	declare @countmpEstimacionPend int  select @countmpEstimacionPend = count(*) from #tmpEstimacionPend  print '#tmpEstimacionPend = ' + cast( @countmpEstimacionPend as varchar(10) )

	--Estimaciones sin aceptacion
	select e.IdOTEstimacion,
		e.IdOTSolicitud,
		idPedido = e.IdPedido,
		idPedidoGen = e.IdPedidoGeneral
	into #tmpAceptacionesPend
	from OT_Estimacion e
	inner join OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato
	where sc.IdContrato = @pIdContrato and
	not exists (
		select 1
		from Petrovendor..MM_AceptacionPedido p 
		where p.IdPedido = e.IdPedido
	) and
	isnull(e.cancelada,0) = 0
	group by e.IdOTEstimacion,
		 e.IdPedido,
		e.IdPedidoGeneral,e.IdOTSolicitud

	declare @countmpAceptacionesPend int  select @countmpAceptacionesPend = count(*) from #tmpAceptacionesPend  print '#tmpAceptacionesPend = ' + cast( @countmpEstimacionPend as varchar(10) )

	--Aceptaciones sin reclasificacion
	select e.IdOTEstimacion,
		e.IdOTSolicitud,
		idPedido = e.IdPedido,
		idPedidoGen = e.IdPedidoGeneral,
		ap.idAceptacionPedido
	into #tmpAceptacionesSinRec
	from OT_Estimacion e
	inner join OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato
	inner join petrovendor..MM_AceptacionPedido ap on ap.IdPedido = e.IdPedido and
										ap.ModificadoPor is null
	where sc.IdContrato = @pIdContrato and not exists (
		select 1
		from petrovendor..[MM_AceptacionPedidoDetalleEliminada] sae
		where sae.IdAceptacionPedido = ap.idAceptacionPedido
	)
	and not exists (
		select 1
		from petrovendor..MM_AceptacionFactura saf
		where saf.IdAceptacionPedido = ap.idAceptacionPedido
	)
	and isnull(e.Cancelada,0) = 0
	group by e.IdOTEstimacion,
		 e.IdPedido,
		e.IdPedidoGeneral,e.IdOTSolicitud,
		ap.idAceptacionPedido

	declare @countmpAceptacionesSinRec int  select @countmpAceptacionesSinRec = count(*) from #tmpAceptacionesSinRec  print '#tmpAceptacionesSinRec = ' + cast( @countmpAceptacionesSinRec as varchar(10) )

	--ISSUE 1018. Generar info de Estimaciones sin PO
	select e.IdOTSolicitud,e.IdOTEstimacion,e.IdPedidoGeneral,e.CreadoEl
	into #tmpEstimacionSinPO
	from OT_Estimacion e	
	inner join OT_Solicitud ot on ot.IdOTSolicitud = E.IdOTSolicitud
	inner JOIN SC_SubContrato sc on sc.IdSubContrato = ot.IdSubContrato and
							sc.IdContrato = @pIdContrato
	inner join petrovendor..DEA_Relacion_PR_PO po on po.IdPedido = e.IdPedido
	where isnull(e.Cancelada,0) = 0 and
	po.IdPedido is null
	group by e.IdOTSolicitud,e.IdOTEstimacion,e.IdPedidoGeneral,e.CreadoEl
	
	declare @countmpEstimacionSinPO int  select @countmpEstimacionSinPO = count(*) from #tmpEstimacionSinPO  print '#tmpEstimacionSinPO = ' + cast( @countmpEstimacionSinPO as varchar(10) )

	--usuarios OT
	select u.UsuarioID,u.Usuario,fu.FlujoAprobacionEstatusId,ot.IdOTSolicitud
	into #tmpOTUsuarios
	from OT_Solicitud ot
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdCentroCosto = ot.IdCentroCosto
	inner join AP_Usuario u on u.usuarioId = ucc.IdUsuario
	inner join [dbo].[AP_FlujoAprobacionEstatusUsuarios] fu on fu.UsuarioId = u.usuarioId
	group by u.UsuarioID,u.Usuario,fu.FlujoAprobacionEstatusId,ot.IdOTSolicitud

	declare @countmpOTUsuarios int  select @countmpOTUsuarios = count(*) from #tmpOTUsuarios  print '#tmpOTUsuarios = ' + cast( @countmpOTUsuarios as varchar(10) )

	--OT's pendientes de aprobar
	--insert into #tmpTareas(
	--IdOTTarea,		Folio,		IdOTSolicitud,	FechaRegistro,
	--Tarea,			Estatus,	Url,			UrlText,
	--FechaCompletada,Completada, UsuarioAsignado,	CentroCosto)
	select  prov.RFC , pv.RFC , prov.IdProveedor, pv.IdSubcontratista,
		1,			ot.Folio,	ot.IdOTSolicitud,	ot.CreadoEl,
		/*********ESTATUS TAREA***************/
		case 
				when ot.IdOTEstatus = 1 then 
								case	
										when ot.ProgIniPorProveedor = 0 then 'Operadora - Pendiente de Enviar a Manager' 
										when ot.ProgIniPorProveedor = 1 then 'Operadora - Pendiente de Enviar a Proveedor' 
								end
				when ot.IdOTEstatus in( 2,4) then 'Proveedor - Revisión de OT'
				when ot.IdOTEstatus in (5,6) then
						case
							 when  aPendRec.IdOTSolicitud is not null then 'Operadora - Reclasificar Aceptación '+cast(aPendRec.idAceptacionPedido as varchar)+' en Procura '
							 when  aPend.IdOTSolicitud is not null then 'Operadora - Generar Aceptación en Procura '
							 when  ePend.IdOTSolicitud is not null then 'Operadora - Generar Estimación para semana '+ ePend.SemanaID
							when tmp2.Fecha is null and ePend.IdOTSolicitud is null and aPend.IdOTSolicitud is null  then 'Proveedor - Capturar Avance '							
							when tmp2.Fecha is not null and ePend.IdOTSolicitud is null  and aPend.IdOTSolicitud is null then 'Operadora - Revisar y cerrar semana para fecha:'+ convert(varchar,tmp2.Fecha,103)
							
							
							
						end
				when ot.IdOTEstatus IN(9) then 'Operadora - Revisar convenio en Procura' 
				when ot.IdOTEstatus IN(3, 11) then 'Operadora - Aprobar OT por Manager' 
				
		end,		'Pendiente', 
		/************URL ACCIÓN**********/
		case 
				when ot.IdOTEstatus = 1 then @dominioAdinco+'/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id=' +cast( ot.IdOTSolicitud as varchar)
				when ot.IdOTEstatus in( 2,4) then @dominioPetrovendor+'/02Proveedores/RegistrarOTSolicitudProv.aspx?id=' +cast( ot.IdOTSolicitud as varchar)
				when ot.IdOTEstatus in (5,6) then
						case 
							when  aPendRec.IdOTSolicitud is not null then @dominioProcura+'/01Proveedores/APListaReclasificacion.aspx'
							when  aPend.IdOTSolicitud is not null then @dominioProcura+'/02Proveedores/AceptacionPedido.aspx?ped='+cast(aPend.IdPedido as varchar)+'&pedgral='+cast(aPend.IdPedidoGen as varchar)+'&ori=pedido'
							when  ePend.IdOTSolicitud is not null then @dominioAdinco+'/2/OrdenTrabajo/GenerarEstimacionOT.aspx?id1='+cast( ot.IdOTSolicitud as varchar)
						
							when tmp2.Fecha is null and ePend.IdOTSolicitud is null and aPend.IdOTSolicitud is null then @dominioPetrovendor+'/02Proveedores/CapturaProgramaOT.aspx?id=' +cast( ot.IdOTSolicitud as varchar)
							when tmp2.Fecha is not null and ePend.IdOTSolicitud is null and aPend.IdOTSolicitud is null then @dominioAdinco+'/2/OrdenTrabajo/CapturaProgramaOT.aspx?id='+cast( ot.IdOTSolicitud as varchar)
									end
				when ot.IdOTEstatus IN(9) then @dominioProcura + '/02Proveedores/ActualizarSCOTConvenio.aspx?id='+cast(ot.IdSubcontrato as varchar)+'&id2='+cast(ot.IdOTSolicitud as varchar)
				when ot.IdOTEstatus IN ( 3,11) then @dominioAdinco+'/2/OrdenTrabajo/RegistrarOTSolicitudUpd.aspx?id=' +cast( ot.IdOTSolicitud as varchar)
				
		end,	
		/**********Url Text*************/		
		case 
				when ot.IdOTEstatus = 1 then case when @pUsuarioAdincoId > 0 then 'Completar' else '' end 
				when ot.IdOTEstatus in( 2,4) then case when isnull(@pUsuarioAdincoId,0) =0 then 'Completar' else '' end 
				when ot.IdOTEstatus in (5,6) then
						case
							 when  aPendRec.IdOTSolicitud is not null then case when isnull(@pUsuarioAdincoId,0) >0 then 'Completar' else '' end 
							 when  aPend.IdOTSolicitud is not null then case when isnull(@pUsuarioAdincoId,0) >0 then 'Completar' else '' end 
							 when  ePend.IdOTSolicitud is not null then case when isnull(@pUsuarioAdincoId,0) >0 then 'Completar' else '' end 

							when tmp2.Fecha is null  and ePend.IdOTSolicitud is null and aPend.IdOTSolicitud is null then case when isnull(@pUsuarioAdincoId,0) =0 then 'Completar' else '' end 						
							when tmp2.Fecha is not null and ePend.IdOTSolicitud is null and aPend.IdOTSolicitud is null  then case when isnull(@pUsuarioAdincoId,0) >0 then 'Completar' else '' end 
							
							
							
						end
				when ot.IdOTEstatus IN( 9) then case when isnull(@pUsuarioAdincoId,0)>0 then 'Completar' else '' end  
				when ot.IdOTEstatus IN( 3,11) then case when isnull(@pUsuarioAdincoId,0)>0 then 'Completar' else '' end  
				
							
		end,
	getdate(),		0,
	/*************USUARIO ASIGNADO***************/
	case 
				when ot.IdOTEstatus = 1 
						then 
							
										/*when ot.ProgIniPorProveedor = 0 then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,1)
										when ot.ProgIniPorProveedor = 1 then uot.Usuario*/
										 [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,1,0)
							
								
				when ot.IdOTEstatus in( 2,4) then pv.RazonSocial
				when ot.IdOTEstatus in (5,6) then
						case
							 when  aPendRec.IdOTSolicitud is not null then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,5,0)
							 when  aPend.IdOTSolicitud is not null then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,5,0)
							 when  ePend.IdOTSolicitud is not null then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,4,0)
							when tmp2.Fecha is null and ePend.IdOTSolicitud is null  and aPend.IdOTSolicitud is null then pv.RazonSocial							
							when tmp2.Fecha is not null and ePend.IdOTSolicitud is null and aPend.IdOTSolicitud is null then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,3,0)
													
							
						end
				when ot.IdOTEstatus IN( 9) then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,6,0)
				when ot.IdOTEstatus IN( 3,11) then [dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,2,0)
				
		end,
	cc.CentroCosto
	from OT_Solicitud ot
	inner join petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
	inner join AP_Usuario uot on uot.UsuarioId = ot.CreadoPor and
									ot.IsActivo = 1 	aND @pPend_Comp = 1 and
									(
										(ot.IdOTEstatus not in (7,8,12) and @pUsuarioAdincoId > 0)
										OR
										(ot.IdOTEstatus not in (1,7,8,12) and isnull(@pUsuarioAdincoId,0) = 0)
										OR
										(ot.IdOTEstatus not in (7,8,12) and @pUsuarioPetroId > 0)
									)
	inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud	
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on 
									(
										@pUsuarioAdincoId in (ucc.IdUsuario,9999999)
										OR
										@pUsuarioPetroId > 0
									)
									and
									ucc.IdCentroCosto in( ot.IdCentroCosto)
	inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato	
	inner join PV_Subcontratista pv on pv.IdSubcontratista = sc.IdSubcontratista
	left join petrovendor..S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS= pv.RFC collate SQL_Latin1_General_CP1_CI_AS --and
									--	@pIdProveedor in (0,prov.IdProveedor)
	left join  #tmpOTUsuarios u on u.IdOTSolicitud = ot.IdOTSolicitud
	left join #tmpCerrarSemanas tmp2 on tmp2.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
	left join #tmpEstimacionPend ePend on ePend.IdOTSolicitud = ot.IdOTSolicitud
	left join #tmpAceptacionesPend aPend on aPend.IdOTSolicitud = ot.IdOTSolicitud
	left join #tmpAceptacionesSinRec aPendRec on aPendRec.IdOTSolicitud = ot.IdOTSolicitud
	
	where @pIdContrato in (sc.IdContrato,0) 
	group by 
		
		ot.Folio,
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
		ot.IdSubcontrato	,
		ot.CreadoEl		,
		aPendRec.idPedidoGen,
		aPendRec.idOTSolicitud,
		cc.CentroCosto		,
		aPendRec.idAceptacionPedido	,prov.RFC , pv.RFC, prov.IdProveedor, pv.IdSubcontratista
	--		from OT_Solicitud ot
	--left join petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
	--left join AP_Usuario uot on uot.UsuarioId = ot.CreadoPor and
	--								ot.IsActivo = 1 	aND @pPend_Comp = 1 and
	--								(
	--									(ot.IdOTEstatus not in (7,8,12) and @pUsuarioAdincoId > 0)
	--									OR
	--									(ot.IdOTEstatus not in (1,7,8,12) and isnull(@pUsuarioAdincoId,0) = 0)
	--									OR
	--									(ot.IdOTEstatus not in (7,8,12) and @pUsuarioPetroId > 0)
	--								)
	--left join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud	
	--left join [dbo].[AP_UsuarioCentroCosto] ucc on 
	--								(
	--									@pUsuarioAdincoId in (ucc.IdUsuario,9999999)
	--									OR
	--									@pUsuarioPetroId > 0
	--								)
	--								and
	--								ucc.IdCentroCosto in( ot.IdCentroCosto)
	--left join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato	
	--left join PV_Subcontratista pv on pv.IdSubcontratista = sc.IdSubcontratista
	--left join petrovendor..S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS= pv.RFC collate SQL_Latin1_General_CP1_CI_AS and
	--									@pIdProveedor in (0,prov.IdProveedor)
	--left join  #tmpOTUsuarios u on u.IdOTSolicitud = ot.IdOTSolicitud
	--left join #tmpCerrarSemanas tmp2 on tmp2.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
	--left join #tmpEstimacionPend ePend on ePend.IdOTSolicitud = ot.IdOTSolicitud
	--left join #tmpAceptacionesPend aPend on aPend.IdOTSolicitud = ot.IdOTSolicitud
	--left join #tmpAceptacionesSinRec aPendRec on aPendRec.IdOTSolicitud = ot.IdOTSolicitud
	
	--where @pIdContrato in (sc.IdContrato,0) 
	--group by 
		
	--	ot.Folio,
	--	ot.IdOTSolicitud,
	--	ot.IdOTEstatus,				
	--	tmp2.Fecha,
	--	ot.ProgIniPorProveedor,
	--	uot.Usuario,
	--	pv.RazonSocial,
	--	ePend.IdOTSolicitud,
	--	ePend.SemanaID,
	--	aPend.IdOTSolicitud,
	--	aPend.IdPedido,
	--	aPend.IdPedidoGen,
	--	ot.IdSubcontrato	,
	--	ot.CreadoEl		,
	--	aPendRec.idPedidoGen,
	--	aPendRec.idOTSolicitud,
	--	cc.CentroCosto		,
	--	aPendRec.idAceptacionPedido	


		SELECT * FROM #tmpTareas

	--declare @countmpTareas int  select @countmpTareas = count(*) from #tmpTareas  print '#tmpTareas = ' + cast( @countmpTareas as varchar(10) ) + ' OT''s pendientes de aprobar'

	----ISSUE 1018 OT's sin relación Pedido - PO. Se agrega tarea para Relacionar Pedido-PO
	--insert into #tmpTareas(
	--IdOTTarea,		Folio,		IdOTSolicitud,	FechaRegistro,
	--Tarea,			Estatus,	Url,			UrlText,
	--FechaCompletada,Completada, UsuarioAsignado,	CentroCosto)
	--select 1,ot.Folio,ot.IdOTSolicitud, e.CreadoEl,
	--'Operadora - Relacionar Pedido:'+cast(e.IdPedidoGeneral as varchar) + ' con PO en Procura','Pendiente', @dominioProcura + '/DEA/Relacion_PR_PO.aspx','Completar',
	--null,			0,			[dbo].[fn_OT_GetMailUsuariosEstatus](ot.IdOTSolicitud,0,6,0), cc.CentroCosto
	--from #tmpEstimacionSinPO e
	--left join OT_Solicitud ot on ot.IdOTSolicitud = e.IdOTSolicitud
	--left join petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto

	--select @countmpTareas = count(*) from #tmpTareas  print '#tmpTareas = ' + cast( @countmpTareas as varchar(10) ) + ' sin relación Pedido - PO. Se agrega tarea para Relacionar Pedido-PO'

	----order by ot.CreadoEl desc

	--if @pUsuarioAdincoId > 0
	--begin
	--	select @emailusuario= isnull(Usuario,'')
	--	from ap_usuario
	--	where usuarioid = @pUsuarioAdincoId

	--	update #tmpTareas
	--	set UrlText = ''
	--	where UsuarioAsignado not like '%'+isnull(@emailusuario,'')+'%'

	--end
	--End

	----OT's tareas completadas
	--insert into #tmpTareas(
	--IdOTTarea,		Folio,		IdOTSolicitud,	FechaRegistro,
	--Tarea,			Estatus,	Url,			UrlText,
	--FechaCompletada,Completada, UsuarioAsignado, CentroCosto)
	--select sb.IdOTBitacora,		ot.Folio,	ot.IdOTSolicitud,ot.CreadoEl,
	--case when isnull(sb.Descripcion,'') = '' then t.Descripcion else isnull(sb.Descripcion,'') end
	--,	'Completada','',			'',
	--sb.CreadoEl,	1,			CASE WHEN isnull(sb.UsuarioAdincoId,0) >0 then u.Usuario		
	--								else pv.RazonSocial
	--							end,
	--cc.CentroCosto
	--from OT_Solicitud ot
	--left join petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
	--left join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud	aND @pPend_Comp = 2
	--left join [dbo].[AP_UsuarioCentroCosto] ucc on 
	--								(
	--									@pUsuarioAdincoId in (ucc.IdUsuario,0)
	--								)
	--								and
	--								ucc.IdCentroCosto in( ot.IdCentroCosto,0)
	--left join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato	
	--left join PV_Subcontratista pv on pv.IdSubcontratista = sc.IdSubcontratista
	--left join petrovendor..S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS= pv.RFC collate SQL_Latin1_General_CP1_CI_AS and
	--									@pIdProveedor in (0,prov.IdProveedor)	
	--left join OT_SolicitudBitacora sb on sb.IdOTSolicitud = ot.IdOTSolicitud and sb.CreadoEl >= dateadd(day,-15,getdate())
	--left join AP_Usuario u on u.UsuarioId = sb.UsuarioAdincoId
	--left join [AP_FlujoAprobacion_Tareas] t on t.FlujoAprobacionTareaId = sb.FlujoAprobacionTareaId
	--where @pIdContrato in (sc.IdContrato,0) and
	--ot.IsActivo = 1 	 
	
	--group by sb.UsuarioAdincoId,pv.RazonSocial,
	--ot.Folio,	ot.IdOTSolicitud,ot.CreadoEl,
	--sb.Descripcion,	sb.CreadoEl,	
	--u.Usuario,
	--t.Descripcion	, sb.IdOTBitacora,
	--cc.CentroCosto
	--order by sb.CreadoEl desc	
	
	--select @countmpTareas = count(*) from #tmpTareas  print '#tmpTareas = ' + cast( @countmpTareas as varchar(10) ) + ' OT''s tareas completadas'
	----update #tmpTareas
	----set UsuarioAsignado = replace(replace(replace(UsuarioAsignado,'daniel.moreno@adinco.mx',''),'juventino.sanchez@wintershalldea.com',''),'yazmin.gonzalez@ogss.com.mx','')
		

	--select * from #tmpTareas
	
	--order by  UrlText desc,FechaRegistro desc, FechaCompletada desc,Folio

end
END 
