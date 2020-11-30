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
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- Insert statements for procedure here

         /*Determinar UUID Factura para buscar en Petrovendor*/

         --DECLARE @IdFactura INT= 61498;
         DECLARE @UUID NVARCHAR(MAX);
         DECLARE @Contador INT;
         DECLARE @IdFacturaP INT;

         /**/

         SELECT @UUID = UUID
         FROM Adinco.dbo.FI_Factura
         WHERE IdFactura = @IdFactura;

         /**/

         SELECT @Contador = COUNT(FP.IdFactura), 
                @IdFacturaP = FP.IdFactura
         FROM Petrovendor.dbo.FI_Factura FP
              LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF ON FP.IdFactura = AF.IdFactura
              LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AC ON AC.IdAceptacionPedido = AF.IdAceptacionPedido
              LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
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
                        'petrovendor-pr' AS CubetaDev, 
                        CONCAT('IdFacturaAdinco: ', @IdFactura, ' - ', D.NombreDocumento) AS NombreDocumento, 
                        AF.IdFactura, 
                        FP.UUID
                 FROM Petrovendor.dbo.FI_Factura FP
                      LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF ON FP.IdFactura = AF.IdFactura
                      LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AC ON AC.IdAceptacionPedido = AF.IdAceptacionPedido
                      LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                      LEFT JOIN Petrovendor.dbo.S_Documento_S3 D ON D.IdDocumento = AC.IdDocumento
                      LEFT JOIN Petrovendor.dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
                      LEFT JOIN Petrovendor.dbo.S_Proveedor PR ON PR.IdProveedor = P.IdSubcontratista
                 WHERE FP.IdFactura = @IdFacturaP
                       AND ISNULL(AC.IdEstatus, 0) = 2
                       AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                       AND ISNULL(FP.Activa, 0) = 1
                       AND ISNULL(FP.IsEliminado, 0) = 0;
             END;
             ELSE
             BEGIN
                 SELECT UPPER(D.UUIDAmazon) AS Identificador, 
                        D.Folder AS Carpeta, 
                        CONCAT(D.Folder, D.UUIDAmazon) AS Ruta, 
                        'adinco-pr' AS CubetaDev, 
                        CONCAT('IdFacturaAdinco: ', F.IdFactura, ' - ', D.NombreArchivo) AS NombreDocumento, 
                        F.IdFactura, 
                        F.UUID
                 FROM dbo.FI_Factura F
                      JOIN dbo.AWS_DocAwsDocAdinco DA ON F.IdFactura = DA.IdDocAdinco
                      JOIN dbo.AWS_Documentos D ON D.AWSDocumentoId = DA.AWSDocumentoId
                      JOIN dbo.PV_Subcontratista S ON S.IdSubcontratista = F.IdSubcontratista
                 WHERE F.IdFactura = @IdFactura;
             END;
     END;