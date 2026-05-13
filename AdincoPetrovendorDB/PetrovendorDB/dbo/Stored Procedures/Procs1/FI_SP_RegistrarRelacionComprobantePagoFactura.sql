-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-06-2018>
-- Description:	<Se registra la relacion entre el comprobante de pago y Facturas>
-- =============================================

CREATE procedure FI_SP_RegistrarRelacionComprobantePagoFactura
	@IdFacturaCompPago INT,
	@IdFactura INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.FI_FacturaCompPagoRelacion
	(
	    IdFacturaCompPago,
	    IdFactura
	)
	VALUES
	(   @IdFacturaCompPago, -- IdFacturaCompPago - int
	    @IdFactura  -- IdFactura - int
	)
END