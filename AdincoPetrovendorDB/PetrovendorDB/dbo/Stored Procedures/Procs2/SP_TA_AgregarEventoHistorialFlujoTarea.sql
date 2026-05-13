-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 30/Marzo/2017
-- Description:	Permite agregar Actividad al Historial de la Operacion
-- =============================================
CREATE PROCEDURE  [dbo].[SP_TA_AgregarEventoHistorialFlujoTarea] 
	-- Add the parameters for the stored procedure here
		
	@Descripcion nvarchar(MAX),
	@IdOperacion int,
	@IdEstadoFlujoTarea int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	----- Agregar Historial ---------
	
	INSERT INTO TA_HistorialFlujoTarea(Descripcion, IdOperacion,IdEstadoFlujo, Fecha)
	VALUES(@Descripcion,@IdOperacion,@IdEstadoFlujoTarea,GETDATE())

END

