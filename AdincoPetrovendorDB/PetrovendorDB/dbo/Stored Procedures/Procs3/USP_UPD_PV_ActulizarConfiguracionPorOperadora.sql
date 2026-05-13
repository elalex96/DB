USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_UPD_PV_ActulizarConfiguracionPorOperadora];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Actualiza una configuración de preferencias por operadora
--              en PV_ConfiguracionProveedoresOperadoras.
--              Reemplaza el parámetro @IdUsuario por @ModificadoPor para
--              alinearlo con la convención de auditoría establecida, y
--              agrega @ModificadoEl para registrar la fecha de modificación.
--
-- NOTA: Verificar nombre de tabla y campos que actualiza el SP original
--       antes de ejecutar en producción.
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_PV_ActulizarConfiguracionPorOperadora]
    @IdConfiguracionProveedoresOperadoras  INT,
    @IdContrato                            INT,
    @Activo                                BIT,
    @Descripcion                           NVARCHAR(MAX) = NULL,
    @TipoConfiguracion                     NVARCHAR(MAX) = NULL,
    @ModificadoPor                         INT           = NULL,
    @ModificadoEl                          DATETIME      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.PV_ConfiguracionProveedoresOperadoras
    SET
        IdContrato         = @IdContrato,
        Activo             = @Activo,
        Descripcion        = @Descripcion,
        TipoConfiguracion  = @TipoConfiguracion,
        ModificadoPor      = @ModificadoPor,
        ModificadoEl       = @ModificadoEl
    WHERE IdConfiguracionProveedoresOperadoras = @IdConfiguracionProveedoresOperadoras;

END