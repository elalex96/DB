-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 30-03-17
-- Description:	 Actualiza el Estatus de la Tarea ha Cancelado y 
-- Regresa la información del flujo de Tarea junto con todos los aprobadores involucrados
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_CancelarTarea] 
	-- Add the parameters for the stored procedure here
	@IdOperacion int,
	@IdAsignador int,
	@Comentario nvarchar(MAX)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @DescripcionH  nvarchar(MAX)

	--- Actualizar la Operación Estatus General a Cancelado por Asignador, Actualizar Estatus del Flujo

		UPDATE TA_Operacion SET IdEstatusOperacion  = 6, IdEstadoFlujo = 5
		WHERE IdOperacion= @IdOperacion

    --- Actualizar la Tarea a Todos los Aprobadores que tienen el Estatus de Tarea Pendiente ---

		UPDATE TA_Tarea SET IdEstatus = 6 
		WHERE IdTarea IN (SELECT T.IdTarea 
						  FROM TA_Tarea AS T
						  INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdTarea = T.IdTarea
						  WHERE TAO.IdOperacion = @IdOperacion AND T.IdEstatus = 1)

    --- Agregar Comentario Cancelacion de Tarea---
	    INSERT INTO TA_ComentariosTareaCancelada(Descripcion,IdOperacion,IdUsuario)
		VALUES(@Comentario,@IdOperacion,@IdAsignador)


	--- Agregar Evento al Historia de la Operacion  ---
		
		SET @DescripcionH = 'El Usuario '+(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdAsignador) +' ha Cancelado la Tarea'

		INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
		VALUES(@IdOperacion,GETDATE(),@DescripcionH,5)

		SET @DescripcionH = 'Tarea Finalizada'
		INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
		VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

		   

	--- Obtener la información del Flujo Tarea -- 
		SELECT DISTINCT TOO.IdOperacion, FT.IdFlujoTarea, FT.IdTipoFlujo,TOO.IdEstatusOperacion,TAE.Nombre, TOO.IdEstadoFlujo, TOO.IdTipoOperacion,TTO.NombreOperacion, U.IdUsuario, TAA.NoSecuencia, U.Nombre, U.Correo,T.IdEstatus,TOO.IdDocumento
		FROM TA_Tarea AS T
		INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdTarea =T.IdTarea
		INNER JOIN TA_Operacion AS TOO ON TAO.IdOperacion = TOO.IdOperacion
		INNER JOIN TA_FlujoTarea AS FT ON FT.IdFlujoTarea = TOO.IdFlujoTarea
		INNER JOIN TA_Aprobador  AS TAA on TAA.IdUsuario= T.IdAprobador  AND TAA.IdFlujoTarea = FT.IdFlujoTarea
		INNER JOIN S_Usuario AS U on u.IdUsuario = T.IdAprobador
		INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion = TOO.IdTipoOperacion
		INNER JOIN TA_Estatus AS TAE ON TAE.IdEstatus = TOO.IdEstatusOperacion
		WHERE  TAO.IdOperacion = @IdOperacion
		ORDER BY NoSecuencia ASC 
		
END


