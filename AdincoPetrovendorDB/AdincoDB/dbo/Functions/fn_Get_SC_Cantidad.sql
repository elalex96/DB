--  select * from [fn_Get_SC_Cantidad](14,24)
create function dbo.fn_Get_SC_Cantidad(@pIdSubcontrato int,@pIdOTSolicitud int) 
returns  @output TABLE(idOTSolicitud int, 
		idSCMaterial int, 
		cantDisponibleSC float,
		cantOcupadaOTS float,
		cantOcupadaOT float )
as
begin

	

	 declare  @cantidades TABLE(
        IdSubcontrato int,
        IdSCMaterial int,
		CantidadSC float,
		CantidadOT float
    )
   
   --Obtener cantidades para todo el contrato
	insert into @cantidades(IdSubcontrato,idSCMaterial,CantidadSC,CantidadOT)
	select 
                sc.IdSubContrato,
                sMat.IdSCMaterial,
                CantidadSC = max(sMat.Cantidad),
                CantidadOT = sum(otMat.Cantidad)
        from OT_Solicitud ot
        inner join SC_Subcontrato sc on sc.IdSubContrato = ot.IdSubContrato
        inner join SC_Materiales sMat on sMat.IdSubContrato = sc.IdSubContrato
        inner join [dbo].[OT_SolicitudMaterial] otMat on otMat.IdSCMaterial = sMat.IdSCMaterial 
        inner join OT_Solicitud ot2 on ot2.IdSubcontrato = ot.IdSubcontrato and
                                ot2.IdOTEstatus not in (7,8,12) and
                                otMat.IdOTSolicitud = ot2.IdOTSolicitud and
                                isnull(ot2.IsActivo,0) = 1
        where sc.IdSubContrato = @pIdSubcontrato and
        isnull(ot.IsActivo,0) = 1 
        group by sc.IdSubContrato,
                sMat.IdSCMaterial



		 --Si la OT está cerrada, solo tomar cantidades aprobadas					
		insert into @cantidades(IdSubcontrato,idSCMaterial,CantidadSC,CantidadOT)
		select 
					sMat.idSubcontrato,
					sMat.IdSCMaterial,  
					CantidadSC = max(sMat.Cantidad),
					CantidadOT = sum(spc.Captura)
			from  SC_Materiales sMat 
			inner join [OT_SolicitudMaterial] otMat2 on otMat2.IdSCMaterial = SmAT.IdSCMaterial 
			inner join OT_Solicitud ot2 on ot2.IdOTSolicitud = otMat2.IdOTSolicitud and
									ot2.IdOTEstatus  in (12) and                                
									isnull(ot2.IsActivo,0) = 1			
			inner join OT_SolicitudProgramaCaptura spc on spc.VoBoContratista = 1 and
													spc.IdOTSolicitudMaterial = otMat2.IdOTSolicitudMaterial
		
		   where sMat.IdSubcontrato = @pIdSubcontrato
       
			group by 
				sMat.idSubcontrato,
					sMat.IdSCMaterial

		insert into @output(idOTSolicitud , idSCMaterial , cantDisponibleSC ,cantOcupadaOTS ,cantOcupadaOT  )
		select @pIdOTSolicitud,IdSCMaterial,
				case when max(CantidadSC) - sum(CantidadOT) < 0 then 0 else max(CantidadSC) - sum(CantidadOT) end,
				sum(CantidadOT),0
		from @cantidades
		group by idSubcontrato,IdSCMaterial



		delete @cantidades


		


		--Obtener cantidades X OT
	insert into @cantidades(IdSubcontrato,idSCMaterial,CantidadSC,CantidadOT)
	select 
                sc.IdSubContrato,
                sMat.IdSCMaterial,
                CantidadSC = max(sMat.Cantidad),
                CantidadOT = sum(otMat.Cantidad)
        from OT_Solicitud ot
        inner join SC_Subcontrato sc on sc.IdSubContrato = ot.IdSubContrato
        inner join SC_Materiales sMat on sMat.IdSubContrato = sc.IdSubContrato
        inner join [dbo].[OT_SolicitudMaterial] otMat on otMat.IdSCMaterial = sMat.IdSCMaterial and
												otMat.IdOTSolicitud = @pIdOTSolicitud
        inner join OT_Solicitud ot2 on ot2.IdSubcontrato = ot.IdSubcontrato and
                                ot2.IdOTEstatus not in (7,8,12) and
                                otMat.IdOTSolicitud = ot2.IdOTSolicitud and
                                isnull(ot2.IsActivo,0) = 1 

        where sc.IdSubContrato = @pIdSubcontrato and
        isnull(ot.IsActivo,0) = 1 and
		ot.IdOTSolicitud = @pIdOTSolicitud
        group by sc.IdSubContrato,
                sMat.IdSCMaterial



		 --Si la OT está cerrada, solo tomar cantidades aprobadas					
		insert into @cantidades(IdSubcontrato,idSCMaterial,CantidadSC,CantidadOT)
		select 
					sMat.idSubcontrato,
					sMat.IdSCMaterial,  
					CantidadSC = max(sMat.Cantidad),
					CantidadOT = sum(spc.Captura)
			from  SC_Materiales sMat 
			inner join [OT_SolicitudMaterial] otMat2 on otMat2.IdSCMaterial = SmAT.IdSCMaterial  and
												otMat2.IdOTSolicitud = @pIdOTSolicitud
			inner join OT_Solicitud ot2 on ot2.IdOTSolicitud = otMat2.IdOTSolicitud and
									ot2.IdOTEstatus  in (12) and                                
									isnull(ot2.IsActivo,0) = 1	AND	
									otMat2.IdOTSolicitud = ot2.IdOTSolicitud
			inner join OT_SolicitudProgramaCaptura spc on spc.VoBoContratista = 1 and
													spc.IdOTSolicitudMaterial = otMat2.IdOTSolicitudMaterial
		
		   where sMat.IdSubcontrato = @pIdSubcontrato
       
			group by 
				sMat.idSubcontrato,
					sMat.IdSCMaterial


		update @output
		set cantOcupadaOT = c.CantidadOT
		from @output t1
		inner join @cantidades c on c.IdSCMaterial = t1.idSCMaterial

return
end
