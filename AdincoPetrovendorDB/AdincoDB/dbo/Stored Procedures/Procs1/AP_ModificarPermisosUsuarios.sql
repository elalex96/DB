CREATE PROCEDURE [dbo].[AP_ModificarPermisosUsuarios] 
	-- Add the parameters for the stored procedure here
	@UsuarioID AS INT,
	@IdPermiso AS INT,
	@BitActivo AS BIT,
	@IdContrato AS INT,
	@IdUsuario AS INT
AS
BEGIN
	-- ===========================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 25/02/2019
	-- Description:	Modifica datos en la tabla AP_PermisosUsuarios
	-- ===========================================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE AP_PermisosUsuarios 
	SET BitActivo = @BitActivo
	WHERE UsuarioID = @UsuarioID AND 
		  IdPermiso = @IdPermiso
END
