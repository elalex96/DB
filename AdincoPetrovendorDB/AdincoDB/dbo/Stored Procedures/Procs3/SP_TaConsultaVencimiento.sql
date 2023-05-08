
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 05-01-17
-- Description:	Regresa a la parte web Los dias que puede declarar para el vencimiento de la tarea que esta creando y asignando
				-- asi como una opcion por default
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaConsultaVencimiento] 
	-- Add the parameters for the stored procedure here
	 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #TVencimiento(DiaVencimiento varchar(max),IdVencimiento int)

	INSERT INTO #TVencimiento(IdVencimiento,DiaVencimiento) 
	VALUES(0,'-- Seleccione una opción --')

	INSERT INTO #TVencimiento(IdVencimiento,DiaVencimiento)
	SELECT IdVencimiento, DiaVencimiento 
	FROM TaVencimiento 
	ORDER BY DiaVencimiento ASC

	SELECT IdVencimiento, DiaVencimiento FROM #TVencimiento

END



