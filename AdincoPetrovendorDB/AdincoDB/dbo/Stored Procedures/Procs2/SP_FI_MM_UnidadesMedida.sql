-- =============================================
-- Author:		Manuel CD
-- Create date: 06-10-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_MM_UnidadesMedida] 
	-- Add the parameters for the stored procedure here
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdUnidad,
                Unidad
         FROM PV_MM_MaterialUnidad

     END;
