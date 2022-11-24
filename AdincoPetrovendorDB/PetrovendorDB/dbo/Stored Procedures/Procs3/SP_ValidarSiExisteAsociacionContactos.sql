-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarSiExisteAsociacionContactos]
@IdContacto                  int,
@IdContratistaSubContratista int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select c.IdContacto
	from S_Contacto_PA c
	inner join S_ContactoContratistaSubContratista ccs
	on c.IdContacto = ccs.IdContacto
	where ccs.IdContacto = @IdContacto and ccs.IdContratistaSubContratista = @IdContratistaSubContratista
	and ccs.IsActivo = 1

END

