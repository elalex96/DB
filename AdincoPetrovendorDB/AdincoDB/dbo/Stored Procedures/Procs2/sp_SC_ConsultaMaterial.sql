-- sp_SC_ConsultaMaterial 12,0
CREATE Proc sp_SC_ConsultaMaterial
@pIdSubContrato int,
@pSoloConvenios bit = 0
As

	create table  #tmpCantidades (
        IdSubcontrato int,
        IdSCMaterial int,
		IdOTSM int,
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
		
		
       where sMat.IdSubcontrato = @pIdSubContrato 
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
		
       where sMat.IdSubcontrato = @pIdSubContrato
      
        group by 
			sMat.idSubcontrato,
                sMat.IdSCMaterial,
				SPC.IdOTSolicitudMATERIAL


	select 
	
		
		--sc.ModificadoEl
		mat.IdSCMaterial,
		sc.IdSubContrato,
		mat.Concepto,
		mat.IdMaestro,
		IdSubFamilia = 0,--maestro.IdSubFamilia,
		mat.IdUnidad,
		mat.IdServicio,
		NombreUnidad = u.Unidad,
		Cantidad = mat.Cantidad,
		mat.PrecioUnitario,
		mat.Importe,
		Descripcion = mat.Concepto + '-' + rtrim(ltrim(mat.Descripcion)),
		mat.DescripcionCorta,
		mat.CreadoPor,
		mat.CreadoEl,
		mat.ModificadoPor,
		mat.ModificadoEl,
		CantidadEnOTPendAut = isnull(
									isnull(sum(CantidadOT),0)/* - isnull(max(cant.CantidadSC),0) */
									,0),
	Moneda = isnull(TipoMonedaCorto,'NO DEFINIDA'),
	COnvenio = 0
	into #tmpContrato
	from SC_SubContrato sc
	inner join CO_Contratista c on c.IdContratista = sc.IdContratista
	inner join PV_Subcontratista pv on pv.IdSubContratista = sc.IdSubContratista
	inner join SC_Materiales mat on mat.IdSubContrato = sc.IdSubContrato	
	left join #tmpCantidades cant on cant.IdSCMaterial = mat.IdSCMaterial
	left join petrovendor..PV_MM_MaterialUnidad u on u.IdUnidad = mat.IdUnidad
	--left join Petrovendor.dbo.MM_Material mm on mm.IdMaterial = mat.IdMaestro
	--LEFT join Petrovendor.dbo.mm_maestro maestro on maestro.IdMaestro = mm.IdMaestro
	--left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = sc.Idpedido

	left join Petrovendor.dbo.PV_TipoMoneda moneda on moneda.idMoneda = sc.IdMoneda
	where sc.IdSubContrato = @pIdSubContrato
	group by mat.IdSCMaterial,
		sc.IdSubContrato,
		mat.Concepto,
		mat.IdMaestro,		
		mat.IdUnidad,
		mat.IdServicio,
		u.Unidad,
		mat.Cantidad,
		mat.PrecioUnitario,
		mat.Importe,
		mat.Concepto ,
		mat.Descripcion,
		mat.DescripcionCorta,
		mat.CreadoPor,
		mat.CreadoEl,
		mat.ModificadoPor,
		mat.ModificadoEl,
		TipoMonedaCorto


	update #tmpContrato
	set COnvenio = 1
	where CantidadEnOTPendAut > Cantidad

	select * from #tmpContrato
	where (COnvenio = 1 and @pSoloConvenios = 1)
	OR 
	@pSoloConvenios = 0
	order by COnvenio desc





