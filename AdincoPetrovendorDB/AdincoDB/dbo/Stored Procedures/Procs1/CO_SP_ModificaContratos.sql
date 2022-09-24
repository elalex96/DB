-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/10/2017
-- Description:	Para AppMovil extrae DescripcionAprobacion
-- =============================================
CREATE PROCEDURE AM_ExtraeDescripcion
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

 Select descripcion from AM_Aprobacion
  where idUsuario =@idUser and IdStatusAprobacionM = @idEstatus and idtipoAprobacion=@idTipoAprobacion
END

