USE Petrovendor 
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ReasignarAprobadorComprobanteExtranjero'
)
    DROP PROCEDURE AD_SP_ReasignarAprobadorComprobanteExtranjero
GO
-- =============================================  
-- Author:  Daniel AC
-- Create date: 07-04-2017  
-- Description:  SP que reasigna una tarea a otra aprobador de un comprobante extranjero  
-- =============================================  
-- =============================================
-- Author:		DANIEL AC
-- Create date: 15/12/2025
-- Description:	Se elimina correo de notificaciones directamente desde la tabla TA_CorreoServidor y se envia correo por el sdk
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ReasignarAprobadorComprobanteExtranjero]   
 -- Add the parameters for the stored procedure here  
 @IdOperacion int,   
 @IdTareaActual int,   
 @IdNuevoAprobador int,  
 @Comentario nvarchar(max),
 @IdComprobante int 
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
    
  DECLARE @EstatusId int   
  DECLARE @IdTareaNueva int    
  DECLARE @Descripcion nvarchar(max)   
  DECLARE @IdAprobador INT;
  DECLARE @DominioProcura NVARCHAR(500) = (SELECT URL FROM TA_Dominios WHERE IdDominio = 2) --> CTE DOMINIO PROCURA

   DECLARE   
   @CONTTOTAL    INT,  
   @CONT     INT,     
   @IDAPROBPARALELO  INT,  
   @DescripcionH   NVARCHAR(MAX),  
   @NOMBRESUBCONTRATISTA NVARCHAR(MAX),  
   @NOMBRESIGAPROBADOR  NVARCHAR(MAX),  
   @CORREOSIGAPROBADOR  NVARCHAR(MAX),  
   @CORREOSIG    NVARCHAR(MAX),  
   @TIPOFLUJO INT, 
   @IDSIGAPROBADOR INT,
   @IDNOTIFICACION   NVARCHAR(MAX);  
   DECLARE @APROBADORESTABLE  TABLE(ID INT IDENTITY(1,1),IdAprobador INT, Nombre NVARCHAR(1000), Correo NVARCHAR(MAX));  

    CREATE TABLE #TemporalCorreosUsuario (  
	Para VARCHAR(500),  
	Asunto VARCHAR(500),  
	Mensaje NVARCHAR(MAX),  
	De VARCHAR(200),
	CreadoPor INT
	);  

  --- Obtener el IdTarea de la Tarea del Usuario Actual----  

    SELECT @IdAprobador =T.IdAprobador,
	@EstatusId=T.IdEstatus
    FROM TA_Tarea AS T 
    WHERE T.IdOperacion = @IdOperacion 
	AND T.IdTarea = @IdTareaActual

	IF ISNULL(@EstatusId,0)<>1 --EN APROBACIÓN
	BEGIN 
		SELECT 'ERROR_ESTATUS_DIF_ENAPRB','El aprobador actual, seleccionado ya tiene un estatus diferente de En aprobación, por lo tanto no es posible realizar el cambio solicitado'
		RETURN 
	END 

	IF ISNULL(@IdTareaActual,0)=0 --NO SE ENCONTRO LA TAREA
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
  
  
  --ELIMINADO LOGICO DE LA TAREA DEL APROBADOR ANTERIOR 
  UPDATE dbo.TA_Tarea  
  SET Activo = 0,
  IdEstatus= 7--> Cancelado por Reasignacion
  WHERE IdOperacion = @IdOperacion
  AND IdTarea = @IdTareaActual 


  --- Agregar Evento Historial ---   
  
   SET @Descripcion = 'Se reasignó aprobación del usuario '+  
       (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdAprobador)+   
       ' al usuario ' +  
       (SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdNuevoAprobador)  +
	   ' , comentario: '+ @Comentario
         
   INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
   VALUES(@Descripcion,@IdOperacion,GETDATE(),8)  
       
    ---> NOTIFICAR A LOS USUARIOS CORRESPONDIENTES 
	BEGIN
	 -- MANDAR NOTIFICACIÓN A LOS APROBADORES 	  		
	SET @TIPOFLUJO = (SELECT TOP 1  
         TFT.IdTipoFlujoTarea  
        FROM dbo.TA_Operacion AS OP  
         JOIN dbo.TA_FlujoTarea AS FT  
          ON OP.IdFlujoTarea = FT.IdFlujoTarea
         JOIN dbo.TA_TipoFlujoTarea AS TFT  
          ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea 
        WHERE OP.IdOperacion = @IdOperacion); 
		 
	 IF @TIPOFLUJO = 1  --> SERIAL
  BEGIN  
  
   SET @IDSIGAPROBADOR = (SELECT TOP 1  
           IdAprobador  
          FROM dbo.TA_Tarea  
          WHERE IdOperacion = @IdOperacion  
           AND Activo = 1 --> QUE ESTE ACTIVO
		   AND IdEstatus = 1--> QUE ESTE EN APROBACIÓN
		   ORDER BY NoSecuencia ASC);  
        
   IF @IDSIGAPROBADOR IS NOT NULL  
   BEGIN  
      
    SET @NOMBRESUBCONTRATISTA = (SELECT TOP 1  
                 PVS.RazonSocial  
                FROM dbo.FI_PedimentoComprobante AS PC  
                 JOIN Adinco.dbo.PV_Subcontratista AS PVS  
                  ON  PC.IdSubcontratistaExportador  = PVS.IdSubcontratista
                WHERE PC.IdPedimentoComprobante = @IdComprobante);  
         
    SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);  
    SET @CORREOSIGAPROBADOR = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);  
    SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);  
  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdComprobante AS NVARCHAR(10))));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##',CONCAT(@DominioProcura,'04Tareas/AprobacionPedimentoComprobante_CD.aspx')));  
  
  
   INSERT INTO #TemporalCorreosUsuario (   
	Para,
    Asunto,
    Mensaje,                                       
    CreadoPor
    ) 
    VALUES  
    (
        @CORREOSIGAPROBADOR,        -- Para - varchar(1000)  
        'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)  
        @CORREOSIG,        -- Mensaje - text  
        3        -- CreadoPor - int  --> CTE USUARIO GRAL        
        );  
  
    INSERT INTO dbo.TA_BitacoraCorreo  
    (  
     IdDocumento,  
     Detalle,  
     Correo,  
     Enviado,  
     FechaEnvio,  
     IdUsuarioEnvio,  
     IdProveedorEnvio,  
     IdUsuarioReceptor  
    )  
    VALUES  
    (@IdComprobante,         -- IdDocumento - int  
     N'Notificacion de Aprobacion para Pedimento/Comprobante',       -- Detalle - nvarchar(max)  
     @CORREOSIGAPROBADOR,       -- Correo - nvarchar(350)  
     1,      -- Enviado - bit  
     GETDATE(), -- FechaEnvio - datetime  
     0,         -- IdUsuarioEnvio - int  
     0,         -- IdProveedorEnvio - int  
     0          -- IdUsuarioReceptor - int  
     );  
  
   END   

   
  END  
    
  
  IF @TIPOFLUJO = 2 --> PARALELO 
  BEGIN  
        
   INSERT INTO @APROBADORESTABLE  
   (  
       IdAprobador,  
       Nombre,  
       Correo  
   )  
   SELECT  
    T.IdAprobador,  
    US.Nombre,  
    US.Correo  
   FROM dbo.TA_Tarea AS T  
   JOIN dbo.S_Usuario AS US  
    ON T.IdAprobador = US.IdUsuario
   WHERE T.IdOperacion = @IdOperacion  
   AND T.Activo = 1  --> ACTIVO
   AND T.IdEstatus = 1 ---> EN APROBACIÓN
   AND T.FechaCambioEstatus IS NULL;  
  
   SET @CONTTOTAL = (SELECT COUNT(1) FROM @APROBADORESTABLE);  
   SET @CONT = 1;  
  
   WHILE @CONT <= @CONTTOTAL  
   BEGIN  
         
    SET @IDAPROBPARALELO = (SELECT IdAprobador FROM @APROBADORESTABLE WHERE ID = @CONT);  
      
    SET @NOMBRESUBCONTRATISTA = (SELECT TOP 1  
                 PVS.RazonSocial  
                FROM dbo.FI_PedimentoComprobante AS PC  
                 JOIN Adinco.dbo.PV_Subcontratista AS PVS  
                  ON PC.IdSubcontratistaExportador = PVS.IdSubcontratista
                WHERE PC.IdPedimentoComprobante = @IdComprobante);  
         
    SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);  
    SET @CORREOSIGAPROBADOR = (SELECT Correo FROM @APROBADORESTABLE WHERE ID = @CONT);  
    SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);  
  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdComprobante AS NVARCHAR(10))));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##',CONCAT(@DominioProcura,'04Tareas/AprobacionPedimentoComprobante_CD.aspx')));  
    
   INSERT INTO #TemporalCorreosUsuario (   
	Para,
    Asunto,
    Mensaje,                                       
    CreadoPor
    ) 
    VALUES  
    ( 
	@CORREOSIGAPROBADOR,        -- Para - varchar(1000)  
	'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)  
    @CORREOSIG,        -- Mensaje - text       
    3         -- CreadoPor - int  CTE CORREO DE USUARIO DEFAULT       
    );  
   
    INSERT INTO dbo.TA_BitacoraCorreo  
    (  
     IdDocumento,  
     Detalle,  
     Correo,  
     Enviado,  
     FechaEnvio,  
     IdUsuarioEnvio,  
     IdProveedorEnvio,  
     IdUsuarioReceptor  
    )  
    VALUES  
    (   @IdComprobante,         -- IdDocumento - int  
     N'Notificacion de Aprobacion para Pedimento/Comprobante',       -- Detalle - nvarchar(max)  
     @CORREOSIGAPROBADOR,       -- Correo - nvarchar(350)  
     1,      -- Enviado - bit  
     GETDATE(), -- FechaEnvio - datetime  
     0,         -- IdUsuarioEnvio - int  
     0,         -- IdProveedorEnvio - int  
     0          -- IdUsuarioReceptor - int  
     );  
  
    SET @CONT = @CONT + 1;  
  
   END  
  END  
  

	END 


  
    SELECT 'SUCCESS'

	SELECT 
	Para,
	Asunto,
	Mensaje,
	CreadoPor
	FROM #TemporalCorreosUsuario
	       
 END  
  
  