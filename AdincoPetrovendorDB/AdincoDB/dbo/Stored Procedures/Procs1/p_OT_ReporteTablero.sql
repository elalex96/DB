CREATE proc p_OT_ReporteTablero
as

delete Adinco..[OT_ReporteTablero]

insert into Adinco..[OT_ReporteTablero](
	Folio,Objeto,Tarea,SubTarea,Estatus,
	Fecha_Registro_OT,Requisitor,Fecha_Rechazo,Fecha_AprobacionManager,Fecha_Aprobacion_PRSAP,
	No_PR_SAP,Fecha_Aceptacion_Proveedor,Fecha_Carga_Avance,Fecha_Cierre_Semana,Responsable_Cierre_Semana,
	Fecha_Estimacion,Responsable_Estimacion,Fecha_Aceptacion_Pedido,No_Aceptacion_Pedido,Responsable_Aceptacion,
	Fecha_Pedido,No_Pedido,Moneda,Costo,Estatus_Pedido,FechaRelacion_PedidoPo,Num_PO_SAP,
	RegistroPCN,Fecha_Aprobacion_PCN,Fecha_Recepcion_Factura,ResponsableRecepcionFactura,Fecha_Aprobacion_Factura,
	--
	SubtotalFactura,	MontoAceptado,		IdOTSolicitud,		IdCentroCosto,		
	CentroCosto,		IdContrato,			IdProveedor,		RazonSocialProv
	
)

select distinct 
		--sc.IdContratista,
		--sc.IdContrato,
		Folio = ot.Folio,
		ot.Objeto,
		Tarea =CONCAT(t.id_Tarea, ' ', t.TareaPetrolera),
		SubTarea = serv.NombreServicio,
		Estatus = est.Descripcion,
		RegistroDeOT = ot.CreadoEl,
		Requisitor = uReq.Usuario,
		Fecha_De_Rechazo = case when ot.IdOTEstatus in (7,8) then ot.ModificadoEl end,
		Fecha_De_AprobacionManager = case when ot.IdOTEstatus in (5) then  isnull(max(bitaAprobMan.CreadoEl),ot.ModificadoEl) 
								when ot.IdOTEstatus in (6) then  isnull(max(bitaAprobEnviadaSC.CreadoEl),ot.ModificadoEl) 
								 else ot.ModificadoEl
							end,
		Fecha_De_Aprobacion_PRSAP = ot.FechaAprobacionSAPPR,
		No_PR_SAP = ot.SAPPR,
		Fecha_De_Aceptacion_Proveedor = case when ot.IdOTEstatus  in (6) then isnull(max(bitaAprobSC.CreadoEl ),ot.ModificadoEl)
											when ot.IdOTEstatus  in (5) then isnull(max(bitaPropSC.CreadoEl ),ot.ModificadoEl)
											 else ot.ModificadoEl
										end,
		FechaCargaAvance = max(cap.FechaVoBoSubcontratista),
		FechaCierreSemana = max(cap.FechaCierre),
		Responsable_Cierre_Semana = max(uCierre.Usuario),
		FechaDeEstimacion = estima.CreadoEl,
		ResponsableEstimacion = uEst.Usuario,
		FechaAceptacionPedido =	rept.AprobacionPedido,
		NoAceptacionPedido = rept.IdAceptacionPedido,
		rept.ResponsableAceptacion,
		FechaPedido = repT.FEchaPedido,
		NoPedido = estima.IdPedidoGeneral,
		repT.Moneda,
		repT.Costo,
		rept.EstatusPedido,
	
		rept.FechaRelacionPedidoPo,
		rept.NUmPoSAP,
		rept.RegistroPCN,
		rept.AprobacionPCN,
		rept.RecepcionFactura,
		rept.ResponsableRecepcionFactura,
		rept.AprobacionFactura,
		SubtotalFactura = repT.SubtotalFactura,	
		MontoAceptado = repT.MontoAceptado,		
		IdOTSolicitud = ot.IdOTSolicitud,		
		IdCentroCosto = ot.IdCentroCosto,		
		CentroCosto	= cc.CentroCosto,
		IdContrato = sc.IdContrato,
		IdProveedor = rept.IdProveedor,
		RazonSocialProv = isnull(rept.RazonSocial,pv.RazonSocial)
from OT_Solicitud ot (NOLOCK)
inner join OT_SolicitudMaterial om (NOLOCK)
	on om.IdOTSolicitud = ot.IdOTSolicitud
inner join [dbo].[OT_LineaPresupuesto] olp (NOLOCK)
	on olp.IdOTSolicitud = ot.IdOTSolicitud
inner join CO_LineaPresupuestoMes lpm (NOLOCK)
	on lpm.IdLineaPresupuestoMes = olp.IdLineaPresupuestoMes
inner join CO_TareaPetrolera t (NOLOCK)
	on t.IdTareaPetrolera = lpm.IdTareaPetrolera
inner join CO_Servicio serv (NOLOCK)
	on serv.IdServicio = lpm.IdServicio
inner join OT_Estatus est (NOLOCK)
	on est.IdOTEstatus = ot.IdOTEstatus
inner join AP_Usuario uReq (NOLOCK)
	on uReq.UsuarioId = ot.CreadoPor
inner join petrovendor..CC_CentroCosto cc (NOLOCK)
	on cc.IdCentroCosto =  ot.IdCentroCosto
inner join SC_Subcontrato sc (NOLOCK)
	on sc.IdSubcontrato = ot.IdSubcontrato and sc.IdContrato = 10038 --DEA
inner join PV_Subcontratista pv (NOLOCK)
	on pv.IdSubcontratista = sc.IdSubcontratista
left join [dbo].[OT_SolicitudProgramaCaptura] cap (NOLOCK)
	on cap.IdOTSolicitudMaterial = om.IdOTSolicitudMaterial and
										cap.FechaVoBoSubcontratista is not null
left join OT_Estimacion estima (NOLOCK)
	on estima.IdOTSolicitud = ot.IdOTSolicitud and
									estima.FechaCorteInicio <= cap.Fecha and
									estima.FechaCorteFin >= cap.Fecha
left join AP_Usuario uEst (NOLOCK)
	on uEst.UsuarioId = estima.CreadoPor
left join AP_Usuario uCierre (NOLOCK)
	on uCierre.UsuarioId = cap.CerradoPor
left join [dbo].[OT_SolicitudBitacora] bitaAprobMan (NOLOCK)
	on bitaAprobMan.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobMan.IdTipoMovimiento =2 --Aprbada por operador
left join [dbo].[OT_SolicitudBitacora] bitaAprobEnviadaSC (NOLOCK)
	on bitaAprobEnviadaSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobEnviadaSC.IdTipoMovimiento = 3 --Enviada a Subcontratista
left join [dbo].[OT_SolicitudBitacora] bitaAprobSC (NOLOCK)
	on bitaAprobSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobSC.IdTipoMovimiento  = 4-- Aprobada Subcontratista 
left join [dbo].[OT_SolicitudBitacora] bitaPropSC (NOLOCK)
	on bitaPropSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaPropSC.IdTipoMovimiento = 5--Propuesta subcontratista

--left join AP_Usuario uAdincoBita on uAdincoBita.UsuarioId = bita.UsuarioAdincoId
left join Petrovendor..ReporteTablero repT (NOLOCK)
	on repT.NumPedido = estima.IdPedidoGeneral
group by 
ot.Folio,
CONCAT(t.id_Tarea, ' ', t.TareaPetrolera),
serv.NombreServicio,
est.Descripcion,
ot.CreadoEl,
uReq.Usuario,
ot.IdOTEstatus,
ot.ModificadoEl,
 --bita.CreadoEl,
  --ot.SAPPR,
 cap.IdAnioMesDia,
  estima.CreadoEl,
  uEst.Usuario,
  repT.FEchaPedido,
  estima.IdPedidoGeneral,
  repT.Moneda,
  repT.Costo,
  rept.EstatusPedido,
  rept.AprobacionPedido,

  rept.FechaRelacionPedidoPo,
  rept.NUmPoSAP,
  rept.RegistroPCN,
  rept.AprobacionPCN,
  rept.RecepcionFactura,
  rept.ResponsableRecepcionFactura,
		rept.AprobacionFactura,
		ot.Objeto, 
		ot.FechaAprobacionSAPPR,
		ot.SAPPR,
		rept.IdAceptacionPedido,
		rept.ResponsableAceptacion,
		sc.IdContratista,
		sc.IdContrato,
		repT.SubtotalFactura,
		repT.MontoAceptado,
		ot.IdOTSolicitud,
		ot.IdCentroCosto,
		cc.CentroCosto,
		rept.IdProveedor, rept.RazonSocial,
		pv.RazonSocial
order by ot.CreadoEl desc


select Folio,Objeto,Tarea,SubTarea,Estatus,
	Fecha_Registro_OT,Requisitor,Fecha_Rechazo,Fecha_AprobacionManager,Fecha_Aprobacion_PRSAP,
	No_PR_SAP,Fecha_Aceptacion_Proveedor,Fecha_Carga_Avance,Fecha_Cierre_Semana,Responsable_Cierre_Semana,
	Fecha_Estimacion,Responsable_Estimacion,Fecha_Aceptacion_Pedido,No_Aceptacion_Pedido,Responsable_Aceptacion,
	Fecha_Pedido,No_Pedido,Moneda,Costo,Estatus_Pedido,FechaRelacion_PedidoPo,Num_PO_SAP,
	RegistroPCN,Fecha_Aprobacion_PCN,Fecha_Recepcion_Factura,ResponsableRecepcionFactura,Fecha_Aprobacion_Factura,
	SubtotalFactura,MontoAceptado,IdOTSolicitud,IdCentroCosto,CentroCosto,IdContrato
from [OT_ReporteTablero]


