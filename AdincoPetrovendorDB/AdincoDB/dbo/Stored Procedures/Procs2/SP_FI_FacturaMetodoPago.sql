-- =============================================
-- Author:		Manuel Cruz
-- Create date: 23-08-2019
-- Description:	
-- =============================================
-- Author:		Marcos Neri Cruz
-- Create date: 13-12-2019
-- Description:	Seleccion de Proveedor y metodo de pago 
--				para las facturas de FI_FacturaContrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturaMetodoPago]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@IdFactura  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                F.IdSubcontratista
         FROM dbo.FI_Factura F
         WHERE F.IdFactura = @IdFactura
               AND F.IdContrato = @IdContrato
         UNION
         SELECT CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                F.IdSubcontratista
         FROM dbo.FI_FacturaContrato FC
              LEFT JOIN dbo.FI_Factura F ON F.IdFactura = FC.IdFactura
         WHERE F.IdFactura = @IdFactura
               AND FC.IdContrato = @IdContrato;
     END;