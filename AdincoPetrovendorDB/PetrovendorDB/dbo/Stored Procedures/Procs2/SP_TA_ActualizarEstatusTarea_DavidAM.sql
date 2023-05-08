-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Actualiza el Estatus de la Tarea y 
-- Regresa la información del flujo de Tarea junto con todos los aprobadores involucrados
-- =============================================
--**************************************************************
-- Modified:      <Jose Roman>									
-- Updated date: <09/01/2018>									
-- Description: <Se agrega el guardado de la Firma Electronica y los parametros de contrato>
--**************************************************************
--**************************************************************
-- Modified:      <Alexander Gomez>									
-- Updated date: <08/03/2018>									
-- Description: <Se modifico la variable de las palabras del estatus>
--**************************************************************
create PROCEDURE [dbo].[SP_TA_ActualizarEstatusTarea_DavidAM] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdEstatus INT,
	@IdUsuario INT,
	@Comentario NVARCHAR(MAX),
	@IdFirma NVARCHAR(max),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/ 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE	@IdTarea INT;
	DECLARE @IdFlujoTarea INT;
	DECLARE @IdOperacionR INT;
	DECLARE @DescripcionH nvarchar(MAX)

	SET @IdOperacionR = @IdOperacion;

	
	SET	@IdTarea = (SELECT T.IdTarea 
					FROM TA_Tarea AS T
					INNER JOIN TA_TareaOperacion AS TA ON TA.IdTarea =T.IdTarea
					WHERE IdAprobador = @IdUsuario AND TA.IdOperacion = @IdOperacion)

	---Validar que la Tarea Tenga un Estatus Pendiente para poder actualizar 

	IF (SELECT IdEstatus FROM TA_Tarea WHERE IdTarea= @IdTarea) = 1   
		BEGIN 
			-- Actualizar Estatus de Tarea ---

			UPDATE TA_Tarea 
			SET IdEstatus =  @IdEstatus, 
				FechaCambioEstatus = GETDATE(),
				TA_Tarea.Comentario= @Comentario,
				IdFirma = @IdFirma
			WHERE IdTarea= @IdTarea
 
			
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

			SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario)+ ' ha ' + @ESTATUSTA + ' la Tarea'

			INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,2)


			--- Ejecutar el Cambio de Estatus General de la Operacion  -----

			EXEC SP_TA_CambiarEstatusFlujo @IdOperacionR 


			--- Obtener la información del flujo --- 

			SELECT DISTINCT TOO.IdOperacion, FT.IdFlujoTarea, FT.IdTipoFlujo,TOO.IdEstatusOperacion,TAE.Nombre, TOO.IdEstadoFlujo, TOO.IdTipoOperacion,TTO.NombreOperacion, U.IdUsuario, T.NoSecuencia, U.Nombre, U.Correo,T.IdEstatus, TOO.IdDocumento,TOO.IdAsignador, TOO.IdProveedor,ISNULL(T.Comentario,'') AS Comentario
			FROM TA_Tarea AS T
			INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdTarea =T.IdTarea
			INNER JOIN TA_Operacion AS TOO ON TAO.IdOperacion = TOO.IdOperacion
			INNER JOIN TA_FlujoTarea AS FT ON FT.IdFlujoTarea = TOO.IdFlujoTarea
			INNER JOIN S_Usuario AS U on u.IdUsuario = T.IdAprobador
			INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
			INNER JOIN TA_Estatus AS TAE ON TAE.IdEstatus = TOO.IdEstatusOperacion
			WHERE  TAO.IdOperacion = @IdOperacion
			ORDER BY NoSecuencia ASC 


		END 
	ELSE
	 SELECT 'ERROR DOBLE APROBACION' AS MENSAJE

	 --Actualizar en versión móvil

	 IF	EXISTS(SELECT 1 FROM Adinco.dbo.AM_Aprobacion WHERE IdTareaOrigen = @IdTarea) 
	 BEGIN
		--1 Pendiente
		--2 Aprobada
		--3 Rechazada
		IF @IdEstatus = 1
		BEGIN
			UPDATE Adinco.dbo.AM_Aprobacion
			SET IdStatusAprobacionM = @IdEstatus,
			FechaModificacion = NULL
			WHERE IdTareaOrigen = @IdTarea
		END
		IF @IdEstatus <> 1
		BEGIN
			UPDATE Adinco.dbo.AM_Aprobacion
			SET IdStatusAprobacionM = @IdEstatus,
			FechaModificacion = GETDATE(),
			ComentarioAprobacionRechazo = @Comentario
			WHERE IdTareaOrigen = @IdTarea
        END

     END
END