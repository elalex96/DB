---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc p_OT_Solicitud_Upd
@pIdOTSolicitud int,
@pObjeto varchar(600),
@pSAPPR varchar(15),
@pError varchar(250) out
as
	set @pError = ''

	BEGIN TRY  

		update OT_Solicitud
		set SAPPR = @pSAPPR,
			Objeto =case when isnull(@pObjeto,'')='' then Objeto else @pobjeto end,
			FechaAprobacionSAPPR  = case when FechaAprobacionSAPPR is null then  
											case when @pSAPPR <>  SAPPR then getdate() else FechaAprobacionSAPPR end
										 else FechaAprobacionSAPPR
									end,
			ModificadoEl = getdate()
		where IdOTSolicitud = @pIdOTSolicitud

	
		if isnull(@pSAPPR,'') <> ''
		begin


				Update petrovendor..DEA_AdjuntoPR
				set ID_PR = @pSAPPR
				from petrovendor..DEA_AdjuntoPR a 
				inner join OT_Estimacion e on e.IdOTSolicitud = @pIdOTSolicitud 
				inner join petrovendor..MM_Pedido p on p.IdPedido = e.IdPedido  and a.IdSolicitudPedido = p.IdSolicitudPedido
			

				INSERT INTO petrovendor..DEA_AdjuntoPR(IdSolicitudPedido,IdDocumento,IdProveedor,
				Comentario,CreadoPor,CreadoEl,EditadoEl,
				EditadoPor,EliminadoEl,EliminadoPor,Activo,
				IsEliminado,ID_PR)
				select p.IdSolicitudPedido,null,p.IdProveedorCompras,
				e.FolioEstimacion,null,getdate(),null,
				null,null,null,1,
				0,@pSAPPR
				from OT_Estimacion e
				inner join petrovendor..MM_Pedido p on p.IdPedido = e.IdPedido 
				where e.IdOTSolicitud = @pIdOTSolicitud and
				not exists (
					select 1
					from petrovendor..DEA_AdjuntoPR
					where IdSolicitudPedido = p.IdSolicitudPedido
				) and isnull(e.cancelada,0) = 0

				
		end
		
		

	END TRY  
	BEGIN CATCH  
		set @pError = error_message()
	END CATCH 



