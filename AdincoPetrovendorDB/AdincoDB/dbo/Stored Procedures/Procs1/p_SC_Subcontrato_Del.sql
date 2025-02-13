IF OBJECT_ID('[dbo].[p_SC_Subcontrato_Del]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Subcontrato_Del]
GO

CREATE PROCEDURE [dbo].[p_SC_Subcontrato_Del]
(
    @IdSubContrato INT
)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM OT_Solicitud (NOLOCK)
        WHERE IdOTEstatus IN (2, 3, 4, 5, 6, 9, 10, 11) 
        AND IdSubcontrato = @IdSubContrato
    )
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM OT_Solicitud (NOLOCK)
            WHERE IdSubcontrato = @IdSubContrato 
            AND ISNULL(IsActivo, 0) = 1
        )
        BEGIN
            UPDATE SC_SubContrato
            SET IsEliminado = 1
            WHERE IdSubContrato = @IdSubContrato
        END
        SELECT Error = 0
    END
    ELSE
    BEGIN
        SELECT Error = 2
    END
END

