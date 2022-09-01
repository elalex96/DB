CREATE PROCEDURE [dbo].[SP_CO_EsDocumentoFacturacionDePetrovendor]
    @IdContrato INT,
    @IdUsuario INT,
    @Id INT,
    @EsFactura BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @EsDePetrovendor BIT = 0;

    IF (@EsFactura = 1)
    BEGIN
        SELECT @EsDePetrovendor = ISNULL(FI_FacturaAdincoPetrovendor.IdFacturaAdinco, 0)
        FROM FI_FacturaAdincoPetrovendor
        WHERE FI_FacturaAdincoPetrovendor.Activo = 1
              AND FI_FacturaAdincoPetrovendor.IdFacturaAdinco = @Id

    END;
    ELSE
    BEGIN
        SELECT @EsDePetrovendor = ISNULL(FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor, 0)
        FROM FI_PedimentoComprobante
        WHERE FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor IS NOT NULL
              AND FI_PedimentoComprobante.IdPedimentoComprobante = @Id
    END;

    SELECT @EsDePetrovendor
END;
