USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_ConsultarDetalleTimeline'
)
    DROP PROCEDURE DEA_SP_ConsultarDetalleTimeline;
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPedidosCliente]    Script Date: 05/07/2022 02:12:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Update: 11-07-2022
-- Description: Consulta  la linea de tiempo a partir de un pedido y una SAS
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_ConsultarDetalleTimeline] 
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,    
    @IdUsuario INT,
	@IdPedido INT,
	@IdContrato INT,
	@IdSolicitudAceptacionPedido INT,
    @Accion NVARCHAR(MAX) = '' --Filtro por campo 
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @EstatusValidar NVARCHAR(MAX),@EstadoEtapa NVARCHAR(MAX),@Etapa NVARCHAR(MAX), @ID_FLUJO_APROBACION INT, @AprobacionCNActual INT
    DECLARE @ID_OPERADORA INT
    DECLARE @EstatusIdSASActual INT, @OperacionSASId INT, @CantidadUsuarioOBS INT, @EstatusSolicitanteSASId INT 
    DECLARE @tbUsuarioOBS AS TABLE(IdUsuario INT, Nombre NVARCHAR(MAX)) 
	DECLARE @HayProceso INT = 0
	DECLARE @EtapaProcesoActual NVARCHAR(1000)
	DECLARE @EtapaActual NVARCHAR(1000), @EtapaSASActual NVARCHAR(1000)
	DECLARE @EtapaTimeLine NVARCHAR(1000)
	DECLARE @IdAceptacionPedido int
	DECLARE @IdNacionalidadProveedor int
	DECLARE @PermisosCargarCN int

	DECLARE @HISTORIAL TABLE (
		IdAceptacionPedido INT, 
	    IdDocumento INT,
	    Titulo NVARCHAR(MAX),
		SubtituloFechaRegistro  NVARCHAR(1000),		
		Subtitulo NVARCHAR(MAX),
		SubtituloEstado  NVARCHAR(1000),		
		Etapa NVARCHAR(100),		
		Fecha DATETIME,
		IdProceso INT,
		Url NVARCHAR(1000),
		IsEncriptado BIT,
		tieneHistorial BIT,
		Estatus  NVARCHAR(1000),
		EstadoEtapaTooltip NVARCHAR(1000),
		EstadoEtapa  NVARCHAR(1000) --> (FINALIZADA, DETENIDA, EN_PROCESO, SIN_INICIAR) --> SE USA PARA INDICAR QUE ICON MOSTRAR EN LA LINEA DE TIEMPO 
	);

	CREATE TABLE #AceptacionesPedidoExtranjeros(  
	 IdAceptacionPedido INT null, 
	 Creado DATETIME null,  	
	 IdAceptacionCartaPCN INT null,  
	 EstatusAprobacion NVARCHAR(100) NULL,
	 IdEstatus INT null
	);  
	
	CREATE TABLE #AceptacionConPedimentos (IdAceptacionPedido INT)	

	DECLARE @HISTORIALSEC TABLE (
		IdDocumento INT,
		Descripcion NVARCHAR(1000),
		Fecha NVARCHAR(1000),
		IdEstatus INT,
		tieneHistorial BIT,
		IsRedireccion BIT,
		Url NVARCHAR(1000),
		IsEncriptado BIT,
		Etapa NVARCHAR(100),
		EstadoHistorialTooltip NVARCHAR(1000),
		EstadoHistorial  NVARCHAR(1000) -->(FINALIZADA, DETENIDA, EN_PROCESO, SIN_INICIAR) --> SE USA PARA INDICAR QUE ICON MOSTRAR EN LA LINEA DE TIEMPO 
	);
	   	

	SELECT @IdAceptacionPedido = IdAceptacionPedido 
	FROM  MM_SolicitudAceptacionPedido 
	WHERE IdSolicitudAceptacionPedido =  @IdSolicitudAceptacionPedido

	SELECT @IdNacionalidadProveedor = IdNacionalidadProveedor,
	@ID_OPERADORA = IdProveedor 
	FROM  MM_AceptacionPedido
	WHERE IdAceptacionPedido =  @IdAceptacionPedido	

	BEGIN --> SI ES PROVEEDOR EXTRANJERO VALIDAR SI TIENE PERMISOS PARA CARGAR CN 
		IF @IdNacionalidadProveedor= 2
			BEGIN 
			     --> VALIDAR SI YA EXISTE UN CE RELACIONADO A LA ACEPTACION
				INSERT INTO #AceptacionConPedimentos(IdAceptacionPedido)
				SELECT        
				AP.IdAceptacionPedido  
				FROM MM_AceptacionPedido AP 
				JOIN MM_Pedido P 
					ON AP.IdPedido = P.IdPedido 
				JOIN FI_AceptacionPedido_PedimentoComprobante APC 
					ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
				JOIN FI_PedimentoComprobante PC 
					ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
				JOIN TA_Operacion O 
					ON PC.IdPedimentoComprobante  = O.IdDocumento
					AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
				WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
				AND AP.IdAceptacionPedido=@IdAceptacionPedido		
				AND ISNULL(PC.IdEstatusEliminado,0)<>1  --> NO MOSTRAR COMPROBANTES CON ESTATUS ELIMINADO		
				GROUP BY  AP.IdAceptacionPedido 

				--> OBTENER ACEPTACIONES DE PEDIDO QUE SON EXTRANJERAS PERO QUE LES FALTA INICIAR CARGA DE CONTENIDO NACIONAL, EXCEPTUANDO LAS ACEPTACIONES QUE YA TIENE UNA APROBACION DE PEDIMENTO
				INSERT INTO #AceptacionesPedidoExtranjeros(
				 IdAceptacionPedido, 
				 Creado,  		
				 IdAceptacionCartaPCN,  
				 EstatusAprobacion,
				 IdEstatus)
				SELECT  TOP	1	
				A.IdAceptacionPedido,  
				AC.CreadoEl,
				AC.IdAceptacionCartaPCN,
				CASE WHEN rel.PedirCarta = 1 THEN ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') ELSE 'Carta de CN Excluida' END AS EstatusAprobacion,  
				TV.IdTipoValidacionDoc
				FROM MM_Pedido AS P   		
				JOIN MM_AceptacionPedido AS A 
					ON P.IdPedido = A.IdPedido
				JOIN DEA_SolicitudCNProveedorExtranjero SCNP
					ON P.IdSubcontratista = SCNP.IdProveedor
					AND P.IdContrato =  SCNP.IdContrato
					AND SCNP.Activo=1  --> CTE QUE ESTE ACTIVO EL PERMISO
				JOIN S_Proveedor AS PV 
					ON P.IdProveedorCompras  = PV.IdProveedor
				JOIN RelacionCartaCNPedido rel 
					ON A.IdAceptacionPedido    = rel.IdAceptacionPedido 
					AND P.IdPedido  = rel.IdPedido 					
				LEFT JOIN MM_AceptacionCartaPCN AS AC 
					ON A.IdAceptacionPedido  = AC.IdAceptacionPedido
					AND ISNULL(AC.IdEstatusEliminado,0) <> 1  		
				LEFT JOIN S_TipoValidacionDoc AS TV 
					ON AC.IdEstatus  = TV.IdTipoValidacionDoc		
				LEFT JOIN #AceptacionConPedimentos ACPEA
					ON A.IdAceptacionPedido = ACPEA.IdAceptacionPedido
				WHERE A.IdAceptacionPedido = @IdAceptacionPedido  
				AND AC.IdAceptacionCartaPCN IS NULL   
				AND ACPEA.IdAceptacionPedido IS NULL --> QUE NO ESTE EN ESTA TABLA #AceptacionConPedimentos			
				AND ISNULL(A.IdEstatusEliminado,0)<>1 -->CTE OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
				AND ISNULL(A.IdNacionalidadProveedor,0) = 2 -->CTE NACIONALIDAD EXTRANJERA    
				ORDER BY AC.IdAceptacionCartaPCN DESC

		        --> CARTAS DE CONTENIDO NACIONAL QUE YA ESTAN CARGADAS EN PETROVENDOR
				INSERT INTO #AceptacionesPedidoExtranjeros(
				 IdAceptacionPedido, 
				 Creado,  		
				 IdAceptacionCartaPCN,  
				 EstatusAprobacion,
				 IdEstatus)
				SELECT  TOP	1   
				   A.IdAceptacionPedido, 
				   AC.CreadoEl,  		    
				   AC.IdAceptacionCartaPCN,  		 
				   CASE WHEN rel.PedirCarta = 1 THEN ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') ELSE 'Carta de CN Excluida' END AS EstatusAprobacion,  		    
				   TV.IdTipoValidacionDoc 
				   FROM dbo.MM_Pedido AS P  
				   JOIN MM_AceptacionPedido AS A 
						ON P.IdPedido = A.IdPedido 
				   JOIN dbo.MM_AceptacionCartaPCN AS AC 
						ON A.IdAceptacionPedido  = AC.IdAceptacionPedido 
						AND ISNULL(AC.IdEstatusEliminado,0)<>1  
				   JOIN dbo.S_TipoValidacionDoc AS TV
						ON AC.IdEstatus   = TV.IdTipoValidacionDoc
				   JOIN S_Proveedor AS PV 
						ON  P.IdProveedorCompras  = PV.IdProveedor 
				   JOIN dbo.RelacionCartaCNPedido rel 
						ON A.IdAceptacionPedido = rel.IdAceptacionPedido 
						AND  P.IdPedido = rel.IdPedido						
				   WHERE A.IdAceptacionPedido = @IdAceptacionPedido 
				   AND AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
							FROM dbo.MM_AceptacionCartaPCN A_PCN   
							WHERE A.IdAceptacionPedido = A_PCN.IdAceptacionPedido  
							ORDER BY A_PCN.CreadoEl DESC)   
				   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
				   AND ISNULL(A.IdNacionalidadProveedor,0) = 2 --> NACIONALIDAD EXTRANJERA     
		 
	END 
	END 

	BEGIN --> PEDIDO
		INSERT INTO @HISTORIAL
		(
			IdDocumento,
			Titulo,
			SubtituloFechaRegistro,
			SubtituloEstado,	
			Subtitulo,		
			Url,
			Etapa,
			tieneHistorial,
			IsEncriptado,
			Estatus
		)
		SELECT TOP 1
			IdDocumento		=	P.IdPedido,
			Titulo			=	'Pedido No. ' + CAST(PS.IdPedido AS NVARCHAR(100)),
			SubtituloFechaRegistro	=	CONCAT('Fecha de registro: ',FORMAT(P.CreadoEl,'dd/MM/yy HH:mm')),
			SubtituloEstado		=	CONCAT('Estatus: ',CASE
													   WHEN TOA.IdEstatusOperacion NOT IN (2) THEN E.Nombre 
													   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 1 THEN 'Confirmación Aceptada'
													   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 0 THEN 'Confirmación Rechazada'
													   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN  'Confirmación Vencida'
													   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0 THEN   'En Confirmación'
													   ELSE 'Confirmación No Iniciada '														
													   END),
			Subtitulo	=	CONCAT('Fecha de confirmación: ',ISNULL(FORMAT(P.FechaRecepcionServicio,'dd/MM/yy HH:mm'),'Sin registro')),
			Url	=	'',
			Etapa	=	'PEDIDO',
			tieneHistorial	=	1,
			IsEncriptado	=	0,
			Estado			=	(CASE
								WHEN TOA.IdEstatusOperacion NOT IN (2) THEN E.Nombre 
								WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 1 THEN 'Confirmación Aceptada'
								WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 0 THEN 'Confirmación Rechazada'
								WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN  'Confirmación Vencida'
								WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0 THEN   'En Confirmación'
								ELSE 'Confirmación No Iniciada '														
								END)
		FROM MM_Pedido AS P 
		JOIN TA_Operacion AS TOA
		 ON  P.IdSolicitudPedido = TOA.IdDocumento 
			AND TOA.IdTipoOperacion = 9
			AND P.Version = TOA.NoVersion
		JOIN MM_SolicitudPedido AS SP
			ON P.IdSolicitudPedido  = SP.IdSolicitudPedido
	    JOIN MM_HorasVigenciaPedido AS HV 
            ON P.IdPedido = HV.IdPedido
		JOIN TA_Estatus E
			ON TOA.IdEstatusOperacion = E.IdEstatus
		JOIN dbo.MM_Pedidos AS PS
			ON  P.IdPedido = PS.IdIdentificador 
			 AND  P.IdProveedorCompras = PS.IdProveedorCliente
			 AND PS.IdTipoPedido IN (2,4,6)
		JOIN S_Proveedor AS PR
			ON  P.IdSubcontratista = PR.IdProveedor		
		WHERE P.IdPedido = @IdPedido
		ORDER BY P.CreadoEl DESC;

		--> VALIDAR EL ESTADO DE LA ETAPA
		UPDATE @HISTORIAL
		SET EstadoEtapa = CASE WHEN Estatus = 'Confirmación Aceptada' THEN 'FINALIZADA' 
							   WHEN Estatus = 'Confirmación Rechazada' THEN 'DETENIDA' 
							   WHEN Estatus = 'Rechazada Vencida' THEN 'DETENIDA' 
							   ELSE 'EN_PROCESO' END 
		WHERE Etapa='PEDIDO'
	END 
    
	BEGIN  --> SAS
		INSERT INTO @HISTORIAL
		(
			IdDocumento,
			Titulo,
			SubtituloFechaRegistro,
			SubtituloEstado,	
			Subtitulo,		
			Url,
			Etapa,
			tieneHistorial,
			IsEncriptado,
			Estatus
		)
		SELECT	    TOP 1
					IdDocumento	=SAP.IdSolicitudAceptacionPedido,					
					Titulo		=	CONCAT('SAS No. ',CAST(SAP.IdSolicitudAceptacionPedido AS NVARCHAR(100))),
					SubtituloFechaRegistro	=	CONCAT('Fecha de registro: ',FORMAT(SAP.CreadoEl,'dd/MM/yy HH:mm')),    
					SubtituloEstado	=	CONCAT('Estatus: ',E.Nombre),
					Subtitulo	=	CONCAT('Aceptación de servicio: ',CASE WHEN ISNULL(SAP.IdAceptacionPedido,0) > 0 THEN CAST(SAP.IdAceptacionPedido AS NVARCHAR(20)) ELSE 'Sin registro' END),
					Url			=	'',
					Etapa		=	'SAS',
					tieneHistorial	=	1,
					IsEncriptado	=	0,--ISNULL(SAP.IdAceptacionPedido,  CAST(P.IdPedido AS NVARCHAR(10)) ,
					Estado	=	E.Nombre
		FROM		MM_SolicitudAceptacionPedido			SAP (NOLOCK)
		JOIN		TA_Operacion							O (NOLOCK)
		ON			SAP.IdSolicitudAceptacionPedido			=	O.IdDocumento
		AND			SAP.Activo								=	1
		AND			SAP.IdSolicitudAceptacionPedido			=   @IdSolicitudAceptacionPedido		
		JOIN		TA_TipoOperacion AS TOSAS
					ON O.IdTipoOperacion = TOSAS.IdTipoOperacion
					AND TOSAS.NombreOperacion				=	'Aprobación de solicitud de aceptación de pedido'
		JOIN		TA_Estatus								E (NOLOCK)
		ON			O.IdEstatusOperacion					=	E.IdEstatus
		JOIN		MM_Pedido								P (NOLOCK)
		ON			SAP.IdPedido							=	P.IdPedido
		AND			P.IdPedido								=   @IdPedido	
		WHERE		P.IdProveedorCompras					=	@IdProveedor 	
		

		UPDATE @HISTORIAL
		SET EstadoEtapa = CASE WHEN Estatus = 'Aprobada' THEN 'FINALIZADA' 							  
							   WHEN Estatus = 'Rechazada' THEN 'DETENIDA' 
							   WHEN Estatus = 'En Aprobación' THEN 'EN_PROCESO' 
							   ELSE 'SIN_INICIAR' END 
		WHERE Etapa='SAS'
	END

	BEGIN  --> CN	
	    IF @IdNacionalidadProveedor = 2
		BEGIN 

			--> OBTENER ACEPTACIONES DE PEDIDO QUE SON EXTRANJERAS PERO QUE LES FALTA INICIAR CARGA DE CONTENIDO NACIONAL, EXCEPTUANDO LAS ACEPTACIONES QUE YA TIENE UNA APROBACION DE PEDIMENTO
			INSERT INTO @HISTORIAL
				(
					IdDocumento,
					Titulo,
					SubtituloFechaRegistro,
					SubtituloEstado,	
					Subtitulo,		
					Url,
					Etapa,
					tieneHistorial,
					IsEncriptado,
					Estatus
				)
			SELECT   
				TOP 1
				IdDocumento	=	APCN.IdAceptacionCartaPCN,					
				Titulo		=	CONCAT('Carta CN No. ',CAST(APCN.IdAceptacionPedido AS NVARCHAR(100))),
				SubtituloFechaRegistro	=	CONCAT('Fecha de registro: ',ISNULL(FORMAT(APCN.Creado,'dd/MM/yy HH:mm'),'Sin registro')),    
				SubtituloEstado	=	CONCAT('Estatus: ',APCN.EstatusAprobacion),
				Subtitulo	=	'',
				Url			=	'',
				Etapa		=	'CN-EXTRANJERO',
				tieneHistorial	=	1,
				IsEncriptado	=	0,
				Estado	=	APCN.EstatusAprobacion		
			FROM #AceptacionesPedidoExtranjeros APCN 			
			
			SELECT @HayProceso= COUNT(1) 
			FROM @HISTORIAL
			WHERE Etapa		=	'CN-EXTRANJERO'

			IF (@HayProceso=0)
			BEGIN	

				SELECT @EtapaSASActual= EstadoEtapa
				FROM @HISTORIAL WHERE Etapa='SAS'

				IF @EtapaSASActual='FINALIZADA'
				BEGIN 
					
					INSERT INTO @HISTORIAL
					(
						IdDocumento,
						Titulo,
						SubtituloFechaRegistro,
						SubtituloEstado,	
						Subtitulo,		
						Url,
						Etapa,
						tieneHistorial,
						IsEncriptado,
						Estatus
					)
					SELECT		
					IdDocumento	=	0,					
					Titulo		=	'Carta CN',
					SubtituloFechaRegistro	=	'Fecha de registro: Sin registro',    
					SubtituloEstado	=	'Estatus: Carta de CN Excluida',
					Subtitulo	=	'Proveedor extranjero sin permisos de cargar CN',
					Url			=	'',
					Etapa		=	'CN-EXTRANJERO',
					tieneHistorial	=	1,
					IsEncriptado	=	0,
					Estado	=	'Carta de CN Excluida'

				END 
				ELSE 
				BEGIN
					INSERT INTO @HISTORIAL
					(
						IdDocumento,
						Titulo,
						SubtituloFechaRegistro,
						SubtituloEstado,	
						Subtitulo,		
						Url,
						Etapa,
						tieneHistorial,
						IsEncriptado,
						Estatus
					)
					SELECT		
					IdDocumento	=	0,					
					Titulo		=	'Carta CN',
					SubtituloFechaRegistro	=	'Fecha de registro: Sin registro',    
					SubtituloEstado	=	'Estatus: Sin registro',
					Subtitulo	=	'',
					Url			=	'',
					Etapa		=	'CN-EXTRANJERO',
					tieneHistorial	=	1,
					IsEncriptado	=	0,
					Estado	=	'SIN_INICIAR'
				END 
			END 
		END 
		ELSE 
		BEGIN 
			--> CARTAS DE CONTENIDO NACIONAL PARA PROVEEDORES NACIONALES
			INSERT INTO @HISTORIAL
			(
				IdDocumento,
				Titulo,
				SubtituloFechaRegistro,
				SubtituloEstado,	
				Subtitulo,		
				Url,
				Etapa,
				tieneHistorial,
				IsEncriptado,
				Estatus
			)
			SELECT		TOP 1
						IdDocumento	=	CASE WHEN RCN.PedirCarta = 1 THEN  AC.IdAceptacionCartaPCN ELSE 0 END,					
						Titulo		=	CONCAT('Carta CN No. ',CAST(AP.IdAceptacionPedido AS NVARCHAR(100))),
						SubtituloFechaRegistro	=	CONCAT('Fecha de registro: ',ISNULL(FORMAT(AC.CreadoEl,'dd/MM/yy HH:mm'),'Sin registro')),    
						SubtituloEstado	=	CONCAT('Estatus: ',CASE WHEN RCN.PedirCarta = 1 THEN  ISNULL(TD.TipoValidacion,'Sin iniciar aprobación') ELSE 'Carta de CN Excluida' END),
						Subtitulo	=	'',
						Url			=	'',
						Etapa		=	'CN',
						tieneHistorial	=	1,
						IsEncriptado	=	0,
						Estado	= CASE WHEN RCN.PedirCarta = 1 THEN  ISNULL(TD.TipoValidacion,'Sin iniciar aprobación') ELSE 'Carta de CN Excluida' END
			FROM MM_AceptacionPedido AS AP  (NOLOCK)
			JOIN RelacionCartaCNPedido RCN  (NOLOCK)
				ON AP.IdAceptacionPedido = RCN.IdAceptacionPedido
			LEFT JOIN MM_AceptacionCartaPCN AS AC  (NOLOCK)
				ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
				AND ISNULL(AC.IdEstatusEliminado,0) <>1   --> QUE NO ESTEN ELIMINADOS
			LEFT JOIN S_Documento_S3 AS D  (NOLOCK)
				ON AC.IdDocumento = D.IdDocumento	
			LEFT JOIN S_TipoValidacionDoc AS TD   (NOLOCK)
				ON AC.IdEstatus = TD.IdTipoValidacionDoc
			WHERE AP.IdAceptacionPedido=@IdAceptacionPedido
			AND ISNULL(AP.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA     
			ORDER BY  AC.CreadoEl DESC;		


			SELECT @HayProceso= COUNT(1) 
			FROM @HISTORIAL
			WHERE Etapa  IN ('CN')

			IF (@HayProceso=0)		
				INSERT INTO @HISTORIAL
				(
					IdDocumento,
					Titulo,
					SubtituloFechaRegistro,
					SubtituloEstado,	
					Subtitulo,		
					Url,
					Etapa,
					tieneHistorial,
					IsEncriptado,
					Estatus
				)
				SELECT		
				IdDocumento	=	0,					
				Titulo		=	'Carta CN',
				SubtituloFechaRegistro	=	'Fecha de registro: Sin registro',    
				SubtituloEstado	=	'Estatus: Sin registro',
				Subtitulo	=	'',
				Url			=	'',
				Proceso		=	 'CN',
				tieneHistorial	=	1,
				IsEncriptado	=	0,
				Estado	=	''

		END 	
			 
				UPDATE @HISTORIAL
				SET EstadoEtapa = CASE WHEN Estatus = 'Aprobada' THEN 'FINALIZADA' 
									   WHEN Estatus = 'Carta de CN Excluida' THEN 'FINALIZADA'
									   WHEN Estatus = 'Rechazada' THEN 'DETENIDA' 
									   WHEN Estatus = 'En Aprobación' THEN 'EN_PROCESO' 
									   WHEN Estatus = 'Sin iniciar aprobación' THEN 'EN_PROCESO'
									   ELSE 'SIN_INICIAR' END 
				WHERE Etapa IN ('CN','CN-EXTRANJERO')
				

	END
	
	BEGIN  --> FACTURA

	  IF @IdNacionalidadProveedor = 2
	  BEGIN 
		--> ES FLUJO DE EXTRANJERO VALIDAR SI TIENE PERMISOS PARA CARGAR CN 
		INSERT INTO @HISTORIAL
			(
				IdDocumento,
				Titulo,
				SubtituloFechaRegistro,
				SubtituloEstado,	
				Subtitulo,		
				Url,
				Etapa,
				tieneHistorial,
				IsEncriptado,
				Estatus
			)


		      SELECT TOP 1
						IdDocumento	=	PC.IdPedimentoComprobante,					
						Titulo		=	'Comprobante Extranjero',
						SubtituloFechaRegistro	=	CONCAT('Fecha de registro: ',ISNULL(FORMAT(O.FechaRegistro,'dd/MM/yy HH:mm'),'Sin registro')),    
						SubtituloEstado	=	CONCAT('Estatus: ',CASE
												WHEN O.IdEstatusOperacion IS NOT NULL THEN
													E.Nombre			
												ELSE
													'Sin iniciar aprobación' END),
						Subtitulo	=	'',
						Url			=	'',
						Proceso		=	'COMPROBANTE_EXTRANJERO',
						tieneHistorial	=	1,
						IsEncriptado	=	0,
						Estado	=	ISNULL(E.Nombre,'Sin iniciar aprobación')	
				FROM
				 dbo.MM_AceptacionPedido AP 				
				 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
					ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
				 LEFT JOIN dbo.FI_PedimentoComprobante PC 
					ON APC.IdPedimentoComprobante  = PC.IdPedimentoComprobante
					AND ISNULL(PC.IdEstatusEliminado,0)<>1 --> PEDIMENTO COMPROBANTE NO ESTE ELIMINADO
				 LEFT JOIN dbo.TA_Operacion O 
					ON PC.IdPedimentoComprobante  = O.IdDocumento
					AND O.IdTipoOperacion=16 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
				 LEFT JOIN dbo.TA_Estatus AS E
						ON O.IdEstatusOperacion = E.IdEstatus 		 		 
				 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA	
				 AND AP.IdAceptacionPedido = @IdAceptacionPedido	 		 
				 AND AP.IdAceptacionPedido NOT IN (SELECT IdAceptacionPedido FROM #AceptacionesPedidoExtranjeros WHERE EstatusAprobacion NOT IN ('Aprobada','Carta de CN Excluida'))
		 
	   END 
	  ELSE 
	  BEGIN --> ES NACIONALIDAD NACIONAL ENTONCES ES FACTURA
		INSERT INTO @HISTORIAL
		(
			IdDocumento,
			Titulo,
			SubtituloFechaRegistro,
			SubtituloEstado,	
			Subtitulo,		
			Url,
			Etapa,
			tieneHistorial,
			IsEncriptado,
			Estatus
		)
		 SELECT     TOP 1
					IdDocumento	=	AF.IdAceptacionFactura,					
					Titulo		=	'Factura',
					SubtituloFechaRegistro	=	CONCAT('Fecha de registro: ',ISNULL(FORMAT(O.FechaRegistro,'dd/MM/yy HH:mm'),'Sin registro')),    
					SubtituloEstado	=	CONCAT('Estatus: ',ISNULL(E.Nombre,'Sin registro')),
					Subtitulo	=	ISNULL('UUID: '+F.UUID,''),
					Url			=	'',
					Etapa		=	'FACTURA',
					tieneHistorial	=	1,
					IsEncriptado	=	0,
					Estado	=	ISNULL(E.Nombre,'Sin iniciar aprobación')
        FROM MM_AceptacionPedido AS AP  (NOLOCK)               
            LEFT JOIN dbo.MM_AceptacionCartaPCN AS APC  (NOLOCK)
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido  
                   AND (APC.IdAceptacionCartaPCN IS NOT NULL) --SI NO SE SOLICITA UNA CN, SE MUESTRA UNA ACEPTACION DE SERVICIO     
                   AND ISNULL(APC.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTEN ELIMINADAS  
            LEFT JOIN dbo.MM_AceptacionFactura AS AF  (NOLOCK)
                ON AP.IdAceptacionPedido   = AF.IdAceptacionPedido 
                   AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTEN ELIMINADAS     
            LEFT JOIN dbo.TA_Operacion AS O  (NOLOCK)
                ON O.IdDocumento = AF.IdAceptacionFactura 
				AND O.IdTipoOperacion = 10  --> CTE FACTURA - APROBACIÓN
            LEFT JOIN dbo.TA_Estatus AS E  (NOLOCK)
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN dbo.FI_Factura F  (NOLOCK)
                ON F.IdFactura = AF.IdFactura  
            LEFT JOIN dbo.RelacionCartaCNPedido rel  (NOLOCK)
                ON rel.IdAceptacionPedido = AP.IdAceptacionPedido 
                 AND rel.PedirCarta = 0  			
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido  
              AND  
              (  
                  APC.IdEstatus = 2  
                  OR rel.PedirCarta = 0  
              )               
              AND  
              (  
                  APC.FechaEvaluacion IS NOT NULL  
                  OR rel.PedirCarta = 0  
              )  
       AND ISNULL(AP.IdNacionalidadProveedor,1)<> 2 --> QUE NO SE EXTRANJERA 
        GROUP BY AP.IdAceptacionPedido,
                 E.Nombre,  
                 AF.IdEstatusEliminado,  
                 E.IdEstatus,  
				 AF.IdAceptacionFactura,
				 O.FechaRegistro,
				 F.UUID			             
     
		END 
		
		SELECT @HayProceso= COUNT(1) 
		FROM @HISTORIAL
		WHERE Etapa IN	('COMPROBANTE_EXTRANJERO','FACTURA')
			
		IF (@HayProceso=0)
		BEGIN
			INSERT INTO @HISTORIAL
			(
				IdDocumento,
				Titulo,
				SubtituloFechaRegistro,
				SubtituloEstado,	
				Subtitulo,		
				Url,
				Etapa,
				tieneHistorial,
				IsEncriptado,
				Estatus
			)
			SELECT		
			IdDocumento	=	0,					
			Titulo		=	CASE WHEN @IdNacionalidadProveedor = 2 THEN 'Comprobante Extranjero' ELSE 'Factura' END,
			SubtituloFechaRegistro	=	'Fecha de registro: Sin registro',    
			SubtituloEstado	=	'Estatus: Sin registro',
			Subtitulo	=	'',
			Url			=	'',
			Etapa		=	CASE WHEN @IdNacionalidadProveedor = 2 THEN 'COMPROBANTE_EXTRANJERO' ELSE 'FACTURA' END,
			tieneHistorial	=	1,
			IsEncriptado	=	0,
			Estado	=	''
		END 

			UPDATE @HISTORIAL
			SET EstadoEtapa = CASE WHEN Estatus = 'Aprobada' THEN 'FINALIZADA' 							  
									WHEN Estatus = 'Rechazada' THEN 'DETENIDA' 
									WHEN Estatus = 'En Aprobación' THEN 'EN_PROCESO'
									WHEN Estatus = 'Sin iniciar aprobación' THEN 'EN_PROCESO'
									ELSE 'SIN_INICIAR' END 
			WHERE Etapa IN	('COMPROBANTE_EXTRANJERO','FACTURA')
	END 
  
    
   --> CALCULAR LA ETAPA DEL PROCESO DE UNA SAS
   BEGIN 
	   UPDATE @HISTORIAL
	   SET IdAceptacionPedido =@IdAceptacionPedido


	   SELECT @EtapaActual = 'Facturación',	
	   @EtapaProcesoActual = CASE WHEN Estatus = 'Aprobada' THEN 'Completado' 							  
						  WHEN Estatus = 'Rechazada' THEN 'Rechazada - Por cargar Factura/CE' 
						  WHEN Estatus = 'En Aprobación' THEN 'En aprobación'
						  WHEN Estatus = 'Sin iniciar aprobación' THEN 'Por cargar Factura/CE' END
	   FROM @HISTORIAL
	   WHERE Etapa IN	('COMPROBANTE_EXTRANJERO','FACTURA')
	   AND EstadoEtapa NOT IN ('SIN_INICIAR')   
   

	   SELECT @EtapaActual = 'Contenido Nacional',	
	   @EtapaProcesoActual =  CASE WHEN Estatus = 'Aprobada' THEN 'Carta de CN Aprobada por OBS' 
										  WHEN Estatus = 'Carta de CN Excluida' THEN 'Carta Excluida'
										   WHEN Estatus = 'Rechazada' THEN 'Carta CN Rechazada por OBS' 
										   WHEN Estatus = 'En Aprobación' THEN 'Carta CN en aprobación por OBS' 
										   WHEN Estatus = 'Sin iniciar aprobación' THEN 'Por  cargar Carta CN Petrovendor' 
										   END
	   FROM @HISTORIAL 		
	   WHERE Etapa IN ('CN','CN-EXTRANJERO')
	   AND EstadoEtapa NOT IN ('SIN_INICIAR','FINALIZADA')    

	   --select * from  @HISTORIAL WHERE Etapa IN ('CN','CN-EXTRANJERO')
	   SELECT @EtapaActual = 'Solicitud de aceptación de servicio',	
	   @EtapaProcesoActual =  CASE WHEN Estatus = 'Aprobada' THEN   'Aprobada por OBS'							  
								   WHEN Estatus = 'Rechazada' THEN 'Rechazada por OBS' 
								   WHEN Estatus = 'En Aprobación' THEN 'En aprobación por OBS' END
	   FROM @HISTORIAL
	   WHERE Etapa IN ('SAS')
	   AND EstadoEtapa NOT IN ('SIN_INICIAR','FINALIZADA')     
	   
	   IF @EtapaActual = 'Solicitud de aceptación de servicio'
	   BEGIN --> VALIDAR QUIEN ESTA APROBANDO SI SOLICITANTE U OBS SIEMPRE Y CUANDO AUN ESTE EN APROBACIÓN

		   /*OBTENER ESTATUS ACTUAL DE LA APROBACION GRAL*/
			 SELECT 
			 @OperacionSASId=O.IdOperacion
			 FROM TA_Operacion O
			 JOIN TA_TipoOperacion AS TOSAS
				ON O.IdTipoOperacion = TOSAS.IdTipoOperacion
				AND TOSAS.NombreOperacion	=	'Aprobación de solicitud de aceptación de pedido'
			 WHERE 	O.IdDocumento=@IdSolicitudAceptacionPedido	
			 
			SELECT @EstatusSolicitanteSASId = T.IdEstatus		 			
			FROM TA_Tarea T 
			WHERE T.IdOperacion=@OperacionSASId		
			AND T.Activo=1 AND T.NoSecuencia=1 ---> UN SOLICITANTE SIEMPRE ES EL NUM SECUENCIA #1

			 IF @EtapaProcesoActual IN ('En aprobación por OBS')
			 BEGIN 			

				IF @EstatusSolicitanteSASId = 1 --> CTE TAREA EN APROBACIÓN
				BEGIN 
					SET @EtapaProcesoActual = 'En aprobación por Solicitante'
				END 				 
			 END 

			 IF @EtapaProcesoActual IN ('Rechazada por OBS')
			 BEGIN 	
				IF @EstatusSolicitanteSASId =3 --> CTE TAREA RECHAZADA
				BEGIN 
					SET @EtapaProcesoActual = 'Rechazada por Solicitante'
				END 				 
			 END 


		END 

	   SET @EtapaTimeLine = CONCAT(ISNULL(@EtapaActual,'-'),' / ' ,ISNULL(@EtapaProcesoActual,'-'))
	   IF @EtapaActual = 'Facturación' AND  @EtapaProcesoActual ='Completado'
			SET @EtapaTimeLine='Completado'
   END 
  
  
  BEGIN --> GENERAR HISTORICO POR DETALLE DEL PROCESO  
	  BEGIN  -->HISTORIAL DETALLE FACTURA/COMPROBANTE EXTRANJERO

		SELECT @EstadoEtapa = EstadoEtapa,	
		@EstatusValidar =  Estatus ,
		@Etapa =Etapa
		FROM @HISTORIAL
		WHERE Etapa IN	('COMPROBANTE_EXTRANJERO','FACTURA')
	
	 --  SELECT  @EstadoEtapa,	
		--@EstatusValidar ,
		--@Etapa

		IF @Etapa ='FACTURA'
		BEGIN 
		    
			--> OBTENER EL FLUJO DE APROBACIÓN DE LA FACTURA SI NO HA INICIADO EL FLUJO DE APROBACIÓN
			IF EXISTS (SELECT 1 FROM DEA_Proveedor WHERE IdProveedor = @ID_OPERADORA)
			BEGIN -- CONSULTAMOS EL FLUJO DE APROBACION DE FATURA RELACIONADO CON EL CENTRO DE COSTO DE LA REQUISICION
				
			SET @ID_FLUJO_APROBACION = (SELECT TOP 1 
											RCFA.IdFlujoFactura 
										FROM MM_SolicitudPedido SP
										LEFT JOIN MM_Pedido P 
											ON SP.IdSolicitudPedido	 = P.IdSolicitudPedido 								
										LEFT JOIN MM_SolicitudPedidoDetalle SPD
											ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido 
										LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL
											ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle  
										LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA 
											ON SPDL.IdCentroCosto = RCFA.IdCentroCosto
										WHERE P.IdPedido = @IdPedido 
											AND RCFA.IdFlujoFactura IS NOT NULL
											AND RCFA.Activo = 1
										GROUP BY RCFA.IdFlujoFactura,RCFA.IdCentroCosto);
		   
			END
			ELSE
			BEGIN
					--CONSULTAMOS EL FLUJO DE APROBACION DE FACTURA PRETERMINADO DE LA OPERADORA
	    			SET @ID_FLUJO_APROBACION = (SELECT TOP 1 
													FT.IdFlujoTarea
													FROM MM_Pedido   AS P 
													JOIN S_Proveedor AS PR 
													ON  P.IdProveedorCompras = PR.IdProveedor
													JOIN TA_FlujoTarea AS FT 
													ON P.IdProveedorCompras = FT.IdProveedor 
													WHERE P.IdPedido = @IdPedido 
														AND FT.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
														AND FT.Activo=1 
														AND FT.Predeterminado=1);
			END;

			IF @EstadoEtapa='SIN_INICIAR' 
			BEGIN 		
				

				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT 
				IdDocumento = 0,
				Descripcion= 'El proveedor registra la Factura',
				Fecha= NULL,
				Etapa=@Etapa,
				EstadoHistorial='SIN_INICIAR'

				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT
					US.IdUsuario,			
					CONCAT('El usuario ',ISNULL(US.Nombre,'-'),' realiza aprobación de factura'),
					NULL,
					@Etapa,
					'SIN_INICIAR'
				FROM TA_Aprobador AS APR
					JOIN dbo.S_Usuario AS US 
						ON US.IdUsuario = APR.IdUsuario
						AND US.Activo = 1
				WHERE APR.IdFlujoTarea = @ID_FLUJO_APROBACION
				GROUP BY US.IdUsuario,
						 APR.NoSecuencia,
						 US.Nombre,
						 US.Correo
				ORDER BY APR.NoSecuencia ASC;	

		END 
		
			IF(@EstadoEtapa='EN_PROCESO' AND @EstatusValidar = 'Sin iniciar aprobación')
			BEGIN 

				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT 
				IdDocumento = 0,
				Descripcion= 'El proveedor registra la Factura',
				Fecha= NULL,
				Etapa=@Etapa,
				EstadoHistorial='EN_PROCESO'

				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT
					US.IdUsuario,			
					CONCAT('El usuario ',ISNULL(US.Nombre,'-'),' realiza aprobación de factura'),
					NULL,
					@Etapa,
					'SIN_INICIAR'
				FROM TA_Aprobador AS APR
					JOIN dbo.S_Usuario AS US 
						ON US.IdUsuario = APR.IdUsuario
						AND US.Activo = 1
				WHERE APR.IdFlujoTarea = @ID_FLUJO_APROBACION
				GROUP BY US.IdUsuario,
						 APR.NoSecuencia,
						 US.Nombre,
						 US.Correo
				ORDER BY APR.NoSecuencia ASC;	
			END 
					   
			IF(@EstadoEtapa<>'SIN_INICIAR' AND @EstatusValidar <> 'Sin iniciar aprobación')
				BEGIN 		
			
					INSERT INTO @HISTORIALSEC
					(
						IdDocumento,
						Descripcion,
						Fecha,
						Etapa,
						EstadoHistorial
					)
					SELECT
					AF.IdAceptacionFactura,
					CONCAT(ISNULL(US.Nombre + ' de ','') , ISNULL(PR.RazonSocial,''), ' registró la factura'),
					FORMAT(OP.FechaRegistro,'dd/MM/yyyy HH:mm'),
					'FACTURA',
					'FINALIZADA'
					FROM dbo.MM_AceptacionFactura AS AF
					JOIN dbo.MM_AceptacionPedido AS AP
						ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
					LEFT JOIN MM_Pedido AS P
						ON AP.IdPedido = P.IdPedido 
					LEFT JOIN dbo.S_Proveedor AS PR
						ON  P.IdSubcontratista = PR.IdProveedor
					LEFT JOIN dbo.TA_Operacion AS OP
						ON AF.IdAceptacionFactura =  OP.IdDocumento 
						AND OP.IdTipoOperacion = 10 --> CTE APROBACION DE FACTURA
					LEFT JOIN dbo.FI_Factura AS F
						ON  AF.IdFactura = F.IdFactura
					LEFT JOIN dbo.S_Usuario AS US
						ON F.CreadoPor = US.IdUsuario 
					WHERE AF.IdAceptacionPedido = @IdAceptacionPedido				
					

					INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT
				AF.IdAceptacionFactura,
				CASE 
					WHEN T.IdEstatus = 1 THEN ISNULL(US.Nombre,'') + ' tiene pendiente la aprobación de la factura' 
					WHEN T.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó la factura' 
					WHEN T.IdEstatus = 3 THEN ISNULL(US.Nombre,'')  + ' rechazó la factura' 
					WHEN T.IdEstatus = 4 THEN ISNULL(US.Nombre,'')  + ' se le ha cancelado la aprobación de factura'
					WHEN T.IdEstatus = 6 THEN ISNULL(US.Nombre,'')  + '(Asignador) cancelo la factura' 
					WHEN T.IdEstatus = 7 THEN ISNULL(US.Nombre,'')  + ' reasigno la factura'
				END,
				FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),
				'FACTURA',
				CASE 
					WHEN T.IdEstatus = 1 THEN 'EN_PROCESO' 
					WHEN T.IdEstatus = 2 THEN 'FINALIZADA' 
					WHEN T.IdEstatus = 3 THEN 'DETENIDA' 
					WHEN T.IdEstatus = 4 THEN 'DETENIDA' 
					WHEN T.IdEstatus = 6 THEN 'DETENIDA' 
					WHEN T.IdEstatus = 7 THEN 'DETENIDA'
				END
				FROM MM_AceptacionFactura AS AF
				LEFT JOIN dbo.MM_AceptacionPedido AS AP
					ON AF.IdAceptacionPedido= AP.IdAceptacionPedido 
				LEFT JOIN dbo.MM_Pedido AS P
					ON AP.IdPedido= P.IdPedido 			
				LEFT JOIN dbo.TA_Operacion AS OP
					ON AF.IdAceptacionFactura= OP.IdDocumento 
					AND OP.IdTipoOperacion = 10	--> CTE APROBACION DE FACTURA	
				LEFT JOIN dbo.TA_Tarea AS T
					ON OP.IdOperacion =T.IdOperacion 
				LEFT JOIN S_Usuario AS US
					ON T.IdAprobador =US.IdUsuario 
				WHERE AF.IdAceptacionPedido = @IdAceptacionPedido
				AND T.Activo =1	
			END 
				
			IF(@EstadoEtapa='DETENIDA')
				BEGIN 
					INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						AF.IdAceptacionFactura,
						CONCAT('El proveedor ', ISNULL(PR.RazonSocial,''), ' debe registrar nuevamente una factura'),
						NULL,
						'FACTURA',
						'EN_PROCESO'
					FROM MM_AceptacionFactura AS AF
						JOIN dbo.MM_AceptacionPedido AS AP
							ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
						LEFT JOIN MM_Pedido AS P
							ON AP.IdPedido = P.IdPedido 
						LEFT JOIN S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor					
					WHERE AF.IdAceptacionPedido = @IdAceptacionPedido
				
				END 
		END 

		IF @Etapa ='COMPROBANTE_EXTRANJERO'
		BEGIN 
			IF(@EstadoEtapa='SIN_INICIAR' OR @EstatusValidar = 'Sin iniciar aprobación')
			BEGIN 

				IF EXISTS (SELECT 1 FROM DEA_Proveedor WHERE IdProveedor = @ID_OPERADORA)
			BEGIN -- CONSULTAMOS EL FLUJO DE APROBACION DE CE RELACIONADO CON EL CENTRO DE COSTO DE LA REQUISICION
				SET @ID_FLUJO_APROBACION =
					(
						SELECT TOP 1 RCFA.IdFlujoComprobante
						FROM dbo.MM_SolicitudPedido SP
							 LEFT JOIN dbo.MM_Pedido P 
								ON SP.IdSolicitudPedido  = P.IdSolicitudPedido                        
							 LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD 
								ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido 
							 LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL 
								ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle 
							 LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA 
								ON SPDL.IdCentroCosto = RCFA.IdCentroCosto 
						WHERE P.IdPedido = @IdPedido
							  AND RCFA.IdFlujoComprobante IS NOT NULL
							  AND RCFA.Activo = 1
						GROUP BY RCFA.IdFlujoComprobante, 
								 RCFA.IdCentroCosto
					);
			END
			ELSE 
			BEGIN 
				  SET @ID_FLUJO_APROBACION =
					(
						SELECT TOP 1 FT.IdFlujoTarea
						FROM dbo.TA_FlujoTarea FT
						WHERE FT.IdProveedor = @ID_OPERADORA
							  AND FT.Predeterminado = 1
							  AND FT.IdTipoOperacion = 16 --CTE DONDE 16 ES PEDIMENTO/COMPROBANTE 
					); 
			END 

				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT 
					IdDocumento = P.IdPedido,
					Descripcion= CONCAT(ISNULL(PR.RazonSocial,''),' registra el Comprobante Extranjero'),
					Fecha=  NULL,
					Etapa=@Etapa,
					EstadoHistorial= CASE WHEN @EstatusValidar ='Sin iniciar aprobación' THEN 'EN_PROCESO' ELSE 'SIN_INICIAR' END 
					FROM MM_Pedido AS P 		
					JOIN S_Proveedor AS PR 
					ON P.IdSubcontratista = PR.IdProveedor  		  
					WHERE P.IdPedido =@IdPedido		
			
				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT 
				IdDocumento = 0,
				Descripcion=CONCAT (ISNULL(U.Nombre,'El aprobador'),' aprueba el Comprobante Extranjero'),
				Fecha=  NULL,
				Etapa=@Etapa,
				EstadoHistorial='SIN_INICIAR'
				FROM TA_Aprobador AS A
				JOIN S_Usuario AS U 
					ON A.IdUsuario  = U.IdUsuario 
						AND U.Activo = 1 
						AND ISNULL(U.IsEliminado,0) = 0
				 WHERE A.IdFlujoTarea = @ID_FLUJO_APROBACION
				 ORDER BY  NoSecuencia ASC

			END

			IF(@EstadoEtapa<>'SIN_INICIAR' AND @EstatusValidar <> 'Sin iniciar aprobación')
			BEGIN 
		
			    --> REGISTRO DE CE
				INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
				SELECT 
				IdDocumento = PC.IdPedimentoComprobante,
				Descripcion= CONCAT(ISNULL(UC.Nombre,'-'),' de ',ISNULL(PR.RazonSocial,''),' registró el Comprobante Extranjero'),
				Fecha=  FORMAT(O.FechaRegistro,'dd/MM/yyyy HH:mm'),
				Etapa=@Etapa,
				EstadoHistorial='FINALIZADA'
			  FROM MM_AceptacionPedido AS AP		 
			  JOIN MM_Pedido AS P 
				ON AP.IdPedido	 = P.IdPedido  
			  JOIN S_Proveedor AS PR 
				ON  P.IdSubcontratista = PR.IdProveedor
			  JOIN FI_AceptacionPedido_PedimentoComprobante AS AP_PC 
				ON AP.IdAceptacionPedido = AP_PC.IdAceptacionPedido
			  JOIN FI_PedimentoComprobante PC 
				ON AP_PC.IdPedimentoComprobante = PC.IdPedimentoComprobante
			  JOIN TA_Operacion O 
				ON PC.IdPedimentoComprobante = O.IdDocumento  
				AND O.IdTipoOperacion=16 --> CTE APROBACIÓN DE CE
			  JOIN S_Usuario UC
				ON O.IdAsignador = UC.IdUsuario
			  WHERE AP.IdAceptacionPedido =@IdAceptacionPedido	
			
			 -->LISTA DE APROBADORES
			 INSERT INTO @HISTORIALSEC
				(
					IdDocumento,
					Descripcion,
					Fecha,
					Etapa,
					EstadoHistorial
				)
			 SELECT 
				IdDocumento = T.IdTarea,
				Descripcion= CASE 
					WHEN T.IdEstatus = 1 THEN ISNULL(US.Nombre,'') + ' tiene pendiente la aprobación del comprobante extranjero' 
					WHEN T.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó el comprobante extranjero' 
					WHEN T.IdEstatus = 3 THEN ISNULL(US.Nombre,'')  + ' rechazó el comprobante extranjero' 
					WHEN T.IdEstatus = 4 THEN ISNULL(US.Nombre,'')  + ' se le ha cancelado la aprobación del comprobante extranjero'
					WHEN T.IdEstatus = 6 THEN ISNULL(US.Nombre,'')  + '(Asignador) cancelo la aprobación del comprobante extranjero' 
					WHEN T.IdEstatus = 7 THEN ISNULL(US.Nombre,'')  + ' reasignó la aprobación del comprobante extranjero'
				END,
				Fecha=  FORMAT(O.FechaRegistro,'dd/MM/yyyy HH:mm'),
				Etapa=@Etapa,
				EstadoHistorial=CASE 
									WHEN T.IdEstatus = 1 THEN 'EN_PROCESO' 
									WHEN T.IdEstatus = 2 THEN 'FINALIZADA' 
									WHEN T.IdEstatus = 3 THEN 'DETENIDA' 
									WHEN T.IdEstatus = 4 THEN 'DETENIDA' 
									WHEN T.IdEstatus = 6 THEN 'DETENIDA' 
									WHEN T.IdEstatus = 7 THEN 'DETENIDA'
								END
			  FROM FI_AceptacionPedido_PedimentoComprobante AS AP_PC 		
			  JOIN FI_PedimentoComprobante PC 
				ON AP_PC.IdPedimentoComprobante = PC.IdPedimentoComprobante
			  JOIN TA_Operacion O 
				ON  PC.IdPedimentoComprobante  = O.IdDocumento 
				AND O.IdTipoOperacion=16 --> CTE APROBACIÓN DE CE
			 JOIN TA_Tarea T 	
				ON O.IdOperacion = T.IdOperacion
			  LEFT JOIN S_Usuario US
				ON T.IdAprobador = US.IdUsuario
			  WHERE AP_PC.IdAceptacionPedido =   @IdAceptacionPedido
			  AND T.Activo=1
			  ORDER BY T.NoSecuencia ASC

			END 

			IF(@EstadoEtapa='DETENIDA')
				BEGIN 
					INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)					
					SELECT 
					IdDocumento = P.IdPedido,
					Descripcion= CONCAT(ISNULL(PR.RazonSocial,''),' debe registrar nuevamente el Comprobante Extranjero'),
					Fecha=  NULL,
					Etapa=@Etapa,
					EstadoHistorial='EN_PROCESO'
					FROM MM_Pedido AS P 		
					JOIN S_Proveedor AS PR 
					ON P.IdSubcontratista = PR.IdProveedor  		  
					WHERE P.IdPedido =@IdPedido
				
				END 


		END 
	  END 

	  BEGIN -->HISTORIAL DETALLE CN  

		SELECT @EstadoEtapa = EstadoEtapa,	
		@EstatusValidar =  Estatus ,
		@Etapa =Etapa,
		@AprobacionCNActual = IdDocumento
		FROM @HISTORIAL
		WHERE Etapa IN	('CN','CN-EXTRANJERO')
			
		IF @EstadoEtapa = 'SIN_INICIAR'
		BEGIN 
					  INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						P.IdPedido,
						'El proveedor ' + ISNULL(PR.RazonSocial,'') + ' registra carga de carta de CN',
						null,
						@Etapa,
						'SIN_INICIAR'
					FROM MM_Pedido AS P
						LEFT JOIN dbo.S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor
					WHERE P.IdPedido = @IdPedido

					INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						0,
						'El usuario OBS aprueba la CN',
						null,
						@Etapa,
						'SIN_INICIAR'				

		END 

		IF @EstadoEtapa = 'EN_PROCESO' AND @EstatusValidar ='Sin iniciar aprobación' 
		BEGIN 
					  INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						P.IdPedido,
						'El proveedor ' + ISNULL(PR.RazonSocial,'') + ' registra carga de carta de CN',
						null,
						@Etapa,
						'EN_PROCESO'
					FROM MM_Pedido AS P
						LEFT JOIN dbo.S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor
					WHERE P.IdPedido = @IdPedido

					INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						0,
						'El usuario OBS aprueba la carta de CN',
						null,
						@Etapa,
						'SIN_INICIAR'				

		END 
				
		IF @EstadoEtapa <> 'SIN_INICIAR' AND @EstatusValidar <>'Sin iniciar aprobación' 
		BEGIN
			--> LOG DE REGISTROS DE CN
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
			SELECT
				ACN.IdAceptacionCartaPCN,
				ISNULL(US.Nombre + ' de ','') + ISNULL(PR.RazonSocial,'') + ' registró la carta de CN',
				FORMAT(ACN.CreadoEl,'dd/MM/yy HH:mm'),
				@Etapa,
				'FINALIZADA'			
			FROM dbo.MM_AceptacionCartaPCN AS ACN
				LEFT JOIN dbo.S_Usuario AS US
					ON ACN.CreadoPor = US.IdUsuario  
				LEFT JOIN dbo.MM_AceptacionPedido AS AP
					ON ACN.IdAceptacionPedido = AP.IdAceptacionPedido 
				LEFT JOIN dbo.MM_Pedido AS P
					ON AP.IdPedido = P.IdPedido 
				LEFT JOIN dbo.S_Proveedor AS PR
					ON P.IdSubcontratista = PR.IdProveedor 
			WHERE ACN.IdAceptacionPedido = @IdAceptacionPedido
				AND ACN.IdAceptacionCartaPCN =@AprobacionCNActual 
				AND ACN.IdEstatusEliminado IS NULL;

			--> LOG DE REGISTROS DE APROBACIÓN DE CN
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
			SELECT
				ACN.IdAceptacionCartaPCN,
				CASE
					WHEN ACN.IdEstatus = 2 THEN ISNULL(US.Nombre,'') + ' aprobó la carta de CN' 
					WHEN ACN.IdEstatus = 3 THEN ISNULL(US.Nombre,'') + ' rechazó la carta de CN' 
					WHEN ACN.IdEstatus = 1 THEN ISNULL(US.Nombre,'') + ' tiene en aprobación la carta de CN'
				END,
				FORMAT(ACN.FechaEvaluacion,'dd/MM/yy HH:mm'),
				@Etapa,
				CASE
					WHEN ACN.IdEstatus = 2 THEN 'FINALIZADA' 
					WHEN ACN.IdEstatus = 3 THEN 'DETENIDA' 
					WHEN ACN.IdEstatus = 1 THEN 'EN_PROCESO' 
				END
			FROM dbo.MM_AceptacionCartaPCN AS ACN
				LEFT JOIN dbo.S_Usuario AS US
					ON  ACN.IdUsuarioEvaluador = US.IdUsuario 			
			WHERE ACN.IdAceptacionPedido = @IdAceptacionPedido
				 AND ACN.IdAceptacionCartaPCN =@AprobacionCNActual
				AND ACN.IdEstatus <> 1
				AND ACN.IdEstatusEliminado IS NULL;
		END
		
		IF @EstadoEtapa = 'EN_PROCESO' AND @EstatusValidar ='En Aprobación' 
		begin 

						INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						0,
						'El usuario OBS aprueba la carta de CN',
						null,
						@Etapa,
						'EN_PROCESO'	
		end 


		IF @EstadoEtapa = 'DETENIDA'
		BEGIN
			 INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						P.IdPedido,
						'El proveedor ' + ISNULL(PR.RazonSocial,'') + ' debe cargar Carta de CN Petrovendor',
						null,
						@Etapa,
						'EN_PROCESO'
					FROM MM_Pedido AS P
						LEFT JOIN dbo.S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor
					WHERE P.IdPedido = @IdPedido

		END

		IF @EstatusValidar ='Carta de CN Excluida'
		BEGIN 
		
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)

			SELECT
				SECN.IdAprobacionExclucionCN,
				ISNULL(US.Nombre,'-') + ' solicitó excluir la Carta de CN',
				FORMAT(SECN.FechaSolicitud,'dd/MM/yy HH:mm'),
				@Etapa,
				'FINALIZADA'
			FROM dbo.MM_Solicitud_ExclucionCN AS SECN
				LEFT JOIN dbo.S_Usuario AS US
					ON SECN.IdUsuarioRequesitor = US.IdUsuario 
			WHERE SECN.IdAceptacionPedido = @IdAceptacionPedido;


			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)

			SELECT
				SECN.IdAprobacionExclucionCN,
				ISNULL(US.Nombre,'-') +' '+E.Nombre +' la exclusión de la Carta de CN',
				FORMAT(SECN.FechaSolicitud,'dd/MM/yy HH:mm'),
				@Etapa,
				'FINALIZADA'
			FROM dbo.MM_Solicitud_ExclucionCN AS SECN
				LEFT JOIN dbo.S_Usuario AS US
					ON SECN.UsuarioAprobador = US.IdUsuario 
				left join TA_Estatus E
					on SECN.IdEstatus = E.IdEstatus
			WHERE SECN.IdAceptacionPedido = @IdAceptacionPedido;

		END 

	  END 

	  BEGIN -->HISTORIAL DETALLE SAS
	
		SELECT @EstadoEtapa = EstadoEtapa,	
		@EstatusValidar =  Estatus ,
		@Etapa =Etapa,
		@AprobacionCNActual = IdDocumento
		FROM @HISTORIAL
		WHERE Etapa IN	('SAS')

		IF @EstadoEtapa = 'SIN_INICIAR'
		BEGIN 
					  INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						P.IdPedido,
						'El proveedor ' + ISNULL(PR.RazonSocial,'') + ' registra SAS',
						null,
						@Etapa,
						'SIN_INICIAR'
					FROM MM_Pedido AS P
						LEFT JOIN dbo.S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor
					WHERE P.IdPedido = @IdPedido

					INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						0,
						'El usuario Solicitante aprueba la SAS',
						null,
						@Etapa,
						'SIN_INICIAR'	
					
					INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						0,
						'El usuario OBS aprueba la SAS',
						null,
						@Etapa,
						'SIN_INICIAR'	

		END 

		IF @EstadoEtapa <> 'SIN_INICIAR'
		BEGIN 

			--> LA SAS YA ESTA CARGADA POR PARTE DE PETROVENDOR
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						P.IdPedido,
						CONCAT('El usuario ',ISNULL(USAP.Nombre,'-'),' del proveedor ',ISNULL(PR.RazonSocial,'') , ' registró la SAS'),
						null,
						@Etapa,
						'FINALIZADA'
					FROM MM_SolicitudAceptacionPedido AS SAP 
						JOIN MM_Pedido AS P
							ON SAP.IdPedido = P.IdPedido
							AND SAP.IdSolicitudAceptacionPedido = @IdSolicitudAceptacionPedido
						JOIN dbo.S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor
						LEFT JOIN S_Usuario USAP
							ON SAP.CreadorPor = USAP.IdUsuario
					WHERE P.IdPedido = @IdPedido


			 /*OBTENER ESTATUS ACTUAL DE LA APROBACION GRAL*/
			 SELECT  @EstatusIdSASActual = O.IdEstatusOperacion,
			 @OperacionSASId=O.IdOperacion
			 FROM TA_Operacion O
			 JOIN TA_TipoOperacion AS TOSAS
				ON O.IdTipoOperacion = TOSAS.IdTipoOperacion
				AND TOSAS.NombreOperacion	=	'Aprobación de solicitud de aceptación de pedido'
			 WHERE 	O.IdDocumento=@IdSolicitudAceptacionPedido		

			 /*VALIDAR CUANTOS USUARIOS DE OBS EXISTEN EN EL CONTRATO, SI SOLO EXISTE UNO, MOSTRAR NOMBRE DEL USUARIO, 
			 SI SON MAS DE UNO MOSTRAR OBS COMO APROBADOR*/
			  SELECT 			
				@CantidadUsuarioOBS =	 COUNT(U.IdUsuario),
				@IdContrato = P.IdContrato
				FROM DEA_UsuarioOBS UOBS
				JOIN S_Usuario U
				ON UOBS.IdUsuario=U.IdUsuario
				JOIN MM_Pedido P 
					ON UOBS.IdContrato = UOBS.IdContrato
				WHERE UOBS.Activo = 1	
				AND P.IdPedido = @IdPedido	
				GROUP BY P.IdContrato
								
		
			IF @CantidadUsuarioOBS = 1 
			BEGIN 
				INSERT INTO @tbUsuarioOBS(IdUsuario,Nombre)
				SELECT 			
					U.IdUsuario,U.Nombre
				FROM DEA_UsuarioOBS UOBS
				JOIN S_Usuario U
				ON UOBS.IdUsuario=U.IdUsuario				
				WHERE UOBS.Activo = 1	
				AND UOBS.IdContrato=@IdContrato		
				GROUP BY U.Nombre,U.IdUsuario 		 
			END 
			ELSE 
			BEGIN
				INSERT INTO @tbUsuarioOBS(IdUsuario,Nombre)
				VALUES(-1,'Usuario OBS')
			END 

			 IF @EstatusIdSASActual IN (2,3) --> SI ESTA APROBADA O RECHAZADA MOSTRAR APROBADORES QUE REALIZARON LA ACCION
			 BEGIN
			 
				  INSERT INTO @HISTORIALSEC
					(
						IdDocumento,
						Descripcion,
						Fecha,
						Etapa,
						EstadoHistorial
					)
				 SELECT 
				 IdDocumento=T.IdTarea,
				Descripcion=CASE WHEN T.NoSecuencia= 1 THEN CONCAT(U.Nombre, ' como solicitante ',
								CASE WHEN E.IdEstatus= 1 THEN 'tiene pendiente la aprobación de ' 
									 WHEN E.IdEstatus = 2  THEN  'Aprobó' 
									 WHEN E.IdEstatus = 3  THEN  'Rechazó' 
									 WHEN E.IdEstatus = 4  THEN  ' se le ha cancelado' 
								END 
								, ' la SAS')
								 ELSE CONCAT(U.Nombre, ' como OBS ',
								 CASE WHEN E.IdEstatus= 1 THEN 'tiene pendiente la aprobación de ' 
									 WHEN E.IdEstatus = 2  THEN  'Aprobó' 
									 WHEN E.IdEstatus = 3  THEN  'Rechazó' 
									 WHEN E.IdEstatus = 4  THEN  ' se le ha cancelado' 
								 END, ' la SAS')
								 END ,
				Fecha=ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),''),
				Etapa=@Etapa,
				EstadoHistorial=CASE WHEN E.IdEstatus = 1 THEN 'EN_PROCESO' 
									 WHEN E.IdEstatus = 2  THEN  'FINALIZADA' 
									 WHEN E.IdEstatus = 3  THEN  'DETENIDA' 
									 WHEN E.IdEstatus = 4  THEN  'DETENIDA' 
								END			 	 			
				 FROM TA_Operacion O
				 JOIN TA_Tarea T 
					ON O.IdOperacion = T.IdOperacion
				 JOIN S_Usuario U
					ON T.IdAprobador = U.IdUsuario
				 JOIN TA_Estatus E
					ON T.IdEstatus = E.IdEstatus
				WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
				AND O.IdOperacion=@OperacionSASId		
				AND T.Activo=1
				ORDER BY T.NoSecuencia ASC 
			END 
			 ELSE 
			 BEGIN 
				INSERT INTO @HISTORIALSEC
					(
						IdDocumento,
						Descripcion,
						Fecha,
						Etapa,
						EstadoHistorial
					)
				 SELECT 
				IdDocumento=T.IdTarea,
				Descripcion=CASE WHEN T.NoSecuencia= 1 THEN CONCAT(U.Nombre, ' como solicitante ',
								CASE WHEN E.IdEstatus= 1 THEN 'tiene pendiente la aprobación de ' 
									 WHEN E.IdEstatus = 2  THEN  'Aprobó' 
									 WHEN E.IdEstatus = 3  THEN  'Rechazó' 
									 WHEN E.IdEstatus = 4  THEN  ' se le ha cancelado' 
								END 
								, ' la SAS')
								 ELSE CONCAT(U.Nombre, ' como OBS ',
								 CASE WHEN E.IdEstatus= 1 THEN 'tiene pendiente la aprobación de ' 
									 WHEN E.IdEstatus = 2  THEN  'Aprobó' 
									 WHEN E.IdEstatus = 3  THEN  'Rechazó' 
									 WHEN E.IdEstatus = 4  THEN  ' se le ha cancelado' 
								 END, ' la SAS')
								 END ,
				Fecha=ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),''),
				Etapa=@Etapa,
				EstadoHistorial=CASE WHEN E.IdEstatus = 1 THEN 'EN_PROCESO' 
									 WHEN E.IdEstatus = 2  THEN  'FINALIZADA' 
									 WHEN E.IdEstatus = 3  THEN  'DETENIDA' 
									 WHEN E.IdEstatus = 4  THEN  'DETENIDA' 
								END	
				 FROM TA_Operacion O
				 JOIN TA_Tarea T 
					ON O.IdOperacion = T.IdOperacion
				 JOIN S_Usuario U
					ON T.IdAprobador = U.IdUsuario
				 JOIN TA_Estatus E
					ON T.IdEstatus = E.IdEstatus
				WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
				AND O.IdOperacion=@OperacionSASId			
				AND T.Activo=1

				INSERT INTO @HISTORIALSEC
					(
						IdDocumento,
						Descripcion,
						Fecha,
						Etapa,
						EstadoHistorial
					)

				SELECT 
				IdDocumento=-1,
				Descripcion=CONCAT(Nombre, ' como OBS tiene pendiente la aprobación de la SAS'),
				Fecha=NULL,
				Etapa=@Etapa,
				EstadoHistorial='EN_PROCESO'
				FROM @tbUsuarioOBS

			END 

				  
		

		END 

		IF @EstadoEtapa='DETENIDA'
		BEGIN 
			--> LA SAS YA ESTA CARGADO
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
						SELECT
						P.IdPedido,
						CONCAT('El proveedor ',ISNULL(PR.RazonSocial,'') , ' debe registrar SAS'),
						null,
						@Etapa,
						'EN_PROCESO'
					FROM MM_SolicitudAceptacionPedido AS SAP 
						JOIN MM_Pedido AS P
							ON SAP.IdPedido = P.IdPedido
							AND SAP.IdSolicitudAceptacionPedido = @IdSolicitudAceptacionPedido
						JOIN dbo.S_Proveedor AS PR
							ON  P.IdSubcontratista = PR.IdProveedor
						LEFT JOIN S_Usuario USAP
							ON SAP.CreadorPor = USAP.IdUsuario
					WHERE P.IdPedido = @IdPedido

		END 

	  END 

	  BEGIN -->HISTORIAL DETALLE PEDIDO

		SELECT @EstadoEtapa = EstadoEtapa,	
		@EstatusValidar =  Estatus ,
		@Etapa =Etapa,
		@AprobacionCNActual = IdDocumento
		FROM @HISTORIAL
		WHERE Etapa IN	('PEDIDO')
		
			--> REGISTRO DE PEDIDO
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
		
			SELECT 
				IdDocumento=OP.IdOperacion,
							Descripcion=CONCAT(US.Nombre,' registró el pedido para que sea evaluado'),
							Fecha=FORMAT(OP.FechaRegistro,'dd/MM/yy HH:mm'),
							Etapa=@Etapa,
							EstadoHistorial='FINALIZADA'
			FROM MM_Pedido AS P
				JOIN dbo.TA_Operacion AS OP
					ON OP.IdDocumento = P.IdSolicitudPedido
					AND OP.IdTipoOperacion = 9
					AND OP.NoVersion = P.Version
				LEFT JOIN dbo.S_Usuario AS US
					ON US.IdUsuario = OP.IdAsignador
			WHERE P.IdPedido = @IdPedido
		
			--> APROBACIONES DE PEDIDO
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)
		
			SELECT 
				IdDocumento=T.IdTarea,
					Descripcion=CASE 
									WHEN T.IdEstatus = 1 THEN CONCAT(ISNULL(US.Nombre,''),' tiene pendiente la aprobación del pedido')
									WHEN T.IdEstatus = 2 THEN CONCAT(ISNULL(US.Nombre,''),' aprobó el pedido')
									WHEN T.IdEstatus = 3 THEN CONCAT(ISNULL(US.Nombre,''), ' rechazó el pedido')
									WHEN T.IdEstatus = 6 THEN CONCAT(ISNULL(US.Nombre,''),' (Asignador) cancelo el pedido') 
									WHEN T.IdEstatus = 7 THEN CONCAT(ISNULL(US.Nombre,''),' reasignó el pedido') 
								END,
					Fecha=FORMAT(T.FechaCambioEstatus,'dd/MM/yy HH:mm'),
					Etapa=@Etapa,
					EstadoHistorial=CASE 
									WHEN T.IdEstatus = 1 THEN 'EN_PROCESO'
									WHEN T.IdEstatus = 2 THEN 'FINALIZADA'
									WHEN T.IdEstatus = 3 THEN 'DETENIDA'
									WHEN T.IdEstatus = 6 THEN 'DETENIDA'
									WHEN T.IdEstatus = 7 THEN 'DETENIDA'
								END
					FROM MM_Pedido AS P
						JOIN TA_Operacion AS OP
							ON P.IdSolicitudPedido= OP.IdDocumento 
							AND OP.IdTipoOperacion = 9 --> CTE APROBACION DE PEDIDO
							AND P.Version =OP.NoVersion  
						JOIN TA_Tarea AS T
							ON OP.IdOperacion=T.IdOperacion 
						JOIN S_Usuario AS US
							ON T.IdAprobador = US.IdUsuario
					WHERE P.IdPedido = @IdPedido
						AND T.IdEstatus <> 1			

			--> ESTATUS DE LA CONFIRMACIÓN
			INSERT INTO @HISTORIALSEC
						(
							IdDocumento,
							Descripcion,
							Fecha,
							Etapa,
							EstadoHistorial
						)		
			SELECT TOP 1			
			IdDocumento = P.IdPedido,
			Descripcion= CONCAT('El proveedor ',ISNULL(PR.RazonSocial,''),CASE
														   WHEN TOA.IdEstatusOperacion NOT IN (2) THEN ' ha confirmado el pedido'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 1 THEN ' confirmó el pedido'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 0 THEN ' rechazó el pedido'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN  ' tiene la confirmación vencida del pedido'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0 THEN   ' tiene pendiente la confirmación del pedido'
														   ELSE ' ha confirmado el pedido'												
														   END),
			Fecha= FORMAT(P.FechaRecepcionServicio,'dd/MM/yy HH:mm'),
			Etapa=@Etapa,
			EstadoHistorial=(CASE
														   WHEN TOA.IdEstatusOperacion NOT IN (2) THEN 'SIN_INICIAR'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 1 THEN 'FINALIZADA'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio = 0 THEN 'DETENIDA'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN  'DETENIDA'
														   WHEN TOA.IdEstatusOperacion = 2 AND P.RecepcionServicio IS NULL AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0 THEN   'EN_PROCESO'
														   ELSE 'SIN_INICIAR'														
														   END)
			FROM MM_Pedido AS P 
			JOIN TA_Operacion AS TOA
			 ON  P.IdSolicitudPedido = TOA.IdDocumento 
				AND TOA.IdTipoOperacion = 9
				AND P.Version = TOA.NoVersion
			JOIN MM_HorasVigenciaPedido AS HV 
				ON P.IdPedido = HV.IdPedido
			JOIN TA_Estatus E
				ON TOA.IdEstatusOperacion = E.IdEstatus		
			JOIN S_Proveedor AS PR
				ON  P.IdSubcontratista = PR.IdProveedor		
			WHERE P.IdPedido = @IdPedido
			ORDER BY P.CreadoEl DESC;

	  END 
  END    


  UPDATE @HISTORIAL
  SET EstadoEtapaTooltip = CASE WHEN EstadoEtapa = 'FINALIZADA' THEN 'Completado' 
								WHEN EstadoEtapa = 'DETENIDA' THEN 'Detenido' 
								WHEN EstadoEtapa = 'EN_PROCESO' THEN 'En progreso' 
								WHEN EstadoEtapa = 'SIN_INICIAR' THEN 'Sin inicar' 
							END 

  UPDATE @HISTORIALSEC
  SET EstadoHistorialTooltip = CASE WHEN EstadoHistorial = 'FINALIZADA' THEN 'Realizado' 
								WHEN EstadoHistorial = 'DETENIDA' THEN 'Realizado' 
								WHEN EstadoHistorial = 'EN_PROCESO' THEN 'En progreso' 
								WHEN EstadoHistorial = 'SIN_INICIAR' THEN 'Sin inicar' 
							END 


   --> TABLA 1
   SELECT * FROM @HISTORIAL

   --> TABLA 2
   SELECT 	
	P.IdPedido,
	P.IdSolicitudPedido,
	O.Descripcion, 
	Proveedor = CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')),	
	O.FechaRegistro,		
	IdPedidoGeneral = PG.IdPedido,
	TP.TipoPedido,
	Contrato = CONCAT(ISNULL(C.NumeroContrato,''),ISNULL(' - '+AC.NombreAreaContractual,'')) ,
	EtapaTimeLine = @EtapaTimeLine,
	Nacionalidad = CASE WHEN ISNULL(@IdNacionalidadProveedor,0)=1 THEN 'Proveedor: Nacional' 
						WHEN ISNULL(@IdNacionalidadProveedor,0)=2 THEN 'Proveedor: Extranjero' 
						WHEN ISNULL(@IdNacionalidadProveedor,0)=0 AND PV.IdNacionalidad=1 THEN 'Proveedor: Nacional' 
						WHEN ISNULL(@IdNacionalidadProveedor,0)=0 AND PV.IdNacionalidad=2 THEN 'Proveedor: Extranjero' 
						ELSE 'Proveedor: Sin nacionalidad definada' END,
	EtapaActual=@EtapaActual,
	EtapaProcesoActual=@EtapaProcesoActual,
	EtapaProcesoActualTooltip=CASE WHEN @EtapaProcesoActual = 'Completado' THEN 'Proceso completado' ELSE 'Proceso pendiente de completar' END
	FROM MM_Pedido AS P (NOLOCK)
	JOIN S_Proveedor AS PV  (NOLOCK)
		ON P.IdSubcontratista	=	PV.IdProveedor 
	JOIN dbo.TA_Operacion AS O  (NOLOCK)
		ON P.IdSolicitudPedido	=	O.IdDocumento
		AND P.Version			=	O.NoVersion
		AND O.IdTipoOperacion	=	9 --> CTE APROBACION DE PEDIDO	
	JOIN TA_TipoOperacion AS TTO  (NOLOCK)
		ON O.IdTipoOperacion	=	TTO.IdTipoOperacion
	JOIN dbo.TA_Estatus AS E  (NOLOCK)
		ON O.IdEstatusOperacion =	E.IdEstatus 	
	JOIN MM_Pedidos AS PG  (NOLOCK)
		ON P.IdPedido			=	PG.IdIdentificador 
		AND P.IdProveedorCompras = PG.IdProveedorCliente  
		AND PG.IdTipoPedido IN (2, 4, 6) ---(Mer, AD, OT)
	LEFT JOIN MM_TipoPedido AS TP 
		ON PG.IdTipoPedido		=	TP.IdTipoPedido	
	LEFT JOIN Adinco..CO_Contrato	AS	C 	 (NOLOCK)
			ON	P.IdContrato = C.IdContrato
	LEFT JOIN Adinco..CO_AreaContractual AC  (NOLOCK)
		on C.IdAreaContractual	=	AC.IdAreaContractual
	WHERE P.IdPedido = @IdPedido 
	

	--> TABLA 3
	SELECT * FROM @HISTORIALSEC

	
END

