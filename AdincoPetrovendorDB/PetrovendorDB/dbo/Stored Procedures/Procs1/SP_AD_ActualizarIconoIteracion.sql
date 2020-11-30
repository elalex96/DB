
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarIconoIteracion]
	-- Add the parameters for the stored procedure here
	@version INT,
	@icono NVARCHAR(MAX),
	@versioncatual BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @versions NVARCHAR(MAX) = (CAST(@version AS NVARCHAR(MAX)))
    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteraciones
	SET IconoModulo = @icono,
		VersionActual = @versioncatual
	WHERE IdIteracion = @version

	SELECT @icono
END

