---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_OT_ConsultaSolicitudMateriales 57,1
CREATE Proc sp_OT_ConsultaSolicitudMateriales
@pIdOTSolicitud INT,
@pTipoUsuario INT = 1 -- 1.Contratista 2.SubContratista
As

	declare @IdSubcontrato int

	

	select @idSubcontrato = IdSubcontrato
	from OT_Solicitud
	where IdOTSolicitud = @pIdOTSolicitud
 

	create table  #tmpCantidades (
        IdSubcontrato int,
        IdSCMaterial int,
		IdOTSM int,
		CantidadSC float,
		CantidadOT float
    )
	create table  #tmpCantidades2 (
        IdSubcontrato int,
        IdSCMaterial int,
		--IdOTSM int,
		CantidadSC float,
		CantidadOT float
    )

	insert into #tmpCantidades
	select 
                sMat.idSubcontrato,
                sMat.IdSCMaterial,  
				otMat2.IdOTSolicitudMATERIAL,
				CantidadSC = max(sMat.Cantidad),
                CantidadOT = sum(otMat2.Cantidad)
        from  SC_Materiales sMat 
        inner join [OT_SolicitudMaterial] otMat2 on otMat2.IdSCMaterial = SmAT.IdSCMaterial 
        inner join OT_Solicitud ot2 on ot2.IdOTSolicitud = otMat2.IdOTSolicitud and
                                ot2.IdOTEstatus NOT in (7,8,12) and                                
                                isnull(ot2.IsActivo,0) = 1			
		
		
       where sMat.IdSubcontrato = @idSubcontrato 
	    group by 
			sMat.idSubcontrato,
                sMat.IdSCMaterial,
				otMat2.IdOTSolicitudMATERIAL

	insert into #tmpCantidades 
	select 
                sMat.idSubcontrato,
                sMat.IdSCMaterial,  
				SPC.IdOTSolicitudMATERIAL,
				CantidadSC = max(sMat.Cantidad),
                CantidadOT = sum(spc.Captura)
        from  SC_Materiales sMat 
        inner join [OT_SolicitudMaterial] otMat2 on otMat2.IdSCMaterial = SmAT.IdSCMaterial 
        inner join OT_Solicitud ot2 on ot2.IdOTSolicitud = otMat2.IdOTSolicitud and
                                ot2.IdOTEstatus  in (12) and                                
                                isnull(ot2.IsActivo,0) = 1	 and ot2.IsEliminado = 0		
		inner join OT_SolicitudProgramaCaptura spc on spc.VoBoContratista = 1 and
												spc.IdOTSolicitudMaterial = otMat2.IdOTSolicitudMaterial
		
       where sMat.IdSubcontrato = @idSubcontrato
      
        group by 
			sMat.idSubcontrato,
                sMat.IdSCMaterial,
				SPC.IdOTSolicitudMATERIAL


	insert into #tmpCantidades2
	select  IdSubcontrato ,
        IdSCMaterial ,		
		max(CantidadSC) ,
		sum(CantidadOT ) 
	from #tmpCantidades
	group by IdSubcontrato,IdSCMaterial

	

	select 
			Id = ROW_NUMBER() OVER(ORDER BY sm.IdOTSolicitudMaterial ASC),
			sm.IdOTSolicitudMaterial,
			sm.IdOTSolicitud,
			sc.IdSCMaterial,
			sc.Concepto,
			NombreMaterial = sc.Descripcion,
			sm.IdServicio,
			sc.IdUnidad,
			NombreUnidad = Unidad,
			Cantidad = ISNULL(sm.Cantidad,0),
			CantidadDisponible = 
							 case when isnull(max(tmp2.CantidadSC),0) - isnull(max(tmp2.CantidadOT),0)  < 0 then 0
									else isnull(max(tmp2.CantidadSC),0) - isnull(max(tmp2.CantidadOT),0)
							end
								,
			PrecioUnitario = sc.PrecioUnitario,
			Importe = cast(isnull(sm.Cantidad,0) * isnull(sc.PrecioUnitario,0) as  money),
			sm.FechaProgramaInicio,
			sm.FechaProgramaFin,
			sm.CreadoPor,
			sm.CreadoEl,
			sm.ModificadoPor,
			sm.ModificadoEl,
			ModificadaPorContratista = cast(CASE WHEN bita.IdOTSolicitudMaterial IS NOT NULL THEN 1 ELSE 0 END AS bit),			
			Moneda = isnull(TipoMonedaCorto,'NO DEFINIDO')	,		
			sm.Comentarios
	from dbo.SC_Materiales sc	
	inner join petrovendor..MM_Material mmm on mmm.IdMaterial = sc.IdMaestro
	--inner join petrovendor..MM_Maestro mae on mae.IdMaestro = mmm.IdMaestro
	inner join OT_Solicitud sol on sol.IdSubContrato = sc.IdSubContrato
	inner join sc_subcontrato sc2 on sc2.idsubcontrato = sol.idsubcontrato
	inner join #tmpCantidades2 tmp2 on tmp2.IdSCMaterial = sc.IdSCMaterial
	left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc2.idPedido
	left join Petrovendor.dbo.PV_TipoMoneda moneda on moneda.idMoneda = isnull(ped.idMoneda,sol.IdMoneda)
	left JOIN OT_SolicitudMaterial sm on sol.IdOTSolicitud = sm.IdOTSolicitud AND
										sm.IdSCMaterial = sc.IdSCMaterial
	
	left JOIN Petrovendor.dbo.PV_MM_MaterialUnidad uni ON uni.IdUnidad = SC.IdUnidad
	LEFT JOIN dbo.OT_SolicitudMaterialBitacora bita ON bita.IdOTSolicitudMaterial = sm.IdOTSolicitudMaterial AND
												bita.IdTipoUsuario = 1
	
											
	
	where sol.IdOTSolicitud = @pIdOTSolicitud
	AND (
		
		(sol.IdOTEstatus in(5,6) AND sm.Cantidad > 0 AND @pTipoUsuario = 1)
		OR
		(sol.IdOTEstatus not in (5,6)  AND @pTipoUsuario = 1)
		OR @pTipoUsuario = 2
	)
	-- Si se activa la captura manual, solo mostrar items con relación entre contrato y materiales de OT
	AND (
		isnull(CapturaManual,0) = 0 
		OR
		(
			isnull(CapturaManual,0) = 1 and isnull(sm.Cantidad,0) > 0
		)
	)
	group by sm.IdOTSolicitudMaterial,
			sm.IdOTSolicitud,
			sc.IdSCMaterial,
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
			sm.ModificadoEl, sol.IdSubContrato,
			Unidad,
			bita.IdOTSolicitudMaterial,
			TipoMonedaCorto,
			sm.Comentarios,sc.Concepto,tmp2.IdSCMaterial
	order by sm.Cantidad desc,sc.Concepto








