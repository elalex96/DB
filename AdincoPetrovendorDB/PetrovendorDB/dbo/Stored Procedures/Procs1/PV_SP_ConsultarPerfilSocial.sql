
CREATE procedure [dbo].[PV_SP_ConsultarPerfilSocial]
	@IdProveedor INT

AS
BEGIN
	SELECT SitioWeb, Facebook, Twitter
		FROM dbo.PV_PerfilSocial WHERE IdProveedor = @IdProveedor
END
