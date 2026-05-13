USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[AD_SP_UpdateProveedores];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Actualiza los campos editables de un proveedor en
--              S_Proveedor. Agrega los parámetros @ModificadoPor y
--              @ModificadoEl para registrar el usuario de sesión y la
--              fecha de la última modificación, con la misma lógica de
--              auditoría aplicada en AD_SP_UpdateUsuarios.
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_UpdateProveedores]
    @IdProveedor     INT,
    @RFC             NVARCHAR(MAX),
    @IdNacionalidad  INT          = NULL,
    @RazonSocial     NVARCHAR(MAX),
    @IdTipoRegimen   INT          = NULL,
    @IsEliminado     BIT,
    @Activo          BIT,
    @ModificadoPor   INT          = NULL,
    @ModificadoEl    DATETIME     = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.S_Proveedor
    SET
        RFC            = @RFC,
        IdNacionalidad = @IdNacionalidad,
        RazonSocial    = @RazonSocial,
        IdTipoRegimen  = @IdTipoRegimen,
        IsEliminado    = @IsEliminado,
        Activo         = @Activo,
        ModificadoPor  = @ModificadoPor,
        ModificadoEl   = @ModificadoEl
    WHERE IdProveedor = @IdProveedor;

END