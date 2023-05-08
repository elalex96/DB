-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Consulta las facturas del contrato para anexar PDF Factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarFacturasPDF2] 
-- Add the parameters for the stored procedure here
@IdContrato INT,
@FechaInicio NVARCHAR(MAX),
@FechaFin	NVARCHAR(MAX)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         SELECT F.IdFactura,
                F.Folio,
                F.Emisor,
                F.LugarExpedicion,
                F.Fecha,
                F.MetodoPago,
                F.MontoConIva,
                F.Receptor,
                CASE ISNULL(D.IdFactura, 0)
                    WHEN 0
                    THEN 'No'
                    ELSE 'Si'
                END AS Cargado,
                D.NombreExtensionArchivo,
                F.Serie,
                PV.RazonSocial,
                F.UUID,
                M.TipoMonedaCorto AS Moneda,
				D.IdDocumento
         FROM FI_Factura AS F
              INNER JOIN PV_Subcontratista PV ON F.IdSubcontratista = PV.IdSubcontratista
              INNER JOIN PV_TipoMoneda M ON F.IdMoneda = M.IdMoneda
              LEFT OUTER JOIN FI_Documento AS D ON F.IdFactura = D.IdFactura
         WHERE(F.IdContrato = @IdContrato)
		 AND F.FechaRecepcion BETWEEN @FechaInicio AND @FechaFin

     END

