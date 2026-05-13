USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[AD_SP_ConsultaUsuarios];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/04/2026
-- Description:	Agrega campos de auditoría ModificadoPor y ModificadoEl
--              al resultado del SP. Se sustituye la lógica de doble INSERT
--              + WHILE por un CTE con ROW_NUMBER para asignar llaves
--              negativas a usuarios sin IdUsuarioProveedor, reduciendo
--              lecturas y eliminando el cursor implícito.
--              Se aplica NOLOCK en todas las tablas de consulta.
-- =============================================
-- =============================================
-- Modificación: 24/04/2026 - Alexander Gomez
-- Descripción:  Se corrige el ORDER BY para que sea determinístico
--              (agrega IdUsuarioProveedor como columna de desempate).
--              Se cambia la clave de usuarios sin proveedor de
--              (Fila * -1) a (IdUsuario * -1): la nueva clave es
--              permanente e independiente del total de filas, lo que
--              evita que DevExpress pierda la referencia de fila al
--              recargar datos con EnableRowsCache="false" y el
--              formulario de edición inline deje de abrirse para
--              usuarios con múltiples proveedores (RFC).
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ConsultaUsuarios]
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE que consolida usuarios con y sin IdUsuarioProveedor en una sola
    -- pasada.
    -- · Usuarios sin proveedor  → clave = IdUsuario * -1  (estable y única).
    -- · Usuarios con proveedor  → clave = IdUsuarioProveedor real (positivo).
    -- El ORDER BY doble (IdUsuario, IdUsuarioProveedor) garantiza un orden
    -- determinístico entre cargas, condición necesaria para que el grid de
    -- DevExpress abra el formulario de edición en modo EditFormAndDisplayRow.
    ;WITH cteUsuarios AS
    (
        SELECT
            up.IdUsuarioProveedor,
            u.IdUsuario,
            u.Nombre,
            u.Correo,
            ISNULL(u.Activo,         0) AS Activo,
            u.FechaRegistro,
            u.FechaActivacion,
            u.IdTipoUsuario,
            ISNULL(u.IsEliminado,    0) AS IsEliminado,
            u.IdUsuarioADINCO,
            p.IdProveedor,
            p.RFC,
            p.RazonSocial,
            u.CorreoVerificado,
            u.ModificadoPor,
            u.ModificadoEl
        FROM       dbo.S_Usuario          AS u  WITH (NOLOCK)
        LEFT JOIN  dbo.S_UsuarioProveedor AS up WITH (NOLOCK)
               ON  up.IdUsuario  = u.IdUsuario
        LEFT JOIN  dbo.S_Proveedor        AS p  WITH (NOLOCK)
               ON  p.IdProveedor = up.IdProveedor
    )
    -- Retorno a la vista
    SELECT
        ISNULL(c.IdUsuarioProveedor, c.IdUsuario * -1) AS IdUsuarioProveedor,
        c.IdUsuario,
        c.Nombre,
        c.Correo,
        c.Activo,
        c.FechaRegistro,
        c.FechaActivacion,
        c.IdTipoUsuario,
        c.IsEliminado,
        c.IdUsuarioADINCO,
        c.IdProveedor,
        c.RFC,
        c.RazonSocial,
        c.CorreoVerificado,
        c.ModificadoPor,
        c.ModificadoEl,
        um.Nombre AS NombreModificadoPor
    FROM      cteUsuarios        AS c
    LEFT JOIN dbo.S_Usuario      AS um WITH (NOLOCK)
           ON um.IdUsuario = c.ModificadoPor
    -- ORDER BY determinístico: agrupa por usuario y, dentro del mismo usuario,
    -- ordena por IdUsuarioProveedor para que las filas duplicadas (un usuario
    -- asociado a varios RFC) aparezcan siempre en la misma secuencia.
    ORDER BY c.IdUsuario,
             c.IdUsuarioProveedor;

END