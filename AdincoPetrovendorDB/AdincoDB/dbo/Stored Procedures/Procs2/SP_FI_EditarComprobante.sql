IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_EditarComprobante'
)
    DROP PROCEDURE SP_FI_EditarComprobante
GO
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-01-2020
-- Description:	Editar Mediante IdPedimentoComprobante
-- =============================================
-- Modificador:		Marcos Garcia
-- Modificador date: 25-06-2021
-- Description:	Editar @IsNotaCredito NULL
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EditarComprobante] 
-- Add the parameters for the stored procedure here
@IdPedimentoComprobante     INT, 
@IdContrato                 INT, 
@FolioComprobante           VARCHAR(5000), 
@FechaPago                  DATE, 
@IdSubcontratistaExportador INT, 
@IdMoneda                   INT, 
@IdUnidadMedida             INT, 
@NumFac                     VARCHAR(50), 
@ClaseBienServicio          VARCHAR(5000), 
@Subtotal                   MONEY, 
@IdUsuario                  INT, 
@CvTipoDoc                  INT, 
@IsNotaCredito				BIT = NULL,
@DocumentoPDF               IMAGE
AS
     BEGIN
         SET NOCOUNT ON;

         /*COMPROBANTE*/

         DECLARE @Validacion INT;
         SET @Validacion = (DATALENGTH(@DocumentoPDF));
	     BEGIN

			 IF EXISTS(SELECT * FROM dbo.FI_PedimentoComprobante (NOLOCK) WHERE IdPedimentoComprobante = @IdPedimentoComprobante AND EsnotaCredito IS NOT NULL)
			 BEGIN
				SET @IsNotaCredito = (SELECT EsnotaCredito FROM dbo.FI_PedimentoComprobante (NOLOCK) WHERE IdPedimentoComprobante = @IdPedimentoComprobante AND EsnotaCredito IS NOT NULL);
			 END

             UPDATE dbo.FI_PedimentoComprobante
               SET 
                   FolioComprobante = @FolioComprobante, 
                   FechaPago = @FechaPago, 
                   IdSubcontratistaExportador = @IdSubcontratistaExportador, 
                   IdMoneda = @IdMoneda, 
                   CvTipoDocFacturacion = @CvTipoDoc, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE(), 
                   NumFacturaC = @NumFac,
				   EsnotaCredito = @IsNotaCredito
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
         END;
         BEGIN
			IF EXISTS (SELECT 1 FROM FI_PedimentoComprobanteDetalle WHERE IdPedimentoComprobante = @IdPedimentoComprobante	)
			BEGIN
             UPDATE dbo.FI_PedimentoComprobanteDetalle
               SET 
                   IdUnidadMedida = @IdUnidadMedida, 
                   ClaseBienServicio = @ClaseBienServicio, 
                   PrecioUnitario = @Subtotal, 
                   ModificadoPor = @IdUsuario, 
                   ModificadoEn = GETDATE()
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
			 END
			 ELSE
			 BEGIN
				INSERT INTO FI_PedimentoComprobanteDetalle(IdPedimentoComprobante, IdUnidadMedida, ClaseBienServicio, PrecioUnitario, ModificadoPor, ModificadoEn, CreadoPor, CreadoEn)
				SELECT @IdPedimentoComprobante, @IdUnidadMedida, @ClaseBienServicio, @Subtotal, @IdUsuario, GETDATE(), @IdUsuario, GETDATE()
			 END
         END;
         BEGIN
             IF(@Validacion <> 0)
                 BEGIN
                     UPDATE dbo.FI_Documento
                       SET 
                           ModificadoPor = @IdUsuario, 
                           ModificadoEn = GETDATE()
                     WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
                 END;
         END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj, 
                @IdPedimentoComprobante;
     END;


