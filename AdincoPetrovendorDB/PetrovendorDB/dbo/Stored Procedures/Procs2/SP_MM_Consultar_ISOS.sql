-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar ISOS EMPRESA
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Consultar_ISOS]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	CREATE TABLE #TBISOS(IdDocSistemaGestion int, Nombre nvarchar(350))

	INSERT INTO #TBISOS(IdDocSistemaGestion, Nombre)
	VALUES (0, 'Todos')
	

	INSERT INTO #TBISOS(IdDocSistemaGestion, Nombre)
	SELECT [IdDocSistemaGestion],[DocSistemaGestion] FROM [dbo].[PV_DocSistemGestion] WHERE [IdDocSistemaGestion] <> 5

	SELECT * FROM #TBISOS
	
END

