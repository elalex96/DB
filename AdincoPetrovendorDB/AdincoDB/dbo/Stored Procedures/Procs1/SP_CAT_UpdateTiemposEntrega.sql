-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/10/2021
-- Description:	Actualizacion de tiempos de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_UpdateTiemposEntrega] 
	-- Add the parameters for the stored procedure here
	@IdTiempoEntrega INT,
	@TiempoEntrega NVARCHAR(100),
	@Server BIT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @Server = 1
	BEGIN
		UPDATE dbo.EN_TiempoEntrega
		SET TiempoEntrega = @TiempoEntrega
		WHERE IdTiempoEntrega = @IdTiempoEntrega;
	END
END