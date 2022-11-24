
create proc spIsShell
(
	@IdContrato	int
)
as
begin
	if exists(
		select		co.* 
		from		CO_Contrato				co
		inner join	CO_Contratista			ci
		on			co.IdContratista		=		ci.IdContratista
		where		ci.NombreContratista	like	'%shell%'
		and			co.IdContrato			=		@IdContrato
	)
	begin
		select	IsShell		=	cast(1 as bit)
	end
	else
	begin
		select	IsShell		=	cast(0 as bit)
	end
end