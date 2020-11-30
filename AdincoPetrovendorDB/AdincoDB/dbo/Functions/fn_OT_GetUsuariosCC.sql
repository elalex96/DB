
create FUNCTION [dbo].[fn_OT_GetUsuariosCC] 
(
	-- Add the parameters for the function here
	@pIdContratista int,
	@pUsuarioId int

)
RETURNS varchar(1000)
AS
BEGIN
	
	declare @result varchar(1000)=''

	select @result = @result + cc.CentroCosto +', '
	from [AP_UsuarioCentroCosto] ucc
	inner join petrovendor..Cc_centrocosto cc on cc.IdCentroCosto = ucc.IdCentroCosto
	where ucc.IdUsuario = @pUsuarioId



	return isnull(@result,'')

END


