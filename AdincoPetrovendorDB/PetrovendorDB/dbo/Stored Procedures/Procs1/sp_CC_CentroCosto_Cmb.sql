
CREATE proc [dbo].[sp_CC_CentroCosto_Cmb]
(
	@IdProveedor	int
)
as
begin
		select	IdCentroCosto,
				CentroCosto
		from	CC_CentroCosto
		where	((IdProveedor =	@IdProveedor) or @IdProveedor = -1)
		ORDER BY CentroCosto ASC
end