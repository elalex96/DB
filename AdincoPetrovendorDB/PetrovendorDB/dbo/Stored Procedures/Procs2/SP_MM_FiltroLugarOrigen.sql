-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_FiltroLugarOrigen]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE TABLE #TBOrigen(IdOrigen int, NombreOrigen nvarchar(350))

	INSERT INTO #TBOrigen(IdOrigen, NombreOrigen)
	VALUES(1,'Todos'),
	(2,'Extranjeros'),
	(3,'Nacionales'),
	(4,'Locales')

	SELECT * FROM #TBOrigen
	 

END

