IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_RegistrarFactura'
)
    DROP PROCEDURE SP_FI_RegistrarFactura
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 15-09-17
-- Description:	
-- =============================================
-- Author:		RO
-- Create date: 19-09-23
-- Description:	Se modifican los parametros de entrada ya que se ajusto la pantalla de facturas
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RegistrarFactura]
    @Serie VARCHAR(500),
    @Folio VARCHAR(500),
    @Fecha DATETIME,
    @FormaPago VARCHAR(500),
    @MetodoPago VARCHAR(500),
    @SubTotal MONEY,
    @TotalGrl MONEY,
    @LugarExpedicion VARCHAR(1000),
    @NumCtaPago VARCHAR(1000),
    @IdSubcontratista INT,
    @IdMoneda INT,
    @IdContrato INT,
    @CreadoPor INT,
    @TipoComprobante VARCHAR(500),
	@CondicionesPago VARCHAR(8000)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RFCE VARCHAR(250),
			@RFCR VARCHAR(250),
			@TipoComprobanteEstandarizado VARCHAR(5),
			@MetodoPagoEstandarizado VARCHAR(5),
			@MonedaCorta VARCHAR(50);

    DECLARE @Total DECIMAL(18, 4);
    DECLARE @IdFac INT;
	  

    --Emisor
    SELECT @RFCE = RFC
    FROM PV_Subcontratista (NOLOCK)
    WHERE IdSubcontratista = @IdSubcontratista

    --Receptor
    SELECT @RFCR = RFC
    FROM CO_Contrato (NOLOCK)
        JOIN CO_Contratista (NOLOCK)
            ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
    WHERE CO_Contrato.IdContrato = @IdContrato


    --Calculo de Total
    SELECT @Total = ((@SubTotal * .16) + @SubTotal);

	SELECT @TipoComprobanteEstandarizado = CASE
                                               WHEN @TipoComprobante LIKE '%ingreso%'
                                                    OR @TipoComprobante LIKE 'I%' THEN
                                                   'I'
                                               WHEN (@TipoComprobante) LIKE '%egreso%'
                                                    OR @TipoComprobante LIKE 'E%' THEN
                                                   'E'
                                               WHEN (@TipoComprobante) LIKE '%traslado%'
                                                    OR @TipoComprobante LIKE 'T%' THEN
                                                   'T'
                                               WHEN (@TipoComprobante) LIKE '%nómina%'
                                                    OR @TipoComprobante LIKE 'N%' THEN
                                                   'N'
                                               WHEN (@TipoComprobante) LIKE '%pago%'
                                                    OR @TipoComprobante LIKE 'P%' THEN
                                                   'P'
                                               ELSE
                                                   'NA'
                                           END;

    SELECT @MetodoPagoEstandarizado = CASE
                                          WHEN @MetodoPago LIKE '%exhibi%'
                                               OR @MetodoPago LIKE '%exibi%'
											   OR @MetodoPago LIKE '%PUE%'
                                               OR @FormaPago LIKE '%exhibi%'
											   OR @FormaPago LIKE '%exibi%'
                                               OR @FormaPago LIKE '%PUE%' THEN
                                              'PUE'
                                          WHEN @MetodoPago LIKE '%parcia%'
                                               OR @MetodoPago LIKE '%dife%'
                                               OR @MetodoPago LIKE '%PPD%'
                                               OR @FormaPago LIKE '%parcia%'
                                               OR @FormaPago LIKE '%dife%'
                                               OR @FormaPago LIKE '%PPD%' THEN
                                              'PPD'
                                          WHEN @TipoComprobante = 'P' THEN
                                              'PPD'
                                      END;

	SELECT @MonedaCorta =  TipoMonedaCorto  
    FROM PV_TipoMoneda  (NOLOCK)
    WHERE IdMoneda = @IdMoneda;  

    INSERT INTO [dbo].[FI_Factura]
    (
        [Serie],
        [Folio],
        [Fecha],
        [FormaPago],
        [MetodoPago],
        [SubTotal],
        [MontoConIva],
        [LugarExpedicion],
        [NumCtaPago],
        [Emisor],
        [Receptor],
        [IdSubcontratista],
        [IdMoneda],
        [IdContrato],
        [Activa],
        [CreadoPor],
        [CreadoEn],
        [FechaTimbrado],
		[TipoComprobante],
		[TipoComprobanteEstandarizado],
		[MetodoPagoEstandarizado],
		[Moneda],
		[CondicionesDePago]
    )
    VALUES
    (   @Serie,
        @Folio,
        @Fecha,
        @FormaPago,
        @MetodoPago,
        @SubTotal,
        @TotalGrl,
        @LugarExpedicion,
        @NumCtaPago,
        @RFCE,
        @RFCR,
        @IdSubcontratista,
        @IdMoneda,
        @IdContrato,
        1,
        @CreadoPor,
        GETDATE(),
        @Fecha,
		@TipoComprobante,
		@TipoComprobanteEstandarizado,
		@MetodoPagoEstandarizado,
		@MonedaCorta,
		@CondicionesPago
    )

    SET @IdFac = @@IDENTITY
    SELECT @IdFac
END;

