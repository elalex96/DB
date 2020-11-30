-- =============================================
-- Author:		<Abel rivera>
-- Create date: <14/03/2018>
-- Description:	<obtiene la contraseña del usuario apartir de su id>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RS_GetPassCompare] 
@IdUsuario INT,
@Contrato INT = NULL,
@FechaRegistro INT = NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Contrasena FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario

END
