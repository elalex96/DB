-- =============================================
-- Author:		Josue Glez
-- Create date: 25-05-17
-- Description:	Devuelve una lista de las faturas de un contrato ( Relacion, Facturas , transferencia)
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasxContrato]
-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @CONTRATISTA INT;
         SELECT @CONTRATISTA = CA.IdContratista
         FROM CO_Contrato C
              JOIN CO_Contratista CA ON C.IdContratista = CA.IdContratista
         WHERE C.IdContrato = @IdContrato;
         IF @CONTRATISTA = 10000
         -- Insert statements for procedure here

             SELECT CAST(F.IdFactura AS NVARCHAR(50)) AS IdFactura,
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
             WHERE CA.IdContratista = @CONTRATISTA;
             ELSE
         SELECT CAST(F.IdFactura AS NVARCHAR(50)) AS IdFactura,
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
         WHERE F.IdContrato = @IdContrato;

         --EXEC sp_FI_ConsultaFacturas 3,'2016-01-01','2016-10-01'
     END;