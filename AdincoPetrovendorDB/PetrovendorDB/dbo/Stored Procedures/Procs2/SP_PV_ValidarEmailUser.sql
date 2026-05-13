IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_PV_ValidarEmailUser'
    )
    DROP PROCEDURE SP_PV_ValidarEmailUser
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		DANIEL AC 
-- Create date: 31/08/2017
-- =============================================

CREATE PROCEDURE [dbo].[SP_PV_ValidarEmailUser]
    @IdUsuario   int,
    @Correo      varchar(50),
    @IdProveedor int,
    @TipoUsuario varchar(50)
AS
    BEGIN

        SET NOCOUNT ON;

        DECLARE @RESPONSE_CORREO NVARCHAR(300) = 'ERROR'
        DECLARE @CorreoActual NVARCHAR(300) = (
                                                  select
                                                      U.Correo
                                                  from
                                                      S_Usuario as U (NOLOCK)
                                                  where
                                                      U.IdUsuario = @IdUsuario
                                              )

        DECLARE @COUNT_CORREO INT = (
                                        select
                                            COUNT(U.Correo)
                                        from
                                            S_Usuario as U (NOLOCK)
                                        where
                                            U.Correo = @Correo
                                            AND U.Activo = 1
                                    )

        IF @CorreoActual = @Correo
            BEGIN
                SET @RESPONSE_CORREO = 'CORREO_NO_CHANGE'
            END
        ELSE
            BEGIN
                IF @COUNT_CORREO = 0
                    BEGIN
                        SET @RESPONSE_CORREO = 'DISPONIBLE'
                    END
                ELSE
                    BEGIN
                        SET @RESPONSE_CORREO = 'NO_DISPONIBLE'
                    END

            END

        SELECT
            @RESPONSE_CORREO
    END


