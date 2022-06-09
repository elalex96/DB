USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SRAP_GuardarNuevaSolicitudRecepcion]    Script Date: 08/06/2022 02:48:56 p. m. ******/
SET ANSI_NULLS ON
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_GuardarNuevaSolicitudRecepcion'
)
    DROP PROCEDURE SRAP_GuardarNuevaSolicitudRecepcion;
	GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Guardar detalle de solicitud de recepción de pedido -Aprobación Gral
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/05/2022
-- Description:	Eliminado temporal de la primera aprobacion de aceptacion de pedido
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 08-06-2022
-- Description:	Se revierte Eliminado temporal de la primera aprobacion de aceptacion de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_GuardarNuevaSolicitudRecepcion] 
	-- Add the parameters for the stored procedure here
@IdPedido    INT,
@IdProveedor INT,
@UsuarioId   INT,
@Comentario NVARCHAR(MAX),
@NombreUsuarioEntrega  NVARCHAR(MAX),
@NombreRecibidoPor  NVARCHAR(MAX),
@tbPedidoDetalleAceptacion TY_PedidoDetalleAceptacion READONLY

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdContrato INT;
	DECLARE @PO NVARCHAR(1000);
	DECLARE @ValidacionesNoExitosas INT 
	DECLARE @CantidadProductos INT 
	DECLARE @tbPedidoDetalle AS TABLE 
	(Id INT IDENTITY(1,1) PRIMARY KEY,
	IdPedidoDetalle INT,
	CantidadRecepcionar float,
	CantidadPedido float,
	CantidadEnAprobacion float,
	CantidadAceptada float,
	CantidadProcesada float,
	CantidadRestante float,
	ValidacionExitosa bit)

	DECLARE @tbPedidoDetalleEnAprobacion AS TABLE 
	(IdPedidoDetalle INT,	
	CantidadEnAprobacion float)

	DECLARE @tbPedidoDetalleAceptados AS TABLE 
	(IdPedidoDetalle INT,	
	CantidadAceptada float)

	DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')

	DECLARE @IdSolicitudAceptacionPedido INT 
	DECLARE @IdOperacion INT 
	DECLARE @IdEstatusEnAprobacion INT = 1 --> CTE -->EN APROBACIÓN
	DECLARE @IdSolicitanteRequisicion INT
	DECLARE @Descripcion_historial  NVARCHAR(MAX) 
	DECLARE @IdPedidoGeneral INT 
	DECLARE @NombreContrato NVARCHAR(MAX)

	    /*1. OBTENER LAS REFERENCIAS DE LOS PRODUCTOS A ENTREGAR*/
		INSERT INTO @tbPedidoDetalle(IdPedidoDetalle,CantidadPedido,CantidadRecepcionar,CantidadAceptada,CantidadEnAprobacion,CantidadProcesada,CantidadRestante,ValidacionExitosa)
		SELECT 
		IdPedidoDetalle = PD.IdPedidoDetalle,		
		CantidadPedido= PD.Cantidad,
		CantidadRecepcionar= tbAP.CantidadRecepcionar,
		CantidadAceptada= 0,
		CantidadEnAprobacion= 0,
		CantidadProcesada= 0,
		CantidadRestante =0,
		ValidacionExitosa = 0
		FROM MM_Pedido AS P
		JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
		JOIN @tbPedidoDetalleAceptacion AS tbAP
			ON PD.IdPedidoDetalle = tbAP.IdPedidoDetalle
		WHERE 		
		P.IdPedido = @IdPedido

		/*1.1 VALIDAR SE ENCUENTREN PEDIDOS DETALLES*/

		SET @CantidadProductos = (SELECT COUNT(1) FROM @tbPedidoDetalle)
		IF @CantidadProductos=0
		BEGIN 
			/*CANCELAR GUARDADO POR QUE NO SE ENCONTRO NINGUN PRODUCTO RELACIONADO A LOS PEDIDO DETALLES DEL PEDIDO INDICADO*/
			SELECT 
			Response  = 'SIN_PRODUCTOS'
			SELECT * FROM @tbPedidoDetalle
			RETURN 
		END
		
		/*2.- OBTENER CANTIDAD EN APROBACION*/
	     INSERT INTO @tbPedidoDetalleEnAprobacion(IdPedidoDetalle,CantidadEnAprobacion)
		 SELECT 
		 PD.IdPedidoDetalle, 
		 CantidadEnAprobacion = SUM(SAPD.Cantidad)
		FROM @tbPedidoDetalle PD
		JOIN MM_SolicitudAceptacionPedidoDetalle SAPD
			ON PD.IdPedidoDetalle = SAPD.IdPedidoDetalle
		JOIN MM_SolicitudAceptacionPedido SAP
			ON SAPD.IdSolicitudAceptacionPedido = SAP.IdSolicitudAceptacionPedido
			AND SAP.Activo = 1
		JOIN TA_Operacion O 
			ON SAP.IdSolicitudAceptacionPedido = O.IdDocumento
			AND O.IdTipoOperacion = @TipoOperacionId --> Aprobación de solicitud de aceptación de pedido
			AND O.IdEstatusOperacion = 1 --> EN APROBACIÓN 
			AND ISNULL(O.IdEstatusEliminado,0) = 0
		 WHERE SAP.IdPedido = @IdPedido
		 GROUP BY PD.IdPedidoDetalle


		 UPDATE PD
		 SET PD.CantidadEnAprobacion=PDEA.CantidadEnAprobacion
		 FROM @tbPedidoDetalle PD
		 JOIN @tbPedidoDetalleEnAprobacion PDEA
			ON PD.IdPedidoDetalle = PDEA.IdPedidoDetalle			

		 /*3.OBTENER LAS CANTIDADES QUE YA ESTAN EN UNA ACEPTACION DE PEDIDO*/
		 INSERT INTO @tbPedidoDetalleAceptados(IdPedidoDetalle, CantidadAceptada)
		 SELECT
		 PD.IdPedidoDetalle,
		 CantidadAceptada = SUM(APD.Cantidad)
		 FROM  @tbPedidoDetalle PD
		 JOIN MM_AceptacionPedidoDetalle APD
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		 JOIN MM_AceptacionPedido AP 
			ON APD.IdAceptacionPedido	= AP.IdAceptacionPedido
				AND AP.Activo= 1
				AND ISNULL(AP.IdEstatusEliminado,0) =0 
		 WHERE AP.IdPedido=@IdPedido
		GROUP BY PD.IdPedidoDetalle

		UPDATE PD
		 SET PD.CantidadAceptada=APD.CantidadAceptada
		 FROM @tbPedidoDetalle PD
		 JOIN @tbPedidoDetalleAceptados APD
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle	
			

		/*ACTUALIZAR CANTIDADES*/
		UPDATE @tbPedidoDetalle
		SET CantidadProcesada = (CantidadAceptada + CantidadEnAprobacion),
		CantidadRestante = CASE WHEN  (CantidadPedido - (CantidadAceptada + CantidadEnAprobacion)) < 0 THEN 0 ELSE (CantidadPedido - (CantidadAceptada + CantidadEnAprobacion)) END 

		/*ACTUALIZAR LA VALIDACION EXITOSA*/
		UPDATE @tbPedidoDetalle
		SET ValidacionExitosa = (CASE WHEN CAST(CantidadRestante  AS DECIMAL(28,4)) >=  CAST(CantidadRecepcionar AS DECIMAL(28,4)) THEN 1 ELSE 0 END)

	   SET @ValidacionesNoExitosas =  (SELECT COUNT(1)  FROM @tbPedidoDetalle WHERE ValidacionExitosa = 0)
	   IF @ValidacionesNoExitosas >	   0
	    BEGIN
			SELECT 
			Response  = 'ERROR_EN_VALIDACION_PRODUCTOS'

			SELECT PD.IdMaterial, POD.MaterialCotizadoTextoC, TPD.*
			FROM @tbPedidoDetalle TPD
			JOIN MM_PedidoDetalle PD
				ON TPD.IdPedidoDetalle = PD.IdPedidoDetalle
			JOIN MM_PeticionOfertaDetalle POD 
				ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle

		   RETURN 
	   END

	   /*4. GENERAR LA SOLICITUD ACEPTACION PEDIDO Y EL DETALLE*/
	   BEGIN
	   -- TODO ESTA BIEN ENTONCES GENERAR LA APROBACIÓN DE SOLICITUD  DE ACEPTACIÓN DE PEDIDO

	   INSERT INTO MM_SolicitudAceptacionPedido(IdProveedorVenta, IdPedido,Comentario, NombreUsuarioEntrega, NombreRecibidoPor,CreadorPor, CreadoEl,Activo)
	   VALUES(@IdProveedor,@IdPedido,@Comentario,@NombreUsuarioEntrega,@NombreRecibidoPor,@UsuarioId, GETDATE(),1)

	   SET @IdSolicitudAceptacionPedido = (SELECT SCOPE_IDENTITY())

	   INSERT INTO MM_SolicitudAceptacionPedidoDetalle(IdSolicitudAceptacionPedido,IdPedidoDetalle,Cantidad,CreadoPor,CreadoEl)
	   SELECT @IdSolicitudAceptacionPedido,PD.IdPedidoDetalle, PD.CantidadRecepcionar, @UsuarioId,GETDATE()
	   FROM @tbPedidoDetalle PD
	   END

	   /*5.- GENERAR APROBACION*/
	   BEGIN
	   /*AGREGAR ENCABEZADO DE LA APROBACIÓN, ESTOS TIPOS DE APROBACIONES NO TENDRAN FLUJO DE APROBACION, SE TOMARA POR DEFAULT EL SOLICITANTE DE LA REQUISICION,
	   SI NO HAY SOLICITANTE SE PASARA A TOMAR AL REQUISITOR (LO MAS PROBALE APLIQUE PARA REQUISICIONES QUE SE AGREGARON ANTES DE ESTA FUNCIONALIDA ANTES DE 25 JUNIO 2021)*/
	   INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdFlujoTarea,IdEstatusOperacion,IdEstadoFlujo,IdProveedor,IdAsignador,FechaRegistro, Descripcion) 
	   VALUES(@IdSolicitudAceptacionPedido,@TipoOperacionId,NULL,@IdEstatusEnAprobacion,1,@IdProveedor,@UsuarioId,GETDATE(),'')
	   
	   SET @IdOperacion = (SELECT SCOPE_IDENTITY())

	   /*OBTENER EL ID DEL SOLICITANTE DEL REQUISITOR DE LA SOLICITUD DE PEDIDO*/
	   SELECT @IdSolicitanteRequisicion = ISNULL(SP.Solicitante,SP.IdUsuarioSolicitante)
	   FROM MM_Pedido P
	   JOIN MM_SolicitudPedido SP
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE P.IdPedido=@IdPedido

		
		/*AGREGAR AL APROBADOR --> 
		-->NUMERO DE SECUENCIA DEFAULT EN 1 POR QUE SOLO ES UN APROBADOR*/
	   INSERT INTO TA_Tarea(NombreTarea,IdAprobador,IdEstatus,Visto,Comentario,Descripcion,FechaRegistro,Activo,NoSecuencia,IdOperacion)
	   VALUES ('Solicitud Aceptación pedido', @IdSolicitanteRequisicion,@IdEstatusEnAprobacion,0,'','',GETDATE(),1,1,@IdOperacion)
	  

	  SET @Descripcion_historial = CONCAT('El Usuario',
									(SELECT Nombre FROM S_USuario WHERE IdUsuario = @UsuarioId), 
									' ha registrado la ', (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion = @TipoOperacionId))

	   INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
	   VALUES (@Descripcion_historial,@IdOperacion,GETDATE(),1)

	   END 

	   /*6.- OBTENER INFORMACION ADICIONAL*/
	   BEGIN
			SELECT TOP 1
				@IdPedidoGeneral = PG.IdPedido,
				@NombreContrato = CONCAT(ISNULL(C.NumeroContrato,'') ,' - ' , ISNULL(AC.NombreAreaContractual,'')),
				@IdContrato = C.IdContrato,
				@PO = ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'SIN PO RELACIONADO')
			FROM MM_Pedido AS P  
			JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6) 
			LEFT JOIN Adinco..CO_Contrato C
				ON P.IdContrato = C.IdContrato
			LEFT JOIN Adinco..CO_AreaContractual AC 
				 ON C.IdAreaContractual = AC.IdAreaContractual  
			LEFT JOIN TA_Operacion AS O
				ON P.IdSolicitudPedido  = O.IdDocumento
				AND O.IdEstatusOperacion = 2 --> CTE APROBADO
				AND O.IdTipoOperacion = 9  --> CTE PEDIDO
			AND P.Version = O.NoVersion    		 
		    LEFT JOIN S_Proveedor AS PV 
				ON P.IdSubcontratista = PV.IdProveedor
		    LEFT JOIN WDEA_PurchasingDocumentsImportados AS WPI
				ON P.IdPedido = WPI.IdPedidoADINCO
		    LEFT JOIN DEA_Relacion_PR_PO AS POW
				ON P.IdPedido = POW.IdPedido
			WHERE P.IdPedido = @IdPedido

	   END 
	  

	  /*RETORNAR TABLA 1 DETALLE*/
	  SELECT Response = 'SUCCESS',
	  IdSolicitudAceptacionPedido = @IdSolicitudAceptacionPedido,
	  IdAprobacion  = @IdOperacion,
	  IdPedidoGeneral = @IdPedidoGeneral,
	  NombreContrato  = @NombreContrato

	  /*RETORNAR TABLA 2 APROBADORES */
	  SELECT  U.IdUsuario,
	  U.Nombre,
	  T.IdTarea,
	  U.Correo,
	  U.Activo
	  FROM TA_Tarea T
	  JOIN TA_Operacion O 
		ON T.IdOperacion = O.IdOperacion
	  JOIN S_Usuario U
		ON T.IdAprobador = U.IdUsuario
	  WHERE O.IdOperacion = @IdOperacion
	  AND T.Activo = 1

	  			  	 
END