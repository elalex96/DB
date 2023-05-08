CREATE PROCEDURE [dbo].[SP_CO_EsDocumentoFacturacionDePetrovendor]
    @IdContrato INT,
    @IdUsuario INT,
    @Id INT,
    @EsFactura BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    DECLARE @EsDePetrovendor BIT = 0,
			@EsCompraDirecta BIT = 0
    DECLARE @UUID VARCHAR(100) = '';

    IF (@EsFactura = 1)
    BEGIN
        SELECT @EsDePetrovendor = ISNULL(FI_FacturaAdincoPetrovendor.IdFacturaAdinco, 0)
        FROM FI_FacturaAdincoPetrovendor
        WHERE FI_FacturaAdincoPetrovendor.Activo = 1
              AND FI_FacturaAdincoPetrovendor.IdFacturaAdinco = @Id

        IF (@EsDePetrovendor = 0)
        BEGIN
            SELECT @UUID = UUID
            FROM FI_Factura
            WHERE IdFactura = @Id

			SELECT @EsCompraDirecta = 1  
			FROM Petrovendor.dbo.FI_Factura 
            INNER JOIN Petrovendor.dbo.TA_Operacion
                ON FI_Factura.UUID = @UUID
				AND TA_Operacion.IdTipoOperacion = 14
				AND	FI_Factura.IdFactura = TA_Operacion.IdDocumento 			

            IF EXISTS (SELECT UUID FROM Petrovendor.dbo.FI_Factura WHERE UUID = @UUID)
            BEGIN
                SET @EsDePetrovendor = 1;
            END

			-- Si es compra directa entonces se debe de mostrar los controles en la edicion
			IF(@EsCompraDirecta = 1)
			BEGIN
				SET @EsDePetrovendor = 0
			END
        END

		BEGIN
			SELECT @UUID = UUID
            FROM FI_Factura
            WHERE IdFactura = @Id

			SELECT @EsCompraDirecta = 1  
			FROM Petrovendor.dbo.FI_Factura 
            INNER JOIN Petrovendor.dbo.TA_Operacion
                ON FI_Factura.UUID = @UUID
				AND TA_Operacion.IdTipoOperacion = 14
				AND	FI_Factura.IdFactura = TA_Operacion.IdDocumento 
		END
    END;
    ELSE
    BEGIN
        SELECT @EsDePetrovendor = ISNULL(FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor, 0)
        FROM FI_PedimentoComprobante
        WHERE FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor IS NOT NULL
              AND FI_PedimentoComprobante.IdPedimentoComprobante = @Id
    END;

    -- Si es compra directa entonces se debe de mostrar los controles en la edicion
	IF(@EsCompraDirecta = 1)
	BEGIN
		SELECT 0
	END
	ELSE
	BEGIN
		SELECT @EsDePetrovendor 
	END
END;
