-- =============================================
-- Author:		Reyna
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PruebaTablaReporte]
	-- Add the parameters for the stored procedure here
	@idContrato int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	Day (idFecha) as 'Día',VolumenProgramado as 'Volumen Programado' from CO_NominacionVolumen
	Where idContrato=3
END

