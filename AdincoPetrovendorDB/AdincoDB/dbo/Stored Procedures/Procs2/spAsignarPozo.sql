if exists (select * from sys.procedures where name = 'spAsignarPozo')
begin
	drop proc spAsignarPozo
end

go

create proc spAsignarPozo
(
	@IdInstanciaEntregable		int,
	@IdInstalacion				int,
	@FechaCalculadaEntregaReg	date,
	@IdUsuario					int,
	@IdContrato					int
)
as
begin

	update	EN_InstanciasEntregable
	set		IdInstalacion			=	@IdInstalacion
	where	idInstanciaEntregable	=	@IdInstanciaEntregable

	if(@FechaCalculadaEntregaReg = '1753-01-01') 
	begin
		select @FechaCalculadaEntregaReg = null
	end

	insert	into	EN_ExcepcionesFechaBitacora
			values	(
						@IdInstanciaEntregable,
						@FechaCalculadaEntregaReg,
						@IdUsuario,
						@IdContrato,
						GETDATE(),
						@IdInstalacion
					)
end