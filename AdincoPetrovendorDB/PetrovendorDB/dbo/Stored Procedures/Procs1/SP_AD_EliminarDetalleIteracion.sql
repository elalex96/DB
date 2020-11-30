
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_EliminarDetalleIteracion]
	-- Add the parameters for the stored procedure here
	@IdDetalleIteracion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteracionesDetalle
	SET IsEliminado = 1,
		FechaModificado = GETDATE()
	WHERE IdDetalleIteracion = @IdDetalleIteracion
END

