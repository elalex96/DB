--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure p_OT_AvanceOT
@IdContrato int = 0,
@IdCentroCostos int = null,
@TipoPedido int 
as
begin

--=======Tipo 1 AVANCE POR VOLUMETRÍA APROBADA
if	@TipoPedido = 1
begin

if @IdCentroCostos = 0 AND @TipoPedido = 1
begin
	select 
	distinct 
		cc.IdCentroCosto,
		cc.CentroCosto 
		,ots.IdOTSolicitud
		,ots.Folio
		,ots.IdCentroCosto as IdccAsociado
		,DATEADD(DAY,1, ots.FechaInicio) as FechaInicio
		--,replace(convert(varchar, ots.FechaInicio,101),'/','') + replace(convert(varchar, ots.FechaInicio,108),':','') as FechaInicio
		,DATEADD(DAY, 1, ots.FechaFin) as FechaFin
		--,replace(convert(varchar, ots.FechaFin,101),'/','') + replace(convert(varchar, ots.FechaFin,108),':','') as FechaFin
		,CONCAT(scm.Concepto,' ' ,scm.Descripcion) as Descripcion
		,otsm.IdOTSolicitud as IotdSolicituLigado
		--,Concat('A100-',otsm.IdOTSolicitudMaterial) as IdOTSolicitudMaterial
		,Concat('A100-',ROW_NUMBER() OVER(ORDER BY scm.Concepto ASC))  as IdOTSolicitudMaterial
		----
		, isnull(otsmc.Captura,0) as Capturado
		, isnull(scm.Cantidad ,0) as Cantidad
		,isnull((cast((isnull(otsmc.Captura,0) * 100 / isnull(scm.Cantidad ,0)) as  decimal(10,2)))/100,0) as Porcentaje
		,sc.IdContrato
		from Petrovendor..CC_CentroCosto cc
		JOIN OT_Solicitud ots on cc.IdCentroCosto = ots.IdCentroCosto
		join OT_SolicitudMaterial otsm on ots.IdOTSolicitud = otsm.IdOTSolicitud
		join SC_Materiales scm on otsm.IdSCMaterial = scm.IdSCMaterial
		left join OT_SolicitudProgramaCaptura otsmc on  otsm.IdOTSolicitudMaterial = otsmc.IdOTSolicitudMaterial
		join SC_SubContrato as sc on ots.IdSubContrato = sc.IdSubContrato
		WHERE 
		sc.IdContrato = @IdContrato and 
		ots.IsActivo = 1 and 
		ots.IdOTEstatus in (5,6,12) and
		otsm.Cantidad > 0
	group by 
	cc.IdCentroCosto
	,cc.CentroCosto
	,ots.IdOTSolicitud
	,ots.Folio
	,ots.IdCentroCosto
	,ots.IdCentroCosto
	,scm.Descripcion
	,otsm.IdOTSolicitud
	,ots.FechaInicio
	,ots.FechaFin
	,otsm.IdOTSolicitudMaterial
	,scm.Cantidad
	, otsmc.Captura
	, scm.Cantidad 
	,sc.IdContrato
	,scm.Concepto
end
if @IdCentroCostos > 0 AND @TipoPedido = 1
begin
	select 
	distinct 
		cc.IdCentroCosto,
		cc.CentroCosto 
		,ots.IdOTSolicitud
		,ots.Folio
		,ots.IdCentroCosto as IdccAsociado
		,DATEADD(DAY,1, ots.FechaInicio) as FechaInicio
		--,replace(convert(varchar, ots.FechaInicio,101),'/','') + replace(convert(varchar, ots.FechaInicio,108),':','') as FechaInicio
		,DATEADD(DAY, 1, ots.FechaFin) as FechaFin
		--,replace(convert(varchar, ots.FechaFin,101),'/','') + replace(convert(varchar, ots.FechaFin,108),':','') as FechaFin
		,CONCAT(scm.Concepto,' ' ,scm.Descripcion) as Descripcion
		,otsm.IdOTSolicitud as IotdSolicituLigado
		--,Concat('A100-',otsm.IdOTSolicitudMaterial) as IdOTSolicitudMaterial
		, Concat('A100-',ROW_NUMBER() OVER(ORDER BY scm.Concepto ASC))  as IdOTSolicitudMaterial
		----
		, isnull(otsmc.Captura,0) as Capturado
		, isnull(scm.Cantidad ,0) as Cantidad
		,isnull((cast((isnull(otsmc.Captura,0) * 100 / isnull(scm.Cantidad ,0)) as  decimal(10,2)))/100,0) as Porcentaje
		,sc.IdContrato
		from Petrovendor..CC_CentroCosto cc
		JOIN OT_Solicitud ots on cc.IdCentroCosto = ots.IdCentroCosto
		join OT_SolicitudMaterial otsm on ots.IdOTSolicitud = otsm.IdOTSolicitud
		join SC_Materiales scm on otsm.IdSCMaterial = scm.IdSCMaterial
		left join OT_SolicitudProgramaCaptura otsmc on  otsm.IdOTSolicitudMaterial = otsmc.IdOTSolicitudMaterial
		join SC_SubContrato as sc on ots.IdSubContrato = sc.IdSubContrato
		WHERE 
		sc.IdContrato = @IdContrato and 
		ots.IsActivo = 1 and 
		ots.IdOTEstatus in (5,6,12) and 
		cc.IdCentroCosto = @IdCentroCostos and
		otsm.Cantidad > 0
	group by 
	cc.IdCentroCosto
	,cc.CentroCosto
	,ots.IdOTSolicitud
	,ots.Folio
	,ots.IdCentroCosto
	,ots.IdCentroCosto
	,scm.Descripcion
	,otsm.IdOTSolicitud
	,ots.FechaInicio
	,ots.FechaFin
	,otsm.IdOTSolicitudMaterial
	,scm.Cantidad
	, otsmc.Captura
	, scm.Cantidad 
	,sc.IdContrato
	,scm.Concepto
end
end
--=======Tipo 2 AVANCE FINANCIERO
if	@TipoPedido = 2 and @IdCentroCostos > 0
begin
	select 
	distinct
	cc.IdCentroCosto
	,cc.CentroCosto
	,ots.IdOTSolicitud
	,ots.Folio
	,ots.IdCentroCosto as IdccAsociado
	,DATEADD(DAY,1, ots.FechaInicio) as FechaInicio
	,DATEADD(DAY, 1, ots.FechaFin) as FechaFin
	,CONCAT(scm.Concepto,' ' ,scm.Descripcion) as Descripcion
	,otsm.IdOTSolicitud as IotdSolicituLigado
	,Concat('A100-',ROW_NUMBER() OVER(ORDER BY scm.Concepto ASC))  as IdOTSolicitudMaterial
	, ISNULL(sum(ed.Cantidad * ed.PrecioUnitario),0) as Capturado
	, isnull(max(otsm.Cantidad) * max(scm.PrecioUnitario) ,0) as Cantidad
	,isnull(cast(isnull((sum(ed.Cantidad * ed.PrecioUnitario)*100)/(max(otsm.Cantidad) * max(scm.PrecioUnitario))/100,0)as  decimal(10,2))/100,0) as Porcentaje
	,sc.IdContrato
	
	from Petrovendor..CC_CentroCosto cc
	JOIN OT_Solicitud ots on cc.IdCentroCosto = ots.IdCentroCosto
		join OT_SolicitudMaterial otsm on ots.IdOTSolicitud = otsm.IdOTSolicitud
		join SC_Materiales scm on otsm.IdSCMaterial = scm.IdSCMaterial
		left join OT_SolicitudProgramaCaptura otsmc on  otsm.IdOTSolicitudMaterial = otsmc.IdOTSolicitudMaterial
		join SC_SubContrato as sc on ots.IdSubContrato = sc.IdSubContrato
		left join OT_Estimacion e on e.IdOTSolicitud = otsm.IdOTSolicitud and
		e.IdPedido is not null
		left join OT_EstimacionDetalle ed on ed.IdOTEstimacion = e.IdOTEstimacion and
		ed.IdOTSolicitudMaterial = otsm.IdOTSolicitudMaterial
		WHERE 
		sc.IdContrato = @IdContrato and 
		ots.IsActivo = 1 and 
		ots.IdOTEstatus in (5,6,12) and 
		otsm.Cantidad > 0 and 
		cc.IdCentroCosto = @IdCentroCostos
		group by 
		cc.IdCentroCosto
		,cc.CentroCosto
		,ots.IdOTSolicitud
		,ots.Folio
		,ots.IdCentroCosto
		,ots.IdCentroCosto
		,scm.Descripcion
		,otsm.IdOTSolicitud
		,ots.FechaInicio
		,ots.FechaFin
		,otsm.IdOTSolicitudMaterial
		,scm.Cantidad
		, otsmc.Captura
		, scm.Cantidad 
		,sc.IdContrato
		,scm.Concepto

end
if	@TipoPedido = 2 and @IdCentroCostos = 0
begin
	select 
	distinct
	cc.IdCentroCosto
	,cc.CentroCosto
	,ots.IdOTSolicitud
	,ots.Folio
	,ots.IdCentroCosto as IdccAsociado
	,DATEADD(DAY,1, ots.FechaInicio) as FechaInicio
	,DATEADD(DAY, 1, ots.FechaFin) as FechaFin
	,CONCAT(scm.Concepto,' ' ,scm.Descripcion) as Descripcion
	,otsm.IdOTSolicitud as IotdSolicituLigado
	,Concat('A100-',ROW_NUMBER() OVER(ORDER BY scm.Concepto ASC))  as IdOTSolicitudMaterial
	, ISNULL(sum(ed.Cantidad * ed.PrecioUnitario),0) as Capturado
	, isnull(max(otsm.Cantidad) * max(scm.PrecioUnitario) ,0) as Cantidad
	,isnull(cast(isnull((sum(ed.Cantidad * ed.PrecioUnitario)*100)/(max(otsm.Cantidad) * max(scm.PrecioUnitario))/100,0)as  decimal(10,2))/100,0) as Porcentaje
	,sc.IdContrato
	
	from Petrovendor..CC_CentroCosto cc
	JOIN OT_Solicitud ots on cc.IdCentroCosto = ots.IdCentroCosto
		join OT_SolicitudMaterial otsm on ots.IdOTSolicitud = otsm.IdOTSolicitud
		join SC_Materiales scm on otsm.IdSCMaterial = scm.IdSCMaterial
		left join OT_SolicitudProgramaCaptura otsmc on  otsm.IdOTSolicitudMaterial = otsmc.IdOTSolicitudMaterial
		join SC_SubContrato as sc on ots.IdSubContrato = sc.IdSubContrato
		left join OT_Estimacion e on e.IdOTSolicitud = otsm.IdOTSolicitud and
		e.IdPedido is not null
		left join OT_EstimacionDetalle ed on ed.IdOTEstimacion = e.IdOTEstimacion and
		ed.IdOTSolicitudMaterial = otsm.IdOTSolicitudMaterial
		WHERE 
		sc.IdContrato = @IdContrato and 
		ots.IsActivo = 1 and 
		ots.IdOTEstatus in (5,6,12) and 
		otsm.Cantidad > 0  
		group by 
		cc.IdCentroCosto
		,cc.CentroCosto
		,ots.IdOTSolicitud
		,ots.Folio
		,ots.IdCentroCosto
		,ots.IdCentroCosto
		,scm.Descripcion
		,otsm.IdOTSolicitud
		,ots.FechaInicio
		,ots.FechaFin
		,otsm.IdOTSolicitudMaterial
		,scm.Cantidad
		, otsmc.Captura
		, scm.Cantidad 
		,sc.IdContrato
		,scm.Concepto
end

end


