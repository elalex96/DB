
-- select dbo.fn_SC_ExcedidoSiNo(57) 
CREATE FUNCTION dbo.fn_SC_ExcedidoSiNo(@pIdOTSolicitud int) 
RETURNS bit
as
begin
    declare @result bit=0,
			@idSubcontrato int

	select @idSubcontrato = IdSubcontrato
	from OT_Solicitud
	where IdOTSolicitud = @pIdOTSolicitud

	

	 declare  @cantidades TABLE(
        IdSubcontrato int,
        IdSCMaterial int,
		CantidadSC float,
		CantidadOT float
    )

	insert @cantidades
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
        where ot.IdOTSolicitud = @pIdOTSolicitud and
        isnull(ot.IsActivo,0) = 1 
        group by sc.IdSubContrato,
                sMat.IdSCMaterial

    --Si la OT está cerrada, solo tomar cantidades aprobadas					
	insert @cantidades
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
		
       where sMat.IdSubcontrato = @idSubcontrato
       
        group by 
			sMat.idSubcontrato,
                sMat.IdSCMaterial
        

    if exists (
        select idSubcontrato,
				IdSCMaterial,
				CantidadSC = max(CantidadSC),
				CantidadOT = sum(CantidadOT)
		from @cantidades
		group by idSubcontrato,IdSCMaterial
		having sum(CantidadOT) > max(CantidadSC)
        )
        begin
            set @result = 1
        end
        return @result
end
