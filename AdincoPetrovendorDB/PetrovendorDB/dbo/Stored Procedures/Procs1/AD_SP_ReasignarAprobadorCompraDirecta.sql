USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ReasignarAprobadorCompraDirecta'
)
    DROP PROCEDURE AD_SP_ReasignarAprobadorCompraDirecta;
GO 
-- =============================================  
-- Author:  Daniel A Cruz  
-- Create date: 06-04-2021  
-- Description:  SP que reasigna una tarea a otra aprobador  
-- =============================================  
CREATE PROCEDURE [dbo].[AD_SP_ReasignarAprobadorCompraDirecta]   
 -- Add the parameters for the stored procedure here  
 @IdOperacion int,   
 @IdAprobador int,   
 @IdNuevoAprobador int,  
 @Comentario nvarchar(max)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
    
  DECLARE @IdTareaActual int   
  DECLARE @EstatusId int   
  DECLARE @IdTareaNueva int    
  DECLARE @Descripcion nvarchar(max)   
  
  SET NOCOUNT ON;  
  --- Obtener el IdTarea de la Tarea del Usuario Actual----  
  
    SELECT @IdTareaActual =T.IdTarea,
	@EstatusId=T.IdEstatus
    FROM TA_Tarea AS T 
    WHERE T.IdOperacion = @IdOperacion 
	AND T.IdAprobador = @IdAprobador

	IF ISNULL(@EstatusId,0)<>1 --EN APROBACIÓN
	BEGIN 
		SELECT 'ERROR_ESTATUS_DIF_ENAPRB','El aprobador actual, seleccionado ya tiene un estatus diferente de En aprobación, por lo tanto no es posible realizar el cambio solicitado'
		RETURN 
	END 

	IF ISNULL(@IdTareaActual,0)=0 --NO SE ENCONTRO TAREA
	BEGIN 
		SELECT 'ERROR_APROBADOR_NOENC','Cambio no disponible, ya que no se encontró información del aprobador seleccionado'
		RETURN 
	END 


  --- Agregar Tarea Usuario Nuevo ---   
   
   INSERT INTO TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion)  
   SELECT NombreTarea,GETDATE() AS FechaRegistro,IdEstatus,Activo, Visto,@IdNuevoAprobador AS IdAprobador,NoSecuencia,IdOperacion  
   FROM TA_Tarea AS T  
   WHERE T.IdTarea =  @IdTareaActual  
  
  SET @IdTareaNueva = (SELECT @@IDENTITY)  
  
 --- Agregar Relación Tarea Operacion ---  
  
  INSERT INTO TA_TareaOperacion(IdOperacion, IdTarea)  
  VALUES(@IdOperacion,@IdTareaNueva)  

 -- REPLICAR CAMBIO EN LA APROBACIÓN DE LA APP MOVIL
  EXEC dbo.Mobile_NotificacionPetrovendor @IdtareaIdentity = @IdTareaNueva  
  
  --ELIMINAR LA TAREA DEL APROBADOR ANTERIOR 
    DELETE TA_TareaOperacion 
	WHERE IdOperacion=@IdOperacion
	AND IdTarea = @IdTareaActual  

   DELETE TA_Tarea  
   WHERE IdTarea = @IdTareaActual  
   AND IdOperacion = @IdOperacion 

  --- Agregar Evento Historial ---   
  
   SET @Descripcion = 'Se reasignó aprobación del usuario '+  
       (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdAprobador)+   
       ' al usuario ' +  
       (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdNuevoAprobador)  +
	   ' , comentario: '+ @Comentario
         
   INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
   VALUES(@Descripcion,@IdOperacion,GETDATE(),8)  
      
 --- Enviar Datos del Nuevo Aprobador ---  
  
     SELECT 'SUCCESS'

	 -- MANDAR NOTIFICACIÓN A LOS APROBADORES  
			SELECT DISTINCT  
               TOO.IdOperacion,  
               FT.IdFlujoTarea,  
               FT.IdTipoFlujo,  
               TOO.IdEstatusOperacion,  
               TAE.Nombre AS NombreEstatus,  
               TOO.IdEstadoFlujo,  
               TOO.IdTipoOperacion,  
               TTO.NombreOperacion,  
               U.IdUsuario,  
               T.NoSecuencia,  
               U.Nombre AS NombreUsuario,  
               U.Correo,  
               T.IdEstatus AS EstatusAprobador,  
               TOO.IdDocumento,  
               TOO.IdAsignador,  
               TOO.IdProveedor,  
               ISNULL(T.Comentario, '') AS Comentario,
			   TOO.IdProveedor,
			   TOO.Descripcion AS DescripcionAprobacion			       
        FROM TA_Tarea AS T              
            LEFT JOIN TA_Operacion AS TOO  
                ON TOO.IdOperacion = T.IdOperacion  
            LEFT JOIN TA_FlujoTarea AS FT  
                ON FT.IdFlujoTarea = TOO.IdFlujoTarea  
            LEFT JOIN S_Usuario AS U  
                ON U.IdUsuario = T.IdAprobador  
            LEFT JOIN TA_TipoOperacion AS TTO  
                ON TTO.IdTipoOperacion = TOO.IdTipoOperacion  
            LEFT JOIN TA_Estatus AS TAE  
                ON TAE.IdEstatus = TOO.IdEstatusOperacion  
        WHERE TOO.IdOperacion =@IdOperacion  
        ORDER BY NoSecuencia ASC 
  
      
 END  
  
  