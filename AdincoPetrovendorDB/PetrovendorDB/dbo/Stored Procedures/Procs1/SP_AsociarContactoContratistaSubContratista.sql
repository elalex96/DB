-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AsociarContactoContratistaSubContratista]
@IdContacto                  int,
@IdContratistaSubContratista int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	insert into S_ContactoContratistaSubContratista(
    IdContacto,
    IdContratistaSubContratista,
    IsActivo,
    FechaRegistro
	)
	values(
	@IdContacto,
	@IdContratistaSubContratista,
	1,
	getdate()
	)

	select @@identity

END

