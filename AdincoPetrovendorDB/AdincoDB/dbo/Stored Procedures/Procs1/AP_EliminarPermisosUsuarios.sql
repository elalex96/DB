-- =============================================
CREATE PROCEDURE [dbo].[AP_EliminarPermisosUsuarios]
	-- Add the parameters for the stored procedure here
	@UsuarioID AS INT,
	@IdPermiso AS INT
AS
BEGIN
	-- =================================================
	-- Author:		Valeria Rodriguez
	-- Create date: 26/02/2019
	-- Description:	Elimina datos de AP_PermisosUsuarios
	-- =================================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DELETE FROM AP_PermisosUsuarios 
	WHERE (UsuarioID = @UsuarioID) AND 
		  (IdPermiso = @IdPermiso)
END
