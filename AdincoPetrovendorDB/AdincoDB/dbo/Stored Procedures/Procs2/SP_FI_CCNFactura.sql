
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_CCNFactura'
)
    DROP PROCEDURE SP_FI_CCNFactura
GO
--[SP_FI_CCNFactura]10018,10221,77947 
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2019-01-30
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CCNFactura]
-- [SP_FI_CCNFactura] 3,1,61855
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@IdFactura  INT
AS
     BEGIN
         SET NOCOUNT ON;
         
         /*Determinar UUID Factura para buscar en Petrovendor*/
         DECLARE @UUID NVARCHAR(MAX);
         DECLARE @Contador INT;
         DECLARE @IdFacturaP INT;

         /**/

         SELECT @UUID = UUID
         FROM Adinco.dbo.FI_Factura(NOLOCK)
         WHERE IdFactura = @IdFactura;

         /**/

         SELECT @Contador = COUNT(FP.IdFactura), 
                @IdFacturaP = FP.IdFactura
         FROM Petrovendor.dbo.FI_Factura FP(NOLOCK)
              LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
				ON FP.UUID = @UUID COLLATE DATABASE_DEFAULT 
				AND FP.IdFactura = AF.IdFactura
              LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AC (NOLOCK)
				ON AF.IdAceptacionPedido = AC.IdAceptacionPedido
              LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AP (NOLOCK)
				ON AC.IdAceptacionPedido = AP.IdAceptacionPedido 
         WHERE FP.UUID = @UUID COLLATE DATABASE_DEFAULT
               AND ISNULL(AC.IdEstatus, 0) = 2
               AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
               AND ISNULL(FP.Activa, 0) = 1
               AND ISNULL(FP.IsEliminado, 0) <> 1
         GROUP BY FP.IdFactura;

         /**/

         IF(@Contador >= 1)
             BEGIN
                 SELECT D.Identificador AS Identificador, 
                        D.Carpeta AS Carpeta, 
                        CONCAT(D.Carpeta, D.Identificador) AS Ruta, 
                        ISNULL(D.Bucket,'petrovendor-pr') AS CubetaDev, 
                        CONCAT('IdFacturaAdinco: ', @IdFactura, ' - ', D.NombreDocumento) AS NombreDocumento, 
                        AF.IdFactura, 
                        FP.UUID,
						D.IdDocumento
                 FROM Petrovendor.dbo.FI_Factura FP (NOLOCK)
                      LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
						ON FP.IdFactura = @IdFacturaP
						AND FP.IdFactura = AF.IdFactura
                      LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AC (NOLOCK)
						ON AF.IdAceptacionPedido = AC.IdAceptacionPedido 
                      LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AP (NOLOCK)
						ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
                      LEFT JOIN Petrovendor.dbo.S_Documento_S3 D (NOLOCK)
						ON AC.IdDocumento = D.IdDocumento
                      LEFT JOIN Petrovendor.dbo.MM_Pedido P (NOLOCK)
						ON AP.IdPedido = P.IdPedido
                      LEFT JOIN Petrovendor.dbo.S_Proveedor PR (NOLOCK)
						ON P.IdSubcontratista = PR.IdProveedor  
                 WHERE FP.IdFactura = @IdFacturaP
                       AND ISNULL(AC.IdEstatus, 0) = 2
                       AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                       AND ISNULL(FP.Activa, 0) = 1
                       AND ISNULL(FP.IsEliminado, 0) = 0;
             END;
             ELSE
             BEGIN
                 SELECT UPPER(D.UUIDAmazon) AS Identificador, 
                        CASE WHEN CHARINDEX(D.Folder, '/') > 0 THEN D.Folder ELSE CONCAT(D.Folder, '/') END AS Carpeta, 
                        CONCAT(CASE WHEN CHARINDEX(D.Folder, '/') > 0 THEN D.Folder ELSE CONCAT(D.Folder, '/') END, D.UUIDAmazon) AS Ruta, 
                        'adinco-pr' AS CubetaDev, 
                        CONCAT('IdFacturaAdinco: ', F.IdFactura, ' - ', D.NombreArchivo) AS NombreDocumento, 
                        F.IdFactura, 
                        F.UUID
                 FROM dbo.FI_Factura F (NOLOCK)
                      JOIN dbo.AWS_DocAwsDocAdinco DA (NOLOCK)
						ON F.IdFactura = DA.IdDocAdinco
                      JOIN dbo.AWS_Documentos D (NOLOCK)
						ON D.AWSDocumentoId = DA.AWSDocumentoId
                      JOIN dbo.PV_Subcontratista S (NOLOCK)
						ON S.IdSubcontratista = F.IdSubcontratista
                 WHERE F.IdFactura = @IdFactura;
             END;
     END;



