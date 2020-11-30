
create PROCEDURE [dbo].[SP_CF_GuardarCapitalFinanciero]
	@IdProveedor int,
	@IdTipoMoneda int,
	@CapitalContable float
AS
BEGIN
    
	update S_Proveedor
		set IdTipoMoneda = @IdTipoMoneda,
			CapitalContable = @CapitalContable
		where IdProveedor = @IdProveedor

END
