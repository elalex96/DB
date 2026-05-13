use Petrovendor
go
drop proc if exists USP_SEL_PV_ConsultaBancos
go
-- =============================================
-- Author:      Daniel AC
-- Create date: 20/04/2026
-- Description: Se actualiza para retornar solo el nombre de datos de creado y modificado por 
-- =============================================
create proc USP_SEL_PV_ConsultaBancos
@IdContrato int = null,
@IdUsuario int = null
as
begin
	SELECT b.BancoID,
			b.Banco,
			b.Clave,
			b.RazonSocial,
			ISNULL(b.Nacional,0) AS Nacional,
			ISNULL(b.Activo,0) AS Activo,
			uc.Nombre AS CreadoPorNombre,
			b.CreadoEl,
			um.Nombre AS ModificadoPorNombre,
			b.ModificadoEl
	FROM pv_banco b
	LEFT JOIN S_Usuario uc (NOLOCK) ON uc.IdUsuario = b.CreadoPor
	LEFT JOIN S_Usuario um (NOLOCK) ON um.IdUsuario = b.ModificadoPor
	ORDER BY b.BancoID DESC
end