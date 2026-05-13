
create proc sp_PRED_Predios_Upd
(
	@IdPredio				int,
	@IdPropietario			int,
	@IdMunicipio			int,
	@IdEstado				int,
	@IdAreaContractual		int,
	@KilometrosCuadrados	float,
	@Nombre					varchar(max),
	@ModificadoPor			int
)
as
begin

	declare	@ModificadoEl		datetime
	select	@ModificadoEl		=	getdate()
	update	PRED_Predios
	set		
			IdPropietario		=	@IdPropietario,
			IdMunicipio			=	@IdMunicipio,
			IdEstado			=	@IdEstado,
			IdAreaContractual	=	@IdAreaContractual,
			KilometrosCuadrados	=	@KilometrosCuadrados,
			Nombre				=	@Nombre,
			ModificadoPor		=	@ModificadoPor,
			ModificadoEl		=	@ModificadoEl
	where	IdPredio			=	@IdPredio
						
end
