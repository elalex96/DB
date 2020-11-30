-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-05-2020
-- Description:	
-- =============================================
CREATE PROCEDURE SP_ENI_PlanTmp 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT Fecha, 
                Evento
         FROM dbo.ENI_PlanTmp;
     END;
