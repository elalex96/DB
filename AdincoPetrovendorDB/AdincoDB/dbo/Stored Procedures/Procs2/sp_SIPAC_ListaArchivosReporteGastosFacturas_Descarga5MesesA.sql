CREATE PROCEDURE [dbo].[sp_SIPAC_ListaArchivosReporteGastosFacturas_Descarga5MesesA]
-- Add the parameters for the stored procedure here
@FactTransfer INT
AS
     BEGIN
         SET NOCOUNT ON;
         IF @FactTransfer = 1
             BEGIN
                 --=====================================================================================================
                 --Para facturas XML
                 --=====================================================================================================
                 SELECT f.IdFactura, A.IdFactura,F.IdContrato,C.NumeroContrato
                 FROM dbo.FI_Factura F
                      LEFT JOIN dbo.FI_ArchivoXml A ON F.IdFactura = A.IdFactura
					  LEFT JOIN dbo.FI_FacturaAdincoPetrovendor FAP ON F.IdFactura = FAP.IdFacturaAdinco
					  LEFT JOIN dbo.CO_Contrato C ON C.IdContrato = A.IdContrato
                 WHERE F.UUID IN 
(
'76082137-a5e0-4b57-8c20-248b66d0a171',
'85ADC5F1-D798-4FB4-BCE2-891F36533D77',
'E482FA37-F48F-49E0-BCBE-E95794755BAF',
'17193b6b-681b-42ed-8ea4-9b91141e4e61',
'870af6d8-3619-4996-8776-cccac6437621',
'5A226B77-1B58-4DCB-95E0-E65671C3C982',
'3568CBC9-AC8A-4D2C-905F-D46453D248AE',
'0EEB77CF-01E3-4284-BFF6-20C28E422895',
'DF7481F8-1026-4462-8966-555A70B12BB1',
'9CC8FDD4-83A9-4504-BAA2-ED72CF5D946D',
'8B66D82B-FD3E-476B-91A1-4FA36D79EDE2',
'28C5222A-BDCA-4DF2-92A0-0404B1A0F6AF',
'7D5130E8-2291-4AD4-9682-547F2951D537',
'3B98C0C8-C6E9-4D8E-8E6F-566CB172FF88',
'8F0B8A06-1FC3-447E-B9A6-87F29AF2F63F',
'B01E66D4-9068-45FE-AC63-7C31B1C203C6',
'02AD2D90-BF8E-42C9-8476-906B89E495EC',
'99C61F93-EF04-4575-9F74-56519F2D9D6F',
'7C730ED8-CE94-43DF-8ABE-28553221FBD2',
'A00DBF0A-593B-4CBD-8644-24A7C241A05A',
'F85B3102-C40C-4524-806B-2360E01BC497',
'A8A9CCC6-A12B-431F-AFFD-87C0A551A901',
'0E52260B-0CC0-4007-BA95-1D1E2DB823EE'
);
--DELETE dbo.FI_ArchivoXml WHERE IdFactura in ()
                 /**/

                 --			   SELECT cp.IdFactura
                 --             FROM FI_Factura fac
                 --                  INNER JOIN petrovendor..s_proveedor prov ON prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = fac.emisor COLLATE SQL_Latin1_General_CP1_CI_AS
                 --                  LEFT JOIN [dbo].[FI_CPDocRelacionado] dr ON dr.IdDocumento = fac.UUID
                 --                  LEFT JOIN [dbo].[FI_ComplementoDePago] cp ON cp.IdComplementoDePago = dr.IdComplementoDePago
                 --             WHERE dr.IdComplementoDePago IS NOT NULL
                 --                   AND fac.IdContrato IN(10039, 10053)
                 --                  AND (UPPER(fac.TipoComprobante) = 'INGRESO'
                 --                       OR UPPER(fac.TipoComprobante) = 'I') --and fac.activa = 1
                 --             GROUP BY cp.IdFactura;

                 /**/

             END;
         IF @FactTransfer = 3
             BEGIN
                 --=====================================================================================================
                 --Para facturas PDF
                 --=====================================================================================================
                 SELECT F.IdFactura
                 FROM dbo.FI_Factura F
                      JOIN dbo.FI_Documento D ON D.IdFactura = F.IdFactura
                 WHERE F.IdFactura IN(64596)
                 ORDER BY F.IdFactura DESC;
             END;
         IF @FactTransfer = 2
             BEGIN
                 --=====================================================================================================
                 --Para transferencias PDF
                 --=====================================================================================================
                 SELECT IdTransferencia
                 FROM dbo.FI_Transfer
                 WHERE IdTransferencia IN(12422)
                 ORDER BY FechaPago DESC;
             END;
         IF @FactTransfer IN(4, 5)
             BEGIN
                 --=====================================================================================================
                 --Para Pedimentos Comprobantes PDF
                 --=====================================================================================================
                 SELECT IdPedimentoComprobante
                 FROM dbo.FI_PedimentoComprobante
                 WHERE IdPedimentoComprobante IN(500)
                 ORDER BY FechaPago DESC;
             END;
     END;