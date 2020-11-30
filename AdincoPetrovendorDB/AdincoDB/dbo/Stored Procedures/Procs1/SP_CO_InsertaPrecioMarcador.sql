-- =============================================
-- Author:		Manuel CD
-- Create date: 2018-08-28
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_InsertaPrecioMarcador] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@IdMarcador INT, 
@Mes        DATE, 
@Precio     MONEY
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         INSERT INTO [dbo].[CO_PrecioMarcadorMensual]
         ([IdMarcador], 
          [IdContrato], 
          [Mes], 
          [Precio], 
          [CreadoPor], 
          [CreadoEn]
         )
         VALUES
         (@IdMarcador, 
          @IdContrato, 
          @Mes, 
          @Precio, 
          @IdUsuario, 
          GETDATE()
         );
     END;
