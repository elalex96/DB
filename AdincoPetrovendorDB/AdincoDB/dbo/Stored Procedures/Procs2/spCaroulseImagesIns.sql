if exists (select * from sys.procedures where name = 'spCaroulseImagesIns')
begin
	drop proc spCaroulseImagesIns
end

go

create proc spCaroulseImagesIns
(
	@Carpeta	varchar(100),
	@Nombre		varchar(100)
)
as
begin
	declare	@IdCarouselImage	int
	select	@IdCarouselImage	=	isnull(max(IdCarouselImage),0)+1 from CaroulseImages

	insert	into	CaroulseImages
			values	(
						@IdCarouselImage,
						@Carpeta,
						@Nombre,
						1
					)
end

go