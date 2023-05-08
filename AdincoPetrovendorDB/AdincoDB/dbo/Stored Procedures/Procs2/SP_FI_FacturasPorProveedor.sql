-- =============================================
-- Author:      Marcos Garcia
-- Create date: 05-12-2019
-- Description: Seleccion de Facturas por Proveedor
--				de los Contratos de el Mismo Contratista.   
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasPorProveedor]
--[SP_FI_FacturasPorProveedor] 10002,3,10002, 1
-- Add the parameters for the stored procedure here
@IdProveedor INT, 
@IdContrato  INT, 
@IdUsuario   INT, 
@Relacion    INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
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
         IF OBJECT_ID('tempdb..#Contrato', 'U') IS NOT NULL
             DROP TABLE #Contrato;
         IF OBJECT_ID('tempdb..#ContratosFacturas', 'U') IS NOT NULL
             DROP TABLE #ContratosFacturas;
         --========================
         CREATE TABLE #ContratosTempo
         (IdContrato     INT, 
          NumeroContrato NVARCHAR(50)
         );
         --
         CREATE TABLE #Contrato
         (IdFactura      INT, 
          IdContrato     INT, 
          NumeroContrato NVARCHAR(MAX)
         );
         --
         CREATE TABLE #ContratosFacturas
         (IdFactura      INT, 
          NumeroContrato NVARCHAR(MAX)
         );
         --
         --========================
         --Contratistas Jaguar
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
         --Todos los demas Contratista
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
         ----==============Seleccion de Facturas de Todos los Contratos Relacionados===========
         IF(@Relacion = 0)
             BEGIN
                 SELECT F.IdFactura, 
                        T.NumeroContrato, 
                        F.Serie, 
                        F.Folio, 
                        F.Fecha,
                        CASE
                            WHEN F.MetodoPago LIKE '%exhibi%'
                                 OR F.MetodoPago LIKE '%PUE%'
                            THEN F.FormaPago
                            WHEN F.FormaPago LIKE '%exhibi%'
                                 OR F.FormaPago LIKE '%PUE%'
                            THEN F.MetodoPago
                        END AS FormaPago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante,
                        CASE
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
                        SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                        F.UUID, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor
                 FROM #ContratosTempo T
					  JOIN dbo.FI_Factura F (NOLOCK)
						   ON T.IdContrato = F.IdContrato
						   AND F.TipoComprobante <> 'P'
						   AND F.IdSubcontratista = @IdProveedor
                      JOIN dbo.PV_Subcontratista S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						   ON FC.IdFactura = F.IdFactura
                 -- LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND FC.IdFactura IS NULL
                       AND F.TipoComprobante <> 'P'
                       AND (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                 --AND tf.IdTransferFactura IS NULL
                 GROUP BY F.IdFactura, 
                          T.NumeroContrato, 
                          F.Serie, 
                          F.Folio, 
                          F.Fecha,
                          CASE
                              WHEN F.MetodoPago LIKE '%exhibi%'
                                   OR F.MetodoPago LIKE '%PUE%'
                              THEN F.FormaPago
                              WHEN F.FormaPago LIKE '%exhibi%'
                                   OR F.FormaPago LIKE '%PUE%'
                              THEN F.MetodoPago
                          END, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante,
                          CASE
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
                          END, 
                          SUBSTRING(F.LugarExpedicion, 0, 15), 
                          F.UUID, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor
                 UNION
                 SELECT F.IdFactura, 
                        T.NumeroContrato, 
                        F.Serie, 
                        F.Folio, 
                        F.Fecha,
                        CASE
                            WHEN F.MetodoPago LIKE '%exhibi%'
                                 OR F.MetodoPago LIKE '%PUE%'
                                 OR F.MetodoPago LIKE '%parcia%'
                                 OR F.MetodoPago LIKE '%dife%'
                                 OR F.MetodoPago LIKE '%PPD%'
                            THEN F.FormaPago
                            WHEN F.FormaPago LIKE '%exhibi%'
                                 OR F.FormaPago LIKE '%PUE%'
                                 OR F.FormaPago LIKE '%parcia%'
                                 OR F.FormaPago LIKE '%dife%'
                                 OR F.FormaPago LIKE '%PPD%'
                            THEN F.MetodoPago
                        END AS FormaPago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante,
                        CASE
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
                        SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                        F.UUID, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor
					FROM #ContratosTempo T 
					  JOIN dbo.FI_Factura AS F (NOLOCK)
						   ON T.IdContrato = F.IdContrato
							  AND F.IdSubcontratista = @IdProveedor
							  AND F.TipoComprobante <> 'P'
                      JOIN dbo.PV_Subcontratista S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						   ON FC.IdFactura = F.IdFactura
                      LEFT JOIN dbo.FI_CPDocRelacionado CPDR (NOLOCK)
						   ON F.UUID = CPDR.IdDocumento
                      LEFT JOIN dbo.FI_ComplementoDePago CP (NOLOCK)
					       ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                 -- LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = CP.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND FC.IdFactura IS NULL
                       AND F.TipoComprobante <> 'P'
                       AND (F.MetodoPago LIKE '%parcia%'
                            OR F.MetodoPago LIKE '%dife%'
                            OR F.MetodoPago LIKE '%PPD%'
                            OR F.FormaPago LIKE '%parcia%'
                            OR F.FormaPago LIKE '%dife%'
                            OR F.FormaPago LIKE '%PPD%')
                 -- AND TF.IdTransferFactura IS NULL
                 GROUP BY F.IdFactura, 
                          T.NumeroContrato, 
                          F.Serie, 
                          F.Folio, 
                          F.Fecha,
                          CASE
                              WHEN F.MetodoPago LIKE '%exhibi%'
                                   OR F.MetodoPago LIKE '%PUE%'
                                   OR F.MetodoPago LIKE '%parcia%'
                                   OR F.MetodoPago LIKE '%dife%'
                                   OR F.MetodoPago LIKE '%PPD%'
                              THEN F.FormaPago
                              WHEN F.FormaPago LIKE '%exhibi%'
                                   OR F.FormaPago LIKE '%PUE%'
                                   OR F.FormaPago LIKE '%parcia%'
                                   OR F.FormaPago LIKE '%dife%'
                                   OR F.FormaPago LIKE '%PPD%'
                              THEN F.MetodoPago
                          END, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante,
                          CASE
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
                          END, 
                          SUBSTRING(F.LugarExpedicion, 0, 15), 
                          F.UUID, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor
                 UNION
                 SELECT F.IdFactura, 
                        T.NumeroContrato, 
                        F.Serie, 
                        F.Folio, 
                        F.Fecha,
                        CASE
                            WHEN F.MetodoPago LIKE '%exhibi%'
                                 OR F.MetodoPago LIKE '%PUE%'
                                 OR F.MetodoPago LIKE '%parcia%'
                                 OR F.MetodoPago LIKE '%dife%'
                                 OR F.MetodoPago LIKE '%PPD%'
                            THEN F.FormaPago
                            WHEN F.FormaPago LIKE '%exhibi%'
                                 OR F.FormaPago LIKE '%PUE%'
                                 OR F.FormaPago LIKE '%parcia%'
                                 OR F.FormaPago LIKE '%dife%'
                                 OR F.FormaPago LIKE '%PPD%'
                            THEN F.MetodoPago
                        END AS FormaPago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante,
                        CASE
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
                        SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                        F.UUID, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor
                 FROM #ContratosTempo T (NOLOCK)
				      JOIN dbo.FI_Factura AS F (NOLOCK)
						   ON T.IdContrato = F.IdContrato
						      AND F.TipoComprobante <> 'P'
							  AND F.IdSubcontratista = @IdProveedor
                      JOIN dbo.PV_Subcontratista S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						   ON FC.IdFactura = F.IdFactura
                 -- LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND FC.IdFactura IS NULL
                       AND F.TipoComprobante <> 'P'
                       AND (F.MetodoPago LIKE '%parcia%'
                            OR F.MetodoPago LIKE '%dife%'
                            OR F.MetodoPago LIKE '%PPD%'
                            OR F.FormaPago LIKE '%parcia%'
                            OR F.FormaPago LIKE '%dife%'
                            OR F.FormaPago LIKE '%PPD%')
                 --AND TF.IdTransferFactura IS NULL
                 GROUP BY F.IdFactura, 
                          T.NumeroContrato, 
                          F.Serie, 
                          F.Folio, 
                          F.Fecha,
                          CASE
                              WHEN F.MetodoPago LIKE '%exhibi%'
                                   OR F.MetodoPago LIKE '%PUE%'
                                   OR F.MetodoPago LIKE '%parcia%'
                                   OR F.MetodoPago LIKE '%dife%'
                                   OR F.MetodoPago LIKE '%PPD%'
                              THEN F.FormaPago
                              WHEN F.FormaPago LIKE '%exhibi%'
                                   OR F.FormaPago LIKE '%PUE%'
                                   OR F.FormaPago LIKE '%parcia%'
                                   OR F.FormaPago LIKE '%dife%'
                                   OR F.FormaPago LIKE '%PPD%'
                              THEN F.MetodoPago
                          END, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante,
                          CASE
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
                          END, 
                          SUBSTRING(F.LugarExpedicion, 0, 15), 
                          F.UUID, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor
                 ORDER BY MetodoPago, 
                          F.Fecha DESC;
             END;
         IF(@Relacion <> 0)
             BEGIN
                 IF(@IdContratista = 10005
                  OR @IdContratista = 10006)				
                     BEGIN
                         INSERT INTO #Contrato
                         (IdFactura, 
                          IdContrato, 
                          NumeroContrato
                         )
                                SELECT FC.IdFactura, 
                                       C.IdContrato, 
                                       C.NumeroContrato
                                FROM dbo.FI_FacturaContrato FC
                                     JOIN dbo.CO_Contrato C ON C.IdContrato = FC.IdContrato
                                WHERE c.IdContratista IN (10005, 10006)
								GROUP BY FC.IdFactura,
                                         C.IdContrato,
                                         C.NumeroContrato
                     END;                 
				 ELSE                 
                     BEGIN
                         INSERT INTO #Contrato
                         (IdFactura, 
                          IdContrato, 
                          NumeroContrato
                         )
                                SELECT FC.IdFactura, 
                                       C.IdContrato, 
                                       C.NumeroContrato
                                FROM dbo.FI_FacturaContrato FC
                                     JOIN dbo.CO_Contrato C ON C.IdContrato = FC.IdContrato
                                WHERE c.IdContratista = @IdContratista;
                     END;             
                 --
                 INSERT INTO #ContratosFacturas
                 (IdFactura, 
                  NumeroContrato
                 )
                        SELECT DISTINCT 
                               B.IdFactura, 
                               STUFF(
                        (
                            SELECT ' | '+RTRIM(LTRIM(u.NumeroContrato))
                            FROM #Contrato u
                            WHERE B.IdFactura = u.IdFactura FOR XML PATH('')
                        ), 1, 2, '')
                        FROM #Contrato B
                        GROUP BY B.IdFactura;
                 --------------------
                 SELECT F.IdFactura, 
                        ('Contrato Principal: '+C.NumeroContrato+' | Contrato(s) Relacionado(s): '+CF.NumeroContrato) AS NumeroContrato, 
                        F.UUID
                 FROM #ContratosTempo T (NOLOCK)
					  JOIN dbo.FI_Factura F (NOLOCK)
						   ON T.IdContrato = F.IdContrato 
						      AND F.TipoComprobante <> 'P'
							  AND F.IdSubcontratista = @IdProveedor
					  JOIN #ContratosFacturas CF (NOLOCK)
						   ON CF.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.CO_Contrato C (NOLOCK)
						   ON C.IdContrato = F.IdContrato
                      LEFT JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						   ON FC.IdFactura = F.IdFactura
                 -- LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.TipoComprobante <> 'P'
                       AND FC.IdFactura IS NOT NULL
                       AND (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                 -- AND tf.IdTransferFactura IS NULL
                 GROUP BY('Contrato Principal: '+C.NumeroContrato+' | Contrato(s) Relacionado(s): '+CF.NumeroContrato), 
                         F.IdFactura, 
                         F.UUID
                 --
                 UNION
                 --
                 SELECT F.IdFactura, 
                        ('Contrato Principal: '+C.NumeroContrato+' | Contrato(s) Relacionado(s): '+CF.NumeroContrato) AS NumeroContrato, 
                        F.UUID
                 FROM #ContratosTempo T (NOLOCK)
					  JOIN dbo.FI_Factura AS F (NOLOCK)
						   ON T.IdContrato = F.IdContrato
						      AND F.IdSubcontratista = @IdProveedor
                              AND F.TipoComprobante <> 'P' 
					  JOIN #ContratosFacturas CF (NOLOCK)
						   ON CF.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.CO_Contrato C (NOLOCK)
					       ON C.IdContrato = F.IdContrato
                      LEFT JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						   ON FC.IdFactura = F.IdFactura
                      LEFT JOIN dbo.FI_CPDocRelacionado CPDR (NOLOCK)
						   ON F.UUID = CPDR.IdDocumento
                   LEFT JOIN dbo.FI_ComplementoDePago CP (NOLOCK)
						   ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
                 --LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = CP.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.TipoComprobante <> 'P'
                       AND FC.IdFactura IS NOT NULL
                       AND (F.MetodoPago LIKE '%parcia%'
                            OR F.MetodoPago LIKE '%dife%'
                            OR F.MetodoPago LIKE '%PPD%'
                            OR F.FormaPago LIKE '%parcia%'
                            OR F.FormaPago LIKE '%dife%'
                            OR F.FormaPago LIKE '%PPD%')
                 --  AND TF.IdTransferFactura IS NULL
                 GROUP BY('Contrato Principal: '+C.NumeroContrato+' | Contrato(s) Relacionado(s): '+CF.NumeroContrato), 
                         F.IdFactura, 
                         F.UUID
                 --
             UNION
                 --
                 SELECT F.IdFactura, 
                        ('Contrato Principal: '+C.NumeroContrato+' | Contrato(s) Relacionado(s): '+CF.NumeroContrato) AS NumeroContrato, 
                        F.UUID
                 FROM #ContratosTempo T (NOLOCK)
					 JOIN dbo.FI_Factura AS F (NOLOCK)
						   ON T.IdContrato = F.IdContrato
							  AND F.IdSubcontratista = @IdProveedor
							  AND F.TipoComprobante <> 'P'
                     JOIN #ContratosFacturas CF (NOLOCK)
						   ON CF.IdFactura = F.IdFactura
                     JOIN dbo.PV_Subcontratista S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
                     LEFT JOIN dbo.CO_Contrato C (NOLOCK)
						       ON C.IdContrato = F.IdContrato
                     LEFT JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						       ON FC.IdFactura = F.IdFactura
                 -- LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.TipoComprobante <> 'P'
                       AND FC.IdFactura IS NOT NULL
                       AND (F.MetodoPago LIKE '%parcia%'
                            OR F.MetodoPago LIKE '%dife%'
                            OR F.MetodoPago LIKE '%PPD%'
                            OR F.FormaPago LIKE '%parcia%'
                            OR F.FormaPago LIKE '%dife%'
                            OR F.FormaPago LIKE '%PPD%')
                 --AND TF.IdTransferFactura IS NULL
                 GROUP BY('Contrato Principal: '+C.NumeroContrato+' | Contrato(s) Relacionado(s): '+CF.NumeroContrato), 
                         F.IdFactura, 
                         F.UUID
                 ORDER BY F.IdFactura;
             END;
     END;