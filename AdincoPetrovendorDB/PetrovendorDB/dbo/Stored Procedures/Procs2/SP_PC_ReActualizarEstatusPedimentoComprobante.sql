-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 03/04/2018
-- Description:	Permite reactualizar el estatus de pedimento comprobante 
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_PC_ReActualizarEstatusPedimentoComprobante] 
	-- Add the parameters for the stored procedure here

@IdUsuario INT, 
@IdOperacion INT,
@IdProveedor INT, 
@IdContrato INT
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE  @DESCRIPCION NVARCHAR(MAX) ='Se reinicio Aprobación de Pedimento/Comprante Extranjero'  
	INSERT INTO TA_HistorialFlujoTarea(Descripcion, IdOperacion, Fecha,IdEstadoFlujo)
	VALUES(@DESCRIPCION,@IdOperacion, GETDATE(),6)
	 
	UPDATE TA_Operacion 
	SET IdEstatusOperacion = 1,
	FechaModificacion=NULL,
	Descripcion=NULL
	WHERE IdOperacion = @IdOperacion

	UPDATE TA_Tarea 
	SET IdEstatus = 1,
	Visto = 0,
	Comentario='',
    FechaCambioEstatus=NULL
	WHERE IdOperacion = @IdOperacion


	DECLARE @IdFlujoAprobacion int = (SELECT IdFlujoTarea
									  FROM dbo.TA_Operacion 
									  WHERE IdOperacion=@IdOperacion)

	
	---IdTipoOperacion --> Operación de Aprobación Factura


	SELECT @IdFlujoAprobacion AS RESPONSE

END
 
