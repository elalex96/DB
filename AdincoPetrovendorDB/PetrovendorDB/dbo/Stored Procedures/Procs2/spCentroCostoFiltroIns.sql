use Petrovendor

go

if exists (select * from sys.procedures where name  = 'spCentroCostoFiltroIns')
begin
	drop proc spCentroCostoFiltroIns
end

go

create proc spCentroCostoFiltroIns
(
	@IdCentroCosto	int,
	@IdUsuario		int,
	@IdProveedor	int
)
as
begin
	if exists(
		select * 
		from	CentroCostoFiltro 
		where	IdCentroCosto		=	@IdCentroCosto
		and		IdUsuario			=	@IdUsuario
		and		IdProveedor			=	@IdProveedor
	)
	begin
			update	CentroCostoFiltro 
			set		Activo				=	1,
					ModificadoEl		=	getdate()
			where	IdCentroCosto		=	@IdCentroCosto
			and		IdUsuario			=	@IdUsuario
			and		IdProveedor			=	@IdProveedor
	end
	else
	begin
	
		insert into CentroCostoFiltro
					(
						IdCentroCosto,
						IdUsuario,
						IdProveedor,
						Activo,
						CreadoEl,
						ModificadoEl
					)
				values
					(
						@IdCentroCosto,
						@IdUsuario,
						@IdProveedor,
						1,
						getdate(),
						null
					)
	end
end