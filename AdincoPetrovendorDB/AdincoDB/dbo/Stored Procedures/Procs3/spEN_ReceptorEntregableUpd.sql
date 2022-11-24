
create proc spEN_ReceptorEntregableUpd
(
	@idReceptorEntregable	int,
	@receptorEntregable		varchar(max),
	@idUsuario				int
)
as
begin
	

	if not exists (select * from EN_ReceptorEntregable  where ReceptorEntregable = @receptorEntregable and IdReceptorEntregable	<>	@idReceptorEntregable)
	begin
			update	EN_ReceptorEntregable 
			set		ReceptorEntregable		=	@receptorEntregable,
					CreadoPor				=	@idUsuario,
					CreadoEn				=	getdate()
			where	IdReceptorEntregable	=	@idReceptorEntregable
						
			select		Error	=	0
		end
		else
		begin
			select		Error	=	1
		end
end

