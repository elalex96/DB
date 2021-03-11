create proc sp_ProgramaImplementaPolitica_ReOrden --21, 139, 1047, 8353,0,1
(
	@pIdProgramaImplementa			int,
	@pIdProgramaImplementaPolitica	int,
	@pOrden							int, 
	@pUpDown						int
)
as
begin

	declare @pOrdenNew int = @pOrden + @pUpDown

	exec sp_ProgramaImplementaPolitica_ReOrdenMoveTo 
		@pIdProgramaImplementa,	@pIdProgramaImplementaPolitica,
		@pOrden,				@pOrdenNew
end

go
