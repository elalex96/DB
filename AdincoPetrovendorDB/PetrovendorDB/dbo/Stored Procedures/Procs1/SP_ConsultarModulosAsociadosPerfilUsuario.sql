-- =============================================
-- Author:		Alexander Gomez 
-- Create date: Marzo
-- =============================================

CREATE PROCEDURE [dbo].[SP_ConsultarModulosAsociadosPerfilUsuario] --44, 2223, 'Petrovendor'
    @IdProveedor INT,
	@IdUsuario INT,
	@Aplicacion NVARCHAR(MAX),
	@IdContrato INT = NULL,
    @fchRegistro DATETIME = NULL

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
		IntAplicacion INT,
		Titulo NVARCHAR(MAX),
		Subtitulo NVARCHAR(MAX)
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
    SELECT ROW_NUMBER() OVER (ORDER BY M.IdModulo ASC) AS Row#,
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
		   M.Aplicacion,
		   T.NombreTitulo,
		   CASE WHEN T.NombreSubtitulo IS NULL THEN 'Sin descripción por el momento' ELSE T.NombreSubtitulo END
    FROM [dbo].[Modulo] M
		LEFT JOIN dbo.TituloModulo AS TM ON TM.IdModulo = M.IdModulo
		LEFT JOIN dbo.Titulos AS T ON T.IdTitulo = TM.IdTitulo

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
            FROM AdministracionPermisosUsuarios PM
                INNER JOIN Modulo M
                    ON PM.IdModulo = M.IdModulo
            WHERE PM.IdModulo = @IdModuloTemp
                  AND PM.IdProveedor = @IdProveedor
				  AND PM.IdFiltroUsuario = @IdUsuario
        )

        IF @IdModuloTemp = @IfExisteModulo
        BEGIN

            DECLARE @Activo BIT

            SET @Activo =
            (
                SELECT Activo
                FROM AdministracionPermisosUsuarios
                WHERE IdModulo = @IdModuloTemp
                      AND IdProveedor = @IdProveedor
					  AND IdFiltroUsuario = @IdUsuario
            )

            UPDATE #TempPerfilModulos
            SET Activo = @Activo,
                Estado = 'Asociado'
            WHERE IdModulo = @IdModuloTemp
                  AND IdRow = @Incremento

        END


        SET @Incremento = @Incremento + 1

    END

    SELECT IdRow,
           [IdModulo],
           [NombreModulo],
           [URL_MODULO],
           Activo,
           Aplicacion,
           StringModuloId,
		   Titulo,
		   Subtitulo
    FROM #TempPerfilModulos
    WHERE NombreModulo != 'Seguridad'
          AND NombreModulo != 'AgregarModulos.aspx'
          AND NombreModulo != 'AdministrarPermisos.aspx'
		  AND NombreModulo != 'Default'
		  AND NombreModulo != 'Error'
		  AND NombreModulo != 'Acceso Denegado'
		  AND NombreModulo != 'Pagina No Econtrada 404'
		  AND NombreModulo != 'Listado de evaluacion general'
		  AND NombreModulo != 'Aviso de privacidad'
		  AND NombreModulo != 'Mi Cuenta'
		  AND NombreModulo != 'Mi Perfil'
		  AND NombreModulo != 'Alta de Cuenta Bancaria'
		  AND NombreModulo != 'Ordenes de Trabajo'
		  AND NombreModulo != 'Trasabilidad Facturas'
		  AND StringModuloId != 'Formato Carta Contenido Nacional'
		  AND StringModuloId != 'Reporte Orden Compra'
		  AND StringModuloId != 'Contestar Matriz de Evaluación'
		  AND StringModuloId != 'ComprasMaterial'
		  AND StringModuloId != 'AutorizaDocumentos'
		  AND Aplicacion  = @Aplicacion


END