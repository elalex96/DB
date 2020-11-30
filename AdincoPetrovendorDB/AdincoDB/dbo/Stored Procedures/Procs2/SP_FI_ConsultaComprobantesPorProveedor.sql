-- =============================================
-- Author:		 Marcos Garcia
-- Create date:  06-12-2019
-- Description:	 Selección de Todos los Complementos 
--				 por Proveedor y por Contratista 
-- =============================================
-- Author:		 Marcos Garcia
-- Alter date:   06-12-2019
-- Description:	 Agregar MAX a la Columna FechaDePago
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaComprobantesPorProveedor] 
-- [SP_FI_ConsultaComprobantesPorProveedor] 12296,3,10002,0
@IdProveedor INT, 
@IdContrato  INT, 
@IdUsuario   INT, 
@Relacion    INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         --====================IdContratista del Contrato================
         DECLARE @IdContratista INT;
         --========================
         SET @IdContratista =
         (
             SELECT IdContratista
             FROM dbo.CO_Contrato
             WHERE IdContrato = @IdContrato
         );
         --==============Contratos Relacionados al Contratista===========
         IF OBJECT_ID('tempdb..#ContratosTempo', 'U') IS NOT NULL
             DROP TABLE #ContratosTempo;
         --
         IF OBJECT_ID('tempdb..#Transfer', 'U') IS NOT NULL
             DROP TABLE #Transfer;
         --
         IF OBJECT_ID('tempdb..#TransferConcat', 'U') IS NOT NULL
             DROP TABLE #TransferConcat;
         --========================
         CREATE TABLE #ContratosTempo
         (IdContrato     INT, 
          NumeroContrato NVARCHAR(50)
         );
         --
         CREATE TABLE #Transfer
         (IdFactura  INT, 
          IdTransfer INT
         );
         --
         CREATE TABLE #TransferConcat
         (IdFactura      INT, 
          IdTransferChar NVARCHAR(MAX), 
          ConTransfer    INT
         );
         --========================
         --Solo Para Jaguar
         IF(@IdContratista = 10005
            OR @IdContratista = 10006)
             BEGIN
                 INSERT INTO #ContratosTempo
                 (IdContrato, 
                  NumeroContrato
                 )
                        SELECT IdContrato, 
                               NumeroContrato
                        FROM dbo.CO_Contrato
                        WHERE IdContratista IN(10005, 10006)
                        AND Activo = 1;
             END;
             ELSE
             BEGIN
                 INSERT INTO #ContratosTempo
                 (IdContrato, 
                  NumeroContrato
                 )
                 SELECT IdContrato, 
                        NumeroContrato
                 FROM dbo.CO_Contrato
                 WHERE IdContratista = @IdContratista
                       AND Activo = 1;
             END;    			 
         --
         ----============== Seleccion de Complementos de Todos los Contratos Relacionados ===========
         IF(@Relacion = 0)
             BEGIN
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        TEM.NumeroContrato, 
                        F.Serie, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        CP.FormaDePagoP AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(CP.FechaDePago AS DATE)) AS FechaDePago, 
                        CP.MonedaP, 
                        SUM(CP.Monto) AS MontoPagado
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura AS F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista                     
                      INNER JOIN #ContratosTempo TEM ON TEM.IdContrato = F.IdContrato
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.TipoComprobante = 'P'
                       AND ISNULL(F.VarTransfer, 0) = 0
               GROUP BY SUBSTRING(S.RazonSocial, 0, 30),
                        F.IdFactura,
                        TEM.NumeroContrato,
                        F.Serie,
                        F.Folio,
                        F.Fecha,
                        F.FormaPago,
                        F.SubTotal,
                        F.Moneda,
                        F.MontoConIva,
                        F.TipoComprobante,
                        CP.FormaDePagoP,
                        F.LugarExpedicion,
                        F.UUID,
                        F.FechaTimbrado,
                        F.FechaRecepcion,
                        F.Emisor,
                        CP.MonedaP
                 ORDER BY IdCompReciboPago DESC;
             END;
         ------------------
         IF(@Relacion <> 0)
             BEGIN
                 INSERT INTO #Transfer
                 (IdFactura, 
                  IdTransfer
                 )
                        SELECT TF.IdFactura, 
                               TF.IdTransfer
                        FROM dbo.FI_Factura F
                             INNER JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                             INNER JOIN #ContratosTempo TC ON TC.IdContrato = F.IdContrato
                        WHERE F.IdSubcontratista = @IdProveedor
                              AND F.TipoComprobante = 'P'
                              AND ISNULL(F.VarTransfer, 0) = 1
                        GROUP BY TF.IdFactura, 
                                 TF.IdTransfer;
                 --
                 INSERT INTO #TransferConcat
                 (IdFactura, 
                  IdTransferChar, 
                  ConTransfer
                 )
                        SELECT DISTINCT 
                               B.IdFactura, 
                               STUFF(
                        (
                            SELECT ' | '+RTRIM(LTRIM(CONVERT(NVARCHAR(MAX), u.IdTransfer)))
                            FROM #Transfer u
                            WHERE B.IdFactura = u.IdFactura FOR XML PATH('')
                        ), 1, 2, ''), 
                               COUNT(B.IdFactura)
                        FROM #Transfer B
                        GROUP BY B.IdFactura;    
                 -----------
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        TEM.NumeroContrato, 
                        ISNULL(TC.IdTransferChar, 'Sin Transferencia(s) Relacionada(s)') AS Transferencia, 
                        F.UUID, 
                        ISNULL(TC.ConTransfer, 0) AS ConTransfer
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura AS F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                      INNER JOIN #ContratosTempo TEM ON TEM.IdContrato = F.IdContrato
                      LEFT JOIN #TransferConcat TC ON TC.IdFactura = F.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.TipoComprobante = 'P'
                       AND ISNULL(F.VarTransfer, 0) = 1
                 GROUP BY ISNULL(TC.IdTransferChar, 'Sin Transferencia(s) Relacionada(s)'), 
                          F.IdFactura, 
                          TEM.NumeroContrato, 
                          F.UUID, 
                          TC.ConTransfer
                 ORDER BY IdCompReciboPago DESC;
             END;
     END;