-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/10/2017
-- Description:	Para AppMovil extrae DocumentoAprobacion
-- =============================================
CREATE PROCEDURE AM_ExtraeDocumento
	-- Add the parameters for the stored procedure here
	@idUser int,
	@idEstatus int,
	@idTipoAprobacion int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  Select 
TaOpe.idDocumento as 'Documento' from AM_Aprobacion APro
inner join TA_tarea TaTar on Apro.IdTareaOrigen= TaTar.IdTarea
inner join TA_TareaOperacion TaTarOpe on TaTar.IdTarea=TaTarOpe.idTarea
inner join Ta_Operacion TaOpe on TaTarOpe.idoperacion=TaOpe.idOperacion
where idUsuario =@idUser and Apro.IdStatusAprobacionM = @idEstatus and Apro.idtipoAprobacion=@idTipoAprobacion


END

