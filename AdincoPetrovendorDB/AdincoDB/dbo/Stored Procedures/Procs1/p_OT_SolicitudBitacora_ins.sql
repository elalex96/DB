-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [dbo].[p_OT_SolicitudBitacora_ins]    Script Date: 23/04/2020 05:34:30 p. m. ******/

-- [p_OT_SolicitudBitacora_ins] 30,null,'TEST',null,null
CREATE proc [dbo].[p_OT_SolicitudBitacora_ins]
@pIdOTSolicitud int,
@pFlujoAprobacionTareaId int,
@pDescripcion varchar(150),
@pUsuarioAdincoId int,
@pUsuarioPetroId int,
@pTipo int = null
as


	declare @IdOTBitacora int

	
	if(isnull(@pTipo,0) = 0)
	begin
		select @pTipo = case when  @pDescripcion like '%Aprobada%Operador%'  then 2
							 when  @pDescripcion like '%Enviada%Subcontratista%'  then 3
							 when  @pDescripcion like'%Aprobada%Subcontratista%'  then 4
							  when  @pDescripcion like'%Propuesta%Subcontratista%'  then 5
							  else null
						end
	end


	select @IdOTBitacora = isnull(max(IdOTBitacora),0) + 1
	from OT_SolicitudBitacora

	insert into OT_SolicitudBitacora(
		IdOTBitacora,		IdOTSolicitud,		FlujoAprobacionTareaId,		Descripcion,
		CreadoEl,			UsuarioAdincoId,	UsuarioPetroId,IdTipoMovimiento
	)
	select @IdOTBitacora,	@pIdOTSolicitud,	@pFlujoAprobacionTareaId,	@pDescripcion,
		getdate(),		@pUsuarioAdincoId,	  @pUsuarioPetroId	,@pTipo


