USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_SEL_PV_ConsultaConfiguracionesAdjudicacionDirecta];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Consulta las configuraciones de Adjudicación Directa de
--              PV_ConfiguracionProveedoresOperadoras, incluyendo los campos
--              de auditoría CreadoPor, CreadoEl, ModificadoPor y ModificadoEl.
--              Se hacen LEFT JOINs a S_Usuario para resolver los nombres de
--              los usuarios de creación y de última modificación.
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_PV_ConsultaConfiguracionesAdjudicacionDirecta]
    @IdContrato  INT = 0,
    @IdUsuario   INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.IdConfiguracionProveedoresOperadoras,
        c.IdContrato,
        c.CreadoPor,
        c.CreadoEl,
        ISNULL(c.Activo, 0) AS Activo,
        c.ModificadoPor,
        c.ModificadoEl,
        uc.Nombre AS NombreCreadoPor,
        um.Nombre AS NombreModificadoPor
    FROM      dbo.PV_ConfiguracionProveedoresOperadoras AS c  WITH (NOLOCK)
    LEFT JOIN dbo.S_Usuario                             AS uc WITH (NOLOCK)
           ON uc.IdUsuario = c.CreadoPor
    LEFT JOIN dbo.S_Usuario                             AS um WITH (NOLOCK)
           ON um.IdUsuario = c.ModificadoPor
    ORDER BY c.IdConfiguracionProveedoresOperadoras;

END
