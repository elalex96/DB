-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <09/07/2020>
-- Description:	<Consulta la lista de tableros>
-- =============================================
CREATE PROCEDURE SP_ListaTableros
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
	IdTableroContrato,
	IdContrato,
	Workbook,
	Sheet,
	Site,
	Tabs,
	DNS,
	CreadoEn,
	CreadoPor,
	Activo,
	HeightPX,
	NombreMostrar,
	Parametros,
	UserTableau,
	MuestraToolbar
	FROM adinco.dbo.EN_TableroContrato
	ORDER BY IdTableroContrato DESC


END
