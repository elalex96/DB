USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[AD_SP_ConsultaProveedores];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Consulta todos los proveedores de la tabla S_Proveedor
--              incluyendo los campos de auditoría ModificadoPor y
--              ModificadoEl. Se hace LEFT JOIN a S_Usuario para resolver
--              el nombre del usuario que realizó la última modificación.
--              ORDER BY determinístico (IdProveedor) para que el grid
--              de DevExpress con EnableRowsCache="false" pueda localizar
--              siempre la fila correcta al abrir el formulario de edición.
--              Se aplica NOLOCK en todas las tablas de consulta.
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ConsultaProveedores]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.IdProveedor,
        p.RFC,
        p.IdNacionalidad,
        p.RazonSocial,
        p.IdTipoRegimen,
        ISNULL(p.IsEliminado, 0) AS IsEliminado,
        ISNULL(p.Activo,      0) AS Activo,
        p.ModificadoPor,
        p.ModificadoEl,
        u.Nombre AS NombreModificadoPor
    FROM      dbo.S_Proveedor AS p  WITH (NOLOCK)
    LEFT JOIN dbo.S_Usuario   AS u  WITH (NOLOCK)
           ON u.IdUsuario = p.ModificadoPor
    ORDER BY p.IdProveedor;

END