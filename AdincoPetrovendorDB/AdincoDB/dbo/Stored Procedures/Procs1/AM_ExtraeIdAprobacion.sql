-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/10/2017
-- Description:	Para AppMovil extrae Idde Aprobacion
-- =============================================
CREATE PROCEDURE AM_ExtraeIdAprobacion
	-- Add the parameters for the stored procedure here
	@idUser int,
	@idEstatus int,
	@idTipoAprobacion int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select idAprobacion from AM_Aprobacion where idusuario =@idUser and IdStatusAprobacionM = @idEstatus and idtipoAprobacion=@idTipoAprobacion
END

