
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultaImagen]
	-- Add the parameters for the stored procedure here
	@IdIteracionDetalle INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ImagenVideo FROM dbo.RegistroIteracionesDetalle WHERE IdDetalleIteracion = @IdIteracionDetalle
END

