---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Daniel AC
-- Create date: 29-08-17
-- Description:	SP para validar información de usuario
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_AutentificarUsuario]  
	-- Add the parameters for the stored procedure here

	@Correo nvarchar(MAX),
	@Contrasenia nvarchar(MAX)
	
	AS
	BEGIN	 
	SET NOCOUNT ON;
	---Validar que el proveedor no este registrado en la base de datos 
	SELECT U.IdUsuario, U.Activo, U.IdTipoUsuario, U.Nombre  
	FROM S_USUARIO AS U WHERE U.Correo = @Correo
	AND U.Contrasena = @Contrasenia ---AND IsEliminado=0
		
END


