-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_flujoTareaPredeterminadoCatalogo]
@IdProveedor INT,
@IdUsuario   INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT IdFlujoTarea
	FROM TA_FlujoTarea
	WHERE IdProveedor = @IdProveedor AND CreadorPor = @IdUsuario AND IdTipoOperacion = 15 AND Predeterminado = 1

END

