create procedure [dbo].[SP_PV_ConsultaNacionalidad]
as
begin
select NacionalidadId,Nacionalidad
 from PV_Nacionalidad
end