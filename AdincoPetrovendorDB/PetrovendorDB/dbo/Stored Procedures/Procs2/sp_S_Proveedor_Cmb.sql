use Petrovendor
go
if exists(select * from sys.procedures where name = 'sp_S_Proveedor_Cmb')
begin
	drop proc sp_S_Proveedor_Cmb
end

go

create proc sp_S_Proveedor_Cmb
as
begin
		select	IdProveedor,
				RazonSocial
		from	S_Proveedor
end

go 

