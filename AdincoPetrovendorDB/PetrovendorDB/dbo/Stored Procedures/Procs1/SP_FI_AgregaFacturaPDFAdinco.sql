CREATE PROCEDURE dbo.SP_FI_AgregaFacturaPDFAdinco
(
    @IdFactura INT,
    @IdUsuario INT,
    @IdTipoDocumento INT,
    @ComprobantePdfByte IMAGE = NULL	
)
AS
BEGIN
    EXEC Adinco.dbo.SP_FI_AgregaFacturaPDF @IdFactura = @IdFactura,                  -- int
                                           @IdUsuario = @IdUsuario,                  -- int
                                           @ComprobantePDF = '',                     -- nvarchar(max)
                                           @IdTipoDocumento = @IdTipoDocumento,      -- int
                                           @ComprobantePDFByte = @ComprobantePdfByte -- image


END