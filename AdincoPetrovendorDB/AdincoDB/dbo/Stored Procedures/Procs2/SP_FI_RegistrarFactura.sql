-- =============================================
-- Author:		Manuel CD
-- Create date: 15-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RegistrarFactura] 
	-- Add the parameters for the stored procedure here
@Serie            VARCHAR(500),
@Folio            VARCHAR(500),
@Fecha            DATETIME,
@FormaPago        VARCHAR(500),
@MeodoPago        VARCHAR(500),
@SubTotal         MONEY,
@TotalGrl		   MONEY,
@LugarExpedicion  VARCHAR(1000),
@NumCtaPago       VARCHAR(1000),
@IdSubcontratista INT,
@IdMoneda         INT,
@IdContrato       INT,
@CreadoPor        INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @RFCE VARCHAR(250)
         DECLARE @RFCR VARCHAR(250)
         DECLARE @Total DECIMAL(18, 4)
	    DECLARE @IdFac INT
	    DECLARE @Metodo VARCHAR(MAX)
	    
         --Emisor
	    SELECT @RFCE = RFC
         FROM PV_Subcontratista
         WHERE IdSubcontratista = @IdSubcontratista
	    --Receptor
         SELECT @RFCR = RFC
         FROM CO_Contrato C 
		 JOIN CO_Contratista CC 
			ON C.IdContratista = CC.IdContratista 
		WHERE C.IdContrato = @IdContrato
	    --Calculo de Total
         SELECT @Total = ((@SubTotal * .16) + @SubTotal)
	    --Setear metodo de pago
	    SELECT @Metodo = MetodoPago FROM PV_MetodoPago WHERE idMetodoPago = @MeodoPago
     --Insert statements for procedure here
         INSERT INTO [dbo].[FI_Factura]
         ([Serie],
          [Folio],
          [Fecha],
          [FormaPago],
		[MetodoPago],
          [SubTotal],
          [MontoConIva],
          [LugarExpedicion],
          [NumCtaPago],
          [Emisor],
          [Receptor],
		[IdSubcontratista],
          [IdMoneda],
          [IdContrato],
          [Activa],
          [CreadoPor],
          [CreadoEn],
		[FechaTimbrado]
         )
         VALUES
         (@Serie,
          @Folio,
          @Fecha,
          @FormaPago,
		@Metodo,
          @SubTotal,
          @TotalGrl,
          @LugarExpedicion,
          @NumCtaPago,
          @RFCE,
          @RFCR,
          @IdSubcontratista,
          @IdMoneda,
          @IdContrato,
          1,
          @CreadoPor,
          GETDATE(),
		@Fecha
         )

	    SET @IdFac = @@IDENTITY
	    SELECT @IdFac
     END;
