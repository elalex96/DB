CREATE Proc sp_OT_BajaSolicitud
	@pIdOTSolicitud int,
	@pModificadoPor int,
	@pIdContrato	int
As
begin

	create table #tmp
	(
		CreadorOT				int,
		AprobadorOT				int,
		ValidadorCantOT			int,
		GeneradorEstimacion		int,
		AceptacionServicioOT	int,
		AdminContratos int,
		ConsultaContratos int
	)

	insert into #tmp exec p_OT_FlujoAprobacion_Acceso 1,@pIdContrato,@pModificadoPor,@pIdOTSolicitud
	--update #tmp set CreadorOT  = 0
	if((select CreadorOT from #tmp) = 1)
	begin
		update	OT_Solicitud
		set		IsEliminado		= 1,
				IsActivo		= 0,
				ModificadoPor	= @pModificadoPor,
				ModificadoEl	= getdate()
		where	IdOTSolicitud	= @pIdOTSolicitud

		select Msg = 'El proceso se completó con éxito' 
	end
	else
	begin
		select Msg = 'No es posible cancelar la solicitud, no tienes los permisos necesarios'
	end
end



