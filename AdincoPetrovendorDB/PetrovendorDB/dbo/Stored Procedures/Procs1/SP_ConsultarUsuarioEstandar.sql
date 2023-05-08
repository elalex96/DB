-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarUsuarioEstandar]
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select U.IdUsuario, U.Nombre, U.Correo, U.Contrasena, U.IdTipoUsuario,U.Telefono, TU.NombreTipoUsuario, U.Activo, UP.IdProveedor 
from   S_Usuario as U 
inner join S_TipoUsuario as TU on U.IdTipoUsuario = TU.IdTipoUsuario
inner join S_UsuarioProveedor as UP on U.IdUsuario = UP.IdUsuario
where UP.IDProveedor = @IdProveedor and U.IdTipoUsuario != 3 AND (u.IsEliminado= 0 OR u.IsEliminado IS NULL)

END

