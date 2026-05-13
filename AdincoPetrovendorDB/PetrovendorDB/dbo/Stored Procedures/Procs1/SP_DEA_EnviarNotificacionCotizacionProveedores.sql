-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 26-05-2020
-- Description:	 Enviar nbotificaciones a los proveedores que aun tiene cotizaciones pendientes de cotizar (SOLO PROVEEDORES DE DEA)
-- Filtro por contrato
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 03/06/2022
-- Description:	Se obtiene correo de notificaciones directamente desde la tabla TA_CorreoServidor
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_EnviarNotificacionCotizacionProveedores] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TotalCorreoInvitados INT 
	DECLARE @Contador INT
	DECLARE @HTMLporInvitacion NVARCHAR(MAX)
	DECLARE @HTMLporInvitacionPersonalizado NVARCHAR(MAX)
	DECLARE @IdNotificacion INT 
	DECLARE @Codigo NVARCHAR(MAX)
	DECLARE @CorreoInvitado NVARCHAR(MAX)
	DECLARE @ProveedorOperadora NVARCHAR(MAX)
	DECLARE @SolicitudPedidoId INT 
	DECLARE @PeticionOfertaId INT 
	DECLARE @TotalCorreoPetro INT 
	DECLARE @HTMLcotizacion NVARCHAR(MAX) 
	DECLARE @HTMLcotizacionPersonalizado NVARCHAR(MAX)
	DECLARE @CorreoProveedor NVARCHAR(MAX)
	DECLARE @NombreUsuario NVARCHAR(MAX)
	DECLARE @ComentarioOperadora NVARCHAR(MAX)
	DECLARE @DetalleBitacora NVARCHAR(MAX)
	DECLARE @CorreoNotificaciones NVARCHAR(MAX);

	---> MODIFICAR CONTRATOS DE LAS OPERADORAS QUE VAN APLICAR LAS NOTIFICACIONES
	DECLARE @Contratos TABLE
    (ContratoId INT);

    INSERT INTO @Contratos
    (ContratoId)
    VALUES
 --   (3), --> MEXICO
	(10038), --> CNH-A4.OGARRIO/2018
    (10044), --> CNH-R03-L01-G-TMV-02/2018
    (10045), --> CNH-R03-L01-G-TMV-03/2018
    (10046), --> CNH-R03-L01-AS-CS-14/2018
    (10144), --> CNH-DEMMA
	(10145); --> CNH-WD ADMIN  


	DECLARE @SolicitudPedido AS Table (
		SolicitudPedidoId INT,
	    ProveedorProcura NVARCHAR(MAX),
		MotivoUrgencia NVARCHAR(MAX),
		FechaLimiteCotizacion DateTime 
	)

	DECLARE @NotificacionesCorreos AS TABLE 
    (  
        IdRow INT IDENTITY(1,1) PRIMARY KEY,  
        Correo NVARCHAR(MAX),  
        NombreUsuario NVARCHAR(MAX),  
        IdUsuario INT,
		SolicitudPedidoId INT,
		PeticionOfertaId INT,
		ProveedorProcura NVARCHAR(MAX),
		ProveedorPetrovendor NVARCHAR(MAX)
    ); 

	DECLARE @NotificacionesCorreosXinvitacion AS TABLE
	(
	IdRow INT IDENTITY(1, 1) PRIMARY KEY, 
	CorreoInvitado NVARCHAR(MAX),
	SolicitudPedidoId INT, 
	ProveedorProcura NVARCHAR(MAX),
	NoCodigo NVARCHAR(MAX)
	);  

    /*OBTENER LAS REQUISICIONES QUE ESTAN EN TIEMPO DE COTIZACIÓN*/
	 INSERT INTO @SolicitudPedido(SolicitudPedidoId,ProveedorProcura,MotivoUrgencia,FechaLimiteCotizacion)
	 SELECT   SP.IdSolicitudPedido,  
               RazonSocial AS ClienteProveedor,              
               O.Descripcion AS MotivoUrgencia, 
			   O.FechaFinalizacion AS FechaLimite   
        FROM @Contratos C
			JOIN MM_SolicitudPedido AS SP    
			     ON C.ContratoId = SP.IdContrato  
            JOIN TA_Operacion AS O
                ON SP.IdSolicitudPedido  =	O.IdDocumento        
            JOIN S_Proveedor AS P
                ON SP.IdProveedor		 =	P.IdProveedor 
        WHERE O.IdTipoOperacion = 6		---> OPERACIÓN DE TIPO DE COTIZACIONES 
			  AND SP.Activo		= 1	    ---> REEQUISICIÓN ACTIVA
              AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0  --> QUE LA FECHA LIMITE COTIZACIÓN SEA MENOR A LA FECHA ACTUAL
	  
	/*OBTENER LOS PROVEEDORES QUE AUN NO HAN COTIZADOS Y OBTENER SUS USUARIOS A NOTIFICAR APLICA PARA LAS INVITACIONES A COTIZAR POR PROVEEDOR*/
	INSERT INTO @NotificacionesCorreos
	(Correo,NombreUsuario, IdUsuario,
	SolicitudPedidoId,PeticionOfertaId,ProveedorPetrovendor)
	SELECT 
	U.Correo,U.Nombre,U.IdUsuario,
	SP.SolicitudPedidoId,PO.IdPeticionOferta,P.RazonSocial AS ProveedorPetrovendor
	FROM @SolicitudPedido SP
	JOIN MM_PeticionOferta AS PO
		ON SP.SolicitudPedidoId = PO.IdSolicitudPedido
	JOIN S_Proveedor P ON 
		 PO.IdSubcontratista	= P.IdProveedor
	JOIN S_UsuarioProveedor UP
		ON P.IdProveedor	= UP.IdProveedor
	JOIN S_Usuario AS U
		ON UP.IdUsuario	= U.IdUsuario
		AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario=3) --> SOLO APLICA PARA LOS APROBADORES Y USUARIOS DE VENTAS DE LOS PROVEEDORES DE PETROVENDOR
		AND U.Activo = 1--> QUE EL USUARIO ESTE ACTIVO
	WHERE 
	ISNULL(PO.IdEstatusEliminado,0)<>1 --> ESTATUS ELIMINADO              
    AND ISNULL(PO.Cotizado,0) = 0   --> NO ESTE COTIZADO
    AND ISNULL(PO.NoCotizar,0) = 0  --> NO ESTE COMO NO COTIZADO
	
		
	/*OBTENER LOS CORREOS DE LOS INVITADOS A COTIZAR MEDIANDO CORREO ELECTRONICO --> USUARIOS QUE TODAVIA NO ESTAN REGISTRADOS EN EL SISTEMA*/
	INSERT INTO @NotificacionesCorreosXinvitacion 
	(CorreoInvitado,SolicitudPedidoId,
	NoCodigo,ProveedorProcura)
	SELECT IPO.CorreoInvitacion,IPO.IdSolicitudPedido,
	IPO.CodigoActivacion,SP.ProveedorProcura
	FROM @SolicitudPedido SP
	JOIN MM_InvitacionPeticionOferta IPO
	ON SP.SolicitudPedidoId = IPO.IdSolicitudPedido
	AND ISNULL(IPO.CodigoActivo,0)=0 --> QUE EL CODIGO ESTE ACTIVO
	AND IPO.InvitacionPorCorreo = 1 --> INDICA QUE ES UNA INVITACIÓN POR CORREO ELECTRONICO
	AND IPO.Activo=1 --> INVITACIÓN ACTIVA
	AND IdProveedorInvitado IS NULL --> INDICA QUE EL USUARIO NO HA RECUPERADO LA COTIZACIÓN

	/*ENVIO DE CORREOS PARA LOS USUARIOS QUE SON INVITADOS MEDIANTE CORREO Y TIENE CODIGO DE RECUPERACIÓN DE COTIZACIÓN*/
	BEGIN 

	
	SET @TotalCorreoInvitados = (SELECT COUNT(IdRow) FROM @NotificacionesCorreosXinvitacion)
	SET @Contador = 1
	SET @HTMLporInvitacion = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 18); -->CTE  Invitación Cotización Petrovendor 
	SET @HTMLporInvitacionPersonalizado = ''
	SET @IdNotificacion = 0
	SET @Codigo = ''
	SET @CorreoInvitado = ''
	SET @ProveedorOperadora = ''
	SET @SolicitudPedidoId = 0 
	SET @PeticionOfertaId = 0

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 18) --> CTE NUMERO CORREO (TA_Correo)

    WHILE @Contador <= @TotalCorreoInvitados  
    BEGIN  

	    /*ARMAR CORREOS E INSERTARLOS EN S_NOTIFICACIÓN*/
        SET @HTMLporInvitacionPersonalizado = @HTMLporInvitacion; 

        SELECT 
		@CorreoInvitado = CorreoInvitado,
		@Codigo = NoCodigo,
		@SolicitudPedidoId = SolicitudPedidoId,
		@ProveedorOperadora = ProveedorProcura
        FROM @NotificacionesCorreosXinvitacion 		    
        WHERE IdRow = @Contador;  
				
  
        /*REMPLAZAR INFORMACIÓN DE LA PLANTILLA*/
        SET @HTMLporInvitacionPersonalizado  
            = (REPLACE(@HTMLporInvitacionPersonalizado, '##NombreEmpresa##', @ProveedorOperadora));  
        SET @HTMLporInvitacionPersonalizado 
			= (REPLACE(@HTMLporInvitacionPersonalizado, '##NO_CODIGO##', @Codigo));  
        SET @HTMLporInvitacionPersonalizado  
            = (REPLACE(@HTMLporInvitacionPersonalizado, '##CORREO_INVITACION##', @CorreoInvitado));  
        SET @HTMLporInvitacionPersonalizado 
			= (REPLACE(@HTMLporInvitacionPersonalizado, '##ANIO_ACTUAL##', YEAR(GETDATE())));  
        SET @HTMLporInvitacionPersonalizado  
            = (REPLACE(@HTMLporInvitacionPersonalizado, '##DOMINIO##', 'https://petrovendor.com.mx/'));  
        SET @HTMLporInvitacionPersonalizado  
            = (REPLACE(@HTMLporInvitacionPersonalizado, '##SOLICITUD_PEDIDO##', CAST(@SolicitudPedidoId AS NVARCHAR(100))));  
  
        SET @IdNotificacion = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1);  
  
       /*AGREGAR CORREO A LA TABLA DE CORREOS DE ADINCO*/
        INSERT INTO Adinco.dbo.S_Notificacion  
        (  
            IdNotificacion,Para,Asunto,
			Mensaje,FechaProgramadaEnvio,Enviada,  
            FechaEnvio,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De)  
        VALUES  
        (@IdNotificacion, @CorreoInvitado, 'Invitación Cotización Petrovendor ',
		 @HTMLporInvitacionPersonalizado, DATEADD(MINUTE, 1, GETDATE()), 0,
		 NULL, 3, GETDATE(), NULL, NULL,ISNULL(@CorreoNotificaciones,''));  
  
        INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)  
        VALUES  
        (   @IdNotificacion,                                                          -- IdEnvioAdinco - int  
            18,                                                                       -- CORREO DE PETICION OFERTA  
            CONCAT('0 - Codigo de Invitacion Peticion oferta #', @SolicitudPedidoId,' ->JOB-DEA'), -- IdIdentificacion - int  
            0, GETDATE());  
  
        --BITACORA DE CORREO  
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
        (   @SolicitudPedidoId,                           -- IdDocumento - int  
            N'Notificacion Petición Oferta/Recuperación', -- Detalle - nvarchar(max)  
            @CorreoInvitado,                              -- Correo - nvarchar(350)  
            1,                                            -- Enviado - bit  
            GETDATE(),                                    -- FechaEnvio - datetime  
            0,                                            -- IdUsuarioEnvio - int  
            0,                                            -- IdProveedorEnvio - int  
            0                                             -- IdUsuarioReceptor - int  
        );  
      
        SET @Contador = @Contador + 1;  
    END  
	END 

	/*ENVIO DE CORREOS PARA LOS USUARIOS QUE YA ESTAN REGISTRADOS EN PETROVENDOR */
	BEGIN
	SET @TotalCorreoPetro = (SELECT COUNT(IdRow) FROM @NotificacionesCorreos)
	SET @Contador = 1 
	SET @HTMLcotizacion = (SELECT HTML FROM dbo.TA_Correo WHERE IdCorreo = 11); --> Notificación Petición de Oferta (Tienes una solicitud de cotización en Petrovendor)
	SET @HTMLcotizacionPersonalizado =''
	SET @CorreoProveedor =''
	SET @NombreUsuario=''
	SET @ComentarioOperadora=''

	SET @CorreoNotificaciones = (SELECT  TOP 1  CuentaRegistro
								FROM TA_Correo AS C
									INNER JOIN TA_CorreoServidor AS S
										ON C.IdServidor = S.IdServidor
								WHERE IdCorreo = 11) --> CTE NUMERO CORREO (TA_Correo)

	WHILE @Contador <= @TotalCorreoPetro  
        BEGIN  
			
		   SET  @HTMLcotizacionPersonalizado = @HTMLcotizacion            
				 
           SELECT @CorreoProveedor	= Correo,
		   @PeticionOfertaId		= PeticionOfertaId,
		   @SolicitudPedidoId		= SolicitudPedidoId,
		   @NombreUsuario			= NombreUsuario
		   FROM @NotificacionesCorreos 
		   WHERE IdRow = @Contador;  

		   SELECT 
		   @ComentarioOperadora = MotivoUrgencia
		   FROM @SolicitudPedido
		   WHERE SolicitudPedidoId = @SolicitudPedidoId
           
            
            SET @HTMLcotizacionPersonalizado = (REPLACE(@HTMLcotizacionPersonalizado,'##NOMBRE_USUARIO##',@NombreUsuario)); 
			 
            --DESCRIPCION  
            SET @HTMLcotizacionPersonalizado = (REPLACE(@HTMLcotizacionPersonalizado, '##DESCRIPCION_TAREA##', @ComentarioOperadora));  
            --URL  
            SET @HTMLcotizacionPersonalizado  
                = (REPLACE(  
                   @HTMLcotizacionPersonalizado,
				   '##URL_PO##',  
                   CONCAT('https://petrovendor.com.mx/01Proveedores/CO_CotizacionDetalle.aspx?oferta=',CAST(@PeticionOfertaId AS NVARCHAR(100))))
				   );  
            --AÑO  
            SET @HTMLcotizacionPersonalizado  
                = (REPLACE(  
                   @HTMLcotizacionPersonalizado, '##ANIO_ACTUAL##', CAST(YEAR(GETDATE()) AS NVARCHAR(100))));  

            --SOLICITUD DE PEDIDO  
            SET @HTMLcotizacionPersonalizado  
                = (REPLACE(  
                   @HTMLcotizacionPersonalizado,  
                   '##SOLICITUD_PEDIDO##',  
                   CAST(@SolicitudPedidoId AS NVARCHAR(100))));  


            -- AGREGAR EL CORREO  A LA TABLA DE NOTIFICACIONES
  
			SET @IdNotificacion  
                = ((SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1); 

            INSERT INTO Adinco.dbo.S_Notificacion  
            (  
                IdNotificacion,Para,Asunto,Mensaje,
				FechaProgramadaEnvio,Enviada,
				FechaEnvio,CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De  
            )  
            VALUES  
            (@IdNotificacion, @CorreoProveedor,CONCAT('Petición Oferta No.', ISNULL(@PeticionOfertaId, 0)), @HTMLcotizacionPersonalizado,  
             DATEADD(MINUTE, 1, GETDATE()), 0, 
			 NULL, 3, GETDATE(), NULL, NULL, ISNULL(@CorreoNotificaciones,''));  
  
            INSERT INTO dbo.TA_EnvioCorreo (IdEnvioAdinco, IdCorreo, IdIdentificacion, EnviadoPor, EnviadoEl)  
            VALUES  
            (   @IdNotificacion,                                     -- IdEnvioAdinco - int  
                11,                                                  -- CORREO DE PETICION OFERTA  
                CONCAT('0 - Nueva cotización #', @PeticionOfertaId, '->JOB-DEA'), -- IdIdentificacion - int  
                0, GETDATE());  
  
  
            --BITACORA DE CORREO  
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
            (   @PeticionOfertaId,                            -- IdDocumento - int  
                N'Notificacion Petición Oferta/Recuperación', -- Detalle - nvarchar(max)  
                @CorreoProveedor,                                 -- Correo - nvarchar(350)  
                1,                                            -- Enviado - bit  
                GETDATE(),                                    -- FechaEnvio - datetime  
                0,                                            -- IdUsuarioEnvio - int  
                0,                                            -- IdProveedorEnvio - int  
                0                                             -- IdUsuarioReceptor - int  
            );  
               
            SET @Contador = @Contador + 1;  
  
      END;  
	END 
	 

	 SET @DetalleBitacora = CONCAT('Total cotizaciones: ',(SELECT COUNT(1) FROM @SolicitudPedido),
									' Total correos registrados ',(SELECT COUNT(1) from @NotificacionesCorreos),' de Proveedores del catálogo, ',
									(SELECT COUNT(1) FROM @NotificacionesCorreosXinvitacion),' de invitación')

	 INSERT INTO [dbo].[BitacoraErrores]
           ([HResult]
           ,[Mensaje]
           ,[StackTrace]
           ,[IdUsuario]
           ,[IdProveedor]
           ,[FechaRegistro])
     VALUES
           (-1
           ,'JOB-Registro correos cotización'
           ,@DetalleBitacora
           ,0
           ,0
           ,GETDATE())

END