-- =============================================
-- Author:		Reyna Olvera
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE CO_ExtraePaginasLayout
	-- Add the parameters for the stored procedure here
	@idContrato int =0,
	@idUsuario int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT idPagina, Nombrepagina FROM dbo.AP_PaginaLayout
END