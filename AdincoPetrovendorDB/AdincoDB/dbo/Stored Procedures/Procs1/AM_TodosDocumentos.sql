-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/10/2017
-- Description:	Para AppMovil extrae todos DocumentoAprobacion en pendiente
-- =============================================
CREATE PROCEDURE AM_TodosDocumentos
	-- Add the parameters for the stored procedure here
	@idUser int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select 
TaOpe.idDocumento as 'Documento' from AM_Aprobacion APro
inner join TA_tarea TaTar on Apro.IdTareaOrigen= TaTar.IdTarea
inner join TA_TareaOperacion TaTarOpe on TaTar.IdTarea=TaTarOpe.idTarea
inner join Ta_Operacion TaOpe on TaTarOpe.idoperacion=TaOpe.idOperacion
where idUsuario =@idUser and Apro.IdStatusAprobacionM = 1
END

