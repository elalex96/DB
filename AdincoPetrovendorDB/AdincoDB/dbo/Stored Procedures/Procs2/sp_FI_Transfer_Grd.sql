CREATE PROC sp_FI_Transfer_Grd
(@conPDF   BIT, 
 @enAmazon BIT
)
AS
     BEGIN
         DECLARE @pdf NVARCHAR;
         SELECT IdTransferencia, 
                IdContrato, 
                IdComprobantePago, 
                NombreExtencionArchivo = CASE
                                             WHEN NombreExtencionArchivo = ''
                                                  OR NombreExtencionArchivo IS NULL
                                             THEN ReferenciaBancaria+'.pdf'
                                             ELSE NombreExtencionArchivo
                                         END, 
                ReferenciaBancaria, 
                FechaPago, 
                IdCuentaOrigen, 
                IdCuentaDestino, 
                MontoPagado, 
                IdMoneda, 
                IdClasificacionDocumento, 
                Concepto, 
                IdMetodoPago, 
                ProcesadoSIPAC, 
                NumeroPolizaContable, 
                Intereses, 
                PDF = CASE
                          WHEN @conPDF = 1
                          THEN PDF
                          ELSE @pdf
                      END, --cast(PDF as varbinary) else @pdf end,					
                PDF2 = '', 
                HashSHA256 = isnull(d.HashSHA256, t.HashSHA256), 
                IdFacturaPago, 
                AWSPDFId, 
                IdFormaPago, 
                UUIDAmazon
         FROM FI_Transfer t
              LEFT JOIN AWS_Documentos d ON t.AWSPDFId = d.AWSDocumentoId
         WHERE((UUIDAmazon IS NOT NULL)
               AND @enAmazon = 1)
              OR ((UUIDAmazon IS NULL)
                  AND @enAmazon = 0)
              --and			IdTransferencia			=	255
              AND IdContrato IS NOT NULL
              AND isnull(t.PDF, '') <> '';
     END;