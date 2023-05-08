-- =============================================
-- Author:		Manuel CD
-- Create date: 23-11-2018
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CO_EliminaPrecioMarcador 
-- Add the parameters for the stored procedure here
@IdContrato       INT = 0, 
@IdUsuario        INT = 0, 
@IdPrecioMarcador INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         DELETE FROM dbo.CO_PrecioMarcadorMensual
         WHERE IdPrecioMarcadorMensual = @IdPrecioMarcador;
     END; 
