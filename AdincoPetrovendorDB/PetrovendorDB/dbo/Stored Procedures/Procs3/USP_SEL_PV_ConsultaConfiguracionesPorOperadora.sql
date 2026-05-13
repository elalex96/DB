USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_SEL_PV_ConsultaConfiguracionesPorOperadora];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Consulta las configuraciones de preferencias por operadora
--              de PV_ConfiguracionProveedoresOperadoras, incluyendo los
--              campos de auditoría ModificadoPor y ModificadoEl.
--              Se hace LEFT JOIN a S_Usuario para resolver el nombre del
--              usuario que realizó la última modificación.
--              ORDER BY determinístico (IdConfiguracionProveedoresOperadoras)
--              para que el grid de DevExpress con Batch Edit pueda localizar
--              siempre la fila correcta al actualizar.
--              Se aplica NOLOCK en todas las tablas de consulta.
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_PV_ConsultaConfiguracionesPorOperadora]
    @IdContrato  INT = 0,
    @IdUsuario   INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.IdConfiguracionProveedoresOperadoras,
        c.TipoConfiguracion,
        c.Descripcion,
        c.IdContrato,
        c.CreadoEl,
        ISNULL(c.Activo, 0) AS Activo,
        c.ModificadoPor,
        c.ModificadoEl,
        u.Nombre AS NombreModificadoPor
    FROM      dbo.PV_ConfiguracionProveedoresOperadoras AS c  WITH (NOLOCK)
    LEFT JOIN dbo.S_Usuario                             AS u  WITH (NOLOCK)
           ON u.IdUsuario = c.ModificadoPor
    ORDER BY c.IdConfiguracionProveedoresOperadoras;

END