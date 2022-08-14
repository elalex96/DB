-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK y Nombrado de Tablas en select
-- =============================================
CREATE FUNCTION [dbo].[fn_CO_ValidarMontosTransferencia]
(
    @pIdTransfer INT,
    @pIdDocumento INT,
    @pMontoPagado MONEY,
    @cvTipoDocumento INT
)
RETURNS VARCHAR(500)
AS
BEGIN

    DECLARE @error VARCHAR(500) = '',
            @totalPagado MONEY,
            @totalTransferencia MONEY,
            @TipoMoneda varchar(50);

    SELECT @TipoMoneda = dbo.PV_TipoMoneda.TipoMonedaCorto
    FROM dbo.FI_Transfer (NOLOCK)
        JOIN dbo.PV_TipoMoneda (NOLOCK)
            ON PV_TipoMoneda.IdMoneda = FI_Transfer.IdMoneda
    WHERE dbo.FI_Transfer.IdTransferencia = @pIdTransfer;

    IF (@cvTipoDocumento = 1)
    BEGIN

        SELECT @totalPagado = ISNULL(SUM(MontoPagado), 0)
        FROM FI_TransferFactura  (NOLOCK)
        WHERE IdTransfer = @pIdTransfer
              AND IdFactura <> @pIdDocumento;

        SELECT @totalTransferencia = ISNULL(MontoPagado, 0)
        FROM dbo.FI_Transfer (NOLOCK)
        WHERE dbo.FI_Transfer.IdTransferencia = @pIdTransfer;

        IF @totalPagado + ISNULL(@pMontoPagado, 0) > @totalTransferencia
        BEGIN
            SET @error
                = @error + 'No es posible ligar la factura con ID ' + CONVERT(varchar(50), @pIdDocumento)
                  + ' ya que el monto ' + CONVERT(varchar(50), @pMontoPagado)
                  + ' excede el total de la transferencia. El monto disponible a capturar es $'
                  + CAST((ISNULL(@totalTransferencia, 0) - ISNULL(@totalPagado, 0)) AS VARCHAR) + ' ' + @TipoMoneda
                  + '.';
        END;
    END;

    IF (@cvTipoDocumento = 2 OR @cvTipoDocumento = 3)
    BEGIN
		SELECT @totalPagado = ISNULL(SUM(FI_TransferFactura.MontoPagado), 0)
        FROM FI_TransferFactura  (NOLOCK)
        WHERE FI_TransferFactura.IdTransfer = @pIdTransfer
              AND FI_TransferFactura.IdPedimentoComprobante <> @pIdDocumento;

        SELECT @totalTransferencia = ISNULL(dbo.FI_Transfer.MontoPagado, 0)
        FROM dbo.FI_Transfer  (NOLOCK)
        WHERE dbo.FI_Transfer.IdTransferencia = @pIdTransfer;

        IF @totalPagado + ISNULL(@pMontoPagado, 0) > @totalTransferencia
        BEGIN
            SET @error
                = @error + 'No es posible ligar el pedimento o comprobante con ID '
                  + CONVERT(varchar(50), @pIdDocumento) + ' ya que el monto ' + CONVERT(varchar(50), @pMontoPagado)
                  + ' excede el total de la transferencia.  El monto disponible a capturar es $'
                  + CAST((ISNULL(@totalTransferencia, 0) - ISNULL(@totalPagado, 0)) AS VARCHAR) + ' ' + @TipoMoneda
                  + '.';
        END;
    END;
    RETURN @error;
END;