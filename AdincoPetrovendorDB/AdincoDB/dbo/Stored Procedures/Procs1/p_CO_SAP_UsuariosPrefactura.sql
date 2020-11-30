CREATE PROCEDURE [dbo].[p_CO_SAP_UsuariosPrefactura]
@IdSAPProforma int 
as
begin
	SELECT 
	top 1
	u.IdUsuario
	,u.Nombre
	,u.Correo
	FROM CO_SAPProforma p
	join Petrovendor..S_Usuario as u on p.CreadoPor = u.IdUsuario
	where p.IdSAPProforma = @IdSAPProforma
end
