
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultaVersionActualxIteracion]
	-- Add the parameters for the stored procedure here
	@IdIteracion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT VersionActual FROM dbo.RegistroIteraciones WHERE IdIteracion = @IdIteracion
END

