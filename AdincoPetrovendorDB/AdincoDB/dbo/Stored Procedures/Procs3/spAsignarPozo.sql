
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
						GETDATE()
					)
end


--select * from EN_InstanciasEntregable where IdInstalacion is not null
