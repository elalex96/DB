CREATE PROCEDURE [dbo].[SP_AP_InsercionEdicionCalendarioExcepciones]
    @Id INT,
    @EsEdicion BIT = 0,
    @IdFecha DATE,
    @IdRegulador INT,
    @Descripcion VARCHAR(1500),
    @Activo BIT,
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    DECLARE @DiaDeSemana INT,
            @DescripcionPrevio VARCHAR(1500),
            @ActivoPrevio BIT,
            @FechaHoy DATETIME = GETDATE(),
            @DatosAntes VARCHAR(2000) = '',
            @DatosDespues VARCHAR(2000) = '';

    SELECT TOP 1
        @DiaDeSemana = DiaDeSemana
    FROM AP_Calendario (NOLOCK)
    WHERE IdFecha = @IdFecha;

    IF (@EsEdicion = 1)
    BEGIN
        SELECT TOP 1
            @DescripcionPrevio = Descripcion,
            @ActivoPrevio = Activo
        FROM AP_CalendarioExcepciones
        WHERE IdFecha = @IdFecha
              AND IdRegulador = @IdRegulador

        IF (@ActivoPrevio != ISNULL(@Activo, 0))
        BEGIN

            SET @DatosAntes += CONCAT(' Activo [', CONVERT(VARCHAR, @ActivoPrevio), ']')
            SET @DatosDespues += CONCAT(' Activo [', CONVERT(VARCHAR, ISNULL(@Activo, 0)), ']')
        END

        IF (@DescripcionPrevio != ISNULL(@Descripcion, ''))
        BEGIN

            SET @DatosAntes += CONCAT(' Descripcion [', LTRIM(RTRIM(ISNULL(@DescripcionPrevio, ''))), ']')
            SET @DatosDespues += CONCAT(' Descripcion [', LTRIM(RTRIM(ISNULL(@Descripcion, ''))), ']')
        END

        IF (ISNULL(@DatosAntes, '') <> '')
        BEGIN
            UPDATE AP_CalendarioExcepciones
            SET Descripcion = LTRIM(RTRIM(ISNULL(@Descripcion, ''))),
                Activo = ISNULL(@Activo, 0),
                ModificadoPor = @UsuarioId,
                ModificadoEn = @FechaHoy
            WHERE IdFecha = @IdFecha
                  AND IdRegulador = @IdRegulador

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
             'Edición de Valores de AP_CalendarioExcepciones en la página AdministracionDeCalendarios.aspx',
             CONCAT(
                       'IdFecha [',
                       CONVERT(VARCHAR, @IdFecha),
                       '], IdRegulador [',
                       CONVERT(VARCHAR, @IdRegulador),
                       '], Antes:',
                       @DatosAntes,
                       ', Después:',
                       @DatosDespues
                   ),
             @UsuarioId,
             @ContratoId
            )
        END

    END
    ELSE
    BEGIN
        INSERT INTO AP_CalendarioExcepciones
        (
            IdFecha,
            IdRegulador,
            Descripcion,
            DiaDeSemana,
            Activo,
            CreadoPor,
            CreadoEn
        )
        VALUES
        (@IdFecha,
         @IdRegulador,
         LTRIM(RTRIM(ISNULL(@Descripcion, ''))),
         @DiaDeSemana,
         ISNULL(@Activo, 0),
         @UsuarioId,
         @FechaHoy
        )

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
         'Creación ',
         'Creación de Registro en AP_CalendarioExcepciones en la página AdministracionDeCalendarios.aspx',
         CONCAT(
                   'IdFecha [',
                   CONVERT(VARCHAR, @IdFecha),
                   '], IdRegulador [',
                   CONVERT(VARCHAR, @IdRegulador),
                   '], Descripcion [',
                   LTRIM(RTRIM(ISNULL(LTRIM(RTRIM(ISNULL(@Descripcion, ''))), ''))),
                   '], DiaDeSemana [',
                   CONVERT(VARCHAR, ISNULL(@DiaDeSemana, 0)),
                   '], Activo [',
                   CONVERT(VARCHAR, ISNULL(@Activo, 0)),
                   ']'
               ),
         @UsuarioId,
         @ContratoId
        )
    END
END
