USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[SP_MM_ConsultaProveedoresCartaCN];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Consulta las configuraciones de Carta de Contenido Nacional
--              (Proveedor a Proveedor) de la tabla
--              PV_ConfiguracionProveedoresOperadoras, incluyendo los campos
--              de auditoría ModificadoPor y ModificadoEl.
--              Se hace LEFT JOIN a S_Usuario para resolver el nombre del
--              usuario que realizó la última modificación.
--              ORDER BY determinístico (IdConfiguracionProveedoresOperadoras)
--              para que el grid de DevExpress con Batch Edit pueda localizar
--              siempre la fila correcta al actualizar.
--              Se aplica NOLOCK en todas las tablas de consulta.
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaProveedoresCartaCN]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.IdConfiguracionProveedoresOperadoras,
        c.IdContrato,
        c.CreadoEl,
        ISNULL(c.Activo, 0) AS Activo,
        c.ModificadoPor,
        c.ModificadoEl,
        u.Nombre AS NombreModificadoPor
    FROM      dbo.PV_ConfiguracionProveedoresOperadoras AS c  WITH (NOLOCK)
    LEFT JOIN dbo.S_Usuario                             AS u  WITH (NOLOCK)
           ON u.IdUsuario = c.ModificadoPor
    -- NOTA: agregar aquí el filtro original del SP si existía,
    --       p. ej. WHERE c.TipoConfiguracion = 'CartaCN'
    ORDER BY c.IdConfiguracionProveedoresOperadoras;

END