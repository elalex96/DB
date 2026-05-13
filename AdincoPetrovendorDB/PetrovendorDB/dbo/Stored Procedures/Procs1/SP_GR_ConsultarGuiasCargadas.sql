-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SP_GR_ConsultarGuiasCargadas]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
	IdGuiaRapida,
	NombreGuia,
	CASE RIGHT(NombreGuia,4)
	WHEN  'ppsx' THEN 'ppsx'
	WHEN  'pptx' THEN 'pptx' END AS Formato, 
	Modulo,
	Plataforma 
	FROM GuiasRapidas 
	WHERE Activo = 1


END
