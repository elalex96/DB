-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2018/09/04
-- Description:	Extrae RFC del contratista
-- =============================================
CREATE PROCEDURE sp_CO_ExtraeContratista
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT RFC
    FROM dbo.CO_Contrato
        JOIN dbo.CO_Contratista
            ON CO_Contratista.IdContratista = CO_Contrato.IdContratista
    WHERE IdContrato = @IdContrato;
END;
