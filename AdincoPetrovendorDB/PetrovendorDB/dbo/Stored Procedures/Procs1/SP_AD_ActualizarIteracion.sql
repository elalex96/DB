-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizarIteracion]
	-- Add the parameters for the stored procedure here
	@IdIteracion INT,
	@VersionIteracion NVARCHAR(MAX),
	@Modulo NVARCHAR(MAX),
	@TipoActualizacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.RegistroIteraciones
	SET VersionIteracion = @VersionIteracion,
		Modulo = @Modulo,
		TipoActualizacion = @TipoActualizacion
	WHERE IdIteracion = @IdIteracion
END
