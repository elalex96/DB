
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- p_OT_AprobarConvenios 52,10,''
CREATE proc p_OT_AprobarConvenios
@pIdSubcontrato int,
@pIdUsuario int,
@pError varchar(250) out

as

		declare @pIdOTSolicitud_i int,
			@IdOTEstatusNuevo int

			set @pError = ''

		BEGIN TRY  
   
		begin tran

		select ot1.*
		into #tmpOTConvenio
		from OT_Solicitud ot1
		where ot1.IsActivo = 1 and
		ot1.IdSubcontrato = @pIdSubcontrato
		and ot1.IdOTEstatus = 9 --Convenio
		and dbo.fn_SC_ExcedidoSiNo(ot1.IdOTSolicitud)  = 0

		select @pIdOTSolicitud_i = min(IdOTSolicitud)
		from #tmpOTConvenio

		

		

		while @pIdOTSolicitud_i is not null
		begin

			update OT_Convenio
			set Aprobada = 1,
				AprobadaPor = @pIdUsuario,
				FechaAprobacion = getdate()
			from OT_Convenio con
			inner join OT_Solicitud otsol on otsol.IdOTSolicitud = con.IdOTSolicitud
			inner join SC_Subcontrato sc on sc.IdSubContrato = otsol.IdSubContrato
			where sc.IdSubContrato = @pIdSubContrato and
			otsol.IdOTSolicitud = @pIdOTSolicitud_i and
			AprobadaPor is null


			/**********Actualizar Estatus de la OT****************/

			select @IdOTEstatusNuevo = dbo.fn_OT_CalcularEstatusSig(@pIdOTSolicitud_i)

		
			exec p_OT_ActualizarSolicitud @pIdOTSolicitud_i,@IdOTEstatusNuevo,@pIdUsuario,0

			select @pIdOTSolicitud_i = min(IdOTSolicitud)
			from #tmpOTConvenio
			where IdOTSolicitud > @pIdOTSolicitud_i

		end

		

		commit tran


		END TRY  
		BEGIN CATCH  
			rollback tran
			set @pError = error_message()

		END CATCH 



