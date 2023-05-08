-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_AP_DatosPerfil 
	-- Add the parameters for the stored procedure here
	@IdUsuario int = 0, 
	@IdContrato int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Nombre, Foto FROM dbo.AP_Usuario
END
