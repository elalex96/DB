if exists (select * from sys.procedures where name = 'spCaroulseImagesLst')
begin
	drop proc spCaroulseImagesLst
end

go

create proc spCaroulseImagesLst
(
	@Carpeta	varchar(100)
)
as
begin
	select	IdCarouselImage,
			Carpeta,
			Nombre,
			Activo
	from	CaroulseImages 
	where	Carpeta			like	@Carpeta
	and		Activo			=		1
			
end

go
