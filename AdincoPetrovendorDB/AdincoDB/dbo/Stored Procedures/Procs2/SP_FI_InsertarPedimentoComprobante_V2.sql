-- =============================================  
-- Author:  Manuel CD  
-- Create date: 06-10-17  
-- Description:   
-- =============================================  
CREATE PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante_V2]   
-- Add the parameters for the stored procedure here  
@IdContrato                 INT, 
@FolioComprobante           NVARCHAR(MAX), 
@FechaPago                  DATE, 
@IdSubcontratistaExportador INT, 
@IdMoneda                   INT, 
@IdUnidadMedida             INT, 
@NumFac                     NVARCHAR(50), 
@ClaseBienServicio          NVARCHAR(MAX), 
@Subtotal                   MONEY, 
@IdUsuario                  INT, 
@CvTipoDoc                  INT, 
@DocumentoPDF               IMAGE, 
@IsNotaCredito              BIT = NULL
AS
     BEGIN  
         -- SET NOCOUNT ON added to prevent extra result sets from  
         -- interfering with SELECT statements.  
         SET NOCOUNT ON;
         DECLARE @idped INT;

         /*COMPROBANTE*/

         BEGIN
             INSERT INTO [dbo].[FI_PedimentoComprobante]
             ([IdContrato], 
              [FolioComprobante], 
              [FechaPago], 
              [IdSubcontratistaExportador], 
              [IdMoneda], 
              [CvTipoDocFacturacion], 
              [CreadoPor], 
              [CreadoEn], 
              [NumFacturaC], 
              [EsnotaCredito]
             )
             VALUES
             (@IdContrato, 
              @FolioComprobante, 
              @FechaPago, 
              @IdSubcontratistaExportador, 
              @IdMoneda, 
              @CvTipoDoc, 
              @IdUsuario, 
              GETDATE(), 
              @NumFac, 
              @IsNotaCredito
             );
         END;
         SET @idped = @@IDENTITY;
         BEGIN
             INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
             ([IdPedimentoComprobante], 
              [IdUnidadMedida], 
              [ClaseBienServicio], 
              [PrecioUnitario], 
              [CreadoPor], 
              [CreadoEn]
             )
             VALUES
             (@idped, 
              @IdUnidadMedida, 
              @ClaseBienServicio, 
              @Subtotal, 
              @IdUsuario, 
              GETDATE()
             );
         END;
         BEGIN
             INSERT INTO [dbo].[FI_Documento]
             ([IdTipoDocumento], 
              [IdPedimentoComprobante], 
              [NombreExtensionArchivo], 
              [IdUsuario], 
              [FechaCarga], 
              [IsEliminado], 
              [DocumentoByte]
             )
             VALUES
             (5, 
              @idped, 
              CONCAT('PE_', @idped, '.pdf'), 
              @IdUsuario, 
              GETDATE(), 
              0, 
              @DocumentoPDF
             );
         END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @idped;
     END;