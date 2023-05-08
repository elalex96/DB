-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegObjUserProv] 
	-- Add the parameters for the stored procedure here
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select U.Nombre, U.Correo, U.Contrasena, U.IdTipoUsuario, P.IdNacionalidad, N.Nacionalidad, P.RFC, P.IdTipoRegimen, TP.TipoRegimen, P.RazonSocial, P.RegimenCapital, P.IdProveedor
	from S_Usuario U
	join S_UsuarioProveedor UP on U.IdUsuario = UP.IdUsuario
	join S_Proveedor P on UP.IdProveedor = P.IdProveedor
	join S_Nacionalidad N on P.IdNacionalidad = N.IdNacionalidad
	join S_TipoRegimen TP on P.IdTipoRegimen = TP.IdTipoRegimen
	where U.IdUsuario = @IdUsuario and U.IsEliminado = 0 and U.Activo = 1

END

