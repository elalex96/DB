
create PROCEDURE [dbo].[SP_CE_consultarClasificacionEmpresa]
	@IdProveedor int
AS
BEGIN
     
	 select ce.IdResultado, ce.IdClasificacionEmpresa, cp.Nombre, ce.IdSector, ce.NumEmpleados, ce.ImporteVentas 
		from PV_ClasificacionEmpresaProveedor as ce
			inner join PV_ClasificacionPyMES as cp on cp.IdClasificacion = ce.IdClasificacionEmpresa
		where IdProveedor = @IdProveedor
	 	 
END



