
create proc spEN_ClasificacionIns
(
	@NombreClasificacion	varchar(500),
	@CreadoPor				int,
	@activo					bit,
	@BitJOA					bit
)
as
begin
	if not exists (select * from EN_Clasificacion  where NombreClasificacion = @NombreClasificacion)
	begin
		insert into EN_Clasificacion 
					(
						NombreClasificacion,
						CreadoEl,
						CreadoPor,
						ModificadoEl,
						ModificadoPor,
						activo,
						BitJOA
					)
				values
					(
						@nombreClasificacion,
						getdate(),
						@creadoPor,
						null,
						null,
						@activo,
						@bitJOA
					)
		select		Error	=	0
	end
	else
	begin
		select		Error	=	1
	end
end