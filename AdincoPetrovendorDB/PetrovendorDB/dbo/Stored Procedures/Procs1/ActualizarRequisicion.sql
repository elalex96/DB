CREATE PROCEDURE [dbo].[ActualizarRequisicion]
@IdSolicitudPedidoDetalle INT,
@IdProveedor INT,
@IdMaterial INT,
@IdDomicilioEntrega INT,
@observaciones NVARCHAR(MAX),
@Cantidad MONEY,
@IdUnidad INT,
@IdUsuario INT,
@IdIdentificador NVARCHAR(MAX)
AS
BEGIN
    DECLARE @IdSolicitudPedido INT,
            @IdEstatusOperacion INT,
            @IdOperacion INT,
            @PeticionEnviada BIT,
			@NombreUsuarioModifico NVARCHAR(MAX),
			@IdDocumento INT,
			@RFC_ACTUAL NVARCHAR(MAX),
			@EXISTE_RFC INT,
			@NoPR NVARCHAR(MAX)

	/*ESTE SP SE ENCARGA DE ACTUALIZAR EL DETALLE DE UNA PARTIDA DE UN REQUISICION*/
	/*AL ACTUALIZAR CUALQUIER PARTIDA SE TIENE QUE REINICIAR EL FLUJO DE APROBACIÓN DE LA REQUISICION*/
	/*PARA PROVEEDORES DE DEA SE TIENE QUE ELIMINAR EL DOCUMENTO PR SI YA LO CONTIENE*/

	/*VARIABLES PARA OBTENER VALIDACIÓN DE DEA*/	  
	SELECT @RFC_ACTUAL=RFC FROM dbo.S_Proveedor WHERE IdProveedor=@IdProveedor   
    SET @EXISTE_RFC = (SELECT COUNT(IdProveedor) FROM DEA_Proveedor WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) AND Activo=1)  
  
  
    --YA QUE FUE ACTUALIZADA LA INFORMACION ENTONCES HAY QUE REINICIAR EL FLUJO DE APROBACION DE LA SOLPED
    SELECT @IdSolicitudPedido = IdSolicitudPedido
    FROM dbo.MM_SolicitudPedidoDetalle
    WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle

	SELECT @NombreUsuarioModifico = Nombre FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario

    SELECT @PeticionEnviada = PeticionEnviada
    FROM dbo.MM_SolicitudPedido
    WHERE IdSolicitudPedido = @IdSolicitudPedido

    -- VALIDAR SI LA REQUISICION YA FUE ENVIADA A COTIZAR - SI ES FALSE AUN NO SE HA INVITADO A NADIE A COTIZAR
    IF (ISNULL(@PeticionEnviada,0) = 0)
    BEGIN
	    /*GUARDAR HISTORIAL DE LA PARTIDA ANTES DEL CAMBIO*/
        INSERT INTO dbo.HistoricoSolicitudPedidoDetalle
        (
            IdSolicitudPedidoDetalle,
            IdMaterial,
            IdDomicilio,
            Observaciones,
            Cantidad,
            IdUnidad,
            FechaRegistro,
            IdUsuarioModifico
        )
        SELECT @IdSolicitudPedidoDetalle,
               @IdMaterial,
               @IdDomicilioEntrega,
               @observaciones,
               @Cantidad,
               @IdUnidad,
               GETDATE(),
               @IdUsuario

        UPDATE spd
        SET spd.IdMaterial = @IdMaterial,
            spd.observaciones = @observaciones,
            spd.Cantidad = @Cantidad,
            spd.IdUnidad = @IdUnidad,
            spd.IdDomicilioEntrega = @IdDomicilioEntrega,
            spd.editado = 1,
            spd.FechaModificado = GETDATE()
        FROM dbo.MM_SolicitudPedidoDetalle spd
            INNER JOIN dbo.MM_SolicitudPedido sp
                ON sp.IdSolicitudPedido = spd.IdSolicitudPedido
        WHERE spd.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
              AND sp.IdProveedor = @IdProveedor

		/*OBTENER LA INFORMACIÓN DE LA APROBACIÓN DE LA REQUISICION*/
        SELECT @IdEstatusOperacion = tao.IdEstatusOperacion,
               @IdOperacion = tao.IdOperacion
        FROM dbo.TA_Operacion tao
        WHERE IdTipoOperacion = 2 --> APROBACIÓN DE REQUISICION
              AND IdDocumento = @IdSolicitudPedido
              AND ISNULL(IdEstatusEliminado, 0) = 0 


        -- SI ALGUN USUARIO APROBO O RECHAZO ENTONCES HAY QUE SETEARLOS A TODOS EN APROBACION
        IF EXISTS
        (   SELECT 1
            FROM dbo.TA_Tarea
            WHERE IdEstatus IN ( 2, 3 ) 
                  AND IdOperacion = @IdOperacion)
        BEGIN
            UPDATE dbo.TA_Tarea
            SET IdEstatus = 1,
			FechaCambioEstatus=NULL,
			Comentario = NULL,
            IdFirma = NULL
            WHERE IdOperacion = @IdOperacion
			AND Activo= 1
			AND IdEstatus NOT IN (7,12) --> SI ESTA REASIGNADO NO ACTUALIZAR A EN APROBACION --> 	SELECT* FROM TA_Estatus 

            -- agregar a la bandera para saber que se debe de enviar los correos
            INSERT INTO dbo.RequisicionBandera (IdSolicitudPedido, IdUsuario, EnviarCorreo, FechaRegistro, Identificador)
            SELECT @IdSolicitudPedido,
                   @IdUsuario,
                   1,
                   GETDATE(),
				   @IdIdentificador
			
			INSERT INTO dbo.TA_HistorialFlujoTarea (Descripcion, IdOperacion, Fecha, IdEstadoFlujo)
			VALUES
			(   N'El usuario ' + @NombreUsuarioModifico + ' ha reiniciado el flujo de aprobación',       -- Descripcion - nvarchar(max)
			    @IdOperacion,         -- IdOperacion - int
			    GETDATE(), -- Fecha - datetime
			    1          -- IdEstadoFlujo - int
			)
        END
		
		/*SE ACTUALIZA EL ESTATUS DE LA REQUISICIÓN*/
        UPDATE tao
        SET tao.IdEstatusOperacion = 1 -->REGRESAR AL ESTADO EN APROBACIÓN
        FROM dbo.TA_Operacion tao
        WHERE IdDocumento = @IdSolicitudPedido
              AND IdTipoOperacion = 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
              AND ISNULL(IdEstatusEliminado, 0) = 0

		/*VALIDAR SI EL PROVEEDOR ES PARTE DEL GRUPO DEA*/	 
		 IF ISNULL(@EXISTE_RFC,0)  >0   
		 BEGIN   
			-- ELIMINAR EL DOCUMENTO DE PR RELACIONADO A LA REQUISICION SI EXISTE
			-- PARA QUE SE CARGUE UN NUEVO ARCHIVO CUANDO SE VUELVA A APROBAR LA REQUISICION

			/*OBTENER LA REFERENCIA DEL DOCUMENTO PR ACTUAL*/
			SELECT @IdDocumento=D.IdDocumento ,
			@NoPR=PR.ID_PR
			FROM dbo.DEA_AdjuntoPR PR  
			INNER JOIN dbo.DEA_Documento_S3 D 
			ON D.IdDocumentoTabla=PR.IdAjuntoPr 
			AND d.IdTipoDocumento=1 --> AdjuntoPR (SELECT * FROM dbo.DEA_TipoDocumento)  
			WHERE PR.IdSolicitudPedido = @IdSolicitudPedido;

			 --PASAR DOCUMENTO A TABLA DE HISTORIAL DE DOCUMENTOS   Y ELIMINAR REFERENCIA AL DOCUMENTO PR
			IF ISNULL(@IdDocumento,0)>0
			BEGIN
				--SI HAY DOCUMENTO PASAR AL HISTORIAL DE DOCUMENTOS 
				 INSERT INTO [dbo].[DEA_DocumentoHistorial_S3]  
				 (  
				  [IdDocumento],  
				  [IdTipoDocumento],    
				  [IdProveedor],  
				  [Activo],   
				  [CreadoPor],  
				  [CreadoEl],  
				  [Descripcion],  
				  [Carpeta],  
				  [Identificador],  
				  [Mime],  
				  [Extension],  
				  [NombreDocumento],  
				  [SizeDocumento],    
				  [IdDocumentoTabla]  
				 )   
  
				 SELECT   
				 IdDocumento,  
				 IdTipoDocumento,  
				 IdProveedor,  
				 Activo,  
				 CreadoPor,  
				 CreadoEl,  
				 CONCAT(Descripcion,' #Eliminado por reinicio de flujo Requisición ',CAST(@IdSolicitudPedido as nvarchar(max)) ,'-PR:',+ISNULL(@NoPR,'')),  
				 Carpeta,  
				 Identificador,  
				 Mime,  
				 Extension,  
				 NombreDocumento,  
				 SizeDocumento,  
				 IdDocumentoTabla  --> ESTE VA SER LA REFERENCIA A LA TABLA DEA_AdjuntoPR QUE SE VA ELIMINAR
				 FROM dbo.DEA_Documento_S3   
				 WHERE IdDocumento=@IdDocumento 
				  
				 DELETE DEA_Documento_S3 WHERE IdDocumento=@IdDocumento	
			  END 

			 /*ELIMINAR REFERENCIA AL ADJUNTO PR*/
			 DELETE DEA_AdjuntoPR WHERE IdSolicitudPedido=@IdSolicitudPedido
			  
		 END  
    -- ya que se cambio el estatus entonces enviar los correos
    -- al requisitor solo si el no fue el que modifico
    -- tmb se debe de notificar a los aprobadores
	-- esto en el evento Grid_RowUpdated
    END
END