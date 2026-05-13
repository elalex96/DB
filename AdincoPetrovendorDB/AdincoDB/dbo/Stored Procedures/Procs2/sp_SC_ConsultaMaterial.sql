-- sp_SC_ConsultaMaterial 12,0
CREATE Proc [dbo].[sp_SC_ConsultaMaterial]
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

	CREATE TABLE #tmpContrato(IdSCMaterial INT, IdSubContrato INT, Concepto VARCHAR(MAX), IdMaestro INT, IdSubFamilia INT, IdUnidad INT, IdServicio INT, NombreUnidad NVARCHAR(100),  Cantidad DECIMAL(14, 5), PrecioUnitario MONEY, Importe MONEY,  Descripcion VARCHAR(MAX),  DescripcionCorta VARCHAR(MAX), CreadoPor INT, CreadoEl DATETIME, ModificadoPor INT, ModificadoEl DATETIME, CantidadEnOTPendAut FLOAT, Moneda VARCHAR(50), COnvenio INT )

	insert into #tmpCantidades(idSubcontrato, IdSCMaterial, IdOTSM, CantidadSC, CantidadOT)
	select 
                SC_Materiales.idSubcontrato,
                SC_Materiales.IdSCMaterial,  
				OT_SolicitudMaterial.IdOTSolicitudMATERIAL,
				CantidadSC = max(SC_Materiales.Cantidad),
                CantidadOT = sum(OT_SolicitudMaterial.Cantidad)
        from  SC_Materiales (NOLOCK)
        inner join OT_SolicitudMaterial (NOLOCK) on SC_Materiales.IdSCMaterial = OT_SolicitudMaterial.IdSCMaterial  
        inner join OT_Solicitud (NOLOCK) on OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud  and
                                OT_Solicitud.IdOTEstatus NOT in (7,8,12) and                                
                                isnull(OT_Solicitud.IsActivo,0) = 1					
       where SC_Materiales.IdSubcontrato = @pIdSubContrato 
	    group by 
			SC_Materiales.idSubcontrato,
            SC_Materiales.IdSCMaterial,
			OT_SolicitudMaterial.IdOTSolicitudMATERIAL

	insert into #tmpCantidades (idSubcontrato, IdSCMaterial, IdOTSM, CantidadSC, CantidadOT)
	select 
                SC_Materiales.idSubcontrato,
                SC_Materiales.IdSCMaterial,  
				OT_SolicitudProgramaCaptura.IdOTSolicitudMATERIAL,
				CantidadSC = max(SC_Materiales.Cantidad),
                CantidadOT = sum(OT_SolicitudProgramaCaptura.Captura)
        from  SC_Materiales (NOLOCK)
        inner join OT_SolicitudMaterial (NOLOCK) on SC_Materiales.IdSCMaterial = OT_SolicitudMaterial.IdSCMaterial 
        inner join OT_Solicitud (NOLOCK) on OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud   and
                                OT_Solicitud.IdOTEstatus  in (12) and                                
                                isnull(OT_Solicitud.IsActivo,0) = 1	 and OT_Solicitud.IsEliminado = 0		
		inner join OT_SolicitudProgramaCaptura (NOLOCK) on OT_SolicitudProgramaCaptura.VoBoContratista = 1 and
												OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial 
		
       where SC_Materiales.IdSubcontrato = @pIdSubContrato    
        group by 
			SC_Materiales.idSubcontrato,
            SC_Materiales.IdSCMaterial,
			OT_SolicitudProgramaCaptura.IdOTSolicitudMATERIAL

	

	INSERT INTO #tmpContrato(IdSCMaterial, IdSubContrato, Concepto, IdMaestro, IdSubFamilia, IdUnidad, IdServicio, NombreUnidad,  Cantidad, PrecioUnitario, Importe,  Descripcion,  DescripcionCorta, CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, CantidadEnOTPendAut, Moneda, COnvenio )
	select 
		SC_Materiales.IdSCMaterial,
		SC_SubContrato.IdSubContrato,
		SC_Materiales.Concepto,
		SC_Materiales.IdMaestro,
		IdSubFamilia = 0,--maestro.IdSubFamilia,
		SC_Materiales.IdUnidad,
		SC_Materiales.IdServicio,
		NombreUnidad = PV_MM_MaterialUnidad.Unidad,
		Cantidad = SC_Materiales.Cantidad,
		SC_Materiales.PrecioUnitario,
		SC_Materiales.Importe,
		Descripcion = SC_Materiales.Concepto + '-' + rtrim(ltrim(SC_Materiales.Descripcion)),
		SC_Materiales.DescripcionCorta,
		SC_Materiales.CreadoPor,
		SC_Materiales.CreadoEl,
		SC_Materiales.ModificadoPor,
		SC_Materiales.ModificadoEl,
		CantidadEnOTPendAut = isnull(
									isnull(sum(cant.CantidadOT),0)/* - isnull(max(cant.CantidadSC),0) */
									,0),
	Moneda = isnull(TipoMonedaCorto,'NO DEFINIDA'),
	COnvenio = 0
	from SC_SubContrato (NOLOCK)
	inner join CO_Contratista (NOLOCK) on SC_SubContrato.IdContratista = CO_Contratista.IdContratista 
	inner join PV_Subcontratista (NOLOCK) on SC_SubContrato.IdSubContratista = PV_Subcontratista.IdSubContratista
	inner join SC_Materiales (NOLOCK) on SC_SubContrato.IdSubContrato = SC_Materiales.IdSubContrato
	left join #tmpCantidades cant on SC_Materiales.IdSCMaterial = cant.IdSCMaterial 
	left join petrovendor..PV_MM_MaterialUnidad (NOLOCK) on SC_Materiales.IdUnidad = PV_MM_MaterialUnidad.IdUnidad 
	left join Petrovendor.dbo.PV_TipoMoneda (NOLOCK) on SC_SubContrato.IdMoneda = PV_TipoMoneda.idMoneda 
	where SC_SubContrato.IdSubContrato = @pIdSubContrato
	group by SC_Materiales.IdSCMaterial,
		SC_SubContrato.IdSubContrato,
		SC_Materiales.Concepto,
		SC_Materiales.IdMaestro,		
		SC_Materiales.IdUnidad,
		SC_Materiales.IdServicio,
		PV_MM_MaterialUnidad.Unidad,
		SC_Materiales.Cantidad,
		SC_Materiales.PrecioUnitario,
		SC_Materiales.Importe,
		SC_Materiales.Concepto ,
		SC_Materiales.Descripcion,
		SC_Materiales.DescripcionCorta,
		SC_Materiales.CreadoPor,
		SC_Materiales.CreadoEl,
		SC_Materiales.ModificadoPor,
		SC_Materiales.ModificadoEl,
		TipoMonedaCorto


	update #tmpContrato
	set COnvenio = 1
	where CantidadEnOTPendAut > Cantidad

	select * from #tmpContrato
	where (COnvenio = 1 and @pSoloConvenios = 1)
	OR 
	@pSoloConvenios = 0
	order by COnvenio desc





