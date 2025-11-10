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
	select Pc.Id, PC.ContratoId, PC.PreferenciaId,PC.Valor,PC.Activo,PC.CreadoEl,PC.CreadoPor,PC.ModificadoPor,PC.ModificadoEl from  AP_PreferenciaContrato as PC
	where PC.PreferenciaId = @IdPreferencia
end
