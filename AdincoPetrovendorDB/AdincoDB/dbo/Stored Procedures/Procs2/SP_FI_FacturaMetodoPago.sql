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
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK, Nombrado de Tablas en select y eliminado de union
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturaMetodoPago]
    @IdContrato INT,
    @IdUsuario INT,
    @IdFactura INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    CREATE TABLE #TableFacturaMetodoPago
    (
        MetodoPago VARCHAR(50) NULL,
        IdSubcontratista INT
    )
	/**/
    INSERT INTO #TableFacturaMetodoPago
    (
        MetodoPago,
        IdSubcontratista
    )	
    SELECT CASE
               WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                    OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                    OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                    OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                    OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                    OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
           END AS MetodoPago,
           dbo.FI_Factura.IdSubcontratista
    FROM dbo.FI_Factura (NOLOCK)
    WHERE dbo.FI_Factura.IdFactura = @IdFactura
          AND dbo.FI_Factura.IdContrato = @IdContrato;
	/**/
    IF ((SELECT COUNT(*) FROM #TableFacturaMetodoPago) = 0)
    BEGIN
        INSERT INTO #TableFacturaMetodoPago
        (
            MetodoPago,
            IdSubcontratista
        )
        SELECT CASE
                   WHEN dbo.FI_Factura.MetodoPago LIKE '%exhibi%'
                        OR dbo.FI_Factura.MetodoPago LIKE '%PUE%'
                        OR dbo.FI_Factura.FormaPago LIKE '%exhibi%'
                        OR dbo.FI_Factura.FormaPago LIKE '%PUE%' THEN
                       'PUE'
                   WHEN dbo.FI_Factura.MetodoPago LIKE '%parcia%'
                        OR dbo.FI_Factura.MetodoPago LIKE '%dife%'
                        OR dbo.FI_Factura.MetodoPago LIKE '%PPD%'
                        OR dbo.FI_Factura.FormaPago LIKE '%parcia%'
                        OR dbo.FI_Factura.FormaPago LIKE '%dife%'
                        OR dbo.FI_Factura.FormaPago LIKE '%PPD%' THEN
                       'PPD'
               END AS MetodoPago,
               dbo.FI_Factura.IdSubcontratista
        FROM dbo.FI_FacturaContrato (NOLOCK)
            JOIN dbo.FI_Factura (NOLOCK)
                ON dbo.FI_FacturaContrato.IdContrato = @IdContrato
                   AND dbo.FI_FacturaContrato.IdFactura = @IdFactura
                   AND dbo.FI_FacturaContrato.IdFactura = dbo.FI_Factura.IdFactura
    END;
	/**/
    SELECT MetodoPago,
           IdSubcontratista
    FROM #TableFacturaMetodoPago;
END;
