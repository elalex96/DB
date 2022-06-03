USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AD_SP_AgregarNuevoFlujoAprobacionComprobanteDirecto'
)
    DROP PROCEDURE AD_SP_AgregarNuevoFlujoAprobacionComprobanteDirecto;
GO
/****** Object:  StoredProcedure [dbo].[AD_SP_AgregarNuevoFlujoAprobacionComprobanteDirecto]    Script Date: 03/06/2022 12:15:34 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <07-04-2021>  
-- Description: <Cambia flujo de aprobación de un comprobante extranjero directo>  
-- =============================================  
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_AgregarNuevoFlujoAprobacionComprobanteDirecto]    
@IdProveedor INT,  
@IdUsuario INT,  
@IdNuevoFlujoAprobacion INT,  
@IdOperacion INT,  
@IdComprobante INT, 
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
 DECLARE @TIPOFLUJO INT 
 DECLARE @IDSIGAPROBADOR INT
 DECLARE @CorreoNotificaciones NVARCHAR(MAX);

  DECLARE   
   @CONTTOTAL    INT,  
   @CONT     INT,     
   @IDAPROBPARALELO  INT,  
   @DescripcionH   NVARCHAR(MAX),  
   @NOMBRESUBCONTRATISTA NVARCHAR(MAX),  
   @NOMBRESIGAPROBADOR  NVARCHAR(MAX),  
   @CORREOSIGAPROBADOR  NVARCHAR(MAX),  
   @CORREOSIG    NVARCHAR(MAX),  
   @IDNOTIFICACION   NVARCHAR(MAX);  
   DECLARE @APROBADORESTABLE  TABLE(ID INT IDENTITY(1,1),IdAprobador INT, Nombre NVARCHAR(1000), Correo NVARCHAR(MAX));  

   SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON S.IdServidor = C.IdServidor
								WHERE IdCorreo = 107) --> CTE NUMERO CORREO (TA_Correo)

  --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN   
  
   DECLARE @IdESTATUSACTUAL INT   
  
  SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion  
  IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN  
  BEGIN  
    
  /*NOMBRE FLUJO ANTERIOR*/
  SELECT @NombreFlujoAnterior=FT.Nombre
  FROM TA_FlujoTarea AS FT  
  INNER JOIN TA_Operacion AS O ON O.IdFlujoTarea = FT.IdFlujoTarea  
  WHERE O.IdOperacion = @IdOperacion;  

  /*NOMBRE FLUJO NUEVO*/
  SELECT @NombreFlujoNuevo=FT.Nombre
  FROM TA_FlujoTarea AS FT  
  WHERE FT.IdFlujoTarea = @IdNuevoFlujoAprobacion; 

  /*INSERTAR HISTORIAL*/
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
  
	  --ELIMINADO LOGICO DE LAS TAREAS DE ESTE PEDIMENTO  
	  UPDATE dbo.TA_Tarea  
	  SET Activo = 0  
	  WHERE IdOperacion = @IdOperacion;  

  
	  ---ACTUALIZAR EL NUEVO FLUJO DE APROBACION EN LA OPERACION  
	  UPDATE dbo.TA_Operacion   
	  SET IdEstadoFlujo=1,  
	  IdFlujoTarea=@IdNuevoFlujoAprobacion  
	  WHERE IdOperacion=@IdOperacion    
  
	  --AGREGAR NUEVOS APROBADORES   
	  INSERT INTO dbo.TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion, AsignadoPor,MensajeAsignacion)   
	  SELECT 'Aprobacion Pedimento/Comprobante Compra Directa',@FECHAMODIFICACION, 1, 1,0, IdUsuario, NoSecuencia,@IdOperacion, @IdUsuario, @MensajeAsignacion  
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


   
  -- MANDAR NOTIFICACIÓN A LOS APROBADORES  		
	SET @TIPOFLUJO = (SELECT TOP 1  
         TFT.IdTipoFlujoTarea  
        FROM dbo.TA_Operacion AS OP  
         JOIN dbo.TA_FlujoTarea AS FT  
          ON FT.IdFlujoTarea = OP.IdFlujoTarea  
         JOIN dbo.TA_TipoFlujoTarea AS TFT  
          ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo  
        WHERE OP.IdOperacion = @IdOperacion); 
		 
	IF @TIPOFLUJO = 1  --> FLUJO SERIAL--> SOLO AL PRIMER APROBADOR
		BEGIN  
  
   SET @IDSIGAPROBADOR = (SELECT TOP 1  
           IdAprobador  
          FROM dbo.TA_Tarea  
          WHERE IdOperacion = @IdOperacion  
           AND Activo = 1  
           AND NoSecuencia = 1);  
        
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
        ISNULL(@CorreoNotificaciones,''),        -- De - varchar(100)  
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
     @IdUsuario,  
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
    
  
	IF @TIPOFLUJO = 2  -->  FLUJO PARALELO A TODOS 
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
   AND T.Activo = 1  
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
        ISNULL(@CorreoNotificaciones,''),        -- De - varchar(100)  
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
     @IdUsuario,  
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
  
	SELECT 'SUCCESS'  
  END   
  ELSE   
  BEGIN  
  DECLARE @EstatusActual NVARCHAR(MAX)  
  SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL  
  SELECT 'ESTATUS_NOENAPROBACION' AS Response,@EstatusActual AS EstatusActual  
  END   
   
  
END  
  
   