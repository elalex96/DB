create procedure [dbo].[Mobile_MarcoLegal]
@IdOrganoRegulador int
as
begin
	select IdMarcoLegal,IdOrganoRegulador,NombreMarcoLegal 
	from AM_MarcoLegal 
	where IdOrganoRegulador =@IdOrganoRegulador
end
