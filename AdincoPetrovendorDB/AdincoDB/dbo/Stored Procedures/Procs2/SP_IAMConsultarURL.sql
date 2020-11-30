-- =============================================
-- Author:		Manuel CD
-- Create date: 02-01-18
-- Description:	
-- =============================================
CREATE PROCEDURE SP_IAMConsultarURL
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT URL,
                    IdServiceUrl
             FROM AWS_ServiceUrl;
         END;

