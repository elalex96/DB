-- =============================================
-- Author:		Josue Glez
-- Create date:	13-06-17
-- Description:	Llena un grid con el detalle de las transferencias pendientes por asociar
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidaRelacion_Facturas_Transferencias] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@PInicial   NVARCHAR(50),
@PFinal     NVARCHAR(50)
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT
	    	(SELECT CASE WHEN T.IdTransferencia IS NULL THEN 'Factura Sin relación'
				ELSE 'Factura Relacionada'
				END) as Estatus,
				 TF.IdTransferFactura,
                F.IdFactura,
                F.IdSubcontratista,
                P.RazonSocial,
                f.Emisor,
                F.Folio,
                F.MontoConIva AS MontoFactura,
                f.UUID,
			 f.FechaRecepcion,
			 f.FechaTimbrado,
                F.IdContrato AS contrato_factura,
                T.ReferenciaBancaria,
                TF.IdTransfer,
                T.IdContrato AS Contrato_transferencia,
                T.MontoPagado AS MontoTransferencia,
                T.NumeroPolizaContable,
                t.Concepto,
			 T.FechaPago,
			(SELECT CASE WHEN T.PDF IS NULL OR T.PDF = ''THEN 'Pendiente de Cargar comprobante'
				ELSE 'Comprobante cargado'
				END) as PDF,
                T.IdMetodoPago
         FROM FI_Factura F
              LEFT OUTER JOIN FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
              LEFT OUTER JOIN FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
              LEFT OUTER JOIN PV_Subcontratista P ON F.idSubcontratista = P.IdSubcontratista
         WHERE 
	    --F.FechaRecepcion BETWEEN @PInicial and @PFinal
	    --'2017-01-01' AND '2017-07-01'
               --AND F.IdContrato IN(10001, 10002, 10003)
		--	AND
			 F.IdContrato = @IdContrato
         ORDER BY TF.IdTransferFactura;
     END;


