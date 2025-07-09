USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..EnviarCorreoSolpedAprobadaCarso') IS NOT NULL
BEGIN
DROP PROCEDURE EnviarCorreoSolpedAprobadaCarso;
END
GO
CREATE PROCEDURE [dbo].[EnviarCorreoSolpedAprobadaCarso]  
AS  
BEGIN  
    DECLARE @TablaCorreo TABLE  
    (  
        Html NVARCHAR(MAX),  
        Asunto NVARCHAR(MAX),  
        CuentaRegistro NVARCHAR(500),  
        Contrasena NVARCHAR(500),  
        SMTP NVARCHAR(500),  
        Puerto INT,  
        BBC NVARCHAR(500)  
    )  
    DECLARE @URL NVARCHAR(MAX),  
            @IdOperacion INT,  
            @PrimerParte NVARCHAR(100),  
            @SegundaParte NVARCHAR(100),  
            @IdProveedor INT,  
            @Html NVARCHAR(MAX),  
            @Asunto NVARCHAR(MAX),  
            @Identificador NVARCHAR(MAX),  
            @Contador INT = 1,  
            @CantidadReg INT,  
            @NombreUsuario NVARCHAR(MAX),  
            @Correo NVARCHAR(MAX),  
            @IdUsuario INT,  
            @De NVARCHAR(MAX)  
    DECLARE @TablaSolpeds TABLE  
    (  
        IdSolicitudPedido INT,  
        UrlEnc NVARCHAR(MAX),  
        IdOperacion INT,  
        IdIdentificador NVARCHAR(MAX),  
        IdProveedor INT  
    )  
    DECLARE @TablaEnviarCorreo TABLE  
    (  
        Id INT IDENTITY,  
        IdUsuario INT,  
        Correo NVARCHAR(MAX),  
        NombreUsuario NVARCHAR(MAX),  
        IdSolicitudPedido INT,  
        Asunto NVARCHAR(MAX),  
        Html NVARCHAR(MAX),  
        IdNotificacion INT,  
        UrlEnc NVARCHAR(MAX),
		Comparativa NVARCHAR(MAX)  
    )  
    INSERT INTO @TablaSolpeds  
    (  
        IdSolicitudPedido  
    )  
    SELECT IdSolicitudPedido  
    FROM dbo.AX_Comparativa  
    WHERE ISNULL(EnvioCorreo, 0) = 1
	  
    SELECT @PrimerParte = dbo.Fn_generarValorQueryStringIncognito()  
    SELECT @SegundaParte = dbo.Fn_generarValorQueryStringIncognito()  
    SELECT @URL = Url  
    FROM dbo.TA_Dominios  
    WHERE IdDominio = 2  

    UPDATE solped  
    SET solped.UrlEnc = @URL + N'02Proveedores/DetalleSolicitudOferta.aspx?solped=' + @PrimerParte  
                        + LTRIM(solped.IdSolicitudPedido) + @SegundaParte + '&web=1'  
    FROM @TablaSolpeds solped  

    UPDATE solped  
    SET solped.IdOperacion = O.IdOperacion  
    FROM dbo.TA_Operacion O  
        INNER JOIN @TablaSolpeds solped  
            ON O.IdDocumento = solped.IdSolicitudPedido  
    WHERE O.IdTipoOperacion = 2  

    UPDATE solped  
    SET solped.IdIdentificador = LTRIM(IdOperacion) + N' - Nueva Solicitud de pedido ' + N' #'  
                                 + LTRIM(IdSolicitudPedido)  
    FROM @TablaSolpeds solped  
    INSERT INTO @TablaCorreo  
    (  
        Html,  
        Asunto,  
        CuentaRegistro,  
        Contrasena,  
        SMTP,  
        Puerto,  
        BBC  
    )  
    SELECT   
  C.HTML,  
  C.Asunto,  
  S.CuentaRegistro,   
  S.Contrasena,   
  S.SMTP,  
  S.Puerto,  
  S.BBC  
  FROM dbo.TA_Correo AS C  
  INNER JOIN dbo.TA_CorreoServidor AS S   
   ON S.IdServidor=C.IdServidor  
  WHERE C.IdCorreo = 26  --_Notificacion_Solicitud_Oferta
    
    UPDATE t  
    SET t.IdProveedor = sp.IdProveedor  
    FROM @TablaSolpeds t  
        INNER JOIN dbo.MM_SolicitudPedido sp  
            ON sp.IdSolicitudPedido = t.IdSolicitudPedido 
			 
 DECLARE @retorno nvarchar(max)  

    INSERT INTO @TablaEnviarCorreo  
    (  
        IdUsuario,  
        Correo,  
        NombreUsuario,  
        IdSolicitudPedido  
    )  
    SELECT u.IdUsuario,  
           u.Correo,  
           u.Nombre,  
           solped.IdSolicitudPedido  
    FROM dbo.S_UsuarioProveedor up  
        INNER JOIN dbo.S_Usuario u  
            ON u.IdUsuario = up.IdUsuario  
        INNER JOIN @TablaSolpeds solped  
            ON solped.IdProveedor = up.IdProveedor  
    WHERE ISNULL(u.IsEliminado, 0) = 0  
          AND u.IdTipoUsuario = 5  
    GROUP BY u.IdUsuario,  
             u.Correo,  
             u.Nombre,  
             solped.IdSolicitudPedido 
			  
    SELECT TOP 1  
           @Asunto = Asunto,  
           @Html = Html,  
           @De = CuentaRegistro  
    FROM @TablaCorreo  
    DECLARE @Max INT  
    SELECT @Max = MAX(IdNotificacion)  
    FROM Adinco.dbo.S_Notificacion  

    UPDATE enviar  
    SET enviar.UrlEnc = solped.UrlEnc  
   FROM @TablaEnviarCorreo enviar  
        INNER JOIN @TablaSolpeds solped  
            ON solped.IdSolicitudPedido = enviar.IdSolicitudPedido  

	UPDATE correo
	SET correo.Comparativa = comp.IdComparativa 
	FROM dbo.AX_Comparativa comp 
	INNER JOIN @TablaEnviarCorreo correo ON correo.IdSolicitudPedido = comp.IdSolicitudPedido
	INNER JOIN @TablaSolpeds solped ON solped.IdSolicitudPedido = correo.IdSolicitudPedido

    UPDATE enviar  
    SET enviar.Asunto = CONCAT('Comparativa ',Comparativa,' / ', REPLACE(@Asunto, '##NO##', LTRIM(enviar.IdSolicitudPedido))),  
        enviar.Html = REPLACE(  
                                 REPLACE(@Html, '##NOMBRE_USUARIO##', enviar.NombreUsuario),  
                                 '##URL_TAREA##',  
                                 enviar.UrlEnc  
                             ),  
        enviar.IdNotificacion = @Max + Id  
    FROM @TablaEnviarCorreo enviar  

	UPDATE enviar
	SET enviar.Html = REPLACE(enviar.Html,'##CENTROSCOSTOS##' ,	
	ISNULL(STUFF(( SELECT CAST(', ' AS VARCHAR(MAX)) + UPPER(costo.CentroCosto)
	FROM dbo.MM_SolicitudPedidoDetalle spd 
	INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdi
	ON spdi.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
	INNER JOIN dbo.CC_CentroCosto costo ON costo.IdCentroCosto = spdi.IdCentroCosto
	WHERE spd.IdSolicitudPedido = sp.IdSolicitudPedido
	GROUP BY costo.CentroCosto
	FOR XML PATH('')),  
		   1,  
		   1,  
		   ''), 'No encontrado'))
	FROM dbo.MM_SolicitudPedido sp 
	INNER JOIN @TablaEnviarCorreo enviar ON enviar.IdSolicitudPedido = sp.IdSolicitudPedido 

	UPDATE enviar
	SET enviar.Html = REPLACE(REPLACE(REPLACE(enviar.Html, '##NO_SOLICITUDPEDIDO##' , ' ' + LTRIM(sp.IdSolicitudPedido)), '##CONTRATO##' , ' ' + contrato.NumeroContrato COLLATE DATABASE_DEFAULT), '##ANIO_ACTUAL##', LTRIM(YEAR(GETDATE())))
	FROM dbo.MM_SolicitudPedido sp 
	INNER JOIN @TablaEnviarCorreo enviar ON enviar.IdSolicitudPedido  = sp.IdSolicitudPedido
	INNER JOIN Adinco.dbo.CO_Contrato contrato ON contrato.IdContrato = sp.IdContrato

    SELECT Correo,  
           Asunto,  
           Html
    FROM @TablaEnviarCorreo  

    -- ya que se envio setear la bandera en 0  
    UPDATE comp  
    SET comp.EnvioCorreo = 0  
    FROM dbo.AX_Comparativa comp  
        INNER JOIN @TablaSolpeds solped  
            ON solped.IdSolicitudPedido = comp.IdSolicitudPedido  
END