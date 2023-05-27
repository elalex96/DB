CREATE PROCEDURE [dbo].[SP_AP_InsercionEdicionCalendario]
	@Id INT,
    @EsEdicion BIT = 1,
    @IdFecha DATE,
    @DiaLaborable BIT,
    @DiaFeriado BIT,
    @Descripcion VARCHAR(1500),
    @ContratoId INT = 0,
    @UsuarioId INT = 0
AS
BEGIN
    DECLARE @DiaLaborablePrevio BIT,
            @DiaFeriadoPrevio BIT,
            @DescripcionPrevio VARCHAR(1500),
            @FechaHoy DATETIME = GETDATE(),
            @DatosAntes VARCHAR(2000) = '',
            @DatosDespues VARCHAR(2000) = '';

    IF (@EsEdicion = 1)
    BEGIN
        SELECT TOP 1
            @DiaLaborablePrevio = DiaLaborable,
            @DiaFeriadoPrevio = DiaFeriado,
            @DescripcionPrevio = Descripcion
        FROM AP_Calendario
        WHERE IdFecha = @IdFecha

        IF (@DiaLaborablePrevio <> ISNULL(@DiaLaborable, 0))
        BEGIN
            SET @DatosAntes += CONCAT(' DiaLaborable [', CONVERT(VARCHAR, @DiaLaborablePrevio), ']')
            SET @DatosDespues += CONCAT(' DiaLaborable [', CONVERT(VARCHAR, ISNULL(@DiaLaborable, 0)), ']')
        END

        IF (@DiaFeriadoPrevio <> ISNULL(@DiaFeriado, 0))
        BEGIN
            SET @DatosAntes += CONCAT(' DiaFeriado [', CONVERT(VARCHAR, @DiaFeriadoPrevio), ']')
            SET @DatosDespues += CONCAT(' DiaFeriado [', CONVERT(VARCHAR, ISNULL(@DiaFeriado, 0)), ']')
        END

        IF (@DescripcionPrevio <> ISNULL(@Descripcion, ''))
        BEGIN
            SET @DatosAntes += CONCAT(' Descripcion [', LTRIM(RTRIM(ISNULL(@DescripcionPrevio, ''))), ']')
            SET @DatosDespues += CONCAT(' Descripcion [', LTRIM(RTRIM(ISNULL(@Descripcion, ''))), ']')
        END

        IF (ISNULL(@DatosAntes, '') <> '')
        BEGIN
            UPDATE AP_Calendario
            SET DiaLaborable = ISNULL(@DiaLaborable, 0),
                DiaFeriado = ISNULL(@DiaFeriado, 0),
                Descripcion = LTRIM(RTRIM(ISNULL(@Descripcion, ''))),
                ModificadoPor = @UsuarioId,
                ModificadoEn = @FechaHoy
            WHERE IdFecha = @IdFecha

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
             'Edición de Valores de AP_Calendario en la página AdministracionDeCalendarios.aspx',
             CONCAT('IdFecha [', CONVERT(VARCHAR, @IdFecha), '], Antes:', @DatosAntes, ', Después:', @DatosDespues),
             @UsuarioId,
             @ContratoId
            )
        END
    END
END
