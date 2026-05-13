Create Proc sp_FI_ObtenerTextoPDFConfig
@pRFC varchar(15)
as

select Id,
RFC 
from [dbo].[FI_TextoPDFConfig]
where rfc = @pRFC