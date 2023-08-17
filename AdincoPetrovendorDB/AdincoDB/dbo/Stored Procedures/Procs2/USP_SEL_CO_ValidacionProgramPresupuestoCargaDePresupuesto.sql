IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_CO_ValidacionProgramPresupuestoCargaDePresupuesto'
)
    DROP PROCEDURE USP_SEL_CO_ValidacionProgramPresupuestoCargaDePresupuesto;
GO

CREATE PROCEDURE USP_SEL_CO_ValidacionProgramPresupuestoCargaDePresupuesto 
    @UsuarioId INT,
    @ContratoId INT,
    @IdContratoSeleccionado INT,
    @Programa VARCHAR(100),
    @Presupuesto VARCHAR(100)
AS
SET NOCOUNT ON;

DECLARE @Resultado VARCHAR(100) = '',
        @SeRepitePrograma INT = 0,
        @SeRepitePresupuesto INT = 0;

CREATE TABLE #TablaTemporalValidaciones
(
    Programa VARCHAR(100),
    ProgramaActivo BIT,
    Presupuesto VARCHAR(100),
    PresupuestoActivo BIT
)

INSERT INTO #TablaTemporalValidaciones
(
    Programa,
    ProgramaActivo,
    Presupuesto,
    PresupuestoActivo
)
SELECT CO_ProgramaActividad.NombrePrograma,
       CO_ProgramaActividad.Activo,
       CO_Presupuesto.Nombre,
       CO_Presupuesto.Activo
FROM CO_ProgramaActividad (NOLOCK)
    JOIN CO_PeriodoContrato (NOLOCK)
        ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
		   AND CO_PeriodoContrato.IdContrato = @IdContratoSeleccionado
    JOIN CO_Presupuesto (NOLOCK)
        ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad

SELECT @SeRepitePrograma = COUNT(1)
FROM #TablaTemporalValidaciones
WHERE LTRIM(RTRIM(UPPER(Programa))) = LTRIM(RTRIM(UPPER(@Programa)))

SELECT @SeRepitePresupuesto = COUNT(1)
FROM #TablaTemporalValidaciones
WHERE LTRIM(RTRIM(UPPER(Presupuesto))) = LTRIM(RTRIM(UPPER(@Presupuesto)))


IF (@SeRepitePrograma > 0 AND @SeRepitePresupuesto = 0)
    SET @Resultado = 'ALERTA_PROGRAMA';

IF (@SeRepitePrograma = 0 AND @SeRepitePresupuesto > 0)
   SET @Resultado = 'ALERTA_PRESUPUESTO';

IF (@SeRepitePrograma > 0 AND @SeRepitePresupuesto > 0)
   SET @Resultado = 'ALERTA_PROGRAMA_PRESUPUESTO';

SELECT @Resultado AS Resultado