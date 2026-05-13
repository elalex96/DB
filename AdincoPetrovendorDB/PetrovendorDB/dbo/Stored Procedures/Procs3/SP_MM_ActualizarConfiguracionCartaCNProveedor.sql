USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[SP_MM_ActualizarConfiguracionCartaCNProveedor];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Actualiza una configuración de Carta de Contenido Nacional
--              en PV_ConfiguracionProveedoresOperadoras.
--              Agrega los parámetros @ModificadoPor y @ModificadoEl para
--              registrar el usuario de sesión y la fecha de la última
--              modificación.
--
-- NOTA: Verificar el nombre de la tabla y los campos que actualiza el SP
--       original antes de ejecutar en producción.
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarConfiguracionCartaCNProveedor]
    @IdConfiguracionProveedoresOperadoras  INT,
    @IdContrato                            INT,
    @Activo                                BIT,
    @ModificadoPor                         INT      = NULL,
    @ModificadoEl                          DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.PV_ConfiguracionProveedoresOperadoras
    SET
        IdContrato    = @IdContrato,
        Activo        = @Activo,
        ModificadoPor = @ModificadoPor,
        ModificadoEl  = @ModificadoEl
    WHERE IdConfiguracionProveedoresOperadoras = @IdConfiguracionProveedoresOperadoras;

END