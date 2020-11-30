-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-05-2017
-- Description:	SP PARA GUARDAR EL REGISTRO DE LA TRANSFERENCIA
-- =============================================
CREATE PROCEDURE sp_FI_InsertarTransfer 
	-- Add the parameters for the stored procedure here
@IdContrato               INT,
@IdComprobantePago        NVARCHAR(50),
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
@Intereses                MONEY
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @idtransfer INT;

    -- Insert statements for procedure here
         INSERT INTO [dbo].[FI_Transfer]
         ([IdContrato],
          [IdComprobantePago],
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
          [Intereses]
         )
         VALUES
         (@IdContrato,
          @IdComprobantePago,
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
          @Intereses
         );

         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;

     END;
