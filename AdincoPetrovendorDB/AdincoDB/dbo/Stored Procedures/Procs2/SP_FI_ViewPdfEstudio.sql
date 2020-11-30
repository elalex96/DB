-- =============================================
-- Author:		Manuel CD
-- Create date: 12-10-17
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_FI_ViewPdfEstudio] 
	-- Add the parameters for the stored procedure here
@IdEstudio INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT E.IdEstudioPrecioTransfer,
                E.Archivo
         FROM FI_EstudioPreciosTransfer E
         WHERE E.IdEstudioPrecioTransfer = @IdEstudio;
     END;
