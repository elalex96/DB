-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/10/2021
-- Description:	Validar si ya existe el tiempo de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ValidarTiempoRespuesta]
	-- Add the parameters for the stored procedure here
	@TiempoRespuesta NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EXISTE_REGISTRO INT = (SELECT COUNT(1) FROM EN_TiempoRespuesta WHERE UPPER(TiempoRespuesta) = UPPER(@TiempoRespuesta));

	IF @EXISTE_REGISTRO > 0
	BEGIN 
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END


END