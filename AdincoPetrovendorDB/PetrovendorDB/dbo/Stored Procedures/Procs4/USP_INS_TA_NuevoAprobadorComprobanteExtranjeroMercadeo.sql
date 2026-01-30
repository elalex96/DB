USE [Petrovendor]
GO
DROP PROC IF EXISTS USP_INS_TA_NuevoAprobadorComprobanteExtranjeroMercadeo
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Daniel AC>
-- Create date: <28-01-2026>
-- Description: Se agrega nueva tarea de aprobación para comprobante extranjero mercadeo
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_TA_NuevoAprobadorComprobanteExtranjeroMercadeo]  
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido INT, 
@IdNuevoAprobador INT,
@IdOperacion INT,
@MensajeAsignacion NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
     --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 
    DECLARE @IdESTATUSACTUAL INT 
	DECLARE @ExisteTarea INT
	DECLARE @IdFlujoAprobacion INT 
	DECLARE @TipoFlujo INT 
	DECLARE @NoSecuencia INT 
	DECLARE @IdNuevoTarea INT 
	DECLARE @Descripcion NVARCHAR(MAX)
	DECLARE @EstatusActual NVARCHAR(MAX)

     SELECT @IdESTATUSACTUAL= IdEstatusOperacion 
	 FROM dbo.TA_Operacion 
	 WHERE IdOperacion=@IdOperacion

     IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
     BEGIN 
        --VALIDAR QUE EL NUEVO APROBADOR NO TENGA UNA TAREA ACTIVA
         
         SELECT @ExisteTarea= COUNT(IdTarea) 
		 FROM dbo.TA_Tarea 
         WHERE IdOperacion =@IdOperacion 
         AND IdAprobador=@IdNuevoAprobador 
         AND Activo=1

		 IF ISNULL(@ExisteTarea,0) = 0 --> NO EXISTE TAREA ENTONCE SI AGREGAR NUEVA TAREA
		 BEGIN 
			--SE SEBE BUSCAR EL TIPO DE FLUJO AL QUE PERTENECE LA APROBACIÓN ACTUAL
			
			SELECT @IdFlujoAprobacion= IdFlujoTarea 
			FROM  dbo.TA_Operacion
			WHERE IdOperacion =@IdOperacion

			SELECT @TipoFlujo=IdTipoFlujo 
			FROM  dbo.TA_FlujoTarea 
			WHERE IdFlujoTarea=@IdFlujoAprobacion

			---1 SERIAL 
			---2 PARALELO 
			 SELECT @NoSecuencia=MAX(NoSecuencia) 
			 FROM dbo.TA_Tarea 
			 WHERE IdOperacion =@IdOperacion 
			 AND Activo=1
			      
			SET @NoSecuencia=ISNULL(@NoSecuencia,0)+1
			
			--AGREGAR NUEVA TAREA
			INSERT INTO dbo.TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion, AsignadoPor,MensajeAsignacion)
			VALUES('Aprobación de Comprobante de extranjero',GETDATE(), 1, 1,0, @IdNuevoAprobador, @NoSecuencia,@IdOperacion, @IdUsuario, @MensajeAsignacion)
			
			SELECT @IdNuevoTarea = @@IDENTITY

			--- AGREGAR EVENTO HISTORIAL --- 
			SET @Descripcion = 'El usuario '+
								(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario)+ 
								' ha asignado como aprobador del Comprobante de extranjero al usuario ' +
								(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdNuevoAprobador) 

		    INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			VALUES(@Descripcion,@IdOperacion,GETDATE(),8) 
			 
			SELECT 'SUCCESS' AS Response,
			@IdNuevoTarea AS IdTarea
		 END 
     ELSE 
     BEGIN 
        SELECT 'YA_EXISTE_TAREA' AS Response
     END 
    END 
    ELSE 
    BEGIN

        SELECT @EstatusActual=ISNULL(@EstatusActual,'')
		FROM  TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL

        SELECT 'ESTATUS_NOENAPROBACION' AS Response,
		@EstatusActual AS EstatusActual
    END 
END
    
    
