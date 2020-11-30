-- spDeshacerEstimaciones 6, 10, 3
create proc spDeshacerEstimaciones --6, 10, 3
(
	@pIdOTEstimacion	int,
	@pIdUsuario			int,
	@pIdContrato		int
)
as
begin

	declare @IdOTSolicitud		int,@idPedido int,@folioEstimacion2 varchar(20),@motivo varchar(100), @fechaCierre datetime

	select	@IdOTSolicitud		=	IdOTSolicitud
	from	OT_Estimacion 
	where	IdOTEstimacion		=	@pIdOTEstimacion

	create table #tmp
	(
		CreadorOT				int,
		AprobadorOT				int,
		ValidadorCantOT			int,
		GeneradorEstimacion		int,
		AceptacionServicioOT	int,
		AdminContratos			int,
		ConsultaContrato		int
	)

	insert into #tmp exec p_OT_FlujoAprobacion_Acceso 1,@pIdContrato,@pIdUsuario,@IdOTSolicitud

	if ((select GeneradorEstimacion from #tmp) = 1)-- and 0=1)
	begin

	if exists(
		select		1
		from		OT_Estimacion							e
		inner join	OT_EstimacionDetalle					ed 
		on			ed.IdOTEstimacion						=	e.IdOTEstimacion
		inner join	petrovendor..MM_Pedido					p	
		on			p.IdPedido								=	e.IdPedido
		inner join	petrovendor..MM_AceptacionPedido		ap 
		on			ap.IdPedido								=	p.IdPedido
		inner join	petrovendor..[MM_AceptacionCartaPCN]	cn 
		on			cn.IdAceptacionPedido					=	ap.IdAceptacionPedido 
		and			cn.IdEstatus							=	2
		where		e.IdOTEstimacion						=	@pIdOTEstimacion
	)
	begin
		select	ErrorMessage = 'No es posible deshacer la estimación'
	end
	else
	begin
		if(
				(select count(*) from OT_EstimacionDetalle	where		IdOTEstimacion						=	@pIdOTEstimacion)=0 
			and (select count(*) from OT_Estimacion			where		IdOTEstimacion						=	@pIdOTEstimacion)=0
		)
		begin
			select ErrorMessage = 'No hay registros a borrar'
		end
		else
		begin

			select @idPedido = IdPedido,
				@folioEstimacion2 = FolioEstimacion
			from OT_Estimacion
			where	IdOTEstimacion		=	@pIdOTEstimacion and
			isnull(cancelada,0) = 0

			set @motivo = 'Eliminación de estimación control de Obra:' + @folioEstimacion2

			if isnull(@idPedido,0) > 0
			begin

				exec petrovendor..MM_SP_CierrePedido @idPedido,@motivo,null,1,null,@pIdUsuario,@fechaCierre

			end

			update	OT_Estimacion
			set		Cancelada			=	1,
					FechaCancelacion	=	GETDATE()
			where	IdOTEstimacion		=	@pIdOTEstimacion
			--delete from OT_EstimacionDetalle	where		IdOTEstimacion						=	@pIdOTEstimacion
			--delete from OT_Estimacion			where		IdOTEstimacion						=	@pIdOTEstimacion

			
			declare	@folioEstimacion	varchar(50)

			select	@IdOTSolicitud		=	IdOTSolicitud,
					@folioEstimacion	=	'Se canceló estimacion ' + FolioEstimacion
			from	OT_Estimacion 
			where	IdOTEstimacion		=	@pIdOTEstimacion

			exec [p_OT_SolicitudBitacora_ins] @IdOTSolicitud,null, @folioEstimacion , @pIdUsuario,null,null

		end

		
		select ErrorMessage = ''
	end


	end
	else
	begin
		select ErrorMessage = 'No tienes los privilegios para realizar la acción'
	end
end

