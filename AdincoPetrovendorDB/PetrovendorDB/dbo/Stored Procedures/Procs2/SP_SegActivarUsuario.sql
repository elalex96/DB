-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-01-17
-- Description:	SP Activación de Cuenta de Usuario Administrador 
-- =============================================
-- Modified:      <Jose Roman>									
-- Updated date: <23/03/2018>									
-- Description: <Se cambia la verificacion >			
--**************************************************************
CREATE PROCEDURE [dbo].[SP_SegActivarUsuario]
	-- Add the parameters for the stored procedure here
	@idusuario int,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @Contador int = 0;
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    set @Contador = (select count(IdUsuario) from dbo.S_Usuario where IdUsuario = @idusuario and CorreoVerificado = 1)

	if @Contador = 0
		begin

		   --- Actualziar Estatus de Usuario Administrador de Cuenta de Proveedor ---
			update dbo.S_Usuario
			set CorreoVerificado = 1, FechaActivacion = getDate()
			where IdUsuario = @idusuario

			--- Actualizar Estatus Activo  de Proveedor ---

			UPDATE  p
			SET p.Activo = 1
			FROM dbo.S_Usuario u
				INNER JOIN dbo.S_UsuarioProveedor up ON up.IdUsuario = u.IdUsuario
				INNER JOIN dbo.S_Proveedor p ON p.IdProveedor = up.IdProveedor
			WHERE u.IdUsuario = @idusuario
			
		end 

	select @idusuario as Usuario, Correo, Contrasena From S_Usuario where IdUsuario = @idusuario

END

