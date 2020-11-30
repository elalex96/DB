-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 - UPDATE 04/09/2019
-- Description:	Permite agregar un condicion a un flujo de tareas
-- Solo reiniciar tareas con estatus activos 
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_FI_ReActualizarEstatusAceptacionFactura_VU] 
	-- Add the parameters for the stored procedure here

@IdUsuario int, 
@IdAceptacionPedido int,
@IdOperacion int

 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	


	DECLARE @IdAceptacionFactura int = (SELECT IdAceptacionFactura 
						  FROM MM_AceptacionFactura 
						  WHERE IdAceptacionPedido = @IdAceptacionPedido)

	 
	UPDATE MM_AceptacionFactura 
	SET [IdEstatusXML] = 1,
	[IdEstatusPDF] = 1,
	[ModificadoPor]  = @IdUsuario,
	[ModificadoEl] = getdate()
	WHERE IdAceptacionFactura = @IdAceptacionFactura

	DECLARE  @DESCRIPCION NVARCHAR(MAX) ='Se reinicio Aprobación de Factura'  
	INSERT INTO TA_HistorialFlujoTarea(Descripcion, IdOperacion, Fecha,IdEstadoFlujo)
	VALUES(@DESCRIPCION,@IdOperacion, GETDATE(),6)


	UPDATE TA_Operacion 
	SET IdEstatusOperacion = 1,
	FechaModificacion=NULL,
	Descripcion=NULL
	WHERE IdOperacion = @IdOperacion

	UPDATE TA_Tarea 
	SET IdEstatus = 1,
	Visto = 0
	WHERE IdOperacion = @IdOperacion
	AND Activo=1 --> SOLO ACTUALIZAR TAREAS ACTIVAS


	DECLARE @IdFlujoAprobacion int = (SELECT IdFlujoTarea
									  FROM dbo.TA_Operacion 
									  WHERE IdOperacion=@IdOperacion)

	
	---IdTipoOperacion --> Operación de Aprobación Factura


	SELECT @IdAceptacionFactura,@IdFlujoAprobacion AS RESPONSE 

END
 
