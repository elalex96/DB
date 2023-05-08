
create proc spEN_ClasificacionUpd
(
	@idClasificacion		int,
	@NombreClasificacion	varchar(max),
	@idUsuario				int,
	@activo					bit,
	@BitJOA					bit
)
as
begin
	

	if not exists (select * from EN_Clasificacion  where NombreClasificacion = @NombreClasificacion and IdClasificacion	<>	@idClasificacion)
	begin
			update	EN_Clasificacion 
			set		NombreClasificacion		=	@NombreClasificacion,
					ModificadoPor			=	@idUsuario,
					ModificadoEl			=	getdate(),
					activo					=	@activo,
					BitJOA					=	@BitJOA
			where	IdClasificacion			=	@idClasificacion
						
			select		Error	=	0
		end
		else
		begin
			select		Error	=	1
		end
end

