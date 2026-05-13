-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 05-01-18
-- Description:	 Actualiza el Estatus de de la APROBACI�N DE LA OPERACI�N X 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ActualizarEstatusAprobacionOperacion] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdContrato	INT=0,
	@IdSubcontratista INT =0,
	@FechaRegistro DATETIME= '25-01-2017 00:00',
	@Resultado INT OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdEstatus INT
	DECLARE @CountTarea INT
	DECLARE @CountEstPen INT
	DECLARE @CountEstApr INT
	DECLARE @CountEstRech INT
	DECLARE @CountEstCanc INT
	--DECLARE @Resultado INT = 1
	DECLARE @DescripcionH NVARCHAR(MAX)
	DECLARE @TIPO_OPERACION NVARCHAR(300)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	---Glosario ---
	-- 1 Pendiente
	-- 2 Aceptada
	-- 3 Rechazada
	-- 4 Vencida
	-- 7 Reasignada
	

    SET @CountTarea =  (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM MA_Operacion TAO
	INNER JOIN MA_OperacionDetalle AS OD ON OD.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion = @IdOperacion AND OD.IdEstatus <> 7 )

	--- OD.IdEstatus <> 7 ---> Es Cancelado por ReASIGNACIÓN ---@IdOperacion

	SET @CountEstPen = (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM MA_Operacion TAO
	INNER JOIN MA_OperacionDetalle AS OD ON OD.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion =@IdOperacion   AND OD.IdEstatus = 1)
	
	SET @CountEstApr = (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM MA_Operacion TAO
	INNER JOIN MA_OperacionDetalle AS OD ON OD.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion = @IdOperacion  AND OD.IdEstatus = 2)


	SET @CountEstRech = (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM MA_Operacion TAO
	INNER JOIN MA_OperacionDetalle AS OD ON OD.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion = @IdOperacion  AND OD.IdEstatus = 3)

		
	BEGIN
		IF (@CountEstRech > 0)
			BEGIN
			--- Actualizar el Estatus de la Operacion ---> Se cancela la Tarea 
			UPDATE MA_Operacion SET IdEstatusOperacion = 3,  @Resultado = 3 WHERE IdOperacion = @IdOperacion
			---Actualizar los estatus que aun no a sido aprobados(Pendientes) ---> Se cancelan por cancelaci�n las tareas no evaluadas
			UPDATE dbo.MA_OperacionDetalle SET IdEstatus= 4 
			WHERE IdOperacionDetalle IN (SELECT OD.IdOperacionDetalle
							  FROM MA_OperacionDetalle AS OD
							  INNER JOIN MA_Operacion AS TAO ON TAO.IdOperacion = OD.IdOperacion
							  WHERE TAO.IdOperacion = @IdOperacion AND OD.IdEstatus= 1)
	
			--- HISTORIAL ---
			
			 
			(SELECT @TIPO_OPERACION= OT.Nombre FROM dbo.MA_Flujo F
			INNER JOIN dbo.MA_Operacion O ON O.IdFlujo=F.IdFlujo
			INNER JOIN dbo.MA_TipoOperacion OT ON OT.IdTipoOperacion = F.IdTipoOperacion
			WHERE O.IdOperacion=@IdOperacion)

			SET @DescripcionH = 'Aprobaci�n de ' ++ISNULL(@TIPO_OPERACION,'') + ' RECHAZADA'

			INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle,IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,2) -- IdEstadoFlujo= 2 --> Tarea En Aprobaci�n


			SET @DescripcionH = 'Se ha finalizado aprobaci�n de ' ++ISNULL(@TIPO_OPERACION,'')

			INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle,IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,7) -- IdEstadoFlujo= 7 --> Tarea Finalizada
			
			END  
		ELSE
			IF (@CountEstApr = @CountTarea)
			BEGIN
				--Actualizar el Estatus de la Operacion y el Estado del Flujo ---> Tarea Aprobada

				UPDATE MA_Operacion SET IdEstatusOperacion = 2, @Resultado = 2 WHERE IdOperacion = @IdOperacion

					
				--- HISTORIAL ---
					
					(SELECT @TIPO_OPERACION= OT.Nombre FROM dbo.MA_Flujo F
					INNER JOIN dbo.MA_Operacion O ON O.IdFlujo=F.IdFlujo
					INNER JOIN dbo.MA_TipoOperacion OT ON OT.IdTipoOperacion = F.IdTipoOperacion
					WHERE O.IdOperacion=@IdOperacion)

					
					SET @DescripcionH = 'Aprobaci�n de ' ++ISNULL(@TIPO_OPERACION,'') + ' APROBADA'
					
					INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle, IdEstadoFlujo)
					VALUES(@IdOperacion,GETDATE(),@DescripcionH,2)-- IdEstadoFlujo= 2 --> Tarea En Aprobaci�n

					SET @DescripcionH = 'Se ha finalizado aprobaci�n de ' +ISNULL(@TIPO_OPERACION,'') 

					INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle,IdEstadoFlujo)
					VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)-- IdEstadoFlujo= 7 --> Tarea Finalizada

			END 
			ELSE
			UPDATE MA_Operacion SET IdEstatusOperacion = 1, @Resultado = 1 WHERE IdOperacion = @IdOperacion
	
			
	END
	
	

 END