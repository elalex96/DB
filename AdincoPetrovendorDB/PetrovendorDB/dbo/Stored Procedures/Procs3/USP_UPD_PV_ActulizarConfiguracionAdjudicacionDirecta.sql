USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_UPD_PV_ActulizarConfiguracionAdjudicacionDirecta];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Actualiza una configuración de Adjudicación Directa en
--              PV_ConfiguracionProveedoresOperadoras.
--              Reemplaza el parámetro @IdUsuario por @ModificadoPor para
--              alinearlo con la convención de auditoría establecida, y
--              agrega @ModificadoEl para registrar la fecha de modificación.
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_PV_ActulizarConfiguracionAdjudicacionDirecta]
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