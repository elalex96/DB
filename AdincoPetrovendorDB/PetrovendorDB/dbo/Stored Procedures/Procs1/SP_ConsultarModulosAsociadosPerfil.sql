-- =============================================
-- Author:		Abel Rivera 
-- Create date: Marzo
-- =============================================
-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se agrega el campo aplicacion que pobla el grid para saber a quien pertenece si procura o petrovendor >
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarModulosAsociadosPerfil]
    @IdPerfil INT,
    @IdProveedor INT
AS
BEGIN
    DECLARE @ContadorIdPerfil INT
    DECLARE @Incremento INT
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON


    CREATE TABLE #TempPerfilModulos
    (
        IdRow INT,
        [IdPerfil] INT,
        [IdModulo] INT,
        [NombreModulo] NVARCHAR(200),
        [URL_MODULO] NVARCHAR(350),
        Activo BIT,
        Estado VARCHAR(50),
        IdProveedor INT,
        Aplicacion NVARCHAR(100),
        StringModuloId NVARCHAR(400),
		IntAplicacion INT
    )

    --CREATE TABLE #TempPerfil 
    --(
    --IdRow int, 
    --   [IdPerfil] int,
    --IdModulo int
    --)

    --   SET @ContadorIdPerfil = (SELECT COUNT(PM.[IdPerfilModulo]) FROM [dbo].[PerfilModulo] PM
    --INNER JOIN Modulo M ON 
    --PM.[IdModulo] = M.[IdModulo]
    --WHERE PM.IdPerfil = 4 AND PM.Activo = 1
    --)

    INSERT INTO #TempPerfilModulos
    SELECT ROW_NUMBER() OVER (ORDER BY [IdModulo] ASC) AS Row#,
           0,
           M.IdModulo,
           M.NombreModulo,
           ISNULL(M.URL_MODULO, ''),
           0,
           'No asociado',
           0,
           CASE
               WHEN M.Aplicacion = 1 THEN
                   'Procura'
               ELSE
                   CASE
                       WHEN M.Aplicacion = 0 THEN
                           'Petrovendor'
                       ELSE
                           'Sin asociar'
                   END
           END,
           M.StringModuloId,
		   M.Aplicacion
    FROM [dbo].[Modulo] M

    ---------------------------------
    DECLARE @ContadorTotalModulos INT

    --SET @ContadorTotalModulos = (SELECT COUNT(IdRow) FROM #TempPerfilModulos)
    SET @ContadorTotalModulos =
    (
        SELECT COUNT(IdModulo) FROM #TempPerfilModulos
    )
    --WHERE IdPerfil = @IdPerfil)

    SET @Incremento = 1
    ----------------------------------

    WHILE @Incremento <= @ContadorTotalModulos
    BEGIN

        -----------------------------------
        DECLARE @IdModuloTemp INT
        SET @IdModuloTemp =
        (
            SELECT IdModulo FROM #TempPerfilModulos WHERE IdRow = @Incremento
        )
        -----------------------------------
        ---Actualizar IdPerfil ----


        DECLARE @IfExisteModulo INT
        SET @IfExisteModulo =
        (
            SELECT PM.IdModulo
            FROM PerfilModulo PM
                INNER JOIN Modulo M
                    ON PM.IdModulo = M.IdModulo
            WHERE IdPerfil = @IdPerfil
                  AND PM.IdModulo = @IdModuloTemp
                  AND PM.IdFiltroProveedor = @IdProveedor
        )

        IF @IdModuloTemp = @IfExisteModulo
        BEGIN

            DECLARE @Activo BIT

            SET @Activo =
            (
                SELECT Activo
                FROM PerfilModulo
                WHERE IdPerfil = @IdPerfil
                      AND IdModulo = @IdModuloTemp
                      AND IdFiltroProveedor = @IdProveedor
            )

            UPDATE #TempPerfilModulos
            SET [IdPerfil] = @IdPerfil,
                Activo = @Activo,
                Estado = 'Asociado'
            WHERE IdModulo = @IdModuloTemp
                  AND IdRow = @Incremento

        END


        SET @Incremento = @Incremento + 1

    END

    SELECT IdRow,
           [IdPerfil],
           [IdModulo],
           [NombreModulo],
           [URL_MODULO],
           Activo,
           Estado,
           IdProveedor,
           Aplicacion,
           StringModuloId,
		   IntAplicacion
    FROM #TempPerfilModulos
    WHERE NombreModulo != 'Seguridad'
          AND NombreModulo != 'AgregarModulos.aspx'
          AND NombreModulo != 'AdministrarPermisos.aspx'


END

