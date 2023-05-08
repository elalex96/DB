create procedure [dbo].[Mobile_DocumentoMarcoLegal]
@IdMarcoLegal int
as
begin
	select NombreDocumento,Url from AM_DocumentoMarcoLegal where IdMarcoLegal = @IdMarcoLegal
end
