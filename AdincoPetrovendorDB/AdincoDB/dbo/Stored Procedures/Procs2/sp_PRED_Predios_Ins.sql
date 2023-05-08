
create proc sp_PRED_Predios_Ins
(
	@IdPredio				int output,
	@IdPropietario			int,
	@IdMunicipio			int,
	@IdEstado				int,
	@IdAreaContractual		int,
	@KilometrosCuadrados	float,
	@Nombre					varchar(max),
	@CreadoPor				int
)
as
begin
	select @IdPredio = isnull(max(IdPredio),0)+1 from PRED_Predios

	declare @CreadoEl datetime
	select @CreadoEl = getdate()

	insert into PRED_Predios
				(
					IdPredio,
					IdPropietario,
					IdMunicipio,
					IdEstado,
					IdAreaContractual,
					KilometrosCuadrados,
					Nombre,
					CreadoPor,
					CreadoEl,
					Activo
				)
			values
				(
					@IdPredio,
					@IdPropietario,
					@IdMunicipio,
					@IdEstado,
					@IdAreaContractual,
					@KilometrosCuadrados,
					@Nombre,
					@CreadoPor,
					@CreadoEl,
					1
				)

end