
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarDetalleIteracion]
	-- Add the parameters for the stored procedure here
	@IdDetalleIteracion INT,
	@DescripcionLarga NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteracionesDetalle
	SET DescripcionLarga = @DescripcionLarga
	WHERE IdDetalleIteracion = @IdDetalleIteracion
END

