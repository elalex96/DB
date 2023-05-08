create procedure [dbo].[SP_GiroComercialHijo](@ID int )
as
begin
select IdGiroProveedorHijo,GiroProovedor from PV_GiroComercialHijo
where IdGiroProveedorPadre=@ID
end

