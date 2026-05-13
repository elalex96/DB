USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[AD_SP_UpdateUsuarios];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/04/2026
-- Description:	Agrega parámetros @ModificadoPor y @ModificadoEl para
--              registrar el usuario de sesión y la fecha de la última
--              modificación en la tabla S_Usuario.
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_UpdateUsuarios]
    @IdUsuario        INT,
    @Correo           NVARCHAR(MAX),
    @Activo           BIT,
    @IdTipoUsuario    INT,
    @IdUsuarioADINCO  INT          = NULL,
    @Nombre           NVARCHAR(MAX),
    @IdUsuarioProveedor INT,
    @CorreoVerificado BIT,
    @ModificadoPor    INT          = NULL,
    @ModificadoEl     DATETIME     = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.S_Usuario
    SET
        Correo           = @Correo,
        Activo           = @Activo,
        Nombre           = @Nombre,
        IdTipoUsuario    = @IdTipoUsuario,
        IdUsuarioADINCO  = @IdUsuarioADINCO,
        CorreoVerificado = @CorreoVerificado,
        ModificadoPor    = @ModificadoPor,
        ModificadoEl     = @ModificadoEl,
        IsEliminado      = CASE
                               WHEN @Activo = 1 THEN 0
                               ELSE 1
                           END
    WHERE IdUsuario = @IdUsuario;

END