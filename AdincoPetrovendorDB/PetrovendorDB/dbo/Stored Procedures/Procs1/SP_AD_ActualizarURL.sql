-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SP_AD_ActualizarURL] 
	-- Add the parameters for the stored procedure here
	@IdDominio INT,
	@Url NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE  TA_Dominios 
	SET Url=@Url
	WHERE IdDominio=@IdDominio
END
