IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_RelacionPedimento_INS'
)
    DROP PROCEDURE SP_FI_RelacionPedimento_INS;
GO
--Created by: DANIEL MORENO
--Created at : 04/11/2021
--Usage: Get a bill and add more than one with relationship to that

CREATE PROCEDURE [dbo].[SP_FI_RelacionPedimento_INS]
    @IdFacturaPadre INT,
    @IdPedimentoHijo INT,
    @CreadoPor INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    IF NOT EXISTS
    (
        SELECT 1
        FROM FI_RelacionPedimento
        WHERE IdFacturaPadre = @IdFacturaPadre
              AND IdPedimentoHijo = @IdPedimentoHijo
    )
    BEGIN
        INSERT INTO FI_RelacionPedimento
        (
            IdFacturaPadre,
            IdPedimentoHijo,
            CreadoPor,
            CreadoEl
        )
        VALUES
        (@IdFacturaPadre, @IdPedimentoHijo, @CreadoPor, GETDATE());
    END;
END;