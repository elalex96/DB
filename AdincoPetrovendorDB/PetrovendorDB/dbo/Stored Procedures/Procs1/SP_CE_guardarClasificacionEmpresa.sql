
create PROCEDURE [dbo].[SP_CE_guardarClasificacionEmpresa]
	@IdProveedor int,
	@IdClasificacionEmpresa int,
	@IdSector int,
	@NumEmpleados int,
	@ImporteVentas float
AS
BEGIN
     declare @contador int = (select count(IdResultado) from PV_ClasificacionEmpresaProveedor where IdProveedor = @IdProveedor)

	 if(@contador > 0)
	 begin

		update PV_ClasificacionEmpresaProveedor
			set IdClasificacionEmpresa = @IdClasificacionEmpresa,
				IdSector = @IdSector,
				NumEmpleados = @NumEmpleados,
				ImporteVentas = @ImporteVentas
			where IdProveedor = @IdProveedor

	 end
	 else
	 begin
		insert into PV_ClasificacionEmpresaProveedor(IdProveedor, IdClasificacionEmpresa, IdSector, NumEmpleados, ImporteVentas)
			values(@IdProveedor, @IdClasificacionEmpresa, @IdSector, @NumEmpleados, @ImporteVentas)
	 end
	 	 
END



