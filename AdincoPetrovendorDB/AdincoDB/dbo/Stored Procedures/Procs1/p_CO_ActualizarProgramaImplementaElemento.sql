
create Proc p_CO_ActualizarProgramaImplementaElemento
(
	@pIdProgramaImplementaElemento	int ,
	@pIdProgramaImplementa			int,
	@pDescripcion					varchar(1500),
	@pCreadoPor						int
)
as
begin
	update	[CO_ProgramaImplementaElemento]
	set		Descripcion						=	@pDescripcion,
			ModificadoEl					=	GETDATE(),
			ModificadoPor					=	@pCreadoPor
	where	IdProgramaImplementaElemento	=	@pIdProgramaImplementaElemento
end