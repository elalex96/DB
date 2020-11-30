-- =============================================
-- Author:		Manuel CD
-- Create date: 01-09-17
-- Description:	
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 19-11-2019
-- Description:	Agregar BIT en AWS_Documentos(Reemplazado) 
--				si en FI_Transfer ya existia un (AWSPDFId) 
--				para ese Registro
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarTransferencia] 
-- Add the parameters for the stored procedure here
@IdContrato           INT, 
@ReferenciaBancaria   NVARCHAR(50), 
@FechaPago            DATE, 
@IdCuentaOrigen       INT, 
@IdCuentaDestino      INT, 
@MontoPagado          MONEY, 
@IdMoneda             INT, 
@Concepto             NVARCHAR(MAX), 
@IdMetodoPago         INT, 
@NumeroPolizaContable INT, 
@Intereses            MONEY, 
@PDF                  NVARCHAR(MAX), 
@IdUsuario            INT, 
@IdTransfer           INT, 
@IdFormaPago          INT, 
@pAWSDocumentId       INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         IF @PDF = ''
             BEGIN
                 UPDATE FI_Transfer
                   SET
                 -- [IdContrato] = @IdContrato,
                       [ReferenciaBancaria] = @ReferenciaBancaria, 
                       [FechaPago] = @FechaPago, 
                       [IdCuentaOrigen] = @IdCuentaOrigen, 
                       [IdCuentaDestino] = @IdCuentaDestino, 
                       [MontoPagado] = @MontoPagado, 
                       [IdMoneda] = @IdMoneda, 
                       [Concepto] = @Concepto, 
                       [IdMetodoPago] = @IdMetodoPago, 
                       [NumeroPolizaContable] = @NumeroPolizaContable, 
                       [Intereses] = @Intereses, 
                       [ModificadoPor] = @IdUsuario, 
                       [ModificadoEn] = GETDATE(), 
                       [IdFormaPago] = @IdFormaPago, 
                       AWSPDFId = CASE
                                      WHEN isnull(@pAWSDocumentId, 0) > 0
                                      THEN @pAWSDocumentId
                                      ELSE AWSPDFId
                                  END
                 WHERE IdTransferencia = @IdTransfer
                       AND IdContrato = @IdContrato;
             END;
             ELSE
             BEGIN
                 DECLARE @AWSExistente INT=
                 (
                     SELECT AWSPDFId
                     FROM dbo.FI_Transfer
                     WHERE IdTransferencia = @IdTransfer
                           AND AWSPDFId IS NOT NULL
                 );
                 IF @AWSExistente IS NOT NULL
                     BEGIN
                         UPDATE dbo.AWS_Documentos
                           SET 
                               Reemplazado = 1
                         WHERE AWSDocumentoId = @AWSExistente;
                     END;
                 UPDATE FI_Transfer
                   SET
                 -- [IdContrato] = @IdContrato,
                       [ReferenciaBancaria] = @ReferenciaBancaria, 
                       [FechaPago] = @FechaPago, 
                       [IdCuentaOrigen] = @IdCuentaOrigen, 
                       [IdCuentaDestino] = @IdCuentaDestino, 
                       [MontoPagado] = @MontoPagado, 
                       [IdMoneda] = @IdMoneda, 
                       [Concepto] = @Concepto, 
                       [IdMetodoPago] = @IdMetodoPago, 
                       [NumeroPolizaContable] = @NumeroPolizaContable, 
                       [Intereses] = @Intereses, 
                       [PDF] = @PDF, 
                       [ModificadoPor] = @IdUsuario, 
                       [ModificadoEn] = GETDATE(), 
                       [IdFormaPago] = @IdFormaPago, 
                       AWSPDFId = CASE
                                      WHEN isnull(@pAWSDocumentId, 0) > 0
                                      THEN @pAWSDocumentId
                                      ELSE AWSPDFId
                                  END
                 WHERE IdTransferencia = @IdTransfer
                       AND IdContrato = @IdContrato;
             END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;