
create proc sp_CAT_Municipios_Cmb
(
	@IdEstado	int
)
as
begin
	select	m.IdMunicipio,
			m.IdEstado,
			m.Municipio 
	from	CAT_Municipios	m
	where	((IdEstado		=	@IdEstado)	or @IdEstado = -1)
end