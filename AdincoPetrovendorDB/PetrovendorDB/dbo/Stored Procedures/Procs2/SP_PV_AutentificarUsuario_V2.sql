-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se valida el usuario que se esta intendando loguear >
-- =============================================
-- Modificacion:		<Jose Roman>
-- Create date: <23-03-2018>
-- Description:	<Se agrega la columna CorreoVerificado a la consulta y fecha de registro>
-- =============================================
CREATE PROCEDURE SP_PV_AutentificarUsuario_V2
(
    @Correo NVARCHAR(MAX),
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT U.IdUsuario,
           U.Activo,
           U.IdTipoUsuario,
           U.Nombre,
           U.Contrasena,
		   u.CorreoVerificado,
		   u.FechaRegistro
    FROM S_Usuario AS U
    WHERE U.IdUsuario = @IdUsuario
          AND U.Correo = @Correo

END


