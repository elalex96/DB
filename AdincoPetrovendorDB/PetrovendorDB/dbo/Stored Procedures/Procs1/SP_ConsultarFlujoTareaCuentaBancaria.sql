-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarFlujoTareaCuentaBancaria]
@IdTipoOperacion int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select [IdFlujoTarea] from TA_FlujoTarea  where [IdTipoOperacion] = @IdTipoOperacion
	
END

