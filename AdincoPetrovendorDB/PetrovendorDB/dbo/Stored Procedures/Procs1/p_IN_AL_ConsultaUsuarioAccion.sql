
-- p_IN_AL_ConsultaUsuarioAccion 2
create proc p_IN_AL_ConsultaUsuarioAccion
@pIdUsuario int
as
	declare @IdusuarioPetro int

	select @IdusuarioPetro = up.IdUsuario
	from Adinco..Ap_usuario ap
	inner join S_usuario  up on up.Correo collate SQL_Latin1_General_CP1_CI_AS= ap.usuario collate SQL_Latin1_General_CP1_CI_AS
	where  usuarioid  =@pIdUsuario 

	select 	
		
		aa.IdAccion,
		Accion = aa.Nombre,
		Activo = cast(case when uaa.IdAccion is not null then 1 else 0 end as bit )
		
	from  S_AlmacenAccion aa 
	left join S_UsuarioAlmacenAccion uaa on
										uaa.IdAccion = aa.IdAccion and
										uaa.IdUsuario = @IdusuarioPetro
	
	