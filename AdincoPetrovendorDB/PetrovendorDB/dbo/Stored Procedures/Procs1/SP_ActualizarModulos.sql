-- =============================================
-- Author:	Abel Rivera
-- Create date: ABRIL
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarModulos]
@IdModulo int,
@NombreModulo nvarchar(200),
@StringModuloId nvarchar(200)
--@URL_MODULO nvarchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE Modulo
	SET
	NombreModulo = @NombreModulo,
	StringModuloId = @StringModuloId
	--URL_MODULO = @URL_MODULO
	WHERE IdModulo = @IdModulo


END

