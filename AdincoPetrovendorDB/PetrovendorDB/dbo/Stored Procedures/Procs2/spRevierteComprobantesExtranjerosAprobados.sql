use Petrovendor

go

if exists(select * from sys.procedures where name = 'spRevierteComprobantesExtranjerosAprobados')
begin
	drop proc spRevierteComprobantesExtranjerosAprobados
end

go

create proc spRevierteComprobantesExtranjerosAprobados
(
	@idOperacion	int,
	@motivo			varchar(max)
)
as
begin
	declare	@idDocumento								int,
			@idBitacoraReversaComprobanteExtranjero		int

	select	@idDocumento		=	IdDocumento
	from	TA_Operacion
	where	IdOperacion			=	@idOperacion

	if not exists(select * from FI_RelacionComprobanteAdinco where IdComprobantePetrovendor  = @idDocumento)
	begin 

		update	TA_Operacion
		set		IdEstatusOperacion	=	1,--2
				IdEstadoFlujo		=	1 --3
		where	IdOperacion			=	@idOperacion

		update	TA_Tarea 
		set		IdEstatus			=	1--2
		where	IdOperacion			=	@idOperacion

		
		delete
		from		FI_RelacionAdincoPedimentoComprobante		
		where		IdPedimentoComprobantePetrovendor		=	@idDocumento


		select		@idBitacoraReversaComprobanteExtranjero	=	isnull(max(IdBitacoraReversaComprobanteExtranjero),0)+1 
		from		BitacoraReversaComprobantesExtranjeros

		insert into BitacoraReversaComprobantesExtranjeros values (@idBitacoraReversaComprobanteExtranjero, @motivo, getdate(), @idOperacion)

		select	Error = 0
	end
	else
	begin
		select Error = 1
	end

end

go