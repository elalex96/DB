CREATE PROCEDURE [dbo].[Mobile_sp_RegistroBitacora_Aprobacio]
	@IdTarea Int,
	@IdContrato Int,
	@IdEstatus Int,
	@Comentario varchar(max),
	@AprobadorPetrovendor Int,
	@AprobadorAdinco Int,
	@FechaAprobacion datetime
as
begin	
	if not exists(select 1 from AM_BitacoraAprobaciones where IdTarea = @IdTarea)
	begin
		insert Into AM_BitacoraAprobaciones(IdTarea ,
								IdContrato ,
								IdEstatus ,
								Comentario ,
								AprobadorPetrovendor ,
								AprobadorAdinco ,
								FechaAprobacion ) values (@IdTarea,
								@IdContrato,
								@IdEstatus,
								@Comentario,
								@AprobadorPetrovendor,
								@AprobadorAdinco,
								@FechaAprobacion
								)
	end
end