create procedure [dbo].[IndicadorCotizacionesPendiente](@IdProveedor  int)
as
begin
SELECT COUNT(*) as 'No Finalizado'  from MM_PeticionOferta where Finalizado=0 and idSubcontratista=@IdProveedor

end
