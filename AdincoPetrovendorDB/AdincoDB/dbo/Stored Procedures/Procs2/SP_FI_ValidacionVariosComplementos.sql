-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Validaciones de PPD con más de un Complemento de Pago 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidacionVariosComplementos]
-- =============================================
--[SP_FI_ValidacionVariosComplementos] 3,10113,1
-- =============================================
@IdContrato INT, 
@IdUsuario  INT, 
@IntTop     INT
AS
     BEGIN
         DECLARE @Consulta NVARCHAR(MAX);
         --==============================
         SET @Consulta = 'SELECT TOP '+CAST(@IntTop AS NVARCHAR(MAX))+'
								    F.IdFactura, 
									F.TipoComprobante, 
									CDP.IdComplementoDePago
							FROM dbo.FI_Factura AS F
								LEFT JOIN dbo.FI_ComplementoDePago AS CDP ON F.IdFactura = CDP.IdFactura
							WHERE IdContrato = '+CAST(@IdContrato AS NVARCHAR(MAX))+' 
								  AND CreadoPor = '+CAST(@IdUsuario AS NVARCHAR(MAX))+'
							ORDER BY F.IdFactura DESC';
         --==============================
         IF OBJECT_ID('tempdb..#TemporalTopFacturtas', 'U') IS NOT NULL
             DROP TABLE #TemporalTopFacturtas;
         --==============================
         CREATE TABLE #TemporalTopFacturtas
         (IdFacturaTOP           INT, 
          TipoComprobanteTOP     NVARCHAR(MAX), 
          IdComplementoDePagoTOP INT
         );
         --==============================
         INSERT INTO #TemporalTopFacturtas
         (IdFacturaTOP, 
          TipoComprobanteTOP, 
          IdComplementoDePagoTOP
         )
         EXEC (@Consulta);
         --==============================
         IF EXISTS
         (
             SELECT IdDocumento
             FROM dbo.FI_CPDocRelacionado
             WHERE IdDocumento IN
             (
                 SELECT DR.IdDocumento
                 FROM #TemporalTopFacturtas AS TTP
                      LEFT JOIN dbo.FI_CPDocRelacionado AS DR ON TTP.IdComplementoDePagoTOP = DR.IdComplementoDePago
                 WHERE TTP.TipoComprobanteTOP = 'P'
                 GROUP BY DR.IdDocumento
                 HAVING COUNT(TTP.IdFacturaTOP) < 2
             )
             GROUP BY IdDocumento
             HAVING COUNT(*) >= 2
         )
             BEGIN
                 SELECT 'Ya existe un complemento de pago relacionado aun PPD revisa el detalle en la tabla inferior.' AS Resultado;
             END;
     END;