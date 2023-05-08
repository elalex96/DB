-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Create date: <02/Enero/2018>
-- Description:	<Se Obtienen todos los Usuarios para encriptarlos >
-- =============================================
CREATE PROCEDURE SP_SEG_ENCRIPTARPASSALL
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT IdUsuario,
           Contrasena,
           *
    FROM dbo.S_Usuario
    WHERE Contrasena NOT LIKE '5122%'
END