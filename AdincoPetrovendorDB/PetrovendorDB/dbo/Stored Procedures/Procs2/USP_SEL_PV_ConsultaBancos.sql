use Petrovendor
go
drop proc if exists USP_SEL_PV_ConsultaBancos
go
create proc USP_SEL_PV_ConsultaBancos
@IdContrato int = null,
@IdUsuario int = null
as
begin
	SELECT BancoID,
			Banco,
			Clave,
			RazonSocial,
			ISNULL(Nacional,0) AS Nacional,
			ISNULL(Activo,0) AS Activo,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl
	FROM pv_banco
	ORDER BY BancoID DESC
end
