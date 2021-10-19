DROP PROCEDURE IF EXISTS MM_EnvioNotificacion_CambioSolicitante
GO
--=========================================
-- CREADO: LUIS DAVID
-- FECHA: 28/09/2021
-- DESCRIPCIÓN: SP PARA ENVIAR NOTIFICACIÓN AL CAMBIO DE SOLICITANTE 
--=========================================
CREATE PROCEDURE MM_EnvioNotificacion_CambioSolicitante
@IdProveedor INT,
@IdUsuario INT ,
@IdSolicitudPedido INT
AS
BEGIN
	DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido'),
	@CantidadUsuarioOBS INT,
	@contador int = 1,
	@IdOperacion INT,
	@idOperacionRow int= 0,
	@cantidadAprobacionPendientes int,
	@cantidadAprobacionPendientesUsuario int,
	@CONTADOROPERACION INT = 1,
	@EstatusSolicitanteId INT,
	@NoSecuenciaUsuarioSolicitante INT,
	@EstatusIdAprobacionActual INT,
	@listaPendientesHTML varchar(max) = '',
	@paraval varchar(max),
	@mensajeval varchar(max),
	@pIdNotificacion int ,
	@Mensaje1 varchar(max)= 'Has sido designado como solicitante de la requisición No. ##NumeroRequisicion##',
	@Mensaje2 varchar(max)= 'Has sido designado como solicitante de la requisición No. ##NumeroRequisicion## y tienes una o varias aceptaciones de servicio pendientes de aprobación.',
	@SolicitanteNuevo NVARCHAR(MAX) = (SELECT TOP 1
														US.Nombre
													FROM S_Usuario AS US
													WHERE IdUsuario = @IdUsuario),
	@para NVARCHAR(MAX) = (SELECT TOP 1
														US.Correo
													FROM S_Usuario AS US
													WHERE IdUsuario = @IdUsuario),
	@HTML varchar(max) = 
 '<p></p>
<table class="full" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td height="25">&nbsp;</td>
</tr>
</tbody>
</table>
<table class="full" border="0" width="100%" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td align="center">
<table class="devicewidth" border="0" width="600" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td>
<table class="full" style="border-radius: 6px 6px 0 0;" width="100%" cellspacing="0" cellpadding="0" align="center" bgcolor="#5e5f5e">
<tbody>
<tr>
<td height="3">&nbsp;</td>
</tr>
<tr>
<td>
<table class="inner" style="border-collapse: collapse;" border="0" align="left">
<tbody>
<tr>
<td class="inner" valign="middle" height="45"><a><img class="logo" style="padding-left: 2em;" src="http://qa.procura.adinco.mx/assets/00/img/SMPS_Logo.png" width="75" height="75" /></a></td>
</tr>
</tbody>
</table>
</td>
</tr>
<tr>
<td height="3">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<!--CUERPO DEL MENSAJE DE CORREO-->
<table class="devicewidth" border="0" width="600" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td>
<table class="full" style="background-repeat: repeat-x; background-position: left top; height: 259px; width: 100%;" border="0" width="100%" cellpadding="0" align="center" bgcolor="#FFFFFF">
<tbody>
<tr style="height: 25px;">
<td style="height: 25px;" height="25">&nbsp;</td>
</tr>
<tr style="height: 36px;">
<td class="smallfont" style="color: black; height: 36px;" align="center">Estimado(a) ##NombreUsuario##</td>
</tr>
<tr style="height: 18px;">
<td class="smallfont" style="color: black; height: 18px;" align="center">&nbsp;</td>
</tr>
<tr style="height: 18px;">
<td class="smallfont" style="color: red; height: 18px;" align="center">&nbsp;</td>
</tr>
<tr style="height: 108px;">
<td class="smallfont" style="color: black; height: 108px;" align="center"><br />##Mensaje##<br /><br />##Detalle##</td>
</tr>
<tr style="height: 18px;">
<td style="height: 18px;" height="16">&nbsp;</td>
</tr>
<tr style="height: 18px;">
<td class="smallfont" style="color: #5e5f5e; height: 18px;" align="center">&nbsp;</td>
</tr>
<tr style="height: 18px;">
<td style="height: 18px;" height="10">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
<table class="full" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td align="center">
<table class="devicewidth" border="0" width="600" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td>
<table class="full" style="border-radius: 0 0 6px 6px;" width="100%" cellspacing="0" cellpadding="0" align="center" bgcolor="#5e5f5e">
<tbody>
<tr>
<td height="18">&nbsp;</td>
</tr>
<tr>
<td>
<table class="inner" style="border-collapse: collapse; text-align: center;" border="0" width="230" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td width="20">&nbsp;</td>
<td>
<table border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
<tbody>
<tr>
<td style="color: #ffffff;">|</td>
<td style="font: 10px Helvetica,Arial, sans-serif; color: #ffffff;" align="center">&copy; ##YEAR_ACTUAL##, Todos los derechos reservados</td>
<td style="color: #ffffff;">|</td>
</tr>
<tr>
<td height="15">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
<td width="20">&nbsp;</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>
</td>
</tr>
</tbody>
</table>';

	DROP TABLE IF EXISTS #DOCUMENTOSID
	CREATE TABLE #DOCUMENTOSID
	(
		iddocumentotemp int,
		descripcion varchar(300)
	)
	DROP TABLE IF EXISTS #ENCABEZADOS
	    /*ENCABEZADO PEDIDO PEDIDO*/	
		 SELECT ROW_NUMBER() OVER(
		 ORDER BY P.IdSolicitudPedido) AS RowNum,
		 SAP.IdSolicitudAceptacionPedido,
		 P.IdPedido,
		 O.IdDocumento,
		 SAP.Comentario,
		 P.IdSolicitudPedido,    		 
		 CONCAT(ISNULL(PV.RazonSocial,''),ISNULL(' '+ PV.RegimenCapital,'')) AS Proveedor,    
		 FORMAT(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy') AS FechaEnvioPedido,    
		 P.IdPeticionOferta,    
		 P.RecepcionServicio,    
		 FORMAT(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy') as FechaRecepcionServicio,  
		 PG.IdPedido AS PedidoGeneral,
		 ISNULL(P.Cerrado, 0) AS Cerrado,
		 P.IdSubcontratista AS ProveedorVentaId,
		 E.Nombre AS EstatusAprobacion,
		 O.IdEstatusOperacion AS IdEstatus,
		 FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy') AS SolitudCreadaEl  ,
		 UE.Nombre AS CreadoPor,
		 ISNULL(SAP.IdAceptacionPedido,0) AS IdAceptacionPedido ,
		 SR.Nombre AS  SolicitanteRequisicion,
		 PG.IdTipoPedido
		 into #ENCABEZADOS
		 FROM MM_SolicitudAceptacionPedido SAP
		 JOIN TA_Operacion O 
			ON SAP.IdSolicitudAceptacionPedido = O.IdDocumento
			AND O.IdTipoOperacion = @TipoOperacionId -->CTE 20
		JOIN TA_Estatus E
			ON O.IdEstatusOperacion = E.IdEstatus
		 JOIN MM_Pedido AS P    
			ON SAP.IdPedido = P.IdPedido
		 INNER JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6) 
		 LEFT JOIN S_Proveedor AS PV 
			ON P.IdSubcontratista = PV.IdProveedor
		 LEFT JOIN S_Usuario UE
			ON SAP.CreadorPor = UE.IdUsuario
		LEFT JOIN MM_SolicitudPedido SP
			ON P.IdSolicitudPedido	= SP.IdSolicitudPedido
		LEFT JOIN S_Usuario SR 
			ON SP.Solicitante = SR.IdUsuario
		 WHERE 
			P.IdProveedorCompras = @IdProveedor 
			AND SP.IdSolicitudPedido = @IdSolicitudPedido
			AND O.IdEstatusOperacion = 1

		SET @cantidadAprobacionPendientes = (SELECT count(1) from #ENCABEZADOS)

		WHILE @CONTADOROPERACION <= @cantidadAprobacionPendientes
	    BEGIN
	    set @idOperacionRow = (SELECT IdDocumento FROM #ENCABEZADOS WHERE RowNum = @CONTADOROPERACION)

			 		
        SELECT @EstatusSolicitanteId = TT.IdEstatus,
		@NoSecuenciaUsuarioSolicitante = TT.NoSecuencia		  
        FROM TA_Operacion O  
            JOIN TA_Tarea TT  
                ON O.IdOperacion = TT.IdOperacion  
        WHERE O.IdDocumento=@idOperacionRow
			 AND O.IdTipoOperacion=@TipoOperacionId	             
              AND TT.Activo = 1
			  AND TT.NombreTarea ='Solicitud Aceptación pedido' --> ES PARA VERIFICAR LAS APROBACIONES DEL SOLICITANTE
        ORDER BY TT.NoSecuencia	 DESC

        IF ISNULL(@EstatusSolicitanteId,0) = 1 --> EL APROBADOR NO.1 ESTA EN APROBACION
		BEGIN
			/*VALIDAR SI EL USUARIO ES APROBADOR NO. 1 ES EL USUARIO ACTUAL*/
			insert into #DOCUMENTOSID (iddocumentotemp,descripcion)
			SELECT
			@idOperacionRow as 'IdOperacion',
			 'ES_APROBADOR'  AS EsAprobador
			 FROM TA_Operacion O
			 JOIN TA_Tarea T 
				ON O.IdOperacion = T.IdOperacion
			 JOIN S_Usuario U
				ON T.IdAprobador = U.IdUsuario
			 JOIN TA_Estatus E
				ON T.IdEstatus = E.IdEstatus
			WHERE O.IdDocumento=@idOperacionRow
			AND O.IdTipoOperacion=@TipoOperacionId	
			AND T.IdAprobador=@IdUsuario
			AND T.Activo=1
		END 
		ELSE 
		BEGIN
			/*EL APROBADOR No.1 YA NO ESTA EN APROBACION POR QUE YA APROBO O RECHAZO*/
			/*VALIDAR SI LA APROBACION GENERAL TODAVIA ESTA EN APROBACION*/			
			 SELECT  
			 @EstatusIdAprobacionActual = O.IdEstatusOperacion,
			 @IdOperacion=O.IdOperacion
			 FROM TA_Operacion O
			 WHERE 	  
			 O.IdDocumento=@idOperacionRow
			 AND O.IdTipoOperacion=@TipoOperacionId
			 			
				/*VALIDAR SI EL USUARIO ACTUAL ES PARTE DEL GRUPO DE OBS*/
				insert into #DOCUMENTOSID (iddocumentotemp,descripcion)
				SELECT 
				@idOperacionRow as 'IdOperacion',
				EsAprobador='ES_APROBADOR'
				FROM DEA_UsuarioOBS UOBS
				JOIN S_Usuario U
				ON UOBS.IdUsuario=U.IdUsuario				
				WHERE UOBS.Activo = 1	
				AND UOBS.IdUsuario = @IdUsuario
				AND CASE WHEN ISNULL(@EstatusIdAprobacionActual,0) = 1 THEN 1 ELSE 0 END = 1 -->SOLO MOSTRAR SI LA APROBACIÒN GRAL AUN SIGUE EN APROBACION, FALTA QUE APRUEBE ALGUN USUARIO DE OBS
				GROUP BY U.Nombre, U.IdUsuario 							
			ORDER BY U.Nombre ASC 
	END 
	 SET @CONTADOROPERACION = (@CONTADOROPERACION + 1);
	END
	    

		SELECT * 
		INTO #ENCABEZADOSAPROBACIONUSUARIO
		FROM #ENCABEZADOS as E
		join #DOCUMENTOSID as D
		on E.idDocumento = D.iddocumentotemp
		

		SET @cantidadAprobacionPendientesUsuario = (SELECT COUNT(1) FROM #ENCABEZADOSAPROBACIONUSUARIO)

		IF ISNULL(@cantidadAprobacionPendientesUsuario,0) > 0
		BEGIN
			WHILE @contador <= @cantidadAprobacionPendientesUsuario
			BEGIN
				SET @listaPendientesHTML = ISNULL(@listaPendientesHTML,'')+ (SELECT  CONCAT('<p> <a href="https://procura.adinco.mx/02Proveedores/SolicitudAceptacionPedido.aspx?solicitud=',IdSolicitudAceptacionPedido,'&pedido=',IdPedido,'"> No. Solicitud de Aprobación: #',IdSolicitudAceptacionPedido,'</a> </p>') 
				FROM #ENCABEZADOSAPROBACIONUSUARIO 
				WHERE RowNum = @contador)
				SET @contador = (@contador + 1);
			END
			SET @HTML = (replace(@HTML,'##NombreUsuario##',@SolicitanteNuevo))
			SET @HTML = (replace(@HTML,'##Mensaje##',@Mensaje2))
			SET @HTML = (replace(@HTML,'##NumeroRequisicion##',@IdSolicitudPedido))
			SET @HTML = (replace(@HTML,'##Detalle##',@listaPendientesHTML))
			SET @HTML = (replace(@HTML,'##YEAR_ACTUAL##',CAST(YEAR(getdate()) as varchar(10))))
			-- INSERTA EN LA TABLA DE NOTIFICACIONES
			----------------------------------------
			-- INSERTA EN LA TABLA DE NOTIFICACIONES
			----------------------------------------
			select @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
			from Adinco..S_Notificacion

			select  
					@paraval = Para,
					@mensajeval = Mensaje
			from Adinco..S_Notificacion where IdNotificacion = @pIdNotificacion -1
			--ISNULL(@paraval,'') <> ISNULL(@para,'') and 
			IF Isnull(@mensajeval,'') <> isnull(@HTML,'')
			BEGIN
				insert into Adinco..S_Notificacion(
				IdNotificacion,Para,Asunto,Mensaje,FechaProgramadaEnvio,Enviada,FechaEnvio,
				CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De,EN_MsjEnviado)
				select @pIdNotificacion ,@para,'Requisición asignada',isnull(@HTML,''),getdate(),0,null,
				1,getdate(),null,null,'notificaciones@adinco.mx',null
			END
		END
		ELSE 
		BEGIN
			set @listaPendientesHTML = (SELECT CONCAT('<a href="https://procura.adinco.mx/01Proveedores/SP_DetalleSolicitudPedido.aspx?solped=',@IdSolicitudPedido,'&origin=s&tp_user=2" class="button">Ver solicitud Pedido.</a>'))
			SET @HTML = (replace(@HTML,'##NombreUsuario##',@SolicitanteNuevo))
			SET @HTML = (replace(@HTML,'##Mensaje##',@Mensaje1))
			SET @HTML = (replace(@HTML,'##NumeroRequisicion##',@IdSolicitudPedido))
			SET @HTML = (replace(@HTML,'##Detalle##',@listaPendientesHTML))
			SET @HTML = (replace(@HTML,'##YEAR_ACTUAL##',CAST(YEAR(getdate()) as varchar(10))))
			-- INSERTA EN LA TABLA DE NOTIFICACIONES
			----------------------------------------
			select @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
			from Adinco..S_Notificacion
			
			select  
					@paraval = Para,
					@mensajeval = Mensaje
			from Adinco..S_Notificacion where IdNotificacion = @pIdNotificacion -1

			IF Isnull(@mensajeval,'') <> isnull(@HTML,'')
			BEGIN
				insert into Adinco..S_Notificacion(
				IdNotificacion,Para,Asunto,Mensaje,FechaProgramadaEnvio,Enviada,FechaEnvio,
				CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De,EN_MsjEnviado)
				select @pIdNotificacion ,@para,'Requisición asignada',isnull(@HTML,''),getdate(),0,null,
				1,getdate(),null,null,'notificaciones@adinco.mx',null
			END
		END
END
