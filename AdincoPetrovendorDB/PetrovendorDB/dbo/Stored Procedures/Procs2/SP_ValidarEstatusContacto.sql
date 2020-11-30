-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarEstatusContacto]
@IdContacto int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select ccs.IdContactoCS
	from S_Contacto_PA c
	inner join S_ContactoContratistaSubContratista ccs
	on c.IdContacto = ccs.IdContacto
	where ccs.IdContacto = @IdContacto AND ccs.IsActivo = 1


END
