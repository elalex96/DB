-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/10/2017
-- Description:	Para AppMovil extrae TipoAprobacion 
-- =============================================
CREATE PROCEDURE AM_ExtraeTipoAprobacion
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

	Select AMTA.TipoAprobacion as tipoAprobacion from AM_Aprobacion APro 
	inner join AM_TipoAprobacion AMTA on Apro.idtipoAprobacion = AMTA.idTipoaprobacion 
	where idUsuario =@idUser and IdStatusAprobacionM = @idEstatus and Apro.idtipoAprobacion=@idTipoAprobacion;
	
END

