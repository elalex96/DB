
-- p_IN_AL_ActualizaUsuarioAccion 2,1,1,'mg@smps-sp.com'
create proc p_IN_AL_ActualizaUsuarioAccion
@pIdUsuario int,
@pIdAccion int,
@pActivo bit,
@pUsuarioMail varchar(50)
as

	declare @IdUsuarioPetro int

	select @IdUsuarioPetro = isnull(IdUsuario,0)
	from S_Usuario
	where correo = @pUsuarioMail

	



	if exists (
		select 1
		from [S_UsuarioAlmacenAccion]
		where IdAccion = @pIdAccion and
		IdUsuario = @IdUsuarioPetro
	) AND
	@pActivo = 0
	begin
		DELETE [S_UsuarioAlmacenAccion]		
		where IdAccion = @pIdAccion and
		IdUsuario = @IdUsuarioPetro
	end
	else
	Begin

		
		IF(@PaCTIVO = 1) and not exists (
			select 1
			from [S_UsuarioAlmacenAccion]
			where IdAccion = @pIdAccion and
			IdUsuario = @IdUsuarioPetro
		) 
		begin
			insert into dbo.[S_UsuarioAlmacenAccion](
			IdAccion,		IdUsuario,		CreadoEl,		CreadoPor
			)
			values(@pIdAccion,@IdUsuarioPetro,getdate(),isnull(@IdUsuarioPetro,0))
		end
		

	End

	

	