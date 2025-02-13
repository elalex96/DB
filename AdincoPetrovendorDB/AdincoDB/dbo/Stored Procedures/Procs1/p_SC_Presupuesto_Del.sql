IF OBJECT_ID('[dbo].[p_SC_Presupuesto_Del]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Presupuesto_Del]
GO

CREATE PROCEDURE [dbo].[p_SC_Presupuesto_Del]
(
    @pIdSubContrato INT
)
AS
BEGIN
    BEGIN TRY
        DELETE FROM SC_Presupuesto
        WHERE IdSubContrato = @pIdSubContrato

        SELECT Error = CAST(1 AS BIT)
    END TRY
    BEGIN CATCH
        SELECT Error = CAST(0 AS BIT)
    END CATCH
END

