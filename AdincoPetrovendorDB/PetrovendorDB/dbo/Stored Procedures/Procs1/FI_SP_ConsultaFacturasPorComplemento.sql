
-- =============================================
-- Author:                  <Jose Roman>
-- Create date: <04-12-2018>
-- Description:   <Se consultan los complementos por factura>
-- =============================================
CREATE PROCEDURE FI_SP_ConsultaFacturasPorComplemento
         @IdFacturaComplemento INT,
         /*---------------------Parametros contrato---------------------*/
         @IdContrato INT = NULL,
         @IdUsuario INT = NULL,
         @FechaRegistro DATETIME = NULL       
         /*---------------------Parametros contrato---------------------*/
AS
BEGIN
         SELECT fc.IdFactura,
                            f.MontoConIva AS SubTotal,
                            fc.MontoPagado,
                            f.MontoConIva - fc.MontoPagado AS MontoRemanente
         FROM dbo.FI_FacturaComplemento fc
         INNER JOIN dbo.FI_Factura f ON f.IdFactura = fc.IdFactura
         WHERE fc.IdComplemento = @IdFacturaComplemento
END

