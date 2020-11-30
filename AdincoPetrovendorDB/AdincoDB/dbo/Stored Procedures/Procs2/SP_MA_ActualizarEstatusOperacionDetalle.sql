-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Actualizar estatus de aprobación de operación detalle
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_ActualizarEstatusOperacionDetalle]
-- Add the parameters for the stored procedure here
@Idoperacion INT,
@IdOperacionDetalle INT,
@IdUsuario INT,
@IdEstatus INT,
@Comentario NVARCHAR(MAX),
@IdFirma NVARCHAR(300),
@IdContrato	INT = 0,
@IdSubcontratista INT = 0,
@FechaRegistro DATETIME = '26-01-2017 00:00:00'

AS
BEGIN
    SET NOCOUNT ON;
	--DECLARE @IdOperacionDetalle INT 
	DECLARE @EstatusOperacion INT =0
	DECLARE @DescripcionH NVARCHAR(MAX)
	DECLARE @TIPO_OPERACION NVARCHAR(300)
	 --SELECT @IdOperacionDetalle = OD.IdOperacionDetalle 
		--			FROM dbo.MA_OperacionDetalle AS OD
		--			WHERE OD.IdAprobador = 2 AND OD.IdOperacion = 6

	IF (SELECT IdEstatus FROM MA_OperacionDetalle WHERE IdOperacionDetalle= @IdOperacionDetalle AND IdOperacion=@Idoperacion) = 1   
		BEGIN 
			---ACTUALIZAR ESTATUS 
			UPDATE MA_OperacionDetalle 
			SET IdEstatus =  @IdEstatus,
			FechaCambioEstatus = GETDATE(),
			IdFirma=@IdFirma,
			Comentario=@Comentario
			WHERE IdOperacionDetalle= @IdOperacionDetalle


			 (SELECT @TIPO_OPERACION= OT.Nombre FROM dbo.MA_Flujo F
			INNER JOIN dbo.MA_Operacion O ON O.IdFlujo=F.IdFlujo
			INNER JOIN dbo.MA_TipoOperacion OT ON OT.IdTipoOperacion = F.IdTipoOperacion
			WHERE O.IdOperacion=@IdOperacion)

			SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM dbo.AP_Usuario WHERE UsuarioID=@IdUsuario) 
			+ ' ha '+ + (SELECT Nombre FROM dbo.MA_Estatus WHERE IdEstatus = @IdEstatus) + ' la operación ' +@TIPO_OPERACION

			INSERT INTO MA_HistorialOperacion(IdOperacion,CreadoEl,Detalle, IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,2) --IdEstadoFlujo= 2 --> Tarea En Aprobación 

			DECLARE @FECHA_DATE DATETIME
			SET @FECHA_DATE = GETDATE()
			
			EXEC SP_MA_ActualizarEstatusAprobacionOperacion @IdOperacion,0,0,@FECHA_DATE,@EstatusOperacion OUTPUT
            
			SELECT 'SUCCESS', @EstatusOperacion,@IdOperacionDetalle

		END 
	ELSE 
		BEGIN 		
			 SELECT 'APROBACION_REALIZADA_CON_ANTERIORIDAD' AS MENSAJE, @EstatusOperacion
		END 

END;

