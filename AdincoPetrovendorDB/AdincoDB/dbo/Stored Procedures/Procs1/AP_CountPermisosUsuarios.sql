-- ================================================
CREATE PROCEDURE [dbo].[AP_CountPermisosUsuarios]
	-- Add the parameters for the stored procedure here
	@UsuarioID INT,
	@IdContrato INT,
	@IdUsuario INT = NULL
AS
BEGIN
	-- ======================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 20/02/2019
	-- Description:	
	-- ======================================================
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdPermiso INT
    -- Insert statements for procedure here
	SELECT IdPermiso = @IdPermiso
	FROM AP_PermisosUsuarios
	WHERE idContrato = @IdContrato AND UsuarioID = @UsuarioID;

	-- ======================================================

	SELECT PU.IdPermiso,
		   PU.BitActivo
	FROM AP_PermisosUsuarios PU
		INNER JOIN AP_Permiso P ON P.IdPermiso = PU.IdPermiso
	WHERE PU.UsuarioID = @UsuarioID AND PU.BitActivo = 1;
END
