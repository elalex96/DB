
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 16-08-17
-- Description:	Agregue validación solo tomar tareas activas 
-- =============================================
create   PROCEDURE [dbo].[MPY_SP_NC_ActualizarEstatusNotaCredito]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,    
	@IdNotaCredito INT, 
    @Comentario NVARCHAR(MAX),
    @IdEstatus INT,
    @IdOperacion INT,   
	@IdTarea INT
 

AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET NOCOUNT ON;
    
    DECLARE @IdFlujoTarea INT;
    DECLARE @IdOperacionR INT;
    DECLARE @DescripcionH NVARCHAR(MAX);
    DECLARE @IdFactura INT;
	DECLARE @IdDocumento INT;
	DECLARE @IdEstatusActual INT 
	DECLARE @FECHA_CAMBIO_ESTATUS DATETIME

	-- SE OBTIENE EL NUMERO DE TAREA DEL APROBADOR ACTUAL 
  
   SELECT @IdEstatusActual=IdEstatus,@FECHA_CAMBIO_ESTATUS=FechaAprobacion  
   FROM MPY_MM_AceptacionNotaCredito		
  WHERE IdAceptacionNotaCredito = @IdNotaCredito

   IF @IdEstatusActual=1 --> PENDIENTE DE APROBAR 
   
   BEGIN 
	SET @FECHA_CAMBIO_ESTATUS = GETDATE()
	
	
	

		UPDATE dbo.MPY_MM_AceptacionNotaCredito
		SET IdEstatus = @IdEstatus,
			Comentario = @Comentario,
			IdAprobador = @IdUsuario,
			FechaAprobacion = GETDATE()
		WHERE IdAceptacionNotaCredito = @IdNotaCredito
						

		SELECT DISTINCT
			IdEstatusOperacion = @IdEstatus
			
			
	
	END 
	ELSE 
	BEGIN 
		SELECT 
			0,
			CONCAT('Ya haz realizado la aprobación de esta Nota de crédito el día ', 
			FORMAT(@FECHA_CAMBIO_ESTATUS,'dd/MM/yyyy hh:mm tt'),
			ISNULL((' Tu estatus de aprobación es: '+ (SELECT Nombre FROM dbo.TA_Estatus WHERE IdEstatus=@IdEstatusActual)),'Aprobación no encontrada'))
		

	END 

END;






