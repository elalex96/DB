
create PROCEDURE [dbo].[SP_CF_consultarCapacidadFinanciera]
	@IdProveedor int
AS
BEGIN
     select p.CapitalContable, p.IdTipoMoneda, tm.TipoMoneda
		from S_Proveedor as p
			inner join PV_TipoMoneda as tm on tm.IdMoneda = p.IdTipoMoneda
		where p.IdProveedor = @IdProveedor
	 	 
END

