use Petrovendor

go

if exists(select * from sys.procedures where name = 'sp_CC_CentroCosto_Cmb')
begin
	drop proc sp_CC_CentroCosto_Cmb
end

go

create proc sp_CC_CentroCosto_Cmb
(
	@IdProveedor	int
)
as
begin
		select	IdCentroCosto,
				CentroCosto
		from	CC_CentroCosto
		where	((IdProveedor =	@IdProveedor) or @IdProveedor = -1)
end

go

