
﻿USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SRAP_ConsultaDetalleAprobacionSolicitudRecepcion]    Script Date: 12/10/2021 12:29:29 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar detalle de solicitud de recepción de pedido
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 13/10/2021
-- Description:	Se agrega la validación de cantidad disponible de materiales
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultaDetalleAprobacionSolicitudRecepcion]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT,
@IdPedido    INT,
@IdSolicitudAceptacionPedido INT 

AS
	
	create table #tmpCantidadesRecibidad
	(
		IdPedidoDetalle		int,
		Cantidad			float
	)

     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')
		DECLARE @NoSecuenciaUsuarioSolicitante INT 
		DECLARE @IdEstatusUsuarioAnteriorSecuencia INT
		DECLARE @NoSecuenciaAprobadorAnterior INT 
		DECLARE @EstatusIdAprobacionActual INT
		DECLARE @IdOperacion INT 
		DECLARE @EstatusSolicitanteId INT 
		DECLARE @ContratoId INT 
		DECLARE @tbUsuarioOBS AS TABLE(IdUsuario INT, Nombre NVARCHAR(MAX)) 
	    DECLARE @CantidadUsuarioOBS INT
	   /*OBTENER CONTRATO DEL PEDIDO ACTUAL*/
	   SELECT @ContratoId= IdContrato 
	   FROM MM_Pedido 
	   WHERE IdPedido= @IdPedido
    -- Insert statements for procedure here
	    	
						
	   /*TABLA 1 ENCABEZADO*/
	   BEGIN       
	    /*ENCABEZADO DEL PEDIDO*/	
		 SELECT     
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 P.IdPedido,    
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
			AND SAP.IdPedido = @IdPedido 
			AND SAP.IdSolicitudAceptacionPedido =@IdSolicitudAceptacionPedido
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,		  
		 PV.RazonSocial,     		
		 P.FechaEnvioPedido,    
		 P.IdPeticionOferta,    
		 P.RecepcionServicio,    
		 P.FechaRecepcionServicio,
		 PG.IdPedido,
		 P.DiasCredito,    
		 P.Cerrado,  
		 P.IdSubcontratista,
		 E.Nombre,
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 O.IdEstatusOperacion,
		 SAP.CreadoEl,
		 UE.Nombre,
		 SAP.IdAceptacionPedido,
		 SR.Nombre,
		 PG.IdTipoPedido,
		 PV.RegimenCapital
	END
	  
	  /*TABLA 2 PRODUCTOS*/
	   BEGIN     
	    /*PRODUCTOS A ENTREGAR*/

		insert into #tmpCantidadesRecibidad
		select		apd.IdPedidoDetalle,
					sum(apd.Cantidad)
		from		MM_PedidoDetalle			pd
		inner join	MM_AceptacionPedidoDetalle	apd
		on			pd.IdPedidoDetalle			=	apd.IdPedidoDetalle
		inner join	MM_AceptacionPedido			ap
		on			ap.IdAceptacionPedido		=	apd.IdAceptacionPedido
		and			ap.IdEliminado				is	null
		and			apd.IdEliminado				is	null
		where		pd.IdPedido					=	@IdPedido
		group by	apd.IdPedidoDetalle

		SELECT 		PD.IdPedidoDetalle,
					PD.IdMaterialVendedor,
					Descripcioncorta					=	M.Descripcioncorta,
					M.DescripcionLarga,
					CantidadPedido						=	PD.Cantidad,
					PD.PrecioUnitario,
					PD.Subtotal, 
					CantidadProcesada					=	SAPD.Cantidad, 		
					TM.TipoMonedaCorto,		
					Recepcionservicio					=	ISNULL(PD.RecepcionPedido,'false'),		
					PD.RecepcionPedido,
					Unidad								=	POD.UnidadProveedor,
					CantidadRecibida					=	t1.Cantidad,
					case when dbo.fnGetValidacionCantidadMateriales(PD.IdPedidoDetalle,@IdPedido,SAPD.Cantidad) = 'CANTIDAD_VALIDA'
					then '' else 'La cantidad solicitada excede el límite del pedido.'
					end as 
					CantidadValida,
					case when dbo.fnGetValidacionCantidadMateriales(PD.IdPedidoDetalle,@IdPedido,SAPD.Cantidad) = 'CANTIDAD_VALIDA'
					then '' else 'bgcolor="#ff685d"'
					end as Color
		FROM		MM_SolicitudAceptacionPedidoDetalle SAPD 		
		JOIN		MM_PedidoDetalle					PD 
		ON			SAPD.IdPedidoDetalle				=	PD.IdPedidoDetalle
		JOIN		MM_Pedido							P
		ON			PD.IdPedido							=	P.IdPedido
		JOIN		MM_Material							M 
		ON			PD.IdMaterialVendedor				=	M.IdMaterial 
		JOIN		MM_PeticionOferta					PO 
		ON			PO.IdPeticionOFerta					=	P.IdPeticionOferta		
		JOIN		MM_PeticionOfertaDetalle			POD 
		ON			PO.IdPeticionOferta					=	POD.IdPeticionOferta 
		AND			POD.IdMaterial						=	PD.IdMaterial
		JOIN		MM_SolicitudPedidoDetalle			SPD 
		ON			SPD.IdSolicitudPedidoDetalle		=	POD.IdSolicitudPedidoDetalle		
		JOIN		PV_TipoMoneda						TM 
		ON			TM.IdMoneda							=	PD.IdMoneda
		inner join	#tmpCantidadesRecibidad				t1
		on			t1.IdPedidoDetalle					=	PD.IdPedidoDetalle		
		WHERE		P.IdProveedorCompras				=	@IdProveedor 		
		AND			P.IdPedido							=	@IdPedido
		AND			SAPD.IdSolicitudAceptacionPedido	=	@IdSolicitudAceptacionPedido
		ORDER BY	M.Descripcioncorta ASC

		
	  END 

	  /*TABLA 3 DOCUMENTOS*/
	   BEGIN     
		 /*TABLA DE DOCUMENTOS*/
		 SELECT  D.IdDocumento, 
				D.NombreDocumento + '  -  Cargado Por ' +  US.Nombre + ' el ' + CAST(D.CreadoEl AS nvarchar) AS NombreDocumento, 
				D.IdDocumentoTabla 
         FROM  S_Documento_S3 D  
		 LEFT JOIN S_Usuario AS US ON D.IdUsuario = US.IdUsuario
         WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		 AND D.Activo=1 
		 AND D.IdTipoDocumento = 12 --> CTE ACEPTACION DE PEDIDO --> SELECT * FROM S_TipoDocumento WHERE IdTipoDocumento=12  
	   END

	   /*TABLA 4 APROBADORES*/
	   BEGIN     
	     -- EN TEORIA SIEMPRE HAY UN APROBADOR NO.1 QUE ES EL SOLICITANTE DE LA REQUISICION 
		 -- EL SEGUNDO APROBADOR ES CUALQUIER USUARIO DE OBS (SELECT * FROM DEA_UsuarioOBD WHERE ContratoId=@ContratoId)
		 
		 /*VALIDAR CUANTOS USUARIOS DE OBS EXISTEN EN EL CONTRATO, SI SOLO EXISTE UNO, MOSTRAR NOMBRE DEL USUARIO, 
		 SI SON MAS DE UNO MOSTRAR OBS COMO APROBADOR*/
		  SELECT 			
			@CantidadUsuarioOBS =	 COUNT(U.IdUsuario)
			FROM DEA_UsuarioOBS UOBS
			JOIN S_Usuario U
			ON UOBS.IdUsuario=U.IdUsuario				
			WHERE UOBS.Activo = 1	
			AND UOBS.IdContrato=@ContratoId				
								
		
		IF @CantidadUsuarioOBS = 1 
		BEGIN 
			INSERT INTO @tbUsuarioOBS(IdUsuario,Nombre)
			SELECT 			
				U.IdUsuario,U.Nombre
			FROM DEA_UsuarioOBS UOBS
			JOIN S_Usuario U
			ON UOBS.IdUsuario=U.IdUsuario				
			WHERE UOBS.Activo = 1	
			AND UOBS.IdContrato=@ContratoId		
			GROUP BY U.Nombre,U.IdUsuario 		 
		END 
		ELSE 
		BEGIN
			INSERT INTO @tbUsuarioOBS(IdUsuario,Nombre)
			VALUES(-1,'OBS')
		END 

		/*OBTENER ESTATUS ACTUAL DE LA APROBACION GRAL*/
		 SELECT  @EstatusIdAprobacionActual = O.IdEstatusOperacion,
		 @IdOperacion=O.IdOperacion
		 FROM TA_Operacion O
		 WHERE 	  
		 O.IdDocumento=@IdSolicitudAceptacionPedido
		 AND O.IdTipoOperacion=@TipoOperacionId

		 IF @EstatusIdAprobacionActual IN (2,3) --> SI ESTA APROBADA O RECHAZADA MOSTRAR APROBADORES QUE REALIZARON LA ACCION
		 BEGIN
			 /*TABLA CON INFORMACIÓN DE APROBACIÓN*/
			 SELECT 
			 T.IdTarea,
			 T.IdEstatus,
			 U.Nombre AS Aprobador,
			 ISNULL(T.Comentario,'') AS Comentario,
			 ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),'') AS FechaCambioEstatus,
			 E.Nombre AS Estatus,
			 T.IdOperacion 
			 FROM TA_Operacion O
			 JOIN TA_Tarea T 
				ON O.IdOperacion = T.IdOperacion
			 JOIN S_Usuario U
				ON T.IdAprobador = U.IdUsuario
			 JOIN TA_Estatus E
				ON T.IdEstatus = E.IdEstatus
			WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			AND O.IdTipoOperacion=@TipoOperacionId		
			AND T.Activo=1
			ORDER BY T.NoSecuencia ASC 
		END 
		ELSE 
		BEGIN
		 /*LA APROBACIÓN AUN ESTA EN ESTA APROBACION ENTONCES MOSTRAR USUARIO DE OBS Ó
		 SE AGREGA UN USUARIO GENERICO PARA EL GRUPO DE USUARIOS DE OBS
		 */
			SELECT 
			 T.IdTarea,
			 T.IdEstatus,
			 U.Nombre AS Aprobador,
			 ISNULL(T.Comentario,'') AS Comentario,
			 ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),'') AS FechaCambioEstatus,
			 E.Nombre AS Estatus,
			 T.IdOperacion 
			 FROM TA_Operacion O
			 JOIN TA_Tarea T 
				ON O.IdOperacion = T.IdOperacion
			 JOIN S_Usuario U
				ON T.IdAprobador = U.IdUsuario
			 JOIN TA_Estatus E
				ON T.IdEstatus = E.IdEstatus
			WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			AND O.IdTipoOperacion=@TipoOperacionId		
			AND T.Activo=1

			UNION ALL

			SELECT 
			IdTarea= -1,
			IdEstatus=1,
			Aprobador=UOBS.Nombre,
			Comentario='',
			FechaCambioEstatus='',
			Estatus='En aprobación', 
			IdOperacion=@IdOperacion
			FROM @tbUsuarioOBS UOBS

			
		END 

	  END 

	  /*TABLA 5 APROBADOR ACTUAL*/
	  BEGIN
	    /*LAS APROBACIONES DE SOLICITUD  DE ACEPTACIONES DE PEDIDO POR DEFAULT SON DE TIPO APROBACION SERIAL(NO TIENEN FLUJO DEFINO EN TA_OPERACION)*/
		/* EL FLUJO CONSISTE EN DOS APROBADORES 
		  APROBADOR 1 --> SOLICITANTE DE LA REQUISION --> EN TA_TAREA SE DEFINE EL TIPO COMO NombreTarea = 'Solicitud Aceptación pedido'
		  APROBADOR 2 --> CUALQUIER USUARIO DE OBS DEL CONTRATO ACTUAL --> EN TA_TAREA SE DEFINE EL TIPO COMO NombreTarea = 'Solicitud Aceptación pedido OBS'
		  PARA QUE LA APROBACION GRAL ESTE APROBADA DEBE ESTAR APROBADA POR LOS 2 TIPOS DE APROBADORES
		  SI EL APROBADOR NO.1 RECHAZA YA NO SE MUESTRA LA OPCIÓN DE APROBACIÓN DEL USUARIO NO.2
		 */

		 /*VALIDAR SI APROBADOR NO.1 (SOLICITANTE DE LA REQUISICION) TODAVIA ESTA EN APROBACION*/
			 		
        SELECT @EstatusSolicitanteId = TT.IdEstatus,
		@NoSecuenciaUsuarioSolicitante = TT.NoSecuencia		  
        FROM TA_Operacion O  
            JOIN TA_Tarea TT  
                ON O.IdOperacion = TT.IdOperacion  
        WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			 AND O.IdTipoOperacion=@TipoOperacionId	             
              AND TT.Activo = 1
			  AND TT.NombreTarea ='Solicitud Aceptación pedido' --> ES PARA VERIFICAR LAS APROBACIONES DEL SOLICITANTE
        ORDER BY TT.NoSecuencia	 DESC

        IF ISNULL(@EstatusSolicitanteId,0) = 1 --> EL APROBADOR NO.1 ESTA EN APROBACION
		BEGIN
			/*VALIDAR SI EL USUARIO ES APROBADOR NO. 1 ES EL USUARIO ACTUAL*/
			SELECT 
			 'ES_APROBADOR'  AS EsAprobador,    
			 T.NoSecuencia,
			 T.IdTarea,
			 T.IdEstatus,
			 U.Nombre AS Aprobador,
			 ISNULL(T.Comentario,'') AS Comentario,
			 ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),'') AS FechaCambioEstatus,
			 E.Nombre AS Estatus,
			 'HABILITAR_APROBACION' AS EsperarAprobacion,  
			 0 AS NoSecuenciaAnterior,
			 O.IdOperacion,
			 U.IdUsuario,
			 'Solicitud Aceptación pedido' AS TipoAprobador 
			 FROM TA_Operacion O
			 JOIN TA_Tarea T 
				ON O.IdOperacion = T.IdOperacion
			 JOIN S_Usuario U
				ON T.IdAprobador = U.IdUsuario
			 JOIN TA_Estatus E
				ON T.IdEstatus = E.IdEstatus
			WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			AND O.IdTipoOperacion=@TipoOperacionId	
			AND T.IdAprobador=@IdUsuario
			AND T.Activo=1
		END 
		ELSE 
		BEGIN
			/*EL APROBADOR No.1 YA NO ESTA EN APROBACION POR QUE YA APROBO O RECHAZO*/
			/*VALIDAR SI LA APROBACION GENERAL TODAVIA ESTA EN APROBACION*/			
			 SELECT  @EstatusIdAprobacionActual = O.IdEstatusOperacion,
			 @IdOperacion=O.IdOperacion
			 FROM TA_Operacion O
			 WHERE 	  
			 O.IdDocumento=@IdSolicitudAceptacionPedido
			 AND O.IdTipoOperacion=@TipoOperacionId
			 			
				/*VALIDAR SI EL USUARIO ACTUAL ES PARTE DEL GRUPO DE OBS*/
				SELECT 
				EsAprobador='ES_APROBADOR',    
				NoSecuencia= (@NoSecuenciaUsuarioSolicitante+1),
				 IdTarea =-1,
				 IdEstatus=1, --> EN APROBACIÓN
				 Aprobador=U.Nombre,
				 Comentario= '',
				 FechaCambioEstatus = '',
				 Estatus='En aprobación',
				 EsperarAprobacion='HABILITAR_APROBACION',  
				 NoSecuenciaAnterior = @NoSecuenciaUsuarioSolicitante,
				 IdOperacion =@IdOperacion,
				 U.IdUsuario,
				 TipoAprobador = 'Solicitud Aceptación pedido OBS'     
				FROM DEA_UsuarioOBS UOBS
				JOIN S_Usuario U
				ON UOBS.IdUsuario=U.IdUsuario				
				WHERE UOBS.Activo = 1	
				AND UOBS.IdContrato=@ContratoId
				AND UOBS.IdUsuario = @IdUsuario
				AND CASE WHEN ISNULL(@EstatusIdAprobacionActual,0) = 1 THEN 1 ELSE 0 END = 1 -->SOLO MOSTRAR SI LA APROBACIÒN GRAL AUN SIGUE EN APROBACION, FALTA QUE APRUEBE ALGUN USUARIO DE OBS
				GROUP BY U.Nombre, U.IdUsuario 							
				ORDER BY U.Nombre ASC 

			 
			 
		END 
	  END 

	   /*TABLA 6 USUARIO OBS RELACIONADOS AL CONTRATO DEL PEDIDO*/
	   BEGIN 
		
			SELECT 			
				Usuario=U.Nombre,				 
				U.IdUsuario  
			FROM DEA_UsuarioOBS UOBS
			JOIN S_Usuario U
			ON UOBS.IdUsuario=U.IdUsuario				
			WHERE UOBS.Activo = 1	
			AND UOBS.IdContrato=@ContratoId		
			GROUP BY U.Nombre, U.IdUsuario 							
			ORDER BY U.Nombre ASC
		
	   END 
END
