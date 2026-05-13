-- =============================================
-- Author:      <Daniel AC>
-- Create date: <02-08-19>
-- Description: Se actualiza numero de secuencia tomando como ultimo valor el idtarea
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_AgregarNuevoAprobadorFactura]  
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionFactura INT, 
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
        --SE SEBE BUSCAR EL TIPO DE FLUJO AL QUE PERTENECE 
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
        INSERT INTO dbo.TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion, AsignadoPor,MensajeAsignacion)
        VALUES('Aprobación de Factura',GETDATE(), 1, 1,0, @IdNuevoAprobador, @NoSecuencia,@IdOperacion, @IdUsuario, @MensajeAsignacion)
        SELECT @IdNuevoTarea = @@IDENTITY
        --- Agregar Evento Historial --- 
        DECLARE @Descripcion NVARCHAR(MAX)
         SET @Descripcion = 'El usuario '+
                            (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario)+ 
                            ' ha asignado como aprobador de la factura al usuario ' +
                            (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdNuevoAprobador) 
         INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
         VALUES(@Descripcion,@IdOperacion,GETDATE(),8)  
        SELECT 'SUCCESS',@IdNuevoTarea AS IdTarea
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
    
    
  
  

