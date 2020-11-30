CREATE PROCEDURE [dbo].[SP_CalculoPrecios_ActualizarPrecios]   
    @NuevoPrecio Money,   
    @IdOperacionCom int
AS   

	UPDATE COM_OperacionComercializacion 
	SET NuevoPrecioVentaUnitario = @NuevoPrecio
	WHERE IdOperacionComercializacion = @IdOperacionCom