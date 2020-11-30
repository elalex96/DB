-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/2018
-- Description:	Elimina a los directores
-- =============================================
CREATE PROCEDURE CO_ElminaDirectorOperacion
	-- Add the parameters for the stored procedure here
	@IdDirector int,
	@idUsuario int=0,
	@idContrato int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM CO_DirectorOperaciones WHERE (idDirector = @IdDirector)
END

