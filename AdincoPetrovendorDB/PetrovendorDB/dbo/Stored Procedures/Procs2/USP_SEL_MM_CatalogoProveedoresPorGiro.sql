USE [Petrovendor]
GO
IF OBJECT_ID('USP_SEL_MM_CatalogoProveedoresPorGiro') IS NOT NULL
BEGIN
DROP PROCEDURE USP_SEL_MM_CatalogoProveedoresPorGiro;
END
GO
-- =============================================
-- Author:      Daniel Antonio Cruz
-- Create date: 23/04/2026
-- Description: Consulta proveedores para el catálogo de Procura
--              filtrando por giro empresarial (relación N:M).
--              Reemplaza el filtro client-side de SP_MM_FiltroProveedorOfertas
--              para la pantalla CatalogoMaterialProveedor.aspx
-- =============================================
-- execute USP_SEL_MM_CatalogoProveedoresPorGiro 0, 420
CREATE PROCEDURE [dbo].[USP_SEL_MM_CatalogoProveedoresPorGiro]
    @IdGiroEmpresarial  INT = 0,
    @IdProveedorActual  INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Declaración de tablas temporales
    CREATE TABLE #Contratistas (RFC NVARCHAR(50) COLLATE DATABASE_DEFAULT);

    CREATE TABLE #ProveedoresPorGiro (
        IdProveedor       INT,
        RFC               NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
        RazonSocial       NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
        RegimenCapital    NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
        IdGiroEmpresarial INT
    );

    CREATE TABLE #CorreoProveedor (IdProveedor INT, Correo NVARCHAR(MAX) COLLATE DATABASE_DEFAULT);

    -- 1. Contratistas excluidos
    INSERT INTO #Contratistas (RFC)
    SELECT UPPER(LTRIM(RTRIM(RFC)))
    FROM Adinco..CO_Contratista WITH (NOLOCK)
    WHERE RFC IS NOT NULL;

    -- 2. Proveedores candidatos filtrados por giro, activo y no contratista
    --    @IdGiroEmpresarial = 0 → proveedores SIN giro empresarial registrado
    --    @IdGiroEmpresarial > 0 → proveedores con ese giro específico
    INSERT INTO #ProveedoresPorGiro (IdProveedor, RFC, RazonSocial, RegimenCapital, IdGiroEmpresarial)
    SELECT DISTINCT
        P.IdProveedor,
        P.RFC,
        P.RazonSocial,
        P.RegimenCapital,
        ISNULL(PGE.IdGiroEmpresarial, 0)
    FROM dbo.S_Proveedor AS P WITH (NOLOCK)
        LEFT JOIN dbo.PV_PerfilGiroEmpresarial AS PGE WITH (NOLOCK)
            ON P.IdProveedor = PGE.IdProveedor
           AND PGE.Activo = 1
    WHERE P.Activo = 1
      AND P.IdProveedor <> @IdProveedorActual
      AND ISNULL(P.IsEliminado, 0) = 0
        AND UPPER(LTRIM(RTRIM(P.RFC))) COLLATE DATABASE_DEFAULT NOT IN
            (SELECT RFC COLLATE DATABASE_DEFAULT FROM #Contratistas)
      AND (
            (@IdGiroEmpresarial = 0 AND PGE.IdProveedor IS NULL)
         OR (@IdGiroEmpresarial > 0 AND PGE.IdGiroEmpresarial = @IdGiroEmpresarial)
          );

    -- 3. Correo principal solo para los proveedores del subconjunto anterior
    INSERT INTO #CorreoProveedor (IdProveedor, Correo)
        SELECT UPR.IdProveedor, LTRIM(RTRIM(U.Correo))
    FROM dbo.S_UsuarioProveedor AS UPR WITH (NOLOCK)
        INNER JOIN dbo.S_Usuario AS U WITH (NOLOCK) ON UPR.IdUsuario = U.IdUsuario
    WHERE U.IdTipoUsuario = 3
      AND U.Activo = 1
            AND U.Correo IS NOT NULL
            AND LTRIM(RTRIM(U.Correo)) <> ''
            AND UPR.IdProveedor IN (SELECT IdProveedor FROM #ProveedoresPorGiro);

    -- 4. Resultado final
    SELECT DISTINCT
        PG.IdProveedor,
        CASE
            WHEN LN.RFC IS NULL THEN
                CONCAT(PG.RazonSocial, '  ', ISNULL(PG.RegimenCapital, ''))
            ELSE
                CONCAT(PG.RazonSocial, '  ', ISNULL(PG.RegimenCapital, ''),
                       ' - DESABILITADO POR SAT - [Situación: ',
                       LN.Situacion COLLATE Modern_Spanish_CI_AS, ']')
        END AS NombreProveedor,
        ISNULL(CP.Correo, '') AS CorreoProveedor,
        dbo.ObtenerEstrellasModificado(PG.IdProveedor) AS Estrellas,
        PG.IdGiroEmpresarial,
        CASE WHEN LN.RFC IS NULL THEN 0 ELSE 1 END AS InBlackList
    FROM #ProveedoresPorGiro AS PG
        INNER JOIN #CorreoProveedor AS CP
            ON PG.IdProveedor = CP.IdProveedor
        LEFT JOIN Adinco.dbo.ListaNegra AS LN WITH (NOLOCK)
            ON UPPER(LTRIM(RTRIM(PG.RFC))) COLLATE DATABASE_DEFAULT =
               UPPER(LTRIM(RTRIM(LN.RFC))) COLLATE DATABASE_DEFAULT
    ORDER BY NombreProveedor;

END