-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar FILTRO DE PROVEEDORES
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 05-Jun-18
-- Description:	se agrega el filtro por giro empresarial y por materiales
-- =============================================
-- ============================================= 
-- Author:		Pedro Acuña
-- Create date: 16/Agost/2018
-- Description:	se modifica para que primero tome el correo del usuario de ventas y en caso de no existir toma el correo del administrador
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/Marzo/2019
-- Description:	se agrego el filtrado por activo
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/Marzo/2019
-- Description:	se agrego el filtrado por proveedores sin clasificacion
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 15/Jul/2019
-- Description:	se agrego la lista negra del sat
-- =============================================
-- Author:		Abel Rivera
-- Create date: 16/Jul/2019
-- Description:	Se agrega el campo para validar la lista negra al select

CREATE PROCEDURE [dbo].[SP_MM_FiltroProveedorOfertas] --0,'','',0,'',0,0,0,'',420,0
    -- Add the parameters for the stored procedure here
    @Origen INT,
    @IsPaises NVARCHAR(MAX),
    @IdEstados NVARCHAR(MAX),
    @IdTamanioEmpresa INT,
    @CalificacionMayor NVARCHAR(MAX),
    @AniosExperiencias INT,
    @CapitalContableMinimo FLOAT,
    @IdISOS NVARCHAR(MAX),
    @IdProveedorActual INT,
    @NumeroISOS INT,
    @ALL NVARCHAR(300)

--- execute	SP_MM_FiltroProveedorOfertas    2,'33','',0,'',0,0,'',420,0,'BUSCARxFILTRO'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @CONT INT = 1;
    DECLARE @CONTPROV INT;
    DECLARE @IDPROV INT;
    DECLARE @IDPROVAUX INT;
    DECLARE @tablaAux TABLE
    (
        Id INT IDENTITY,
        IdProveedor INT,
        NombreProveedor NVARCHAR(MAX),
        Estrellas INT,
        IdGiroEmpresarial INT,
        CorreoProveedor NVARCHAR(MAX),
        Evaluacion INT,
        InBlackList BIT
    );



    SELECT P.IdProveedor,
           CASE
               WHEN LN.RFC IS NULL THEN
                   CONCAT(P.RazonSocial, '  ', P.RegimenCapital)
               ELSE
                   CONCAT(
                             P.RazonSocial,
                             '  ',
                             P.RegimenCapital,
                             ' - DESABILITADO POR SAT - [Situación: ',
                             LN.Situacion COLLATE Modern_Spanish_CI_AS,
                             ']'
                         )
           END AS NombreProveedor,
           U.Correo AS CorreoProveedor,
           0 AS Estrellas,
           --0 AS IdGiroEmpresarial,
           ISNULL(
           (
               SELECT TOP 1
                      PGE.IdGiroEmpresarial
               FROM PV_PerfilGiroEmpresarial AS PGE
                   LEFT JOIN dbo.PV_GiroEmpresarial GE
                       ON PGE.IdGiroEmpresarial = GE.IdGiroProveedor
               WHERE PGE.IdProveedor = P.IdProveedor
           ),
           0
                 ) AS IdGiroEmpresarial,
           CASE
               WHEN LN.RFC IS NULL THEN
                   0
               ELSE
                   1
           END AS InBlackList
    FROM S_Proveedor AS P
        INNER JOIN S_UsuarioProveedor AS UP
            ON UP.IdProveedor = P.IdProveedor
        INNER JOIN S_Usuario U
            ON U.IdUsuario = UP.IdUsuario
               AND U.IdTipoUsuario = 3					 
        LEFT JOIN Adinco.dbo.ListaNegra AS LN
            ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
    WHERE P.Activo = 1
          AND P.IdProveedor <> @IdProveedorActual
          AND ISNULL(P.IsEliminado, 0) = 0
          AND P.RFC COLLATE Modern_Spanish_CI_AS NOT IN
              (
                  SELECT RFC FROM Adinco..CO_Contratista WHERE RFC IS NOT NULL
              )
    GROUP BY P.IdProveedor,
             U.Correo,
             P.RazonSocial,
             P.RegimenCapital,
             LN.RFC,
             LN.Situacion
    ORDER BY NombreProveedor;





/**Optimizacion*/

--  SET @CONTPROV =
--  (
--      SELECT COUNT(Id)
--      FROM @tablaAux
--  );

--  --PROVEEDORES SIN CLASIFICACION
--  INSERT INTO @tablaAux
--  (IdProveedor, 
--   NombreProveedor, 
--   Estrellas, 
--   IdGiroEmpresarial, 
--   Evaluacion, 
--   InBlackList
--  )
--         SELECT DISTINCT 
--                P.IdProveedor,
--                CASE
--                    WHEN LN.RFC IS NULL
--                    THEN CONCAT(P.RazonSocial, '  ', P.RegimenCapital)
--                    ELSE CONCAT(P.RazonSocial, '  ', P.RegimenCapital, ' - DESABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS, ']')
--                END AS NombreProveedor, 
--               -- ISNULL(dbo.ObtenerEstrellasModificado(p.IdProveedor), 0)
--0 AS Estrellas, 
--                0, 
--                0,
--                CASE
--                    WHEN LN.RFC IS NULL
--                    THEN 0
--                    ELSE 1
--                END AS InBlackList
--         FROM S_Proveedor AS P
--              INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
--              LEFT JOIN PV_ClasificacionEmpresaProveedor AS CE ON CE.IdProveedor = P.IdProveedor
--              LEFT JOIN PV_ClasificacionPyMES AS CP ON CP.IdClasificacion = CE.IdClasificacionEmpresa
--              LEFT JOIN PV_PerfilEmpresa AS PE ON PE.IdProveedor = P.IdProveedor
--              LEFT JOIN dbo.PV_PerfilGiroEmpresarial PGE ON PGE.IdProveedor = P.IdProveedor
--              LEFT JOIN dbo.PV_GiroEmpresarial GE ON PGE.IdGiroEmpresarial = GE.IdGiroProveedor
--              INNER JOIN dbo.S_Usuario u ON u.IdUsuario = UP.IdUsuario
--              LEFT JOIN Adinco.dbo.ListaNegra AS LN ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
--         WHERE P.Activo = 1
--               --AND P.IdProveedor <> @IdProveedorActual
--               AND ISNULL(PE.AniosExperiencia, 0) >= 0
--               AND ISNULL(P.CapitalContable, 0) >= 0
--               AND u.Activo = 1
--               AND ISNULL(PGE.Activo, 0) = 0
--         GROUP BY P.IdProveedor, 
--                  P.RazonSocial, 
--                  P.RegimenCapital, 
--                  P.CorreoProveedor, 
--                  PGE.IdGiroEmpresarial, 
--                  LN.RFC, 
--                  LN.Situacion
--         ORDER BY NombreProveedor;
--  WHILE @CONT < @CONTPROV
--      BEGIN
--          SET @IDPROV =
--          (
--              SELECT IdProveedor
--              FROM @tablaAux
--              WHERE Id = @CONT
--          );
--          SET @IDPROVAUX =
--          (
--              SELECT DISTINCT 
--                     P.IdProveedor
--              FROM S_Proveedor AS P
--                   INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
--                   LEFT JOIN PV_ClasificacionEmpresaProveedor AS CE ON CE.IdProveedor = P.IdProveedor
--                   LEFT JOIN PV_ClasificacionPyMES AS CP ON CP.IdClasificacion = CE.IdClasificacionEmpresa
--                   LEFT JOIN PV_PerfilEmpresa AS PE ON PE.IdProveedor = P.IdProveedor
--                   LEFT JOIN dbo.PV_PerfilGiroEmpresarial PGE ON PGE.IdProveedor = P.IdProveedor
--                   LEFT JOIN dbo.PV_GiroEmpresarial GE ON PGE.IdGiroEmpresarial = GE.IdGiroProveedor
--                   INNER JOIN dbo.S_Usuario u ON u.IdUsuario = UP.IdUsuario
--              WHERE P.Activo = 1
--                    --AND P.IdProveedor <> @IdProveedorActual
--                    AND ISNULL(PE.AniosExperiencia, 0) >= 0
--                    AND ISNULL(P.CapitalContable, 0) >= 0
--                    AND u.Activo = 1
--                    AND PGE.Activo = 1
--                    AND P.IdProveedor = @IDPROV
--              GROUP BY P.IdProveedor, 
--                       P.RazonSocial, 
--                       P.RegimenCapital, 
--                       P.CorreoProveedor, 
--                       PGE.IdGiroEmpresarial
--          );
--          IF ISNULL(@IDPROVAUX, 0) <> 0
--              BEGIN
--                  DELETE @tablaAux
--                  WHERE Id = @CONT;
--          END;
--          SET @CONT = @CONT + 1;
--      END;


--  INSERT INTO @tablaAux
--  (IdProveedor, 
--   NombreProveedor, 
--   Estrellas, 
--   IdGiroEmpresarial, 
--   Evaluacion, 
--   InBlackList
--  )
--         SELECT P.IdProveedor,
--                CASE
--                    WHEN LN.RFC IS NULL
--                    THEN CONCAT(P.RazonSocial, '  ', P.RegimenCapital)
--                    ELSE CONCAT(P.RazonSocial, '  ', P.RegimenCapital, ' - DESABILITADO POR SAT - [Situación: ', LN.Situacion COLLATE Modern_Spanish_CI_AS, ']')
--                END COLLATE SQL_Latin1_General_CP1_CI_AS AS NombreProveedor, 
--                ISNULL(dbo.ObtenerEstrellasModificado(p.IdProveedor), 0) AS Estrellas, 
--                ISNULL(PGE.IdGiroEmpresarial, 0) AS IdGiroEmpresarial, 
--                0,
--                CASE
--                    WHEN LN.RFC IS NULL
--                    THEN 0
--                    ELSE 1
--                END AS InBlackList
--         FROM S_Proveedor AS P
--              INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = P.IdProveedor
--              LEFT JOIN PV_ClasificacionEmpresaProveedor AS CE ON CE.IdProveedor = P.IdProveedor
--              LEFT JOIN PV_ClasificacionPyMES AS CP ON CP.IdClasificacion = CE.IdClasificacionEmpresa
--              LEFT JOIN PV_PerfilEmpresa AS PE ON PE.IdProveedor = P.IdProveedor
--              LEFT JOIN dbo.PV_PerfilGiroEmpresarial PGE ON PGE.IdProveedor = P.IdProveedor
--              LEFT JOIN dbo.PV_GiroEmpresarial GE ON PGE.IdGiroEmpresarial = GE.IdGiroProveedor
--              INNER JOIN dbo.S_Usuario u ON u.IdUsuario = UP.IdUsuario
--              LEFT JOIN Adinco.dbo.ListaNegra AS LN ON LN.RFC COLLATE Modern_Spanish_CI_AS = P.RFC COLLATE Modern_Spanish_CI_AS
--         WHERE P.Activo = 1
--               AND P.IdProveedor <> @IdProveedorActual
--               AND ISNULL(PE.AniosExperiencia, 0) >= 0
--               AND ISNULL(P.CapitalContable, 0) >= 0
--               AND u.Activo = 1
--               AND PGE.Activo = 1
--         GROUP BY P.IdProveedor, 
--                  P.RazonSocial, 
--                  P.RegimenCapital, 
--                  P.CorreoProveedor, 
--                  PGE.IdGiroEmpresarial, 
--                  LN.RFC, 
--                  LN.Situacion
--         ORDER BY NombreProveedor;
--  DECLARE @Contador INT= 1, @NumRegistros INT, @CorreoAux NVARCHAR(MAX), @IdProveedorAux INT;
--  SELECT @NumRegistros = COUNT(*)
--  FROM @tablaAux;
--  WHILE(@NumRegistros >= @Contador)
--      BEGIN
--          SELECT @IdProveedorAux = IdProveedor
--          FROM @tablaAux
--          WHERE Id = @Contador;
--          SELECT @CorreoAux = u.Correo
--          FROM dbo.S_Usuario u
--               INNER JOIN dbo.S_UsuarioProveedor uProv ON uProv.IdUsuario = u.IdUsuario
--          WHERE uProv.IdProveedor = @IdProveedorAux
--                AND u.IdTipoUsuario = 4; --usuario de ventas

--          IF(@CorreoAux = ''
--             OR @CorreoAux IS NULL)
--              BEGIN
--                  SELECT @CorreoAux = u.Correo
--                  FROM dbo.S_Usuario u
--                       INNER JOIN dbo.S_UsuarioProveedor uProv ON uProv.IdUsuario = u.IdUsuario
--                  WHERE uProv.IdProveedor = @IdProveedorAux
--                        AND u.IdTipoUsuario = 3; --administrador
--          END;
--          UPDATE @tablaAux
--            SET 
--                CorreoProveedor = @CorreoAux
--          WHERE Id = @Contador;
--          SET @CorreoAux = NULL;
--          SET @Contador+=1;
--      END;
--  SELECT *
--  FROM @tablaAux;
END;