-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 30-01-2018
-- Description:	 Actualiza el Estatus de la Tarea ha Cancelado 
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MA_CancelarAprobacion] 
	-- Add the parameters for the stored procedure here
	@IdOperacion int,
	@IdAsignador int,
	@Comentario nvarchar(MAX),
	@IdContrato INT, 
	@IdSubcontratista INT, 
	@FechaRegistro DATETIME


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @DescripcionH  nvarchar(MAX)
		DECLARE @ComentarioCancelacion nvarchar(MAX)
		DECLARE @FechaCancelacion DATETIME
	--- Actualizar la Operación Estatus General a Cancelado por Asignador, Actualizar Estatus del Flujo
		SET @FechaCancelacion = GETDATE()
		UPDATE MA_Operacion SET IdEstatusOperacion  = 6, FechaModificacion=@FechaCancelacion
		WHERE IdOperacion= @IdOperacion

    --- Actualizar la Tarea a Todos los Aprobadores que tienen el Estatus de Tarea Pendiente ---

		UPDATE dbo.MA_OperacionDetalle SET IdEstatus = 6, FechaCambioEstatus=@FechaCancelacion
		WHERE IdOperacionDetalle IN (SELECT OD.IdOperacionDetalle 
						  FROM dbo.MA_OperacionDetalle AS OD					  
						  WHERE OD.IdOperacion = @IdOperacion AND OD.IdEstatus = 1)

    

	--- Agregar Evento al Historia de la Operacion  ---
		DECLARE @TIPO_OPERACION NVARCHAR(300)
		 (SELECT @TIPO_OPERACION= OT.Nombre FROM dbo.MA_Flujo F
			INNER JOIN dbo.MA_Operacion O ON O.IdFlujo=F.IdFlujo
			INNER JOIN dbo.MA_TipoOperacion OT ON OT.IdTipoOperacion = F.IdTipoOperacion
			WHERE O.IdOperacion=@IdOperacion)
		
		SET @DescripcionH = 'El Usuario '+(SELECT Nombre FROM dbo.AP_Usuario WHERE UsuarioID = @IdAsignador) +' ha Cancelado la Aprobación de '+@TIPO_OPERACION
		
		INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle)
		VALUES(@IdOperacion,@FechaCancelacion,@DescripcionH)

		SET @ComentarioCancelacion = 'Comentario de Cancelación: '+ @Comentario
		INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle)
		VALUES(@IdOperacion,@FechaCancelacion,@ComentarioCancelacion)
		
		SET @DescripcionH = 'Aprobación Finalizada'
		INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle)
		VALUES(@IdOperacion,@FechaCancelacion,@DescripcionH)


		SELECT 'SUCCESS'		
END



