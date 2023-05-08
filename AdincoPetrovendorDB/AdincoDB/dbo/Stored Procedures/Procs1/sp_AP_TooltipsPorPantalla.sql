-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	Obtiene informacion para tooltip y controles de acuerdo al idioma
-- =============================================
CREATE PROCEDURE sp_AP_TooltipsPorPantalla
	-- Add the parameters for the stored procedure here
	@IdPantalla int = 0, 
	@IdIdioma int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT        IdTooltip, IdPantalla, IdCampo,  case when @IdIdioma = 1 then Descripcion  when @IdIdioma = 2 then Description end as Display , Activo
FROM            AP_Tooltip
WHERE        (IdPantalla = @IdPantalla)
END
