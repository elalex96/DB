CREATE OR ALTER PROCEDURE dbo.USP_SEL_CO_ObtenerPresupuestosPorContrato
(
    @IdContrato INT,
    @IdUsuario  INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        P.IdPresupuesto,
        CONCAT(P.Nombre, ' [', P.IdPresupuestoCNH, ']') AS Nombre
    FROM CO_ProgramaActividad PA WITH (NOLOCK)
    INNER JOIN CO_PeriodoContrato PC WITH (NOLOCK)
        ON PA.IdPeriodoContrato = PC.IdPeriodo
    INNER JOIN CO_Presupuesto P WITH (NOLOCK)
        ON PA.IdProgramaActividad = P.IdProgramaActividad
    WHERE PC.IdContrato = @IdContrato
      AND P.Actual = 1
    ORDER BY P.Nombre;
END;
GO
