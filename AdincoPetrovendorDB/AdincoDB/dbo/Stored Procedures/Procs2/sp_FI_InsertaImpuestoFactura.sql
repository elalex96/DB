-- Description:	
-- =============================================
-- Author:		Miguel
-- Create date: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_InsertaImpuestoFactura]
-- Add the parameters for the stored procedure here
@IdFactura      INT, 
@Importe        MONEY, 
@IdTipoImpuesto INT, 
@Impuesto       NVARCHAR(50), 
@Tasa           FLOAT, 
@TipoFactor     NVARCHAR(50), 
@NombreImpuesto NVARCHAR(50) = NULL
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         INSERT INTO [dbo].[FI_CFDIImpuesto]
         ([IdFactura], 
          [IdTipoImpuesto], 
          [Impuesto], 
          [Tasa], 
          [Importe], 
          [TipoFactor], 
          [NombreImpuesto]
         )
         VALUES
         (@IdFactura, 
          @IdTipoImpuesto, 
          @Impuesto, 
          @Tasa, 
          @Importe, 
          @TipoFactor, 
          @NombreImpuesto
         );
         SELECT CAST(@@IDENTITY AS NVARCHAR) AS INSERTADO, 
                'El impuesto se ha registrado correctamente con el id '+CAST(@@IDENTITY AS NVARCHAR) AS MSG;
     END;