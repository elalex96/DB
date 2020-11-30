-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/10/2017
-- Description:	Para AppMovil extrae NombreTarea
-- =============================================
CREATE PROCEDURE AM_ExtraeNombreTarea
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

Select Tatar.NombreTarea as tarea from AM_Aprobacion APro 
inner join TA_tarea TaTar on Apro.IdTareaOrigen = TaTar.IdTarea
 where idUsuario =@idUser and IdStatusAprobacionM = @idEstatus and Apro.idtipoAprobacion=@idTipoAprobacion;
END

