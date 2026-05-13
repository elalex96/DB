
create proc sp_CO_ProgramaImplementa_Importar_Ins
(
    
	@IdProgramaImplementa	int,
	@DescripcionPolitica	varchar(max),
	@DescripcionElemento	varchar(max),
	@DescripcionAccion		varchar(max),
	@Departamento			varchar(max),
	@IniciaPrimerAccion		date,
	@TerminaPrimerAccion	date,
	@Anexo3					varchar(max),
	@Numerales				varchar(max),
	@Periodicidad			varchar(max),
	@Porcentaje				money,
	@pIdContrato			int,
	@pIdUsuario				int
)
as
begin

    
    select	@IdProgramaImplementa	=	isnull(max(IdProgramaImplementa),0)+1 from CO_ProgramaImplementa_Importar
    insert	into	CO_ProgramaImplementa_Importar
                (
                    
					IdProgramaImplementa,
					DescripcionPolitica,
					DescripcionElemento,
					DescripcionAccion,
					Departamento,
					IniciaPrimerAccion,
					TerminaPrimerAccion,
					Anexo3,
					Numerales,
					Periodicidad,
					Porcentaje,
					IdContrato,
					IdUsuario
		)

            values
                (
                    
					@IdProgramaImplementa,
					@DescripcionPolitica,
					@DescripcionElemento,
					@DescripcionAccion,
					@Departamento,
					@IniciaPrimerAccion,
					@TerminaPrimerAccion,
					@Anexo3,
					@Numerales,
					@Periodicidad,
					@Porcentaje,
					@pIdContrato,
					@pIdUsuario
		)


end