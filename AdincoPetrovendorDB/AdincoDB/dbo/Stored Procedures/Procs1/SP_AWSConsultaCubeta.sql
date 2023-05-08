-- =============================================
-- Author:		Reyna Olvera
-- Create date: 12/06/2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_AWSConsultaCubeta]
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
               SELECT name
             FROM AWS_Bucket
			 where idBucket=10001;
         END;
