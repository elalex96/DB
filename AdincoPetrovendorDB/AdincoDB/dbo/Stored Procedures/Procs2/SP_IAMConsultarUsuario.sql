-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-18
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_IAMConsultarUsuario]
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT IdIAM,
                    Nombre,
                    RTRIM(LTRIM(AccessKey)) AS AccessKey,
                    RTRIM(LTRIM(SecretAccessKey)) AS SecretAccessKey,
                    IdContrato
             FROM AWS_UserIAM
			 WHERE IdIAM = 10001
         END;