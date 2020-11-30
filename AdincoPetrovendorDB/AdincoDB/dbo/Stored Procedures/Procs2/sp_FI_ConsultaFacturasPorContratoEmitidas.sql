-- =============================================
-- Author:		Manuel Cruz
-- Create date: 21-06-2018
-- Description:	
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 05-02-2020
-- Description:	Agregar Campo (CreadoEn,CreadoPor)
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoEmitidas]
--[sp_FI_ConsultaFacturasPorContratoEmitidas] 3,1
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         IF @IdContrato = 10010
             BEGIN
                 -- Insert statements for procedure here
                 SELECT F.IdFactura, 
                        S.RazonSocial AS NombreEmisor, 
                        S.RFC AS RFC_Emisor, 
                        F.Fecha, 
                        F.Serie, 
                        F.Folio, 
                        F.SubTotal, 
                        F.Descuento, 
                        F.TipoCambio, 
                        F.MontoConIva AS Total, 
                        M.TipoMonedaCorto AS Moneda, 
                        SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante, 
                        F.MetodoPago, 
                        SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion, 
                        F.NumCtaPago, 
                        F.Receptor AS Receptor, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.SelloCFD, 
                        F.NoCertificadoSAT, 
                        F.SelloSAT, 
                        F.Tipo, 
                        F.FechaRecepcion, 
                        YEAR(F.Fecha) AS Año, 
                        CONCAT(RIGHT('00'+CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes, 
                        SR.RazonSocial AS Receptor, 
                        TieneArchivo = CAST(CASE
                                                WHEN D.DocumentoByte IS NULL
                                                THEN 0
                                                ELSE 1
                                            END AS BIT), 
                        ISNULL((F.MontoConIva * .16), 0) AS IVA, 
                        C.IdContrato, 
                        CONVERT(DATE, F.CreadoEn) AS CreadoEn, 
                        UM.Nombre AS CreadoPor
                 FROM dbo.FI_Factura AS F(NOLOCK)
                      JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
                      JOIN dbo.CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
                                                            AND F.Emisor = CC.RFC
                      LEFT JOIN dbo.PV_Subcontratista AS S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.PV_TipoMoneda M(NOLOCK) ON F.IdMoneda = M.IdMoneda 
                      LEFT JOIN dbo.FI_Documento D(NOLOCK) ON F.IdFactura = D.IdFactura
                                                              AND D.IdTipoDocumento = 1
                                                              AND ISNULL(D.IsEliminado, 0) = 0
                      LEFT JOIN dbo.PV_Subcontratista SR WITH(NOLOCK) ON F.Receptor = SR.RFC
					  LEFT JOIN dbo.AP_Usuario UM WITH(NOLOCK) ON F.CreadoPor = UM.UsuarioID
                 WHERE F.IdContrato = @IdContrato
                       AND F.Fecha BETWEEN DATEADD(MONTH, -2, GETDATE()) AND DATEADD(MONTH, 1, GETDATE())
                 ORDER BY F.IdFactura DESC;
             END;
             ELSE
             BEGIN
                 -- Insert statements for procedure here
                 SELECT F.IdFactura, 
                        S.RazonSocial AS NombreEmisor, 
                        S.RFC AS RFC_Emisor,
						C.NumeroContrato,  
                        F.Fecha, 
                        F.Serie, 
                        F.Folio, 
                        F.SubTotal, 
                        F.Descuento, 
                        F.TipoCambio, 
                        F.MontoConIva AS Total, 
                        M.TipoMonedaCorto AS Moneda, 
                        SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante, 
                        F.MetodoPago, 
                        SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion, 
                        F.NumCtaPago, 
                        F.Receptor AS Receptor, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.SelloCFD, 
                        F.NoCertificadoSAT, 
                        F.SelloSAT, 
                        F.Tipo, 
                        F.FechaRecepcion, 
                        YEAR(F.Fecha) AS Año, 
                        CONCAT(RIGHT('00'+CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes, 
                        SR.RazonSocial AS Receptor, 
                        TieneArchivo = CAST(CASE
                                                WHEN D.DocumentoByte IS NULL
                                                THEN 0
                                                ELSE 1
                                            END AS BIT), 
                        ISNULL((F.MontoConIva * .16), 0) AS IVA, 
                        C.IdContrato,
						CONVERT(DATE, F.CreadoEn) AS CreadoEn, 
                        UM.Nombre AS CreadoPor
                 FROM dbo.FI_Factura AS F(NOLOCK)
                      JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
                      JOIN dbo.CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
                                                            AND F.Emisor = CC.RFC
                      LEFT JOIN dbo.PV_Subcontratista AS S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.PV_TipoMoneda M(NOLOCK) ON F.IdMoneda = M.IdMoneda 
                      LEFT JOIN dbo.FI_Documento D(NOLOCK) ON F.IdFactura = D.IdFactura
                                                              AND D.IdTipoDocumento = 1
                                                              AND ISNULL(D.IsEliminado, 0) = 0
                      LEFT JOIN dbo.PV_Subcontratista SR WITH(NOLOCK) ON F.Receptor = SR.RFC
					  LEFT JOIN dbo.AP_Usuario UM WITH(NOLOCK) ON F.CreadoPor = UM.UsuarioID
                 WHERE F.IdContrato = @IdContrato
                 ORDER BY F.IdFactura DESC;
             END;
     END