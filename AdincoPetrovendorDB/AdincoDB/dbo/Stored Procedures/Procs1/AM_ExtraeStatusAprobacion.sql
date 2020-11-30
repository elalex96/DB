-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/10/2017
-- Description:	Para AppMovil extrae StatusAprobacion 
-- =============================================
CREATE PROCEDURE AM_ExtraeStatusAprobacion
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


	Select Amst.Status as status from AM_Aprobacion APro
	 inner join AM_statusAprobacionM AMST on Apro.IdStatusAprobacionM = AMST.IdStatusAprobacionM
	 where idUsuario =@idUser and Apro.IdStatusAprobacionM = @idEstatus and Apro.idtipoAprobacion=@idTipoAprobacion
END

