create proc p_OT_Terminos_Guardar
@pIdOTSolicitud int,
@pIdTerminos int,
@pUsuarioId int,
@pError varchar(250) out
as

	BEGIN TRY  
		begin tran

		update OT_Solicitud
		set IdTerminos = @pIdTerminos
		where IdOTSolicitud = @pIdOTSolicitud
		
		exec p_OT_SolicitudBitacora_ins @pIdOTSolicitud,null,'Se actualizaron Términos y Condiciones',@pUsuarioId,null

		commit tran
	END TRY  
	BEGIN CATCH  

		set @pError = error_message() 
		 
	END CATCH

	