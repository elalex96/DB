-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_AD_EliminarIteracionM
	-- Add the parameters for the stored procedure here
	@IdIteracion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteraciones
	SET IsEliminado = 1
	WHERE IdIteracion = @IdIteracion
END
