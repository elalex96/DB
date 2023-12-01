IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_NombreServicioExiste'
)
    DROP PROCEDURE USP_SEL_CO_NombreServicioExiste;
GO

CREATE PROCEDURE [dbo].[USP_SEL_CO_NombreServicioExiste]
    @UsuarioId INT,
    @ContratoId INT,
    @IdServicio INT,
    @NombreDelServicio VARCHAR(8000)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SeRepite BIT = 0,
            @IdContrato INT = 0;

    SELECT @IdContrato = IdContrato
    FROM CO_Servicio (NOLOCK)
    WHERE IdServicio = @IdServicio;

    IF (
       (
           SELECT COUNT(1)
           FROM CO_Servicio
           WHERE CO_Servicio.IdServicio <> @IdServicio
                 AND CO_Servicio.IdContrato = @IdContrato
                 AND LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, ''))) = LTRIM(RTRIM(ISNULL(@NombreDelServicio, '')))
       ) > 0
       )
    BEGIN
        SET @SeRepite = 1;
    END;

    SELECT @SeRepite;
END