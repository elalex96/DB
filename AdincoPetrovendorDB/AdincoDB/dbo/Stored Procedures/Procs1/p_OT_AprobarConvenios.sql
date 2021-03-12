
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- p_OT_AprobarConvenios 52,10,''
CREATE proc p_OT_AprobarConvenios-- 17,10,''
@pIdSubcontrato int,
@pIdUsuario int,
@pError varchar(250) out

as

	CREATE TABLE #SolicitudBitacora(Id INT IDENTITY(1,1),IdOTSolicitud INT,Descripcion VARCHAR(200),CreadoEl datetime,UsuarioAdincoId INT)

		declare @pIdOTSolicitud_i int,
			@IdOTEstatusNuevo int,
			@EmailUsuario VARCHAR(150)

		SELECT @EmailUsuario = Usuario FROM AP_Usuario WHERE UsuarioID = @pIdUsuario;

			set @pError = ''

		BEGIN TRY  
   
		begin tran

		select ot1.*
		into #tmpOTConvenio
		from OT_Solicitud ot1
		where ot1.IsActivo = 1 and
		ot1.IdSubcontrato = @pIdSubcontrato
		and ot1.IdOTEstatus = 9 --Convenio
		--and dbo.fn_SC_ExcedidoSiNo(ot1.IdOTSolicitud)  = 0
		and not exists (
			select 
				otm.IdSCMaterial,
				CantidadOT = sum(otm.Cantidad),
				sc.Cantidad
			from OT_SolicitudMaterial otm
			inner join OT_Solicitud ot on ot.IdOTSolicitud = otm.IdOTSolicitud
			inner join SC_Materiales sc on sc.IdSCMaterial = otm.IdSCMaterial
			where ot.IdOTEstatus not in (7,8) and
			sc.IdSubContrato = @pIdSubcontrato and
			ot.IsActivo = 1 and
			ot.IdOTSolicitud = ot1.IdOTSolicitud
			group by otm.IdSCMaterial,sc.Cantidad
			having sum(otm.Cantidad) > isnull(sc.Cantidad,0)
		)

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

			INSERT INTO #SolicitudBitacora(IdOTSolicitud ,Descripcion ,CreadoEl,UsuarioAdincoId)
			SELECT @pIdOTSolicitud_i, 'Aprobación de convenio por el usuario '+@EmailUsuario , GETDATE(), @pIdUsuario;

			/**********Actualizar Estatus de la OT****************/

			select @IdOTEstatusNuevo = dbo.fn_OT_CalcularEstatusSig(@pIdOTSolicitud_i)

			exec p_OT_ActualizarSolicitud @pIdOTSolicitud_i,@IdOTEstatusNuevo,@pIdUsuario,0

			select @pIdOTSolicitud_i = min(IdOTSolicitud)
			from #tmpOTConvenio
			where IdOTSolicitud > @pIdOTSolicitud_i
		end

		INSERT INTO OT_SolicitudBitacora(IdOTBitacora,IdOTSolicitud ,Descripcion ,CreadoEl,UsuarioAdincoId)
		SELECT 
			(
                SELECT MAX(IdOTBitacora) + tc.Id FROM dbo.OT_SolicitudBitacora
            ),
			IdOTSolicitud,Descripcion ,CreadoEl,UsuarioAdincoId
		FROM
			#SolicitudBitacora tc

		commit tran


		END TRY  
		BEGIN CATCH  
			rollback tran
			set @pError = error_message()

		END CATCH 

		
