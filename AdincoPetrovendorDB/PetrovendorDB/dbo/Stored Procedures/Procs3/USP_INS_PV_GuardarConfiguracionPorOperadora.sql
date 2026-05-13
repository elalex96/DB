USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_INS_PV_GuardarConfiguracionPorOperadora];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Inserta una nueva configuración de preferencias por
--              operadora en PV_ConfiguracionProveedoresOperadoras.
--              Se reemplaza el parámetro @IdUsuario por @CreadoPor para
--              alinearlo con la convención de auditoría establecida, y se
--              agrega @CreadoEl para registrar la fecha de creación.
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_PV_GuardarConfiguracionPorOperadora]
    @IdContrato        INT,
    @Descripcion       NVARCHAR(MAX) = NULL,
    @TipoConfiguracion NVARCHAR(MAX) = NULL,
    @CreadoPor         INT           = NULL,
    @CreadoEl          DATETIME      = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.PV_ConfiguracionProveedoresOperadoras
        (IdContrato, Descripcion, TipoConfiguracion, Activo, CreadoPor, CreadoEl)
    VALUES
        (@IdContrato, @Descripcion, @TipoConfiguracion, 1, @CreadoPor, ISNULL(@CreadoEl, GETDATE()));

END