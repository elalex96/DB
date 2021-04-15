USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_ReasignarAprobadorComprobanteExtranjero'
)
    DROP PROCEDURE AD_SP_ReasignarAprobadorComprobanteExtranjero;
GO 
-- =============================================  
-- Author:  Daniel AC
-- Create date: 07-04-2017  
-- Description:  SP que reasigna una tarea a otra aprobador de un comprobante extranjero  
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
  DECLARE @IdAprobador INT 

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

  SET NOCOUNT ON;  
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
          ON FT.IdFlujoTarea = OP.IdFlujoTarea  
         JOIN dbo.TA_TipoFlujoTarea AS TFT  
          ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo  
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
                  ON PVS.IdSubcontratista = PC.IdSubcontratistaExportador  
                WHERE PC.IdPedimentoComprobante = @IdComprobante);  
         
    SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);  
    SET @CORREOSIGAPROBADOR = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IDSIGAPROBADOR);  
    SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);  
  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdComprobante AS NVARCHAR(10))));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##','https://procura.adinco.mx/04Tareas/AprobacionPedimentoComprobante_CD.aspx'));  
  
    SET @IDNOTIFICACION = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);  
  
    INSERT INTO Adinco.dbo.S_Notificacion  
    (  
        IdNotificacion,  
        Para,  
        Asunto,  
        Mensaje,  
        FechaProgramadaEnvio,  
        Enviada,  
        FechaEnvio,  
        CreadoPor,  
        CreadoEl,  
        ModificadoPor,  
        ModificadoEl,  
        De,  
        EN_MsjEnviado  
    )  
    VALUES  
    ( @IDNOTIFICACION,         -- IdNotificacion - bigint  
        @CORREOSIGAPROBADOR,        -- Para - varchar(1000)  
        'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)  
        @CORREOSIG,        -- Mensaje - text  
        DATEADD(MINUTE,1,GETDATE()), -- FechaProgramadaEnvio - datetime  
        0,      -- Enviada - bit  
        NULL, -- FechaEnvio - datetime  
        3,         -- CreadoPor - int  
        GETDATE(), -- CreadoEl - datetime  
        NULL,         -- ModificadoPor - int  
        NULL, -- ModificadoEl - datetime  
        'procura@adinco.mx',        -- De - varchar(100)  
        NULL       -- EN_MsjEnviado - bit  
        );  
  
    INSERT INTO dbo.TA_EnvioCorreo  
    (  
     IdEnvioAdinco,  
     IdCorreo,  
     IdIdentificacion,  
     EnviadoPor,  
     EnviadoEl  
    )  
    VALUES  
    (   @IdNotificacion, -- IdEnvioAdinco - int  
     107, -- CORREO DE PETICION OFERTA  
     CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @IdComprobante),  -- IdIdentificacion - int  
     0,  
     GETDATE()  
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
    ON US.IdUsuario = T.IdAprobador  
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
                  ON PVS.IdSubcontratista = PC.IdSubcontratistaExportador  
                WHERE PC.IdPedimentoComprobante = @IdComprobante);  
         
    SET @NOMBRESIGAPROBADOR = (SELECT Nombre FROM @APROBADORESTABLE WHERE ID = @CONT);  
    SET @CORREOSIGAPROBADOR = (SELECT Correo FROM @APROBADORESTABLE WHERE ID = @CONT);  
    SET @CORREOSIG = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 107);  
  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_USUARIO##',@NOMBRESIGAPROBADOR));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##NOMBRE_CLIENTE##',@NOMBRESUBCONTRATISTA));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##COMPROBANTE##',CAST(@IdComprobante AS NVARCHAR(10))));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##ANIO_ACTUAL##',YEAR(GETDATE())));  
    SET @CORREOSIG = (REPLACE(@CORREOSIG,'##URL_PEDIDO##','https://procura.adinco.mx/04Tareas/AprobacionPedimentoComprobante_CD.aspx'));  
  
    SET @IDNOTIFICACION = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);  
  
    INSERT INTO Adinco.dbo.S_Notificacion  
    (  
        IdNotificacion,  
        Para,  
        Asunto,  
        Mensaje,  
        FechaProgramadaEnvio,  
        Enviada,  
        FechaEnvio,  
        CreadoPor,  
        CreadoEl,  
        ModificadoPor,  
        ModificadoEl,  
        De,  
        EN_MsjEnviado  
    )  
    VALUES  
    ( @IDNOTIFICACION,         -- IdNotificacion - bigint  
        @CORREOSIGAPROBADOR,        -- Para - varchar(1000)  
        'Aprobación Pendiente de Pedimento/Comprobante Extranjero',        -- Asunto - varchar(500)  
        @CORREOSIG,        -- Mensaje - text  
        DATEADD(MINUTE,1,GETDATE()), -- FechaProgramadaEnvio - datetime  
        0,      -- Enviada - bit  
        NULL, -- FechaEnvio - datetime  
        3,         -- CreadoPor - int  
        GETDATE(), -- CreadoEl - datetime  
        NULL,         -- ModificadoPor - int  
        NULL, -- ModificadoEl - datetime  
        'procura@adinco.mx',        -- De - varchar(100)  
        NULL       -- EN_MsjEnviado - bit  
        );  
  
    INSERT INTO dbo.TA_EnvioCorreo  
    (  
     IdEnvioAdinco,  
     IdCorreo,  
     IdIdentificacion,  
     EnviadoPor,  
     EnviadoEl  
    )  
    VALUES  
    (   @IdNotificacion, -- IdEnvioAdinco - int  
     107, -- CORREO DE PETICION OFERTA  
     CONCAT('0 - Notificacion para Aprobacion del Pedimento/Comprobante #' , @IdComprobante),  -- IdIdentificacion - int  
     0,  
     GETDATE()  
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
	       
 END  
  
  