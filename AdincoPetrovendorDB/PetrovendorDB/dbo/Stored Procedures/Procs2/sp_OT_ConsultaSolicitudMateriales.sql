
-- sp_OT_ConsultaSolicitudMateriales 9
Create Proc [dbo].[sp_OT_ConsultaSolicitudMateriales]
@pIdOTSolicitud int
As


	select sm.IdOTSolicitudMaterial,
			sm.IdOTSolicitud,
			sm.IdSCMaterial,
			NombreMaterial = sc.Descripcion,
			sm.IdServicio,
			sc.IdUnidad,
			NombreUnidad = NombreUnidad,
			sm.Cantidad,
			CantidadDisponible = sc.Cantidad - 
							(
								select sum(asignado.cantidad)
								from OT_SolicitudMaterial asignado
								inner join OT_Solicitud otasignada on otasignada.IdOTSolicitud = asignado.IdOTSolicitud 
								where otasignada.IsActivo = 1 and  otasignada.IsEliminado = 0 and
								otasignada.IdSubContrato = sol.IdSubContrato and
								asignado.IdSCMaterial = sm.IdSCMaterial
							),
			PrecioUnitario = sc.PrecioUnitario,
			Importe = cast(isnull(sm.Cantidad,0) * isnull(sc.PrecioUnitario,0) as  money),
			sm.FechaProgramaInicio,
			sm.FechaProgramaFin,
			sm.CreadoPor,
			sm.CreadoEl,
			sm.ModificadoPor,
			sm.ModificadoEl

	from OT_SolicitudMaterial sm
	inner join OT_Solicitud sol on sol.IdOTSolicitud = sm.IdOTSolicitud
	inner join SC_Materiales sc on sc.IdSCMaterial  = sm.IdSCMaterial and
								sc.IdSubContrato = sol.IdSubContrato	
	inner join mm_unidad uni on uni.IdUnidad = sm.sc.IdUnidad
											
	
	where sm.IdOTSolicitud = @pIdOTSolicitud
	group by sm.IdOTSolicitudMaterial,
			sm.IdOTSolicitud,
			sm.IdSCMaterial,
			 sc.Descripcion,
			sm.IdServicio,
			sc.IdUnidad,
			sm.Cantidad,
			 sc.Cantidad,
			 sc.PrecioUnitario,
			sm.Cantidad,sc.PrecioUnitario,
			sm.FechaProgramaInicio,
			sm.FechaProgramaFin,
			sm.CreadoPor,
			sm.CreadoEl,
			sm.ModificadoPor,
			sm.ModificadoEl, sol.IdSubContrato

