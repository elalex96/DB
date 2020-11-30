-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180816
-- Description:	Modifica los pagos de los propietarios
-- =============================================
CREATE PROCEDURE CO_ModificaPagosPropietarios
    @idContrato INT,
    @idUsuario INT,
    @IdPagoPropietario INT,
    @MontoPagado FLOAT,
    @FechaPago DATE,
    @MetodoPago NVARCHAR(300),
    @Comentarios NVARCHAR(2000)
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE CO_HistorialPagos_Propietarios
    SET MontoPagado = @MontoPagado,
        FechaPago = @FechaPago,
        MetodoPago = @MetodoPago,
        Comentarios = @Comentarios
    WHERE IdPagoPropietario = @IdPagoPropietario;
END;