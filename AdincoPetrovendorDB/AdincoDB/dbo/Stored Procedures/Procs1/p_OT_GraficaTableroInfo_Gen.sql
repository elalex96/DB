------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create proc p_OT_GraficaTableroInfo_Gen
as


-- Obtener presupuesto por OT
select ot.IdOTSolicitud,
		OTPresuuesto = sum(otm.Cantidad * sc.PrecioUnitario) 
into #tmpOTPresupuesto
from OT_Solicitud ot
inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud
inner join SC_Materiales sc on sc.IdSCMaterial = otm.IdSCMaterial
group by ot.IdOTSolicitud
order by ot.IdOTSolicitud

--Obtener presupuesto por material
select otm.IdOTSolicitudMaterial,
		OTPresuuesto = sum(otm.Cantidad * sc.PrecioUnitario) ,
		ot.IdOTSolicitud
into #tmpOTServPresupuesto
from OT_Solicitud ot
inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud
inner join SC_Materiales sc on sc.IdSCMaterial = otm.IdSCMaterial
group by otm.IdOTSolicitudMaterial,ot.IdOTSolicitud
order by otm.IdOTSolicitudMaterial

--Obtener gasto por OT
select ot.IdOTSolicitud,
		OTGasto = sum(est.Total) 
into #tmpOTGasto
from OT_Solicitud ot
inner join OT_Estimacion est on est.IdOTSolicitud = ot.IdOTSolicitud
where isnull(est.Cancelada ,0) = 0
group by ot.IdOTSolicitud
order by ot.IdOTSolicitud

--Obtener gasto por Material
select otm.IdOTSolicitudMaterial,
		OTGasto = sum(otm.Importe) 
into #tmpOTMatGasto
from OT_Solicitud ot
inner join OT_Estimacion est on est.IdOTSolicitud = ot.IdOTSolicitud and isnull(est.Cancelada,0) = 0
inner join OT_EstimacionDetalle otm on otm.IdOTEstimacion = est.IdOTEstimacion
group by otm.IdOTSolicitudMaterial
order by otm.IdOTSolicitudMaterial


--Resultado
select 	
	Subcontrato = sc.NumeroSubcontrato,
	OTFolio = ot.Folio,
	OTId= ot.IdOTSolicitud,	
	OTCC = cc.CentroCosto,
	otp.OTPresuuesto,
	OTGasto=isnull(otg.OTGasto,0),
	SerConcepto=scm.Concepto,
	SerDescripcion = scm.Descripcion,
	SerPresupuesto = ots.OTPresuuesto,
	SerGasto = otsg.OTGasto
from OT_Solicitud ot
inner join OT_SolicitudMaterial otm on otm.IdOTSolicitud = ot.IdOTSolicitud and otm.Cantidad > 0
inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato
inner join SC_Materiales scm on scm.IdSubcontrato = sc.IdSubcontrato and
								scm.IdSCMaterial = otm.IdSCMaterial
inner join petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
inner join #tmpOTPresupuesto otp on otp.IdOTSolicitud = ot.IdOTSolicitud
inner join #tmpOTServPresupuesto ots on ots.IdOTSolicitud = ot.IdOTSolicitud
left join #tmpOTGasto otg on otg.IdOTSolicitud = ot.IdOTSolicitud
left join #tmpOTMatGasto otsg on otsg.IdOTSolicitudMaterial = otm.IdOTSolicitudMaterial
group by sc.NumeroSubcontrato,
ot.Folio,
ot.IdOTSolicitud,
cc.CentroCosto,
otg.OTGasto,
scm.Concepto,
scm.Descripcion,
ots.OTPresuuesto,
otsg.OTGasto
order by otp.IdOTSolicitud

