
CREATE PROCEDURE dbo.sp_FI_ConsultaFacturasPorContratoYProveedor
@IdContrato as INT,
@DatoBancarioId as INT
AS
BEGIN 
-- =============================================
-- Author:		Oscar Mtz
-- Create date: 04/08/2017
-- Description:	Devuelve el listado de las facturas filtrados por Contrato y Proveedor.
-- =============================================
SELECT  
				SE.IdSubcontratista,
				CAST(F.IdFactura AS NVARCHAR(50)) AS IdFactura,
                Folio,
                Fecha,
                MetodoPago,
                SubTotal,
                MontoConIva,
                Moneda,
                LugarExpedicion,
                Emisor,
                SE.RazonSocial,
                Receptor,
                CA.RazonSocial,
                FechaTimbrado
         FROM FI_Factura F
              JOIN PV_Subcontratista SE ON F.IdSubcontratista = SE.IdSubcontratista
              JOIN CO_Contrato C ON C.IdContrato = @IdContrato
              JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
			  INNER JOIN PV_CuentaBancaria CB ON CB.IdProveedor = SE.IdSubcontratista
         WHERE F.IdContrato = @IdContrato AND CB.DatoBancarioID= @DatoBancarioId;
END