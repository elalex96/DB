USE Petrovendor
go
drop proc if exists USP_SEL_AP_ConsultaPreferenciasContrato
go
create proc USP_SEL_AP_ConsultaPreferenciasContrato
@IdUsuario int = 0,
@IdContrato int = 0,
@IdProveedor int = 0,
@IdPreferencia int 
as
begin
	select * from  AP_PreferenciaContrato as PC
	where PC.PreferenciaId = @IdPreferencia
end