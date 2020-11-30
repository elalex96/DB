
create Function [dbo].[fnEncriptar](
@cadena  varchar(max) 
)
returns  varchar(max) 
begin

	declare @encrypt varbinary(max) 
	select @encrypt = EncryptByPassPhrase('key', @cadena )
	return '0x'+CONVERT(varchar(max),@encrypt,2)  

end
