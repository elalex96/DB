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
	select
		PC.Id,
		PC.ContratoId,
		PC.PreferenciaId,
		PC.Valor,
		PC.Activo,
		PC.CreadoEl,
		US.Nombre  AS CreadoPor,
		USM.Nombre AS ModificadoPor,
		PC.ModificadoEl
	from AP_PreferenciaContrato AS PC WITH (NOLOCK)
	join S_Usuario AS US  WITH (NOLOCK) ON PC.CreadoPor    = US.IdUsuario
	join S_Usuario AS USM WITH (NOLOCK) ON PC.ModificadoPor = USM.IdUsuario
	where PC.PreferenciaId = @IdPreferencia
end
