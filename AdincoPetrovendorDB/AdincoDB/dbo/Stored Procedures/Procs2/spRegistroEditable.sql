-- =============================================
-- Author:		Miguel Gomez
-- Create date: 29 01 2015
-- Description:	Verfica posibilidad de edición
-- =============================================
CREATE PROCEDURE [dbo].[spRegistroEditable] 
	-- Add the parameters for the stored procedure here
	@IdRegistro int = 0, 
	@IdUsuario int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @IdRegistro, @IdUsuario
END

