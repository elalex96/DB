-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/10/2021
-- Description:	Agregado de un nuevo tiempo de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_GuardarTiempoEntrega]
	-- Add the parameters for the stored procedure here
	@TiempoEntrega NVARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.EN_TiempoEntrega
	(
		TiempoEntrega,
		CreadoEn
	)
	VALUES
	(
		@TiempoEntrega,
		GETDATE()
	);

END