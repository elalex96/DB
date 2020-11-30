
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 16-08-17
-- Description:	Agregue validación solo tomar tareas activas 
-- =============================================
CREATE   PROCEDURE [dbo].[SP_NC_ActualizarEstatusNotaCredito]
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
  
   SELECT @IdEstatusActual=IdEstatus,@FECHA_CAMBIO_ESTATUS=FechaCambioEstatus  
   FROM TA_Tarea		
   WHERE IdTarea = @IdTarea;

   IF @IdEstatusActual=1 --> PENDIENTE DE APROBAR 
   
   BEGIN 
	SET @FECHA_CAMBIO_ESTATUS = GETDATE()
	

 
		--ACTUALIZAR ESTATUS DEL APROBADOR 
		UPDATE TA_Tarea
		SET IdEstatus = @IdEstatus,
			FechaCambioEstatus = GETDATE(),
			TA_Tarea.Comentario = @Comentario
		WHERE IdTarea = @IdTarea;

		----Agregar Evento al Historial  ---

			DECLARE @ESTATUSTA NVARCHAR(MAX) = (SELECT Nombre FROM TA_Estatus WHERE IdEstatus = @IdEstatus)
			IF @ESTATUSTA = 'Aprobada'
			BEGIN
				SET @ESTATUSTA = 'Aprobado'
			END

			IF @ESTATUSTA = 'Rechazada'
			BEGIN
				SET @ESTATUSTA = 'Rechazado'
			END
			IF @ESTATUSTA = 'Vencida'
			BEGIN
				SET @ESTATUSTA = 'Vencido'
			END
			SET @DescripcionH = 'El Usuario ' +
								(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario) + ' ha ' +@ESTATUSTA + ' la Tarea.';
			
			IF @Comentario <> ''
			BEGIN
				SET @DescripcionH = @DescripcionH + ' Detalle: ' + @Comentario;
			END;

			INSERT INTO TA_HistorialFlujoTarea
			(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
			VALUES(@IdOperacion, GETDATE(), @DescripcionH, 2);
			
			--- Ejecutar el Cambio de Estatus General de la Operacion  -----

			EXEC SP_TA_CambiarEstatusFlujoNotaCredito @IdOperacion, @IdNotaCredito;
						

			SELECT DISTINCT
			TOO.IdEstatusOperacion,
			FT.IdTipoFlujo,
			TOO.IdDocumento,
			FT.IdFlujoTarea,
			TAE.Nombre,
			TOO.IdEstadoFlujo,
			TOO.IdTipoOperacion,
			TTO.NombreOperacion,
			TOO.IdOperacion,
			TOO.IdAsignador,
			TOO.IdProveedor			
		FROM TA_Operacion AS TOO				
			INNER JOIN TA_FlujoTarea AS FT
				ON FT.IdFlujoTarea = TOO.IdFlujoTarea
			INNER JOIN TA_TipoOperacion AS TTO
				ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
			INNER JOIN TA_Estatus AS TAE
				ON TAE.IdEstatus = TOO.IdEstatusOperacion
		WHERE TOO.IdOperacion = @IdOperacion				 
			
	
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





