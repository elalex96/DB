-- =============================================
-- Author:		Manuel CD
-- Create date: 10-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_VaciarPTI] 
	-- Add the parameters for the stored procedure here
@IdUsuario  INT,
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             DELETE PC_PTI;
         END;