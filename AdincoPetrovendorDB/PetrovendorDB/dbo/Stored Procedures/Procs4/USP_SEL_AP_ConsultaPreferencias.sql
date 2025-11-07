USE Petrovendor
go
drop proc if exists USP_SEL_AP_ConsultaPreferencias
go
create proc USP_SEL_AP_ConsultaPreferencias
@IdUsuario int = 0,
@IdContrato int = 0,
@IdProveedor int = 0
as
begin
	select * from AP_Preferencias
end