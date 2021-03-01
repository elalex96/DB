use Adinco 

go

if exists (select * from sys.procedures where name = 'spTienePermisosAdmin')
begin
	drop proc spTienePermisosAdmin
end

go

create proc spTienePermisosAdmin
(
	@UsuarioId	int,
	@ContratoId	int
)
as
begin
	if exists
	(
		select		* 
		from		Ap_PerfilUsuario	pu
		inner join	AP_Perfil			p
		on			pu.PerfilID			=	p.IdPerfil
		inner join	AP_Rol				r
		on			p.IdRol				=	r.IdRol
		where		rol					like '%admin%'
		and			pu.UsuarioID		=	@UsuarioId
		and			p.IdContrato		=	@ContratoId
	)
	begin
		select TienePermisos = cast(1 as bit)
	end
	else
	begin
		select TienePermisos = cast(0 as bit)
	end
end