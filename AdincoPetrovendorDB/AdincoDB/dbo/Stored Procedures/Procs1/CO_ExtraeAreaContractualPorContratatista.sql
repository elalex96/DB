-- =============================================
-- Author:		Reyna olvera
-- Create date: 20180816
-- Description:	extrae el historial de pagos de los propietarios
-- =============================================
CREATE PROCEDURE CO_ExtraeAreaContractualPorContratatista --3,'2018-06-16',2
    @Contrato INT,
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT dbo.CO_AreaContractual.IdAreaContractual AS IdAreaContractual,
           NombreAreaContractual
    FROM dbo.CO_AreaContractual
        JOIN dbo.CO_Contrato
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
    WHERE IdContrato =@Contrato
END;
