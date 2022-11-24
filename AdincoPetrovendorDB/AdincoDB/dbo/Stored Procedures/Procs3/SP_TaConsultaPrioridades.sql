
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 05-01-17
-- Description:	SP que regresa la consulta de los tipos de prioridades que existen en la base de datos 
				-- para que sean mostrados en la parte web, creando una tabla temporal con un registro
				-- para que muestre una opcion por default
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaConsultaPrioridades] 
	-- Add the parameters for the stored procedure here
	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #TPrioridades(Nombre varchar(max),IdPrioridad int)

	INSERT INTO #TPrioridades(Nombre,IdPrioridad) 
	VALUES('-- Seleccione una opción --',0)

	INSERT INTO #TPrioridades(Nombre,IdPrioridad)
	SELECT Nombre,IdPrioridad 
	FROM TaPrioridad 
	ORDER BY Nombre ASC

	SELECT Nombre, IdPrioridad FROM #TPrioridades

END


