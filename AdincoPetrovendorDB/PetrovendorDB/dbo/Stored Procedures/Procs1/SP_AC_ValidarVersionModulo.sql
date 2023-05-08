-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AC_ValidarVersionModulo] 
	-- Add the parameters for the stored procedure here
	@version NVARCHAR(MAX),
	@modulo NVARCHAR(MAX),
	@aplicacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdIteracion FROM dbo.RegistroIteraciones WHERE VersionIteracion = @version AND Modulo = @modulo AND Aplicacion = @aplicacion AND IsEliminado IS NULL
END

