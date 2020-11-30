-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/2018
-- Description:	Elimina la relacion de un director con algun contrato
-- =============================================
CREATE PROCEDURE CO_EliminaDirectorContrato
	-- Add the parameters for the stored procedure here
	@idDirectorContrato int,
	@idUsuario int=0,
	@idContrato int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM CO_DirectorContrato WHERE (idDirectorContrato = @idDirectorContrato)
END

