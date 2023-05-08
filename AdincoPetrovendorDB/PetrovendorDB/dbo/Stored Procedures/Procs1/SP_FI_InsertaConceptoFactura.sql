-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertaConceptoFactura] 
-- Add the parameters for the stored procedure here
@IdFactura        INT, 
@Descripcion      NVARCHAR(MAX), 
@Cantidad         FLOAT, 
@Unidad           NVARCHAR(MAX) = NULL, 
@ValorUnitario    MONEY, 
@Importe          MONEY, 
@NoIdentificacion NVARCHAR(MAX) = NULL, 
@ClaveProdServ    NVARCHAR(50)  = NULL, 
@ClaveUnidad      NVARCHAR(50)  = NULL, 
@Descuento        MONEY         = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         INSERT INTO [dbo].[FI_CFDIConcepto]
         ([IdFactura], 
          [Descripcion], 
          [Cantidad], 
          [Unidad], 
          [ValorUnitario], 
          [Importe], 
          [NoIdentificacion], 
          [ClaveProdServ], 
          [ClaveUnidad], 
          [Descuento]
         )
         VALUES
         (@IdFactura, 
          @Descripcion, 
          @Cantidad, 
          @Unidad, 
          @ValorUnitario, 
          @Importe, 
          @NoIdentificacion, 
          @ClaveProdServ, 
          @ClaveUnidad, 
          @Descuento
         );
         SELECT CAST(@@IDENTITY AS NVARCHAR) AS INSERTADO, 
                'El concepto se ha registrado correctamente con el id '+CAST(@@IDENTITY AS NVARCHAR) AS MSG;
         -- Insert statements for procedure here

     END;
