
-- =============================================
-- Author:		Josue Glez
-- Create date: 21-05-2017
-- Description:	SP PARA GUARDAR EL REGISTRO DE LA TRANSFERENCIA
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_InsertarTransferconPDF]
-- Add the parameters for the stored procedure here
-- 1, '1234', '24/05/2017',12, 13, 890, 1, 1, 987, 1, 'prueba', 4, 1234, 0 
@IdContrato               INT, 
@ReferenciaBancaria       NVARCHAR(50), 
@FechaPago                DATE, 
@IdCuentaOrigen           INT, 
@IdCuentaDestino          INT, 
@MontoPagado              MONEY, 
@IdMoneda                 INT, 
@IdClasificacionDocumento INT, 
@Concepto                 NVARCHAR(MAX), 
@IdMetodoPago             INT, 
@NumeroPolizaContable     INT, 
@Intereses                MONEY, 
@PDF                      NVARCHAR(MAX), 
@IdUsuario                INT, 
@IdFormaPago              INT,
@pAWSDocumentId				INT
AS

     /**/

     DECLARE @INSERTADO INT;--, @pGastosActualizados INT;

	 if(@pAWSDocumentId = 0)
		set @pAWSDocumentId = null

	

     /**/

     BEGIN
         --BEGIN TRAN;
         SET NOCOUNT ON;
         IF @PDF = '0'
		 begin
			set @PDF = null
             INSERT INTO [dbo].[FI_Transfer]
             ([IdContrato], 
              [ReferenciaBancaria], 
              [FechaPago], 
              [IdCuentaOrigen], 
              [IdCuentaDestino], 
              [MontoPagado], 
              [IdMoneda], 
              [IdClasificacionDocumento], 
              [Concepto], 
              [IdMetodoPago], 
              [NumeroPolizaContable], 
              [Intereses], 
              [PDF], 
              [CreadoPor], 
              [CreadoEn], 
              [IdFormaPago],
			  AWSPDFId
             )
             VALUES
             (@IdContrato, 
              @ReferenciaBancaria, 
              @FechaPago, 
              @IdCuentaOrigen, 
              @IdCuentaDestino, 
              @MontoPagado, 
              @IdMoneda, 
              @IdClasificacionDocumento, 
              @Concepto, 
              @IdMetodoPago, 
              @NumeroPolizaContable, 
              @Intereses, 
              NULL, 
              @IdUsuario, 
              GETDATE(), 
              @IdFormaPago,
			  @pAWSDocumentId
             );

		END
             ELSE
         IF @PDF <> '0'
		 BEGIN
			set @PDF = null
             INSERT INTO [dbo].[FI_Transfer]
             ([IdContrato], 
              [ReferenciaBancaria], 
              [FechaPago], 
              [IdCuentaOrigen], 
              [IdCuentaDestino], 
              [MontoPagado], 
              [IdMoneda], 
              [IdClasificacionDocumento], 
              [Concepto], 
              [IdMetodoPago], 
              [NumeroPolizaContable], 
              [Intereses], 
              [PDF], 
              [CreadoPor], 
              [CreadoEn], 
              [IdFormaPago],
			  AWSPDFId

             )
             VALUES
             (@IdContrato, 
              @ReferenciaBancaria, 
              @FechaPago, 
              @IdCuentaOrigen, 
              @IdCuentaDestino, 
              @MontoPagado, 
              @IdMoneda, 
              @IdClasificacionDocumento, 
              @Concepto, 
              @IdMetodoPago, 
              @NumeroPolizaContable, 
              @Intereses, 
              @PDF, 
              @IdUsuario, 
              GETDATE(), 
              @IdFormaPago,
			  @pAWSDocumentId
             );
		END

         /**/

         SET @INSERTADO = @@IDENTITY;

/*IF @@ERROR <> 0
             BEGIN
                 ROLLBACK TRAN;
                 SELECT 'false' AS msj, 
                        0 AS idtran, 
                        0 Gastos;
             END;
             ELSE
             BEGIN
                 EXEC p_FI_TransferFechaPresentacionGasto_Upd 
                      @INSERTADO, 
                      @pGastosActualizados OUT;
                 IF @@error <> 0
                     BEGIN
                         ROLLBACK TRAN;
                         SELECT 'false' AS msj, 
                                0 AS idtran, 
                                0 Gastos;
                     END;
                     ELSE
                     BEGIN
                         COMMIT TRAN;
                         SELECT 'true' AS msj, 
                                @INSERTADO AS idtran, 
                                @pGastosActualizados Gastos;
                     END;
             END;*/

         IF @@ERROR <> 0
             BEGIN
                 SELECT 'false' AS msj, 
                        0 AS idtran;
             END;
             ELSE
             BEGIN
                 SELECT 'true' AS msj, 
                        @INSERTADO AS idtran
             END;
     END;

