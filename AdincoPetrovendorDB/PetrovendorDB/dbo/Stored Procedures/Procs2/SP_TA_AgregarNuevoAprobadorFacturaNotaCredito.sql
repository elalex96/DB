USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_AgregarNuevoAprobadorFacturaNotaCredito'
)
    DROP PROCEDURE SP_TA_AgregarNuevoAprobadorFacturaNotaCredito;
GO 
/****** Object:  StoredProcedure [dbo].[SP_TA_AgregarNuevoAprobadorFactura]    Script Date: 23/03/2021 04:45:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Daniel AC>
-- Create date: <23-03-2021>
-- Description: Se agrega nuevo aprobador de nota de crédito
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_AgregarNuevoAprobadorFacturaNotaCredito]  
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido INT, 
@IdNuevoAprobador INT,
@IdNotaCredito INT,
@IdOperacion INT,
@MensajeAsignacion NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

     --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 
      DECLARE @IdESTATUSACTUAL INT 
	  DECLARE @IdEstatusUltimoAprobador INT 
	  DECLARE @NoSecuenciaUltimoAprobador INT 
	   DECLARE @IdEstatusAsignar INT 

     SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion

     IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
     BEGIN 

        --VALIDAR QUE EL NUEVO APROBADOR NO TENGA UNA TAREA ACTIVA
        DECLARE @ExisteTarea INT 
         SELECT @ExisteTarea= COUNT(IdTarea) FROM dbo.TA_Tarea 
         WHERE IdOperacion =@IdOperacion 
         AND IdAprobador=@IdNuevoAprobador 
         AND Activo=1

     IF ISNULL(@ExisteTarea,0) = 0
     BEGIN 

        --SE SEBE BUSCAR EL TIPO DE FLUJO AL QUE PERTENECE (SERIAL/PARALELO) 
        DECLARE @IdFlujoAprobacion INT 
        DECLARE @TipoFlujo INT 
        DECLARE @NoSecuencia INT 
        DECLARE @IdNuevoTarea INT 
        SELECT @IdFlujoAprobacion= IdFlujoTarea FROM  dbo.TA_Operacion WHERE IdOperacion =@IdOperacion
        SELECT @TipoFlujo=IdTipoFlujo FROM  dbo.TA_FlujoTarea WHERE IdFlujoTarea=@IdFlujoAprobacion
        ---1 SERIAL 
        ---2 PARALELO 
         SELECT @NoSecuencia=MAX(NoSecuencia) FROM dbo.TA_Tarea WHERE IdOperacion =@IdOperacion AND Activo=1
        --IF @TipoFlujo= 1 
        --BEGIN       
            SET @NoSecuencia=ISNULL(@NoSecuencia,0)+1
        --END 
        --ELSE 
        --BEGIN 
            --SET @NoSecuencia= 1
        --END  
		
		IF @TipoFlujo= 1 --> SERIAL
        BEGIN
			SET @IdEstatusAsignar=9 --> SIN INICIAR APROBACIÓN
        END 
        ELSE 
        BEGIN 
            SET @IdEstatusAsignar= 1 --> EN APROBACIÓN
        END     

        INSERT INTO dbo.TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion, AsignadoPor,MensajeAsignacion)
        VALUES('Aprobación de Nota de crédito',GETDATE(), @IdEstatusAsignar, 1,0, @IdNuevoAprobador, @NoSecuencia,@IdOperacion, @IdUsuario, @MensajeAsignacion)
        
		SELECT @IdNuevoTarea = @@IDENTITY

        --- Agregar Evento Historial --- 
        DECLARE @Descripcion NVARCHAR(MAX)
        SET @Descripcion = 'El usuario '+
                            (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario)+ 
                            ' ha asignado como aprobador de la nota de crédito al usuario ' +
                            (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdNuevoAprobador) 

         INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
         VALUES(@Descripcion,@IdOperacion,GETDATE(),8)  

         SELECT 'SUCCESS',@IdNuevoTarea AS IdTarea,(CASE WHEN @IdEstatusAsignar = 1 THEN 'SI' ELSE 'NO' END) AS Notificar,@IdNuevoAprobador AS IdAprobador 

     END 
     ELSE 
     BEGIN 
        SELECT 'YA_EXISTE_TAREA'
     END 
    END 
    ELSE 
    BEGIN
        DECLARE @EstatusActual NVARCHAR(MAX)
        SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL
        SELECT 'ESTATUS_NOENAPROBACION' AS Response,@EstatusActual AS EstatusActual
    END 
END
    
    
  
  

