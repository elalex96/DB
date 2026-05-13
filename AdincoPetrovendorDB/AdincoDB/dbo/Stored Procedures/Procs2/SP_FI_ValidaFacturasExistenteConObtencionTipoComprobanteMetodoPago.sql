
CREATE PROCEDURE [dbo].[SP_FI_ValidaFacturasExistenteConObtencionTipoComprobanteMetodoPago]
    @UUID VARCHAR(500),
    @TipoComprobante VARCHAR(500),
    @MetodoPago VARCHAR(500),
    @FormaPago VARCHAR(500),
    @idContrato INT = 0,
    @idUsuario INT = 0
AS
BEGIN
    -- =============================================
    -- Author:		Neri del Angel
    -- Create date: 19 de Abril del 2023
    -- Description:	Se utiliza como base el sp sp_FI_ValidaFacturasExistentes
    --				Se agrega cálculo de los nuevos campos TipoComprobanteEstandarizado  y MetodoPagoEstandarizado
    -- =============================================
    SET NOCOUNT ON

    DECLARE @Existe INT = 0,
            @TipoComprobanteEstandarizado VARCHAR(5),
            @MetodoPagoEstandarizado VARCHAR(5);

    SELECT @Existe = COUNT(1)
    FROM FI_FACTURA
    WHERE UUID = @UUID;

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

    SELECT @Existe AS Existe,
           @TipoComprobanteEstandarizado AS TipoComprobanteEstandarizado,
           @MetodoPagoEstandarizado AS MetodoPagoEstandarizado
END