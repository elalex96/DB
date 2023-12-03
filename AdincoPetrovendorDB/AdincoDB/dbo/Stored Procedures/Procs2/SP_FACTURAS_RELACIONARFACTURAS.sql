IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_RELACIONARFACTURAS'
)
    DROP PROCEDURE SP_FACTURAS_RELACIONARFACTURAS;
GO

--Created by: Luis David De La Cruz Bautista
--Made for: This is the relationship 
--Created at : 08/04/2018
--Usage: Get a bill and add more than one with relationship to that

CREATE PROCEDURE [dbo].[SP_FACTURAS_RELACIONARFACTURAS]
    @idFacturaPadre INT,
    @FirstName INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    IF NOT EXISTS
    (
        SELECT 1
        FROM FI_RelacionRefacturas
        WHERE idFacturaPadre = @idFacturaPadre
              AND idFacturaHijo = @FirstName
    )
    BEGIN
        INSERT INTO FI_RelacionRefacturas
        (
            idFacturaPadre,
            idFacturaHijo
        )
        VALUES
        (@idFacturaPadre, @FirstName);
    END;
END;