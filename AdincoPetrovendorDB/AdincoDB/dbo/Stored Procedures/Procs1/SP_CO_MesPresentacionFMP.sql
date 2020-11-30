-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2019-03-25
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_MesPresentacionFMP] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT MesPresentacionCGI
         FROM dbo.CO_Contrato
         WHERE IdContrato = @IdContrato;
     END;
