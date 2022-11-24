-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25/08/2021
-- Description:	Devuelve usuarios filtrados por correo DEA
-- =============================================
CREATE PROCEDURE SP_DEAUsuarios
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdUsuario,Nombre 
	FROM S_Usuario
	WHERE Correo LIKE '%dea.com%' 
	AND ISNULL(Activo,0) = 1 
	AND ISNULL(IsEliminado,0) = 0
	ORDER BY Nombre
END