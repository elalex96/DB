use Petrovendor

go

if exists(select * from sys.procedures where name = 'sp_S_Usuario_Cmb')
begin
	drop proc sp_S_Usuario_Cmb
end

go

create proc sp_S_Usuario_Cmb
as
begin
		select	IdUsuario,
				Nombre
		from	S_Usuario
end