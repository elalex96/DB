
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

