-- =============================================
-- Author:		Reyna Olvera
-- Create date: 02/03/18
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE CO_ExtraeDirectorOperativo
	-- Add the parameters for the stored procedure here
	@idContrato int,
@idUsuario int =0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select DO.idDirector as idDirector,NombreCompleto 
			from CO_DirectorContrato DC
			Join CO_DirectorOperaciones DO on DC.idDirector=DO.idDirector
			where idContrato=@idContrato;

END

