-- =============================================
-- Author:		Manuel Cruz
-- Create date: 26-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegEliminarUsuario]
	-- Add the parameters for the stored procedure here
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update dbo.S_Usuario
	set IsEliminado = 1,
	Activo = 0
	where IdUsuario = @IdUsuario

	select concat ( 'El usuario con el id ' , @IdUsuario , ' ha sido eliminado') as Mensaje

END

