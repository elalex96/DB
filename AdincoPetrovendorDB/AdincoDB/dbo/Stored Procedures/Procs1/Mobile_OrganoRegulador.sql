create procedure [dbo].[Mobile_OrganoRegulador]
as
begin 
	select IdOrganoRegulador,NombreOrganoRegulador from AM_OrganoRegulador where Activo = 1
end
