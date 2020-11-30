-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-08-21
-- Description:	Registra los impuestos de los conceptos
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_InsertaConceptoImpuestoFactura]
-- Add the parameters for the stored procedure here
@IdFacturaConcepto BIGINT, 
@IdTipoImpuesto    INT, 
@NombreImpuesto    NVARCHAR(50), 
@Impuesto          NVARCHAR(50), 
@Tasa              FLOAT, 
@Importe           MONEY, 
@TipoFactor        NVARCHAR(50), 
@Base              MONEY
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         INSERT INTO [dbo].[FI_CFDIConceptoImpuesto]
         ([IdFacturaConcepto], 
          [IdTipoImpuesto], 
          [NombreImpuesto], 
          [Impuesto], 
          [Tasa], 
          [Importe], 
          [TipoFactor], 
          [Base]
         )
         VALUES
         (@IdFacturaConcepto, 
          @IdTipoImpuesto, 
          @NombreImpuesto, 
          @Impuesto, 
          @Tasa, 
          @Importe, 
          @TipoFactor, 
          @Base
         );
         SELECT CAST(@@IDENTITY AS NVARCHAR) AS INSERTADO, 
                'El impuesto se ha registrado correctamente con el id '+CAST(@@IDENTITY AS NVARCHAR) AS MSG;
     END;