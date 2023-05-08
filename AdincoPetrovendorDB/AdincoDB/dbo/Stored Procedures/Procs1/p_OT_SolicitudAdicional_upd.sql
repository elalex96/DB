create proc p_OT_SolicitudAdicional_upd
@pIdOTSolicitudAdicional int,
@pIdOTEstatusAdicional int,
@pUsuarioId int,
@pComentarios varchar(300)='',
@pError varchar(250) out
as

	set @pError = ''
	begin try
		

		--Validaciones
		if not exists (
			select 1
			from OT_SolicitudAdicionalMaterial
			where IdOTSolicitudAdicional = @pIdOTSolicitudAdicional
		)
		begin
			set @pError = 'No se detectaron cambios en los servicios, no es posible continuar'
			return
		end	

		begin tran

		update OT_SolicitudAdicional
		set IdEstatusAdicional = @pIdOTEstatusAdicional
		where IdOTSolicitudAdicional = @pIdOTSolicitudAdicional

		
	   insert into [dbo].[OT_SolicitudAdicionalBitacora](		
				IdOTSolicitudAdicional,IdOTEstatusAdicional,Descripcion,CreadoEl,CreadoPor
		)
		select @pIdOTSolicitudAdicional,@pIdOTEstatusAdicional,@pComentarios,getdate(),@pUsuarioId		

		/*Se aprobó*/
		if(@pIdOTEstatusAdicional = 3)
		begin
			exec p_OT_SolicituAdicional_Aprobada @pIdOTSolicitudAdicional,@pUsuarioId,@pError out
		end
		

		if(isnull(@pError,'') <> '')
		begin
			rollback tran
			
		end
		else
		begin

			exec p_OT_SolicitudAdicional_not @pIdOTSolicitudAdicional,@pIdOTEstatusAdicional,@pUsuarioId,@pError out

			if(isnull(@pError,'') <> '')
			begin
				rollback tran
			
			end
			else
			begin
				commit tran
			end
		end

	end try
	begin catch
		rollback tran

		set @pError = ERROR_MESSAGE()
	end catch
	