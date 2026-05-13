

CREATE Function [dbo].[fnDesEncriptar](
@cadena varbinary(max) 
)
returns varchar(max)
begin

	
	return  convert(varchar(max),DecryptByPassPhrase('key', @cadena )) 

end
