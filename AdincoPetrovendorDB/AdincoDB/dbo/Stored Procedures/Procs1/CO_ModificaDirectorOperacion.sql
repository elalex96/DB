-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/2018
-- Description:	Modifica los Directores
-- =============================================
CREATE PROCEDURE [dbo].[CO_ModificaDirectorOperacion]
	-- Add the parameters for the stored procedure here
@NombreCompleto nvarchar(Max),
@idDirector int,
@idUsuario  int=0,
@idContrato int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE CO_DirectorOperaciones SET NombreCompleto=@NombreCompleto WHERE idDirector = @idDirector

END

