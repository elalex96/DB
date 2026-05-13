-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EliminarRelacionContactoCliente]
@IdContactoCS int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Update S_ContactoContratistaSubContratista
	set
	IsActivo = 0
	where IdContactoCS = @IdContactoCS

	select 'Cuenta eliminada'
END

