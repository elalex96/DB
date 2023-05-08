-- =============================================
-- Author:		Manuel Cruz
-- Create date: 12-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE sp_CO_EliminaRegistroGasto
	-- Add the parameters for the stored procedure here
@NumeroOperacion int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM [dbo].[CO_Registro]
      WHERE IdRegistro = @NumeroOperacion
END
