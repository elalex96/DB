IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_PerfilesAsignadosAUsuariosAdmin'
    )
    DROP PROCEDURE USP_SEL_AP_PerfilesAsignadosAUsuariosAdmin;
GO
CREATE PROC [dbo].[USP_SEL_AP_PerfilesAsignadosAUsuariosAdmin]
    @pIdUsuario INT,
    @IdContrato INT
AS
    BEGIN
        SET NOCOUNT ON;

        CREATE TABLE #PerfilUsuarioSesion
            (
                PerfilUsuarioId INT,
                PerfilId        INT,
                IdContrato      INT
            );


        DECLARE @IsAdministradorRoot INT,@PerfilRootMexico INT = 128,@PerfilCreadorUsuariosProcuraMexico INT = 416;

        SELECT
            @IsAdministradorRoot = COUNT(PerfilID)
        FROM
            dbo.AP_PerfilUsuario (NOLOCK)
        WHERE
            UsuarioID = @pIdUsuario
            AND PerfilID IN (@PerfilRootMexico, @PerfilCreadorUsuariosProcuraMexico); --Para saber si el usuario tiene el perfil administrador no es dependiente del contrato  

        IF (@IsAdministradorRoot > 0)
            BEGIN


                SELECT
                    PerfilUsuarioID,
                    AP_PerfilUsuario.UsuarioID,
                    AP_PerfilUsuario.PerfilID,
                    AP_Perfil.Descripcion,
                    CO_Contrato.NumeroContrato,
                    CO_Contrato.DescripcionContrato,
                    ISNULL(AP_PerfilUsuario.[CreadoPor], 0) CreadoPor,
                    AP_Perfil.IdContrato
                FROM
                    AP_PerfilUsuario (NOLOCK)
                    JOIN
                        AP_Perfil (NOLOCK)
                            ON AP_PerfilUsuario.PerfilID = AP_Perfil.IdPerfil
                    JOIN
                        CO_Contrato (NOLOCK)
                            ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
                ORDER BY
                    AP_PerfilUsuario.UsuarioID 

            END;
        ELSE
            BEGIN

                INSERT INTO #PerfilUsuarioSesion
                    (
                        PerfilUsuarioId,
                        PerfilId,
                        IdContrato
                    )
                            SELECT
                                PerfilUsuarioId,
                                PerfilId,
                                AP_Perfil.IdContrato
                            FROM
                                AP_PerfilUsuario (NOLOCK)
                                JOIN
                                    AP_Perfil (NOLOCK)
                                        ON AP_PerfilUsuario.PerfilID = AP_Perfil.IdPerfil
                            WHERE
                                UsuarioId = @pIdUsuario

                SELECT
                    -- SI NO ES ROOT ENTONCES SE MUESTRAN SOLO PERFILES QUE CONTENGA EL USUARIO
                    ISNULL(AP_PerfilUsuario.PerfilUsuarioID, 0) AS PerfilUsuarioID,
                    AP_PerfilUsuario.UsuarioID,
                    AP_PerfilUsuario.PerfilID,
                    AP_Perfil.Descripcion,
                    CO_Contrato.NumeroContrato,
                    CO_Contrato.DescripcionContrato,
                    ISNULL(AP_PerfilUsuario.CreadoPor, 0)       CreadoPor,
                    AP_Perfil.IdContrato
                FROM
                    #PerfilUsuarioSesion PerfilUsuarioSesion
                    JOIN
                        AP_PerfilUsuario (NOLOCK)
                            ON PerfilUsuarioSesion.PerfilId = AP_PerfilUsuario.PerfilID
                    JOIN
                        AP_Perfil (NOLOCK)
                            ON PerfilUsuarioSesion.PerfilID = AP_Perfil.IdPerfil
                               AND AP_Perfil.IdContrato = PerfilUsuarioSesion.IdContrato
                    JOIN
                        CO_Contrato (NOLOCK)
                            ON AP_Perfil.IdContrato = CO_Contrato.IdContrato
                GROUP BY
                    ISNULL(AP_PerfilUsuario.PerfilUsuarioID, 0),
                    AP_PerfilUsuario.UsuarioID,
                    AP_PerfilUsuario.PerfilID,
                    AP_Perfil.Descripcion,
                    CO_Contrato.NumeroContrato,
                    CO_Contrato.DescripcionContrato,
                    ISNULL(AP_PerfilUsuario.CreadoPor, 0),
                    AP_Perfil.IdContrato
                ORDER BY
                    AP_PerfilUsuario.UsuarioID 
            END;
    END;
