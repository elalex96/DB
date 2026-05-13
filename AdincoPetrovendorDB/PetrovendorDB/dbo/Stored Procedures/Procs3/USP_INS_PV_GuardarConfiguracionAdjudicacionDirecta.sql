USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_INS_PV_GuardarConfiguracionAdjudicacionDirecta];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Inserta una nueva configuración de Adjudicación Directa
--              en la tabla PV_ConfiguracionProveedoresOperadoras.
--              Se reemplaza el parámetro @IdUsuario por @CreadoPor para
--              alinearlo con la convención de auditoría establecida, y se
--              agrega @CreadoEl para registrar la fecha de creación.
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_PV_GuardarConfiguracionAdjudicacionDirecta]
    @IdContrato  INT,
    @CreadoPor   INT      = NULL,
    @CreadoEl    DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.PV_ConfiguracionProveedoresOperadoras
        (IdContrato, Activo, CreadoPor, CreadoEl)
    VALUES
        (@IdContrato, 1, @CreadoPor, ISNULL(@CreadoEl, GETDATE()));

END