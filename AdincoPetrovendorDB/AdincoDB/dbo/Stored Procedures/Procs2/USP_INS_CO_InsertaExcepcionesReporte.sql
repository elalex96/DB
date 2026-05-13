IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_CO_InsertaExcepcionesReporte'
)
    DROP PROCEDURE USP_INS_CO_InsertaExcepcionesReporte;
GO

CREATE PROCEDURE [dbo].[USP_INS_CO_InsertaExcepcionesReporte]
    @ContratoId INT,
    @UsuarioId INT,
    @IdTipoReporte INT,
    @IdContrato INT,
    @MesReporte VARCHAR(50),
    @FechaFin DATETIME,
    @Motivo VARCHAR(5000),
    @Activo BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @FechaHoy DATETIME = GETDATE(),
            @Id INT,
			@FechaFinDate DATE = CONVERT(DATE, @FechaFin);

	SET @FechaFin =  DATEADD(HOUR, 23, DATEADD(MINUTE, 59,DATEADD(SECOND, 59,CONVERT(DATETIME,@FechaFinDate))));

    INSERT INTO CO_ExcepcionesReporte
    (
        [IdTipoReporte],
        [IdContrato],
        [MesReporte],
        [FechaFin],
        [Motivo],
        [Activo],
        [CreadoPor],
        [CreadoEl]
    )
    VALUES(
     @IdTipoReporte,
     @IdContrato,
     CONVERT(DATE, @MesReporte),
     @FechaFin,
     LTRIM(RTRIM(ISNULL(@Motivo, ''))),
     ISNULL(@Activo, 0),
     @UsuarioId,
     @FechaHoy
    )

    SELECT @Id = SCOPE_IDENTITY();
    
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
     'Creación',
     'Creación de registro en tabla CO_ExcepcionesReporte en la página ExcepcionesReporte.aspx',
     CONCAT(
               'Creación de registro con Id [',
               CONVERT(VARCHAR(10), @Id),
               ']',
               ', con los siguientes valores',
               ' IdTipoReporte [',
                CONVERT(VARCHAR(10), @IdTipoReporte),
               '], IdContrato [',
               CONVERT(VARCHAR(10), @IdContrato),
               '], MesReporte [',
               @MesReporte,
               '], FechaFin[',
               CONVERT(VARCHAR(100), @FechaFin),
               '], Motivo[',
               @Motivo,
               '], Activo[',
               CASE
                   WHEN ISNULL(@Activo, 0) IS NULL THEN
                       'Inactivo'
                   ELSE
                       'Activo'
               END,
               ']'
           ),
     @UsuarioId,
     @ContratoId
    );
END;