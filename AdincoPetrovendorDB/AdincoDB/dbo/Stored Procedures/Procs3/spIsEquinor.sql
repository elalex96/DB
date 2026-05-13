CREATE proc spIsEquinor
(
	@IdContrato	int
)
as
begin
	
	if exists(
		select		ct.* 
		from		CO_Contrato			c
		inner join	CO_Contratista		ct
		on			c.IdContratista		=		ct.IdContratista
		where		IdContrato			=		@IdContrato
		and			( NombreContratista	like	'%Equinor%'-- Cambiar por 'Equinor'
		--OR NombreContratista LIKE '%SMART%'
		)
	)
	begin
		select IsEquinor	=	cast(1 as bit)
	end
	else
	begin
		select IsEquinor	=	cast(0 as bit)
	end

end