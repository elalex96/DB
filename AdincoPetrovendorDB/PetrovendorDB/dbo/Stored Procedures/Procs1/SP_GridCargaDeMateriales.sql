-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 06/Jun/2018
-- Description:	es para la carga del grid de los materiales que se tienen en uso
-- =============================================
-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 16/Agost/2018
-- Description:	se modifica para que primero tome el correo del usuario de ventas y en caso de no existir toma el correo del administrador
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/Jul/2019
-- Description:	se agrego la lista negra del sat
-- =============================================
-- Author:		Abel Rivera
-- Create date: 26/ago/2019
-- Description:	se agrego un campo para validar si el proveedor esta en la lista negra
-- =============================================

CREATE PROCEDURE [dbo].[SP_GridCargaDeMateriales] @IdProveedorActual INT
AS
    BEGIN

	/**Optimización**/
       
	   
	     SELECT TOP 1 ROW_NUMBER() OVER(
               ORDER BY DescripcionCorta) AS Id, 
               MM.IdMaterial, 
               'Informacion No disponible' AS DescripcionCorta, 
               'Informacion No disponible' AS DescripcionLarga, 
               'Informacion No disponible' AS NombreUnidad, 
               U.IdUnidad, 
               MM.IdProveedor,
              'Informacion No disponible' AS RazonSocial, 
              1 AS IdTipoCatalogoMaestro, 
               0 AS Estrellas, 
               '''' AS CorreoProveedor,
               CASE
                   WHEN LN.RFC IS NULL
                   THEN 0
                   ELSE 1
               END AS InBlackList
        FROM dbo.MM_Material AS MM
             INNER JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = MM.IdUnidad
             LEFT JOIN dbo.S_Proveedor P ON P.IdProveedor = MM.IdProveedor
             LEFT JOIN Adinco.dbo.ListaNegra AS LN ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
        WHERE MM.IdTipoProveedor = 2
              --AND MM.Activo = 1
              --AND ISNULL(MM.IsEliminado, 0) = 0
              --AND P.Activo = 1
        GROUP BY MM.IdMaterial, 
                 MM.DescripcionCorta, 
                 MM.DescripcionLarga, 
                 U.Unidad, 
                 U.IdUnidad, 
                 MM.IdProveedor, 
                 P.RazonSocial,             
                 LN.RFC, 
                 LN.Situacion, 
                 P.RegimenCapital
        ORDER BY DescripcionCorta;

        --SELECT ROW_NUMBER() OVER(
        --       ORDER BY DescripcionCorta) AS Id, 
        --       MM.IdMaterial, 
        --       MM.DescripcionCorta AS DescripcionCorta, 
        --       MM.DescripcionLarga AS DescripcionLarga, 
        --       U.Unidad AS NombreUnidad, 
        --       U.IdUnidad, 
        --       MM.IdProveedor,
        --       CASE
        --           WHEN LN.RFC IS NULL
        --           THEN CONCAT(P.RazonSocial, '  ', P.RegimenCapital)
        --           ELSE CONCAT(P.RazonSocial, '  ', P.RegimenCapital, ' - DESABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS, ']')
        --       END AS RazonSocial, 
        --       MM.IdTipoCatalogoMaestro, 
        --       ISNULL(dbo.ObtenerEstrellasModificado(p.IdProveedor), 0) AS Estrellas, 
        --       dbo.Fn_ObtenerCorreoVentasoAdministrador(P.IdProveedor) AS CorreoProveedor,
        --       CASE
        --           WHEN LN.RFC IS NULL
        --           THEN 0
        --           ELSE 1
        --       END AS InBlackList
        --FROM dbo.MM_Material AS MM
        --     INNER JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = MM.IdUnidad
        --                                             OR U.IdUnidad = MM.IdUnidad_1
        --                                             OR U.IdUnidad = MM.IdUnidad_2
        --                                             OR U.IdUnidad = MM.IdUnidad_3
        --     LEFT JOIN dbo.S_Proveedor P ON P.IdProveedor = MM.IdProveedor
        --     LEFT JOIN Adinco.dbo.ListaNegra AS LN ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
        --WHERE MM.IdTipoProveedor = 2
        --      AND MM.Activo = 1
        --      AND ISNULL(MM.IsEliminado, 0) = 0
        --      AND MM.IdTipoCatalogoMaestro IS NOT NULL
        --      AND P.Activo = 1
        --GROUP BY MM.IdMaterial, 
        --         MM.DescripcionCorta, 
        --         MM.DescripcionLarga, 
        --         U.Unidad, 
        --         U.IdUnidad, 
        --         MM.IdProveedor, 
        --         P.RazonSocial, 
        --         MM.IdTipoCatalogoMaestro, 
        --         P.CorreoProveedor, 
        --         P.IdProveedor, 
        --         LN.RFC, 
        --         LN.Situacion, 
        --         P.RegimenCapital
        --ORDER BY DescripcionCorta;
    END;