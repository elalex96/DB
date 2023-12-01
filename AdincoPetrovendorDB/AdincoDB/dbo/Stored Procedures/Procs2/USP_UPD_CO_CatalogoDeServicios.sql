IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_CatalogoDeServicios'
)
    DROP PROCEDURE USP_UPD_CO_CatalogoDeServicios;
GO

CREATE PROCEDURE [dbo].[USP_UPD_CO_CatalogoDeServicios]
    @UsuarioId INT,
    @ContratoId INT,
    @IdServicio INT,
    @NombreDelServicio VARCHAR(8000),
    @IdUnidad INT,
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @FechaHoy DATETIME = GETDATE(),
            @DetalleBitacora VARCHAR(8000) = '',
            @UnidadAntes VARCHAR(100) = '',
            @UnidadDespues VARCHAR(100) = '',
            @ContratoRelacionado VARCHAR(100) = '';

    SELECT @UnidadAntes = LTRIM(RTRIM(ISNULL(CO_Unidad.Unidad, '')))
    FROM CO_Servicio (NOLOCK)
        JOIN CO_Unidad (NOLOCK)
            ON CO_Servicio.IdServicio = @IdServicio
               AND CO_Servicio.IdUnidad = CO_Unidad.IdUnidad
               AND CO_Unidad.IdContrato = 1

    SELECT @UnidadDespues = LTRIM(RTRIM(ISNULL(CO_Unidad.Unidad, '')))
    FROM CO_Unidad (NOLOCK)
    WHERE CO_Unidad.IdUnidad = @IdUnidad
          AND CO_Unidad.IdContrato = 1

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' Nombre del Servicio: Antes [',
                        LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, ''))),
                        '], Después [',
                        LTRIM(RTRIM(ISNULL(@NombreDelServicio, ''))),
                        ']'
                    )
    FROM CO_Servicio (NOLOCK)
    WHERE CO_Servicio.IdServicio = @IdServicio
          AND LTRIM(RTRIM(ISNULL(CO_Servicio.NombreServicio, ''))) <> LTRIM(RTRIM(ISNULL(@NombreDelServicio, '')))

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(
                        @DetalleBitacora,
                        ' Unidad: Antes [',
                        CONVERT(VARCHAR(10), CO_Servicio.IdUnidad),
                        ' - ',
                        @UnidadAntes,
                        '], Después [',
                        CONVERT(VARCHAR(10), @IdUnidad),
                        ' - ',
                        @UnidadDespues,
                        ']'
                    )
    FROM CO_Servicio (NOLOCK)
    WHERE CO_Servicio.IdServicio = @IdServicio
          AND CO_Servicio.IdUnidad <> @IdUnidad

    SELECT TOP 1
        @DetalleBitacora
            = CONCAT(   @DetalleBitacora,
                        ' Activo: Antes [',
                        CASE
                            WHEN ISNULL(CO_Servicio.Activo, 0) = 0 THEN
                                'Inactivo'
                            ELSE
                                'Activo'
                        END,
                        '], Después [',
                        CASE
                            WHEN ISNULL(@Activo, 0) = 0 THEN
                                'Inactivo'
                            ELSE
                                'Activo'
                        END,
                        ']'
                    )
    FROM CO_Servicio (NOLOCK)
    WHERE CO_Servicio.IdServicio = @IdServicio
          AND ISNULL(CO_Servicio.Activo, 0) <> ISNULL(@Activo, 0)

    IF (LEN(@DetalleBitacora) > 0)
    BEGIN
        SELECT TOP 1
            @ContratoRelacionado
                = CO_Contrato.NumeroContrato + ' - ' + ISNULL(CO_AreaContractual.NombreAreaContractual, '')
        FROM CO_Servicio (NOLOCK)
            JOIN CO_Contrato (NOLOCK)
                ON CO_Servicio.IdServicio = @IdServicio
                   AND CO_Servicio.IdContrato = CO_Contrato.IdContrato
            JOIN CO_AreaContractual (NOLOCK)
                ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual

        UPDATE CO_Servicio
        SET NombreServicio = @NombreDelServicio,
            IdUnidad = @IdUnidad,
            Activo = @Activo,
            ModificadoPor = @UsuarioId,
            ModificadoEl = @FechaHoy
        WHERE IdServicio = @IdServicio

        INSERT INTO AP_Bitacora
        (
            [Fecha],
            [Tipo],
            [Mensaje],
            [Detalle],
            [UsuarioId],
            [ContratoId]
        )
        VALUES
        (@FechaHoy,
         'Edición',
         'Edición de Valores de CO_Servicio en la página /2/Administrador/CatalogoDeServicios.aspx',
         CONCAT(
                   'Del Servicio con Id: ',
                   CONVERT(VARCHAR(10), @IdServicio),
                   ' -',
                   @DetalleBitacora,
                   ' - relacionado al contrato: [',
                   @ContratoRelacionado,
                   ']'
               ),
         @UsuarioId,
         @ContratoId
        );
    END
END;