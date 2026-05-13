
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <07-04-2021>  
-- Description: Cambiar el flujo de aprobación de una compra directa
-- =============================================  
CREATE PROCEDURE [dbo].[AD_SP_AgregarNuevoFlujoAprobacionCompraDirecta]    
@IdProveedor INT,  
@IdUsuario INT,  
@IdNuevoFlujoAprobacion INT,  
@IdOperacion INT,  
@MensajeAsignacion NVARCHAR(MAX)  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
 DECLARE @FECHAMODIFICACION DATETIME  = GETDATE()  
 DECLARE @NombreFlujoAnterior NVARCHAR(MAX)   
 DECLARE @NombreFlujoNuevo  NVARCHAR(MAX)   
 DECLARE @Contador INT 
 DECLARE @Incremento INT 
 DECLARE @TareaIdRow INT 
 CREATE TABLE #OLD_APROBADORES(IdTarea INT, IdAprobador INT, IdOperacion INT, NoSecuencia INT)  
 CREATE TABLE #NEW_APROBADORES(Id INT IDENTITY(1,1), IdTarea INT)  
  --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN   
  
   DECLARE @IdESTATUSACTUAL INT   
  
  SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion  
  IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN  
  BEGIN  
    
  
  INSERT INTO #OLD_APROBADORES  
  SELECT IdTarea,IdAprobador, IdOperacion, NoSecuencia FROM TA_Tarea WHERE IdOperacion= @IdOperacion AND Activo=1  
  
  /*NOMBRE FLUJO ANTERIOR*/
  SELECT @NombreFlujoAnterior=FT.Nombre
  FROM TA_FlujoTarea AS FT  
  INNER JOIN TA_Operacion AS O ON O.IdFlujoTarea = FT.IdFlujoTarea  
  WHERE O.IdOperacion = @IdOperacion;  

  /*NOMBRE FLUJO NUEVO*/
  SELECT @NombreFlujoNuevo=FT.Nombre
  FROM TA_FlujoTarea AS FT  
  WHERE FT.IdFlujoTarea = @IdNuevoFlujoAprobacion; 

  INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo) 
  VALUES(
  CONCAT('Se ha cambiado el flujo de aprobación: ',
  ISNULL(@NombreFlujoAnterior,''),' a ',
  ISNULL(@NombreFlujoNuevo,''), ', comentario: ',@MensajeAsignacion),
  @IdOperacion,
  @FECHAMODIFICACION,
  8 --> REASIGNACIÓN DE TAREA   
  )

  -- AGREGAR AL HISTORIAL LOS APROBADORES ELIMINADOS  
  INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
  SELECT    
  CONCAT('El usuario ',ISNULL(UE.Nombre,' Administrador'),' ha eliminado al usuario ' , ISNULL(UA.Nombre,' usuario no identificado '),  ' de la aprobación - Por cambio de flujo de aprobación'),  
  @IdOperacion,  
  @FECHAMODIFICACION,  
  10--> ESTATUS DE ELIMINACIÓN DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=10  
  FROM dbo.TA_Tarea  T  
  LEFT JOIN dbo.S_Usuario UA ON UA.IdUsuario=T.IdAprobador  
  LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL  
  WHERE T.Activo=1  
  AND T.IdOperacion=@IdOperacion   
  
	--APROBADORES ACTUALES PASARLOS A ELIMINADOS   --> AQUI SE TIENE QUE ELIMINAR LAS TAREAS POR QUE NO SE TIENE CONTENPLADO EL BIT DE ELIMINADO EN LAS CONSULTAS

	  DELETE TA_TareaOperacion 
	  WHERE IdOperacion=@IdOperacion

	  DELETE TA_Tarea
	  WHERE IdOperacion=@IdOperacion
  
	  ---ACTUALIZAR EL NUEVO FLUJO DE APROBACION EN LA OPERACION  
	  UPDATE dbo.TA_Operacion   
	  SET IdEstadoFlujo=1,  
	  IdFlujoTarea=@IdNuevoFlujoAprobacion  
	  WHERE IdOperacion=@IdOperacion    
  
	  --AGREGAR NUEVOS APROBADORES   
	  INSERT INTO dbo.TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion, AsignadoPor,MensajeAsignacion)   
	  SELECT 'Compra Directa',@FECHAMODIFICACION, 1, 1,0, IdUsuario, NoSecuencia,@IdOperacion, @IdUsuario, @MensajeAsignacion  
	  FROM dbo.TA_Aprobador   
	  WHERE IdFlujoTarea=@IdNuevoFlujoAprobacion  
  
  ---AGREGAR AL HISTORIAL LOS NUEVOS APROBADORES   
	  INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
	  SELECT    
	  CONCAT('El usuario ',ISNULL(UE.Nombre,' Administrador'),'  ha asignado como aprobador al usuario  ' , ISNULL(UA.Nombre,' usuario no identificado ')),  
	  @IdOperacion,  
	  @FECHAMODIFICACION,  
	  8--> REASIGNACIÓN DE TAREA   
	  FROM dbo.TA_Aprobador A  
	  LEFT JOIN dbo.S_Usuario UA ON UA.IdUsuario=A.IdUsuario  
	  LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL  
	  WHERE A.IdFlujoTarea=@IdNuevoFlujoAprobacion  


	  ---> CREAR LAS NUEVAS TAREAS EN LA APP MOVIL y AGREGAR LA RELACIÓN TAREA OPERACION
	  INSERT INTO #NEW_APROBADORES(IdTarea)
	  SELECT    
	  T.IdTarea
	  FROM dbo.TA_Tarea  T  	   
	  WHERE T.Activo=1  
	  AND T.IdOperacion=@IdOperacion 

	  SET @Contador =(SELECT COUNT(1) FROM #NEW_APROBADORES);
	  SET @Incremento =1 

	  WHILE @Contador>=@Incremento
	  BEGIN
				SELECT @TareaIdRow=IdTarea FROM #NEW_APROBADORES WHERE Id=@Incremento
				--INSERTAR LOS NUEVAS TAREAS 
				INSERT INTO TA_TareaOperacion(IdTarea,IdOperacion)
				VALUES(@TareaIdRow,@IdOperacion)		
						
		        EXEC dbo.Mobile_NotificacionPetrovendor @IdtareaIdentity = @TareaIdRow  

		SET @Incremento =@Incremento+1
	  END 

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
  ELSE   
  BEGIN  
  DECLARE @EstatusActual NVARCHAR(MAX)  
  SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL  
  SELECT 'ESTATUS_NOENAPROBACION' AS Response,@EstatusActual AS EstatusActual  
  END   
   
  
END  
  
   