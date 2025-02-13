IF OBJECT_ID('[dbo].[p_SC_Presupuesto_Ins]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Presupuesto_Ins]
GO

CREATE PROCEDURE [dbo].[p_SC_Presupuesto_Ins]
(
    @pIdSubContrato INT,
    @pIdPresupuesto INT,
    @pCreadoPor INT
)
AS
BEGIN
    BEGIN TRY
        DECLARE @IdSubContratoPresupuesto INT
        SELECT @IdSubContratoPresupuesto = ISNULL(MAX(IdSubContratoPresupuesto), 0) + 1
        FROM SC_Presupuesto (NOLOCK)

        INSERT INTO SC_Presupuesto
        VALUES (
            @IdSubContratoPresupuesto,
            @pIdSubContrato,
            @pIdPresupuesto,
            @pCreadoPor,
            GETDATE()
        )

        SELECT Error = CAST(1 AS BIT)
    END TRY
    BEGIN CATCH
        SELECT Error = CAST(0 AS BIT)
    END CATCH
END
GO
