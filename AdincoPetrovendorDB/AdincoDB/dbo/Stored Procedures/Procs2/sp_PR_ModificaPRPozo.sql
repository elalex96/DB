-- =============================================
-- Author:		Reuna Olvera
-- Create date: 20181009
-- Description:	Modifica la region fiscal, y el punto de entrega del pozo
-- =============================================
CREATE PROCEDURE sp_PR_ModificaPRPozo
    @id INT,
    @RegionFiscal NVARCHAR(50),
    @nombrePE INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN

    SET NOCOUNT ON;
    UPDATE dbo.PR_Pozo
    SET RegionFiscal = @RegionFiscal,
        PuntoEntregaID = @nombrePE,
        Modificado = GETDATE(),
        ModificadoPor = @IdUsuario
    WHERE Id = @id;

END;
