-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar CLASIFICACIO EMPRESA
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_TamanioEmpresa]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE TABLE #TBTamanioEmpresa(IdClasificacion int, Nombre nvarchar(350))

	INSERT INTO #TBTamanioEmpresa(IdClasificacion, Nombre)
	VALUES
	(0, 'Todos')
	

	INSERT INTO #TBTamanioEmpresa(IdClasificacion, Nombre)
	SELECT [IdClasificacion],[Nombre] FROM [dbo].[PV_ClasificacionPyMES]

	SELECT * FROM #TBTamanioEmpresa
	 
	 SP_MM_ISOS
END

