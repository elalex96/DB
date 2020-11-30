-- =============================================
-- Author:      <Abel Rivera>
-- Create date: <13/02/2020>
-- Description: <Valida que el token del usuario exista>
-- =============================================
create PROCEDURE [dbo].[SP_ValidarTokenEplus]
@IdUsuarioEplus INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    SELECT IdUsuario,Correo,Contrasena FROM dbo.S_Usuario 
    WHERE IdUsuario = @IdUsuarioEplus
    AND ISNULL(Activo,0) = 1
    AND ISNULL(IsEliminado,0) = 0
END