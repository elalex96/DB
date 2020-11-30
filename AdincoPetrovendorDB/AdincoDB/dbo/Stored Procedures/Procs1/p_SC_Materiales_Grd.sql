
create proc p_SC_Materiales_Grd
(
	@pIdSubContrato		int
)
as
begin
	select		m.IdSCMaterial,
				m.IdSubContrato,
				m.Concepto,
				m.IdMaestro,
				m.IdUnidad,
				mu.Unidad,
				m.Cantidad,
				m.PrecioUnitario,
				m.Importe,
				m.Descripcion,
				m.DescripcionCorta,
				m.IdServicio
	from		SC_Materiales						m
	inner join	Petrovendor..PV_MM_MaterialUnidad	mu
	on			mu.IdUnidad							=	m.IdUnidad
	where		IdSubContrato						=	@pIdSubContrato
end

