
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_SC_ActualizarMaterial 586,42,'33.0',0,10011,0,12,1302.34,15628.08,'33.0-Additional meter 5” Section to adjust total Depth','Additional meter 5” Section to adjust total Depth',4,1,'ra@smps-sp.com',12
CREATE Proc sp_SC_ActualizarMaterial
@pIdSCMaterial	int ,
@pIdSubContrato	int,
@pConcepto	varchar(30),
@pIdMaestro	int,
@pIdUnidad	int,
@pIdServicio int,
@pCantidad	decimal(14,2),
@pPrecioUnitario	money,
@pImporte	money,
@pDescripcion	varchar(510),
@pDescripcionCorta	varchar(250),
@pModificadoPor	int,
@pAprobarConvenioOT bit,
@pNombreUsuario varchar(250),
@pIdOTSolicitud int
as


	declare @IdUsuarioAdinco int,
		@IdOTEstatusNuevo int,
		@IdSCBitacora int,
		@pError varchar(250)

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
		
		
       where sMat.IdSCMaterial = @pIdSCMaterial
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
		
       where  sMat.IdSCMaterial = @pIdSCMaterial
      
        group by 
			sMat.idSubcontrato,
                sMat.IdSCMaterial,
				SPC.IdOTSolicitudMATERIAL

	select @IdUsuarioAdinco = UsuarioID
	from AP_Usuario
	where Usuario = @pNombreUsuario

	/************VALIDAR QUE NO SE INSERTEN CONCEPTOS DUPLICADOS***************/

	if (
		select count(distinct IdSCMaterial)
		from sc_materiales
		where @pIdSubContrato = IdSubContrato and
		Concepto = @pConcepto and
		IdSCMaterial <> @pIdSCMaterial
		)
		>0
	begin
		RAISERROR (15600,-1,-1, 'No se puede ingresar un concepto duplicado'); 
		return
	end

	/************Validar que no se intente insertar mas de una vez el servicio para el subcontrato******************/
	if (
		select count(distinct IdSCMaterial)
		from sc_materiales
		where @pIdSubContrato = IdSubContrato and
		IdServicio = @pIdServicio and
		IdMaestro = @pidMaestro  and
		IdSCMaterial <> @pIdSCMaterial
		)
		>0
	begin
		RAISERROR (15600,-1,-1, 'No se puede ingresar un servicio maestro duplicado'); 
		return
	end


	/********Si existen OT para el subcontrato, asegurarse de no capturar menos cantidad de la que ya esté asignada auna OT***********/
	if(
		SELECT SUM(CantidadOT)
		from #tmpCantidades
		where IdSCMaterial = @pIdSCMaterial
	) > @pCantidad
	begin
				
		RAISERROR (15600,-1,-1, 'No se puede captura menos cantidad de la que ya está asignada a OTs'); 
		return
	end

	begin tran

	/*******************INSERTAR BITACORA****************************************/
	select @IdSCBitacora = isnull(max(IdSCBitacora),0) + 1
	from [SC_MaterialesBitacora]

	insert into [SC_MaterialesBitacora](
		IdSCBitacora,IdSCMaterial,CantidadRespaldo,FechaRespaldo,ModificadoPor
	)	
	select 	@IdSCBitacora,@pIdSCMaterial,Cantidad,getdate(), 
	case when @IdUsuarioAdinco > 0 then @IdUsuarioAdinco else @pModificadoPor end
	from sc_materiales
	where  IdSCMaterial =@pIdSCMaterial

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end	

	update sc_materiales
		set concepto = @pConcepto,				
			IdUnidad = @pIdUnidad,
			Cantidad = @pCantidad,
			PrecioUnitario = @pPrecioUnitario,
			Importe = @pImporte,
			Descripcion = @pDescripcion,
			DescripcionCorta = @pDescripcionCorta,		 	
			ModificadoPor = case when @IdUsuarioAdinco > 0 then @IdUsuarioAdinco else @pModificadoPor end,
			ModificadoEl = getdate(),
			IdServicio = case when @pIdServicio = 0 then null else @pIdServicio end
	where IdSCMaterial =@pIdSCMaterial

	if @@error <> 0
	begin
		rollback tran
		goto fin
	end

	

	/**********Aprobar el convenio , solo si ya se cumple con la cantidad necesaria para completar las OT's************/
	--if @pAprobarConvenioOT = 1
	--and not exists (
	--	select otm.IdSCMaterial,
	--		CantidadOT = sum(otm.Cantidad),
	--		sc.Cantidad
	--	from OT_SolicitudMaterial otm
	--	inner join OT_Solicitud ot on ot.IdOTSolicitud = otm.IdOTSolicitud
	--	inner join SC_Materiales sc on sc.IdSCMaterial = otm.IdSCMaterial
	--	where ot.IdOTEstatus not in (7,8) and
	--	sc.IdSubContrato = @pIdSubContrato and
	--	ot.IsActivo = 1
	--	group by otm.IdSCMaterial,sc.Cantidad
	--	having sum(otm.Cantidad) > isnull(sc.Cantidad,0)
	--)
	--begin 
	--	update OT_Convenio
	--	set Aprobada = 1,
	--		AprobadaPor = @IdUsuarioAdinco,
	--		FechaAprobacion = getdate()
	--	from OT_Convenio con
	--	inner join OT_Solicitud otsol on otsol.IdOTSolicitud = con.IdOTSolicitud
	--	inner join SC_Subcontrato sc on sc.IdSubContrato = otsol.IdSubContrato
	--	where sc.IdSubContrato = @pIdSubContrato and
	--	otsol.IdOTSolicitud = @pIdOTSolicitud and
	--	AprobadaPor is null

	--	if @@error <> 0
	--	begin
	--		rollback tran
	--		goto fin
	--	end

	--	/**********Actualizar Estatus de la OT****************/

	--	select @IdOTEstatusNuevo = dbo.fn_OT_CalcularEstatusSig(@pIdOTSolicitud)

		
	--	exec p_OT_ActualizarSolicitud @pIdOTSolicitud,@IdOTEstatusNuevo,@pModificadoPor,0

	--	if @@error <> 0
	--	begin
	--		rollback tran
	--		goto fin
	--	end


	--end

	if @pAprobarConvenioOT = 1
	begin
		exec p_OT_AprobarConvenios @pIdSubContrato,@IdUsuarioAdinco,@pError out
	end

	
	
	if @@error <> 0 OR @pError <> ''
	begin
		rollback tran
		goto fin
	end

	commit tran

	fin:





	






