CREATE proc spDeshacerEstimaciones --6, 10, 3
(
	@pIdOTEstimacion	int,
	@pIdUsuario			int,
	@pIdContrato		int,
	@pError				varchar(250) out
)
as
begin

	BEGIN TRY

	BEGIN TRAN

	set @pError = ''

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
		where		e.IdOTEstimacion						=	@pIdOTEstimacion AND
		ap.Activo = 1
	)
	begin
		set	@pError = '[ALERTA] No es posible deshacer la estimación. Existe una carta de CN aprobada ligada a la estimación'
	end
	else
	begin
		if(
				(select count(*) from OT_EstimacionDetalle	where		IdOTEstimacion						=	@pIdOTEstimacion)=0 
			and (select count(*) from OT_Estimacion			where		IdOTEstimacion						=	@pIdOTEstimacion)=0
		)
		begin
			SET @pError = '[ALERTA] No se encontró la estimación, no fue posible eliminar'
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

			--Deshacer estimación
			update	OT_Estimacion
			set		Cancelada			=	1,
					FechaCancelacion	=	GETDATE()
			where	IdOTEstimacion		=	@pIdOTEstimacion

			--Rechazar Carta(s)

			UPDATE petrovendor..[MM_AceptacionCartaPCN]
			SET IdEstatus = 3,
				ComentarioEvaluador = isnull(ComentarioEvaluador,'') + '|Se rechazó carta a través de cancelación en estimación control de obra '+convert(varchar,getdate(),103) +' '+ convert(varchar,getdate(),108)
			from petrovendor..[MM_AceptacionCartaPCN] c
			inner join petrovendor..MM_AceptacionPedido ap on ap.IdAceptacionPedido = c.idAceptacionPedido
			inner join Adinco..OT_Estimacion e on e.IdPedido = ap.idpedido
			where isnull(c.IdEstatus,1) = 1 AND
			e.IdOTEstimacion = @pIdOTEstimacion
			

			
			declare	@folioEstimacion	varchar(50)

			select	@IdOTSolicitud		=	IdOTSolicitud,
					@folioEstimacion	=	'Se canceló Estimacion ' + FolioEstimacion
			from	OT_Estimacion 
			where	IdOTEstimacion		=	@pIdOTEstimacion

			exec [p_OT_SolicitudBitacora_ins] @IdOTSolicitud,null, @folioEstimacion , @pIdUsuario,null,null

		end

		
		
	end


	end
	else
	begin
		SET @pError = '[ALERTA] No tienes los privilegios para realizar la acción'
	end

	
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @pError = 'ERROR spDeshacerEstimaciones '+ ERROR_MESSAGE() + ' LINEA:'+ CAST(ERROR_LINE() AS VARCHAR)
	END CATCH
end

