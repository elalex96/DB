-- =============================================
-- Author:		Manuel Cruz
-- Create date: 10-03-17
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CO_Meses 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdMes, NumeroMes, MesCalendario, Descripcion
	FROM CO_Mes
END
