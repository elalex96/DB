use Petrovendor

go

if exists (select * from sys.procedures where name  = 'spCentroCostoFiltroDel')
begin
	drop proc spCentroCostoFiltroDel
end

go

create proc spCentroCostoFiltroDel
(
	@IdCentroCosto	int,
	@IdUsuario		int,
	@IdProveedor	int
)
as
begin

			update	CentroCostoFiltro 
			set		Activo				=	0,
					ModificadoEl		=	getdate()
			where	IdCentroCosto		=	@IdCentroCosto
			and		IdUsuario			=	@IdUsuario
			and		IdProveedor			=	@IdProveedor
	
end