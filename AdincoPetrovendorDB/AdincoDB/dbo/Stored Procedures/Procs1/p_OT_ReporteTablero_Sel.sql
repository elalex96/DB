-- p_OT_ReporteTablero_Sel 3,2,10
CREATE proc p_OT_ReporteTablero_Sel
@pIdContrato int,
@pIdContratista int,
@pUsuarioId int
as

select distinct 
		--sc.IdContratista,
		--sc.IdContrato,
		IdOT = ot.IdOTSolicitud,
		Folio = ot.Folio,
		ot.Objeto,
		Tarea =CONCAT(t.id_Tarea, ' ', t.TareaPetrolera),
		SubTarea = serv.NombreServicio,
		Estatus = est.Descripcion,
		Fecha_Registro_OT = ot.CreadoEl,
		Requisitor = uReq.Usuario,
		Fecha_De_Rechazo = case when ot.IdOTEstatus in (7,8) then ot.ModificadoEl end,
		Fecha_De_AprobacionManager = case when ot.IdOTEstatus in (5) then  max(bitaAprobMan.CreadoEl) 
								when ot.IdOTEstatus in (6) then  max(bitaAprobEnviadaSC.CreadoEl) 
								 else ot.ModificadoEl
							end,
		Fecha_De_Aprobacion_PRSAP = ot.FechaAprobacionSAPPR,
		No_PR_SAP = ot.SAPPR,
		Fecha_De_Aceptacion_Proveedor = case when ot.IdOTEstatus  in (6) then max(bitaAprobSC.CreadoEl )
											 when ot.IdOTEstatus  in (5) then max(bitaPropSC.CreadoEl )
											 else ot.ModificadoEl
										end,
		Fecha_Carga_Avance = max(cap.FechaVoBoSubcontratista),
		Fecha_Cierre_Semana = max(cap.FechaCierre),
		Responsable_Cierre_Semana = max(uCierre.Usuario),
		Fecha_Estimacion = estima.CreadoEl,
		ResponsableEstimacion = uEst.Usuario,
		Fecha_AceptacionPedido =	rept.AprobacionPedido,
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
		rept.AprobacionFactura--,
		--getdate()
from OT_Solicitud ot
inner join OT_SolicitudMaterial om on om.IdOTSolicitud = ot.IdOTSolicitud
inner join [dbo].[OT_LineaPresupuesto] olp on olp.IdOTSolicitud = ot.IdOTSolicitud
inner join CO_LineaPresupuestoMes lpm on lpm.IdLineaPresupuestoMes = olp.IdLineaPresupuestoMes
inner join CO_TareaPetrolera t on t.IdTareaPetrolera = lpm.IdTareaPetrolera
inner join CO_Servicio serv on serv.IdServicio = lpm.IdServicio
inner join OT_Estatus est on est.IdOTEstatus = ot.IdOTEstatus
inner join AP_Usuario uReq on uReq.UsuarioId = ot.CreadoPor
inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato and sc.IdContrato = @pIdContrato and
																		sc.IdContratista = @pIdContratista
inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = @pUsuarioId and
									ucc.IdCentroCosto = ot.IdCentroCosto
left join [dbo].[OT_SolicitudProgramaCaptura] cap on cap.IdOTSolicitudMaterial = om.IdOTSolicitudMaterial and
										cap.FechaVoBoSubcontratista is not null
left join OT_Estimacion estima on estima.IdOTSolicitud = ot.IdOTSolicitud and
									estima.FechaCorteInicio <= cap.Fecha and
									estima.FechaCorteFin >= cap.Fecha and
									isnull(estima.Cancelada,0) = 0
left join AP_Usuario uEst on uEst.UsuarioId = estima.CreadoPor
left join AP_Usuario uCierre on uCierre.UsuarioId = cap.CerradoPor
left join [dbo].[OT_SolicitudBitacora] bitaAprobMan on bitaAprobMan.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobMan.descripcion like '%Aprobada%Operador%' 
left join [dbo].[OT_SolicitudBitacora] bitaAprobEnviadaSC on bitaAprobEnviadaSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobEnviadaSC.descripcion like '%Enviada%Subcontratista%' 
left join [dbo].[OT_SolicitudBitacora] bitaAprobSC on bitaAprobSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaAprobSC.descripcion like '%Aprobada%Subcontratista%' 
left join [dbo].[OT_SolicitudBitacora] bitaPropSC on bitaPropSC.IdOTSolicitud = ot.IdOTSolicitud and  bitaPropSC.descripcion like '%Propuesta%Subcontratista%' 

--left join AP_Usuario uAdincoBita on uAdincoBita.UsuarioId = bitaAprobMan.UsuarioAdincoId
left join Petrovendor..ReporteTablero repT on repT.NumPedido = estima.IdPedidoGeneral
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
 bitaAprobMan.descripcion,
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
		ot.IdOTSolicitud
order by ot.IdOTSolicitud desc

