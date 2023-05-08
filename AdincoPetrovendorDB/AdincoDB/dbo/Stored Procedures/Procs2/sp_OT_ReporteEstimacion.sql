-- sp_OT_ReporteEstimacion 1
CREATE proc sp_OT_ReporteEstimacion
(
	@pIdOTEstimacion	int
)
as
begin

	DECLARE @TOTAL			MONEY ,
			@nombreReviso	varchar(200),
			@nombreAutorizo varchar(200)

	select		@nombreReviso	= upper(c.QuienVoBoContratista),
				@nombreAutorizo = upper(u2.Nombre)
	from		OT_Estimacion e
	inner join	OT_SolicitudMaterial sm on sm.IdOTSolicitud = e.IdOTSolicitud
	inner join	[dbo].[OT_SolicitudProgramaCaptura] c on c.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial and
										convert(varchar,c.Fecha,112) >= convert(varchar,e.FechaCorteInicio,112) and
										convert(varchar,c.Fecha,112) <= convert(varchar,e.FechaCorteFin,112) 	
	inner join AP_Usuario u2 on u2.UsuarioId = e.CreadoPor	
	where e.IdOTEstimacion = @pIdOTEstimacion

	select @TOTAL = Total
	from OT_Estimacion
	where idOTEstimacion = @pIdOTEstimacion




	select 	Logo =  (select Logo from CO_Contratista st1 where st1.IdContratista = subC.IdContratista ),								Logo2 = null,
			OrdenServicio=est.FolioOT,						FechaElaboracion=getdate(),							Departamento=cc.CentroCosto,
			Instalacion=est.Instalacion,					CargoContable='',									NoEstimacion=est.FolioEstimacion,
			Proveedor=upper(con.RazonSocial),				DescripcionServicios=est.Descripcion,								
			Part=ROW_NUMBER() OVER(ORDER BY ed.IdOTEstimacionDetalle ASC) ,			Descripcion=est.Descripcion,										Unidad=est.Unidad,												
			Cantidad=ed.Cantidad,							PrecioUnitario=ed.PrecioUnitario,					PrecioTotal=ed.Importe,										
			CantidadServicioEstimacion=ed.Cantidad,						CantidadServicioAcumulado=ed.CantidadAcumulado,							ImporteEstimacion=ed.Importe,									
			ImporteAcumulado=ed.TotalAvanceAcumulado,								AvanceServicioEstimacion=ed.PorcAvanceOT,							AvanceServicioAcumulado=ed.PorcAvanceAcumulado,
			Elaboro= upper(usu1.Nombre),										Revisado= @nombreReviso,											Autorizado= @nombreAutorizo,
			PuestoElaboro='',									PuestoRevisado='',										PuestoAutorizado='',
			ImporteLetra =  dbo.fnCantidadConLetraMoneda(@TOTAL,est.Moneda),
			est2.FechaCorteInicio,
			est2.FechaCorteFin
	from vwOTEstimacion est
	inner join OT_Estimacion est2 on est2.IdOTEstimacion = est.IdOTEstimacion
	inner join OT_Solicitud ot on ot.IdOTSolicitud = est.IdOTSolicitud
	inner join SC_SubContrato subC on subC.IdSubcontrato = ot.IdSubContrato
	inner join CO_Contratista con on con.IdContratista = subC.IdContratista
	inner join AP_Usuario usu1 on usu1.UsuarioID = ot.CreadoPor
	inner join PV_Subcontratista scon on scon.IdSubcontratista = subC.IdSubcontratista
	inner join OT_EstimacionDetalle ed on ed.IdOTEstimacion = est.IdOTEstimacion and
										ed.IdOTSolicitudMaterial = est.IdOTSolicitudMaterial
	inner join petrovendor..mm_pedido ped on ped.Idpedido = est2.IdPedido
	inner join Petrovendor.dbo.S_Proveedor prov on prov.idProveedor = ped.IdSubcontratista	
	inner join Petrovendor..CC_CentroCosto cc on cc.IdCentroCosto = ot.IdCentroCosto
	--left join Petrovendor.dbo.S_Usuario usu2 on usu2.Correo = prov.CorreoProveedor
	where est.idOTEstimacion = @pIdOTEstimacion
	group by /*con.Logo,*/
	cc.CentroCosto,
	ed.PrecioUnitario,
	ed.Importe,
	ed.IdOTEstimacionDetalle,
	est.FolioOT,
	est.Instalacion,est.FolioEstimacion,
	con.RazonSocial,	
	est.Descripcion,
	est.Unidad,
	est.Cantidad,
	est.PrecioUnitario,					
	ed.Cantidad,
	ed.CantidadAcumulado,	
	ed.Importe,	
	ed.TotalAvanceAcumulado,
	ed.PorcAvanceOT,	
	ed.PorcAvanceAcumulado,
	usu1.Nombre,
	est.Moneda,
	ot.IdMoneda,
	subC.IdContratista,
	FechaCorteInicio,
	FechaCorteFin
	
end




