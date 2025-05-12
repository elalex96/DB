IF OBJECT_ID('[dbo].[USP_INS_FI_RelacionNotaCredito]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_INS_FI_RelacionNotaCredito];
GO

CREATE PROCEDURE [dbo].[USP_INS_FI_RelacionNotaCredito]
    @IdNotaCredito             INT,
    @IdComprobanteRelacionado INT,
    @Monto                    MONEY,
    @CreadoPor                INT,
	@IdContrato				  INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[FI_NotaCredito_REL_Comprobantes]
    (
        IdNotaCredito,
        IdComprobanteRelacionado,
        Monto,
        CreadoPor
    )
    VALUES
    (
        @IdNotaCredito,
        @IdComprobanteRelacionado,
        @Monto,
        @CreadoPor
    );
END;
GO
