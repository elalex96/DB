----USE [Petrovendor]
----IF EXISTS
----(
----    SELECT 1
----    FROM dbo.sysobjects
----    WHERE name = 'UPD_MM_SolicitarRestaurarProcesoEliminado'
----)
----    DROP PROCEDURE UPD_MM_SolicitarRestaurarProcesoEliminado;   
	
----GO
/****** Object:  StoredProcedure [dbo].[SP_MM_HistorialEliminacion_Procura]    Script Date: 06/11/2024 05:46:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description: RESTAURAR PROCESO ELIMINADO
-- =============================================

CREATE  PROCEDURE [dbo].[UPD_MM_SolicitarRestaurarProcesoEliminado]  
 @IdProveedor INT,
 @IdUsuario INT,
 @IdEliminacion INT,
 @Justificacion NVARCHAR(MAX),
 @Accion NVARCHAR(MAX),
 @IdContrato INT 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	DECLARE @Activo BIT 
	DECLARE @TipoEliminacion NVARCHAR(MAX) 
	DECLARE @IdProceso INT
	DECLARE @Id INT
	DECLARE @IdSolicitudPedido INT
	DECLARE @IdSolicitudPedidoDetalle INT 
	DECLARE @IdPeticionOfertaDetalle INT 
	DECLARE @IdPedido INT
	DECLARE @IdPedidoGeneral INT
	DECLARE @IdAceptacionPedido INT 
	DECLARE @EstatusValidacion NVARCHAR(MAX) 
	DECLARE @DetalleRestauracion NVARCHAR(MAX)  = ''
	DECLARE @DetalleNoRestauracion NVARCHAR(MAX)  = ''
	DECLARE @CantidadProductos INT
	DECLARE @CantidadRecuperar INT
	DECLARE @ContadorPedidoDetalle INT 
	DECLARE @ValidacionesNoExitosas INT 
	DECLARE @FECHACONSULTA DATETIME= GETDATE();
	DECLARE @MATERIALES_FALTANTES FLOAT;
	DECLARE @ADJUDICACION_PARCIAL BIT;
	DECLARE @CM_DISPONIBLES_POD FLOAT;
	DECLARE @MATERIALES_ADJ_DISPONIBLES DECIMAL(12, 2);
	DECLARE @ADD_PETICION_OFERTA_DETALLE_ACTUAL FLOAT;
	DECLARE @MaterialPOD NVARCHAR(MAX) 
	DECLARE @MATERIALES_UNICA_DISPONIBLES DECIMAL(12, 2);


	CREATE TABLE #PROCESO_HISTORIAL(
	ID INT IDENTITY(1,1),
	ID_PADRE INT, 
	PROCESO NVARCHAR(MAX),
	ESTATUS NVARCHAR(MAX),
	IDESTATUS INT,
	CLASS NVARCHAR(MAX),
	CLAVE_PROCESO NVARCHAR(MAX), 
	ACCION_EJECUTAR NVARCHAR(MAX),
	ID_PROCESO INT,
	ID_PROCESO_PUBLICO INT )
	CREATE TABLE #VALIDACION_FACTURAS(UUID NVARCHAR(MAX), IdAceptacion INT, FechaCarga NVARCHAR(MAX), Origen NVARCHAR(MAX))
	CREATE TABLE #FACTURAS(UUID NVARCHAR(MAX))
	CREATE TABLE #VALIDACION_Aceptaciones(IdAceptacion INT, IdPedido INT)
	
	CREATE TABLE #tbPedidoDetalleEnAprobacion   
	(IdPedidoDetalle INT,	
	CantidadEnAprobacion float)

	CREATE TABLE #tbPedidoDetalleAceptados 
	(IdPedidoDetalle INT,	
	CantidadAceptada float)

	CREATE TABLE #tbPedidoDetalle  
	(Id INT IDENTITY(1,1) PRIMARY KEY,
	IdPedidoDetalle INT,
	CantidadRecepcionar float,
	CantidadPedido float,
	CantidadEnAprobacion float,
	CantidadAceptada float,
	CantidadProcesada float,
	CantidadRestante float,
	ValidacionExitosa bit,
	PrecioUnitario FLOAT)

	CREATE TABLE #tbPedidoDetalleAceptacion (
		CantidadRecepcionar float NULL,
		IdPedidoDetalle int NULL
	)
	CREATE TABLE #tbPedidoDetalleRecuperar (
		IdRow INT IDENTITY(1,1),
		CantidadRecuperar float NULL,
		IdPeticionOfertaDetalle int NULL,
		IdSolicitudPedidoDetalle int NULL
	)

	CREATE TABLE #tbESTATUS_POR_SOLPED_DETALLE
    (CantidadSolicita                   FLOAT, 
    CantidadPorAgregarPedido            FLOAT, 
    CantidadEnPedidoAprobacion          FLOAT, 
    CantidadEnAprobacionRechazada       FLOAT, 
    CantidadEnConfirmacion              FLOAT, 
    CantidadEnConfirmacionAceptada      FLOAT, 
    CantidadEnConfirmacionRechazada     FLOAT, 
    CantidadEnConfirmacionItemRechazada FLOAT, 
    CantidadPorSolicitar                FLOAT, 
    MaterialSolicitado                  NVARCHAR(MAX), 
    CantidadRecibidaPedidoCerrado       FLOAT
    );
	DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')

	SELECT 
	@Id  = IdEliminacion,
	@Activo = Activo,
	@TipoEliminacion = TipoEliminacion,
	@IdProceso = IdProceso
	FROM AD_RegistroEliminacion
	WHERE IdEliminacion = @IdEliminacion

	IF ISNULL(@Id,0) = 0 
	BEGIN
		SELECT 'PROCESO_NO_ENCONTRADO' AS RESPONSE,
		'' AS DETALLE
		RETURN--> CANCELAR RECUPERACIÓN
	END 

	IF ISNULL(@Activo,0) = 0 
	BEGIN
		SELECT 'PROCESO_YA_RESTAURADO' AS RESPONSE,
		'' AS DETALLE
		RETURN --> CANCELAR RECUPERACIÓN
	END 

	/*VALIDACIONES GENERALES APLICA A TODAS LAS RESTAURACIONES*/
	--> VALIDAR SI LA RESTAURACIÓN INCLUYE FACTURAS
	INSERT INTO #FACTURAS(UUID)
	SELECT DISTINCT F.UUID
	FROM  MM_AceptacionFactura AF (NOLOCK)
	JOIN FI_Factura F (NOLOCK)
		ON AF.IdFactura = F.IdFactura
		AND AF.IdEliminado = F.IdEliminado
	WHERE AF.IdEliminado = @IdEliminacion
	GROUP BY F.UUID

	--VALIDAR QUE LOS UUIDS ELIMINADOS NO ESTEN EN UNA ACEPTACIÓN DE FACTURA ACTIVA
	INSERT INTO #VALIDACION_FACTURAS(UUID, IdAceptacion, FechaCarga, Origen)
	SELECT F.UUID, AF.IdAceptacionPedido, FORMAT(F.CreadoEn, 'dd/MM/yyyy'), 'AceptacionPedido'
	FROM  #FACTURAS FC	
	JOIN FI_Factura F (NOLOCK)
		ON FC.UUID  = F.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
		AND ISNULL(F.IdEliminado,0) = 0 
	JOIN MM_AceptacionFactura AF
		ON F.IdFactura = AF.IdFactura
		AND ISNULL(AF.IdEliminado,0) = 0  

	--VALIDAR QUE LOS UUIDS ELIMINADOS NO ESTEN EN  UNA COMPRA DIRECTA ACTIVA
	INSERT INTO #VALIDACION_FACTURAS(UUID, IdAceptacion, FechaCarga, Origen)
	SELECT F.UUID, PG.IdPedido, FORMAT(F.CreadoEn, 'dd/MM/yyyy'), 'CompraDirecta'
	FROM  #FACTURAS FC	
	JOIN FI_Factura F (NOLOCK)
		ON FC.UUID  = F.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
		AND ISNULL(F.IdEliminado,0) = 0 
	JOIN CO_Registro R
		ON F.IdFactura = R.IdFactura
	JOIN dbo.TA_Operacion AS TAO (NOLOCK)
        ON R.IdFactura = TAO.IdDocumento
		AND TAO.IdTipoOperacion = 14 --> CTE APROBACION COMPRA DIRECTA
	JOIN dbo.MM_Pedidos PG (NOLOCK)
		ON F.IdFactura = PG.IdIdentificador
		AND TAO.IdProveedor = PG.IdProveedorCliente
		AND PG.IdTipoPedido=1  --> CTE COMPRA DIRECTA
	WHERE ISNULL(F.IsEliminado,0) = 0
		
	--VALIDAR QUE LOS UUIDS ELIMINADOS NO ESTEN EN PETROVENDOR ENTONCES BUSCAR DIRECTAMENTE EN ADINCO
	INSERT INTO #VALIDACION_FACTURAS(UUID, IdAceptacion, FechaCarga, Origen)
	SELECT F.UUID, 0, FORMAT(F.CreadoEn, 'dd/MM/yyyy'),'Adinco'
	FROM  #FACTURAS FC	
	JOIN Adinco..FI_Factura F (NOLOCK)
	ON FC.UUID  = F.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE FC.UUID NOT IN (SELECT UUID FROM #VALIDACION_FACTURAS)
	GROUP BY  F.UUID, F.CreadoEn

	-- SI SE ENCONTRO UUIDS YA UTILIZADOS
	IF (SELECT COUNT(IdAceptacion) FROM #VALIDACION_FACTURAS) > 0
	BEGIN 
		
		SELECT @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion,'- El UUID: '+UUID+' que se quiere recuperar ya se encuentrá en la Aceptación de Factura No.', IdAceptacion,', Fecha de carga: ',ISNULL(FechaCarga,''),' <br>')
		FROM #VALIDACION_FACTURAS
		WHERE Origen = 'AceptacionPedido'

		SELECT @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion,'- El UUID: '+UUID+' que se quiere recuperar ya se encuentrá en la Compra directa No.', IdAceptacion,', Fecha de carga: ',ISNULL(FechaCarga,''),' <br>')
		FROM #VALIDACION_FACTURAS
		WHERE Origen = 'CompraDirecta'

		SELECT @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion,'- El UUID: '+UUID+' que se quiere recuperar ya se encuentrá en Adinco, Fecha de carga: ',ISNULL(FechaCarga,''),' <br>')
		FROM #VALIDACION_FACTURAS
		WHERE Origen = 'Adinco'

		SELECT 'PROCESO_NO_PUEDE_RESTAURARSE' AS RESPONSE,
		@DetalleNoRestauracion AS DETALLE
		RETURN --> CANCELAR RECUPERACIÓN

	END 

	/*VALIDACIONES CUANDO SE DEBE RESTAURAR UN DE PEDIDO Y QUE NO SOBREPASEN LAS CANTIDADES DE LA REQUISICION*/
	IF @TipoEliminacion = 'P'
	BEGIN 
		SELECT @IdPedido = IdPedido,
		@IdSolicitudPedido = IdSolicitudPedido
		FROM MM_Pedido P (NOLOCK)
        WHERE P.IdEliminado = @IdEliminacion

		/*1. OBTENER LAS REFERENCIAS DE LOS PRODUCTOS A RECUPERAR EN EL PEDIDO ELIMINADO*/
		INSERT INTO #tbPedidoDetalleRecuperar(CantidadRecuperar, IdPeticionOfertaDetalle, IdSolicitudPedidoDetalle)
		SELECT SUM(PD.Cantidad), PD.IdPeticionOfertaDetalle, POD.IdSolicitudPedidoDetalle
		FROM MM_Pedido P (NOLOCK)
		JOIN MM_PedidoDetalle PD(NOLOCK)
			ON P.IdPedido = PD.IdPedido
		JOIN MM_PeticionOferta PO(NOLOCK)
			ON P.IdPeticionOferta = PO.IdPeticionOferta
			AND P.IdSolicitudPedido = PO.IdSolicitudPedido
		JOIN MM_PeticionOfertaDetalle POD (NOLOCK)
			ON PO.IdPeticionOferta = POD.IdPeticionOferta
			AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
		WHERE P.IdPedido = @IdPedido
		GROUP BY PD.IdPeticionOfertaDetalle, 
		POD.IdSolicitudPedidoDetalle,
		POD.MaterialCotizadoTextoC

		SET @CantidadProductos = (SELECT COUNT(1) 
								 FROM #tbPedidoDetalleRecuperar)

		SET @ContadorPedidoDetalle = 1
		SET @ADJUDICACION_PARCIAL = (
								SELECT SP.AdjudicableParcialmente
								FROM MM_SolicitudPedido AS SP (NOLOCK)
								WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
							);
		-- RECORRER TODOS LOS MATERIALES DEL PEDIDO QUE SE QUIERE RESTAURAR PARA VALIDAR CANTIDADES ESTEN DISPONIBLES
		WHILE @CantidadProductos >= @ContadorPedidoDetalle
		BEGIN
			SELECT 
			@IdSolicitudPedidoDetalle = IdSolicitudPedidoDetalle,
			@IdPeticionOfertaDetalle =IdPeticionOfertaDetalle,
			@CantidadRecuperar =CantidadRecuperar
			FROM #tbPedidoDetalleRecuperar (NOLOCK)
			WHERE IdRow = @ContadorPedidoDetalle

			-- CANTIDAD QUE ESTEN EN EL CARRITO
			SET @ADD_PETICION_OFERTA_DETALLE_ACTUAL =
            (
                SELECT POD.AddCantidadTemp
                FROM MM_PeticionOfertaDetalle AS POD (NOLOCK)
                WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
                AND AddValidado = 1
            );

			-- CONSULTAR RESUMEN DE CANTIDADES DEL MATERIAL ACTUAL
			TRUNCATE TABLE #tbESTATUS_POR_SOLPED_DETALLE
			INSERT INTO #tbESTATUS_POR_SOLPED_DETALLE
			(CantidadSolicita                    , 
			CantidadPorAgregarPedido            , 
			CantidadEnPedidoAprobacion          , 
			CantidadEnAprobacionRechazada       , 
			CantidadEnConfirmacion              , 
			CantidadEnConfirmacionAceptada      , 
			CantidadEnConfirmacionRechazada     , 
			CantidadEnConfirmacionItemRechazada , 
			CantidadPorSolicitar                , 
			MaterialSolicitado                  , 
			CantidadRecibidaPedidoCerrado       
			)
            EXEC dbo.SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5 
                    @IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle, -- int
                    @IdContrato = 0, -- int --> CTE NO ES NECESARIO MANDAR UN CONTRATO
                    @IdUsuario = 0, -- int --> CTE NO ES NECESARIO MANDAR UN USUARIO ID
                    @FechaRegistro = @FECHACONSULTA -- datetime

			-- MATERIALES DISPONIBLES PARA COMPLETAR LO SOLICITADO EN LA REQUISICION DETALLE
            SELECT TOP 1 @MATERIALES_FALTANTES = CantidadPorSolicitar,
			@MaterialPOD = MaterialSolicitado
            FROM #tbESTATUS_POR_SOLPED_DETALLE               
			
			-- VALIDAR CANTIDAD DE ACUERDO AL TIPO DE ADJUDICACIÓN
			IF @ADJUDICACION_PARCIAL = 1
			BEGIN
				 ---#LA REQUISICION ES ADJUDICACION PARCIAL 
				 -- CONSULTAR LA CANTIDAD DISPONIBLE DE LA COTIZACIÓN DETALLE ACTUAL 
                EXEC SP_MM_ConsultarDisponibilidadPOD 
                        @IdPeticionOfertaDetalle, 
                        @IdSolicitudPedidoDetalle, 
                        @CM_DISPONIBLES_POD OUTPUT;

				 -- VALIDAR LA DISPONIBILIDAD DE LA COTIZACIÓN DEL PROVEEDOR QUE NO SOBREPASE LA CANTIDAD INGRESADA 					
                IF CAST(ISNULL(@CM_DISPONIBLES_POD, 0) AS DECIMAL(12, 2)) >= CAST(ISNULL(@CantidadRecuperar, 0) AS DECIMAL(12, 2))
                BEGIN
					--VALIDAR QUE LA CANTIDAD SOLICITADA NO SOBREPASE LA CANTIDAD AGREGADA 
                    -- COMO EN @CM_DISPONIBLES_POD NO SE TOMAN EN CUENTA LOS MATERIALES CARRITO SE DEBEN SUMAR A LA DISPONIBLIDAD ACTUAL
					SET @MATERIALES_ADJ_DISPONIBLES = (ISNULL(@MATERIALES_FALTANTES, 0) + ISNULL(@ADD_PETICION_OFERTA_DETALLE_ACTUAL, 0));
					IF(CAST(ISNULL(@CantidadRecuperar, 0) AS DECIMAL(12, 2)) > @MATERIALES_ADJ_DISPONIBLES)
                    BEGIN
						SET @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion, '- En el material: ',ISNULL(@MaterialPOD,''), ', la cantidad ha recuperar: ',ISNULL(@CantidadRecuperar,0),', es mayor a la cantidad disponible: ', ISNULL(@MATERIALES_ADJ_DISPONIBLES,0),' <br><br>')
					END 
				END 
				ELSE
				BEGIN 
					SET @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion, '- En el material: ',ISNULL(@MaterialPOD,''), ', la cantidad ha recuperar: ',ISNULL(@CantidadRecuperar,0),', es mayor a la cantidad cotizada por el proveedor disponible: ', ISNULL(@CM_DISPONIBLES_POD,0),' <br><br>')

				END
			END 
			ELSE 
			BEGIN
			 ---#ADJUDICACION UNICA
			 ---VALIDAR QUE LA CANTIDAD NO SOBREPASE LA CANTIDAD SOLICITADA 
             --- EN ADJUDICACIÓN ÚNICA SE DEBE AGREGAR A LA ORDEN DE COMPRA LA CANTIDAD INDICADA EN LA SOLPED DETALLE ACTUAL
			   SET @MATERIALES_UNICA_DISPONIBLES = (ISNULL(@MATERIALES_FALTANTES, 0) + ISNULL(@ADD_PETICION_OFERTA_DETALLE_ACTUAL, 0));
			   IF(@MATERIALES_UNICA_DISPONIBLES <> CAST(ISNULL(@CantidadRecuperar, 0) AS DECIMAL(12, 2)))
                BEGIN
					SET @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion, '- En el material: ',ISNULL(@MaterialPOD,''), ', la cantidad ha recuperar: ',ISNULL(@CantidadRecuperar,0),', es diferente a la cantidad disponible: ', ISNULL(@MATERIALES_UNICA_DISPONIBLES,0),' - [Adjudicación única] <br><br>')
				END 
			END 

			SET @ContadorPedidoDetalle = @ContadorPedidoDetalle +1
		END 

		IF LEN(@DetalleNoRestauracion) > 0 
		BEGIN
			SET @DetalleNoRestauracion = CONCAT('Materiales de la Oferta #', @IdSolicitudPedido,'<br><br>',@DetalleNoRestauracion) 
			SELECT 'PROCESO_NO_PUEDE_RESTAURARSE' AS RESPONSE,
			@DetalleNoRestauracion AS DETALLE
		   RETURN --> 
		END 
	END 


	/*VALIDACIONES CUANDO SE DEBE RESTAURAR UNA ACEPTACIÓN DE PEDIDO - VALIDAR CANTIDADES 
	DE LOS PRODUCTOS NO SOPREPASEN LAS CANTIDADES DEL PEDIDO*/
	IF  @TipoEliminacion = 'AP'  
	BEGIN
		
		SELECT @IdPedido = IdPedido,
		@IdAceptacionPedido = IdAceptacionPedido
		FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

		SELECT @IdPedidoGeneral =  PG.IdPedido
		FROM MM_Pedido P
		JOIN MM_Pedidos PG
			ON P.IdPedido = PG.IdIdentificador
			AND	PG.IdProveedorCliente		=	P.IdProveedorCompras
			AND	PG.IdTipoPedido				IN	(2, 4, 6) --> CTES MERCADEO, ORDER DE TRABAJO Y AD DIRECTA
		WHERE P.IdPedido = @IdPedido
	    /*1. OBTENER LAS REFERENCIAS DE LOS PRODUCTOS A RECUPERAR EN LA ACEPTACIÓN*/

		INSERT INTO #tbPedidoDetalleAceptacion(CantidadRecepcionar, IdPedidoDetalle)
		SELECT SUM(APD.Cantidad), APD.IdPedidoDetalle 
		FROM MM_AceptacionPedido AP (NOLOCK)
		JOIN MM_AceptacionPedidoDetalle APD
			ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
		WHERE AP.IdEliminado = @IdEliminacion
		GROUP BY  APD.IdPedidoDetalle
		
		INSERT INTO #tbPedidoDetalle(IdPedidoDetalle,CantidadPedido,CantidadRecepcionar,CantidadAceptada,CantidadEnAprobacion,CantidadProcesada,CantidadRestante,ValidacionExitosa,PrecioUnitario)
		SELECT 
		IdPedidoDetalle = PD.IdPedidoDetalle,		
		CantidadPedido= PD.Cantidad,
		CantidadRecepcionar= tbAP.CantidadRecepcionar,
		CantidadAceptada= 0,
		CantidadEnAprobacion= 0,
		CantidadProcesada= 0,
		CantidadRestante =0,
		ValidacionExitosa = 0,
		PD.PrecioUnitario
		FROM MM_Pedido AS P
		JOIN MM_PedidoDetalle AS PD (NOLOCK)
			ON P.IdPedido = PD.IdPedido 
		JOIN #tbPedidoDetalleAceptacion AS tbAP  (NOLOCK)
			ON PD.IdPedidoDetalle = tbAP.IdPedidoDetalle
		WHERE 		
		P.IdPedido = @IdPedido

		/*2.- OBTENER CANTIDAD EN APROBACION - APLICA PARA LAS SAS*/
	     INSERT INTO #tbPedidoDetalleEnAprobacion(IdPedidoDetalle,CantidadEnAprobacion)
		 SELECT 
		 PD.IdPedidoDetalle, 
		 CantidadEnAprobacion = SUM(SAPD.Cantidad)
		FROM #tbPedidoDetalle PD(NOLOCK)
		JOIN MM_SolicitudAceptacionPedidoDetalle SAPD (NOLOCK)
			ON PD.IdPedidoDetalle = SAPD.IdPedidoDetalle
		JOIN MM_SolicitudAceptacionPedido SAP
			ON SAPD.IdSolicitudAceptacionPedido = SAP.IdSolicitudAceptacionPedido
			AND 1 = SAP.Activo
		JOIN TA_Operacion O (NOLOCK)
			ON SAP.IdSolicitudAceptacionPedido = O.IdDocumento
			AND @TipoOperacionId = O.IdTipoOperacion --> Aprobación de solicitud de aceptación de pedido
			AND 1 = O.IdEstatusOperacion --> EN APROBACIÓN 
			AND 0 = ISNULL(O.IdEstatusEliminado,0)
		 WHERE SAP.IdPedido = @IdPedido
		 GROUP BY PD.IdPedidoDetalle

		 UPDATE PD
		 SET PD.CantidadEnAprobacion=PDEA.CantidadEnAprobacion
		 FROM #tbPedidoDetalle PD
		 JOIN #tbPedidoDetalleEnAprobacion PDEA
			ON PD.IdPedidoDetalle = PDEA.IdPedidoDetalle			

		 /*3.OBTENER LAS CANTIDADES QUE YA ESTAN EN UNA ACEPTACION DE PEDIDO*/
		 INSERT INTO #tbPedidoDetalleAceptados(IdPedidoDetalle, CantidadAceptada)
		 SELECT
		 PD.IdPedidoDetalle,
		 CantidadAceptada = SUM(APD.Cantidad)
		 FROM  #tbPedidoDetalle PD
		 JOIN MM_AceptacionPedidoDetalle APD (NOLOCK)
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		 JOIN MM_AceptacionPedido AP (NOLOCK)
			ON APD.IdAceptacionPedido	= AP.IdAceptacionPedido
				AND 1 = AP.Activo
				AND 0 = ISNULL(AP.IdEstatusEliminado,0)
		 WHERE AP.IdPedido=@IdPedido
		 GROUP BY PD.IdPedidoDetalle

		UPDATE PD
		 SET PD.CantidadAceptada=APD.CantidadAceptada
		 FROM #tbPedidoDetalle PD
		 JOIN #tbPedidoDetalleAceptados APD
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle	
			

		/*ACTUALIZAR CANTIDADES*/
		UPDATE #tbPedidoDetalle
		SET CantidadProcesada = (CantidadAceptada + CantidadEnAprobacion),
		CantidadRestante = CASE WHEN  (CantidadPedido - (CantidadAceptada + CantidadEnAprobacion)) < 0 THEN 0 ELSE (CantidadPedido - (CantidadAceptada + CantidadEnAprobacion)) END 

		/*ACTUALIZAR LA VALIDACION EXITOSA*/
		UPDATE #tbPedidoDetalle
		SET ValidacionExitosa = (CASE WHEN CAST(CantidadRestante  AS DECIMAL(28,4)) >=  CAST(CantidadRecepcionar AS DECIMAL(28,4)) THEN 1 ELSE 0 END)

	   SET @ValidacionesNoExitosas =  (SELECT COUNT(1)  FROM #tbPedidoDetalle WHERE ValidacionExitosa = 0)
	   IF @ValidacionesNoExitosas >	   0
	    BEGIN
			
			SET @DetalleNoRestauracion = CONCAT('Si se recuperá la Aceptación de Pedido # ',ISNULL(@IdAceptacionPedido,0),', excederá las cantidades solicitadas en el Pedido #',ISNULL(@IdPedidoGeneral,0),' <br><br>')
			SELECT @DetalleNoRestauracion = CONCAT(@DetalleNoRestauracion,'- Material: (',ISNULL(PD.IdMaterialVendedor,0),')',POD.MaterialCotizadoTextoC,', Cantidad Pedido: ', ISNULL(TPD.CantidadPedido,0),', Cantidad aceptada actualmente: ',ISNULL(TPD.CantidadProcesada,0),', Cantidad disponible a recuperar: ', ISNULL(TPD.CantidadRestante,0),', Cantidad en Aceptación  a recuperar: ', ISNULL(TPD.CantidadRecepcionar,0),'<br>' )
			FROM #tbPedidoDetalle TPD
			JOIN MM_PedidoDetalle PD (NOLOCK)
				ON TPD.IdPedidoDetalle = PD.IdPedidoDetalle
			JOIN MM_PeticionOfertaDetalle POD 
				ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
			ORDER BY POD.MaterialCotizadoTextoC ASC

			SELECT 'PROCESO_NO_PUEDE_RESTAURARSE' AS RESPONSE,
			@DetalleNoRestauracion AS DETALLE

		   RETURN --> CANCELAR RECUPERACIÓN
	   END
	END 

	-- SI TODO ESTA OK PERO SOLO ERA VALIDACIÓN PARA VER SI SE PUEDE RECUPERAR EL PROCESO 
    IF @Accion = 'VALIDAR_SI_PROCEDE_RESTAURACION' 
	BEGIN 
		
		SELECT 'SOLICITAR_JUSTIFICACION' AS RESPONSE,
		'' AS DETALLE
		RETURN --> CANCELAR RECUPERACIÓN PARA QUE EN INTERFAZ SE SOLICITE LA JUSTIFICACIÓN
	END 
	
	/*RESTAURAR TODO EL PROCESO DE SOLICITUD DE PEDIDO*/
	IF @TipoEliminacion = 'SP'  AND @Accion  ='REALIZAR_RECUPERACION' 
	BEGIN 
		
		/*RESTAURAR DE SOLICITUD DE PEDIDO*/
		INSERT INTO #PROCESO_HISTORIAL(
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO
		)
		EXEC [SP_MM_HistorialEliminacion_Procura]
		 @IDPROVEEDOR = @IdProveedor,
		 @IDCONTRATO = @IdContrato,
		 @IDUSUARIO = @IdUsuario,
		 @ACCION = 'HISTORIAL_DETALLE',
		 @IDELIMINADO = @IdEliminacion

		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_SolicitudPedido WHERE IdSolicitudPedido = ', SP.IdSolicitudPedido,char(10),char(13))
		FROM MM_SolicitudPedido SP (NOLOCK)
		WHERE SP.IdSolicitudPedido = @IdProceso
		AND SP.IdEliminado = @IdEliminacion
	
        UPDATE SP
        SET IdEstatusEliminado = NULL,
           IdEliminado = NULL,
		   Activo = 1
		FROM MM_SolicitudPedido SP (NOLOCK)
		WHERE SP.IdSolicitudPedido = @IdProceso
		AND SP.IdEliminado = @IdEliminacion

		 /*RESTAURAR DE OPERACIÓN DE OFERTA-COTIZACIONES*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdTipoOperacion,IdEstatusEliminado,IdEliminado FROM TA_Operacion WHERE IdOperacion = ', O.IdOperacion,char(10),char(13))
		FROM TA_Operacion O (NOLOCK)
        WHERE O.IdDocumento = @IdProceso
			AND O.IdEliminado = @IdEliminacion
			AND O.IdTipoOperacion = 6 --> OPERACIÓN DE OFERTA - COTIZACIÓN

        UPDATE O
        SET O.IdEstatusEliminado = NULL,
            O.IdEliminado = NULL
        FROM dbo.TA_Operacion O (NOLOCK)
        WHERE O.IdDocumento = @IdProceso
			AND O.IdEliminado = @IdEliminacion
			AND O.IdTipoOperacion = 6 --> OPERACIÓN DE OFERTA - COTIZACIÓN
		
	    /*RESTAURAR DE COTIZACIONES*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_PeticionOferta WHERE IdPeticionOferta = ',PO.IdPeticionOferta,char(10),char(13))
		FROM MM_PeticionOferta PO (NOLOCK)
        WHERE PO.IdSolicitudPedido = @IdProceso
		AND PO.IdEliminado = @IdEliminacion

        UPDATE PO
        SET PO.IdEstatusEliminado = NULL,
            PO.IdEliminado = NULL,
			PO.Activo = 1
        FROM MM_PeticionOferta PO (NOLOCK)
        WHERE PO.IdSolicitudPedido = @IdProceso
		AND PO.IdEliminado = @IdEliminacion

		 /*RESTAURAR APROBACIÓN DE SOLICITUD DE PEDIDO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdTipoOperacion,IdEstatusEliminado,IdEliminado FROM TA_Operacion WHERE IdOperacion = ',O.IdOperacion,char(10),char(13))
		FROM TA_Operacion O(NOLOCK)
        WHERE O.IdDocumento = @IdProceso
        AND O.IdTipoOperacion = 2 --> OPERACIÓN DE SOLICITUD DE PEDIDO
		AND O.IdEliminado = @IdEliminacion


        UPDATE O
        SET O.IdEstatusEliminado = NULL,
            O.IdEliminado = NULL
        FROM TA_Operacion O(NOLOCK)
        WHERE O.IdDocumento = @IdProceso
        AND O.IdTipoOperacion = 2 --> OPERACIÓN DE SOLICITUD DE PEDIDO
		AND O.IdEliminado = @IdEliminacion

		/*RESTAURAR DE APROBACIÓN DE PEDIDO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdTipoOperacion,IdEstatusEliminado,IdEliminado FROM TA_Operacion WHERE IdOperacion = ',O.IdOperacion,char(10),char(13))
		FROM TA_Operacion O (NOLOCK)
        WHERE O.IdDocumento = @IdProceso
        AND O.IdTipoOperacion = 9 --> OPERACIÓN DE PEDIDO
		AND O.IdEliminado = @IdEliminacion

        UPDATE O
        SET O.IdEstatusEliminado = NULL,
            O.IdEliminado = NULL
        FROM TA_Operacion O (NOLOCK)
        WHERE O.IdDocumento = @IdProceso
        AND O.IdTipoOperacion = 9 --> OPERACIÓN DE PEDIDO
		AND O.IdEliminado = @IdEliminacion 

		/*RESTAURAR DE PEDIDOS*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_Pedido WHERE IdPedido = ',P.IdPedido,char(10),char(13))
		FROM MM_Pedido P (NOLOCK)
        WHERE P.IdEliminado = @IdEliminacion
		AND P.IdSolicitudPedido = @IdProceso

        UPDATE P
        SET P.IdEstatusEliminado = NULL,
            P.IdEliminado = NULL,
			P.Activo = 1
        FROM MM_Pedido P (NOLOCK)
        WHERE P.IdEliminado = @IdEliminacion
		AND P.IdSolicitudPedido = @IdProceso

		/*RESTAURAR ACEPTACION DE PEDIDO EN PROCESO DE MM_AceptacionPedido*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_AceptacionPedido WHERE IdAceptacionPedido = ',AP.IdAceptacionPedido,char(10),char(13))
		FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

        UPDATE AP
        SET IdEstatusEliminado = NULL,
            IdEliminado = NULL,
			Activo = 1
        FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

		 /*RESTAURAR APROBACIÓN CARTA CONTENIDO NACIONAL EN PROCESO DE MM_AceptacionCartaPCN*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado FROM MM_AceptacionCartaPCN WHERE IdAceptacionCartaPCN = ',AC.IdAceptacionCartaPCN,char(10),char(13))
	    FROM MM_AceptacionCartaPCN AC (NOLOCK)
        WHERE AC.IdEliminado = @IdEliminacion

        UPDATE AC
        SET AC.IdEstatusEliminado = NULL,
            AC.IdEliminado = NULL
        FROM MM_AceptacionCartaPCN AC (NOLOCK)
        WHERE AC.IdEliminado = @IdEliminacion

		/*RESTAURAR APROBACIÓN FACTURA EN PROCESO DE MM_AceptacionFactura*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado FROM MM_AceptacionFactura WHERE IdAceptacionFactura = ',AF.IdAceptacionFactura,char(10),char(13))
		FROM MM_AceptacionFactura AF (NOLOCK)
        WHERE AF.IdEliminado = @IdEliminacion

		UPDATE AF
        SET AF.IdEstatusEliminado = NULL,
            AF.IdEliminado = NULL
        FROM MM_AceptacionFactura AF (NOLOCK)
        WHERE AF.IdEliminado = @IdEliminacion

		/*RESTAURAR FACTURA EN FI_FACTURA*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado, ComentarioEliminado,EliminadoPor, Activa, IdEliminado FROM FI_Factura WHERE IdFactura = ',F.IdFactura,char(10),char(13))
		FROM FI_Factura F (NOLOCK)
        WHERE F.IdEliminado = @IdEliminacion

        UPDATE F
        SET F.IsEliminado = NULL,
            F.EliminadoEL = NULL,
            F.ComentarioEliminado = '',
            F.EliminadoPor = NULL,
            F.Activa = 1,
            F.IdEliminado = NULL
        FROM FI_Factura F (NOLOCK)
        WHERE F.IdEliminado = @IdEliminacion

		/*RESTAURAR PEDIMENTO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado, IsActivo FROM FI_PedimentoComprobante WHERE IdPedimentoComprobante = ',PC.IdPedimentoComprobante,char(10),char(13))
		FROM  FI_PedimentoComprobante PC
        WHERE PC.IdEliminado = @IdEliminacion

		UPDATE PC
        SET PC.IdEstatusEliminado = NULL,
            PC.IdEliminado = NULL,
			PC.IsActivo = 1
		FROM  FI_PedimentoComprobante PC
        WHERE PC.IdEliminado = @IdEliminacion

		/*GUARDAR DETALLE DE LA RESTAURACIÓN*/
		UPDATE AD_RegistroEliminacion
		SET Activo = 0,
		FechaRecuperacion = GETDATE(),
		ComentarioRecuperacion = @Justificacion,
		RecuperadoPor = @IdUsuario,
		HistorialRecuperacion = @DetalleRestauracion
		WHERE IdEliminacion = @IdEliminacion

		INSERT INTO APP_BitacoraRestauracionProcesosDetalle(
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		ID_ELIMINADO,
	    CREADO_EL,
	    CREADO_POR
		)
		SELECT ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		@IdEliminacion,
		GETDATE(),
		@IdUsuario
		FROM #PROCESO_HISTORIAL

		SELECT 'PROCESO_RESTAURADO' AS RESPONSE,
		'' AS DETALLE

		RETURN 
		
	END 
	
	/*RESTAURAR TODO EL PROCESO DE PEDIDO*/
	IF @TipoEliminacion = 'P'  AND @Accion  ='REALIZAR_RECUPERACION' 
	BEGIN 
		
		/*RESTAURAR DE PEDIDO*/
		INSERT INTO #PROCESO_HISTORIAL(
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO
		)
		EXEC [SP_MM_HistorialEliminacion_Procura]
		 @IDPROVEEDOR = @IdProveedor,
		 @IDCONTRATO = @IdContrato,
		 @IDUSUARIO = @IdUsuario,
		 @ACCION = 'HISTORIAL_DETALLE',
		 @IDELIMINADO = @IdEliminacion
		       

		/*RESTAURAR DE APROBACIÓN DE PEDIDO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdTipoOperacion,IdEstatusEliminado,IdEliminado FROM TA_Operacion WHERE IdOperacion = ',O.IdOperacion,char(10),char(13))
		FROM TA_Operacion O (NOLOCK)
        WHERE O.IdTipoOperacion = 9 --> OPERACIÓN DE PEDIDO
		AND O.IdEliminado = @IdEliminacion

        UPDATE O
        SET O.IdEstatusEliminado = NULL,
            O.IdEliminado = NULL
        FROM TA_Operacion O (NOLOCK)
        WHERE O.IdTipoOperacion = 9 --> OPERACIÓN DE PEDIDO
		AND O.IdEliminado = @IdEliminacion 

		/*RESTAURA DE PEDIDO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_Pedido WHERE IdPedido = ',P.IdPedido,char(10),char(13))
		FROM MM_Pedido P (NOLOCK)
        WHERE P.IdEliminado = @IdEliminacion

        UPDATE P
        SET P.IdEstatusEliminado = NULL,
            P.IdEliminado = NULL,
			P.Activo = 1
        FROM MM_Pedido P (NOLOCK)
        WHERE P.IdEliminado = @IdEliminacion

		/*RESTAURAR ACEPTACION DE PEDIDO EN PROCESO DE MM_AceptacionPedido*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_AceptacionPedido WHERE IdAceptacionPedido = ',AP.IdAceptacionPedido,char(10),char(13))
		FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

        UPDATE AP
        SET IdEstatusEliminado = NULL,
            IdEliminado = NULL,
			Activo = 1
        FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

		 /*RESTAURAR APROBACIÓN CARTA CONTENIDO NACIONAL EN PROCESO DE MM_AceptacionCartaPCN*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado FROM MM_AceptacionCartaPCN WHERE IdAceptacionCartaPCN = ',AC.IdAceptacionCartaPCN,char(10),char(13))
	    FROM MM_AceptacionCartaPCN AC (NOLOCK)
        WHERE AC.IdEliminado = @IdEliminacion

        UPDATE AC
        SET AC.IdEstatusEliminado = NULL,
            AC.IdEliminado = NULL
        FROM MM_AceptacionCartaPCN AC (NOLOCK)
        WHERE AC.IdEliminado = @IdEliminacion

		/*RESTAURAR APROBACIÓN FACTURA EN PROCESO DE MM_AceptacionFactura*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado FROM MM_AceptacionFactura WHERE IdAceptacionFactura = ',AF.IdAceptacionFactura,char(10),char(13))
		FROM MM_AceptacionFactura AF (NOLOCK)
        WHERE AF.IdEliminado = @IdEliminacion

		UPDATE AF
        SET AF.IdEstatusEliminado = NULL,
            AF.IdEliminado = NULL
        FROM MM_AceptacionFactura AF (NOLOCK)
        WHERE AF.IdEliminado = @IdEliminacion

		/*RESTAURAR FACTURA EN FI_FACTURA*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado, ComentarioEliminado,EliminadoPor, Activa, IdEliminado FROM FI_Factura WHERE IdFactura = ',F.IdFactura,char(10),char(13))
		FROM FI_Factura F (NOLOCK)
        WHERE F.IdEliminado = @IdEliminacion

        UPDATE F
        SET F.IsEliminado = NULL,
            F.EliminadoEL = NULL,
            F.ComentarioEliminado = '',
            F.EliminadoPor = NULL,
            F.Activa = 1,
            F.IdEliminado = NULL
        FROM FI_Factura F (NOLOCK)
        WHERE F.IdEliminado = @IdEliminacion

		/*RESTAURAR PEDIMENTO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado, IsActivo FROM FI_PedimentoComprobante WHERE IdPedimentoComprobante = ',PC.IdPedimentoComprobante,char(10),char(13))
		FROM  FI_PedimentoComprobante PC
        WHERE PC.IdEliminado = @IdEliminacion

		UPDATE PC
        SET PC.IdEstatusEliminado = NULL,
            PC.IdEliminado = NULL,
			PC.IsActivo = 1
		FROM  FI_PedimentoComprobante PC
        WHERE PC.IdEliminado = @IdEliminacion

		/*GUARDAR DETALLE DE LA RESTAURACIÓN*/
		UPDATE AD_RegistroEliminacion
		SET Activo = 0,
		FechaRecuperacion = GETDATE(),
		ComentarioRecuperacion = @Justificacion,
		RecuperadoPor = @IdUsuario,
		HistorialRecuperacion = @DetalleRestauracion
		WHERE IdEliminacion = @IdEliminacion


		INSERT INTO APP_BitacoraRestauracionProcesosDetalle(
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		ID_ELIMINADO,
	    CREADO_EL,
	    CREADO_POR
		)
		SELECT ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		@IdEliminacion,
		GETDATE(),
		@IdUsuario
		FROM #PROCESO_HISTORIAL

		SELECT 'PROCESO_RESTAURADO' AS RESPONSE,
		'' AS DETALLE

		RETURN 
		
	END 
	
	/*RESTAURAR TODO EL PROCESO DE ACEPTACIÓN DE PEDIDO*/
	IF @TipoEliminacion = 'AP'  AND @Accion  ='REALIZAR_RECUPERACION' 
	BEGIN 
		
		/*RESTAURAR DE ACEPTACIÓN DE PEDIDO*/
		INSERT INTO #PROCESO_HISTORIAL(
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO
		)
		EXEC [SP_MM_HistorialEliminacion_Procura]
		 @IDPROVEEDOR = @IdProveedor,
		 @IDCONTRATO = @IdContrato,
		 @IDUSUARIO = @IdUsuario,
		 @ACCION = 'HISTORIAL_DETALLE',
		 @IDELIMINADO = @IdEliminacion
		       
			   		
		/*RESTAURAR ACEPTACION DE PEDIDO EN PROCESO DE MM_AceptacionPedido*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado,Activo FROM MM_AceptacionPedido WHERE IdAceptacionPedido = ',AP.IdAceptacionPedido,char(10),char(13))
		FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

        UPDATE AP
        SET IdEstatusEliminado = NULL,
            IdEliminado = NULL,
			Activo = 1
        FROM MM_AceptacionPedido AP (NOLOCK)
        WHERE AP.IdEliminado = @IdEliminacion

		 /*RESTAURAR APROBACIÓN CARTA CONTENIDO NACIONAL EN PROCESO DE MM_AceptacionCartaPCN*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado FROM MM_AceptacionCartaPCN WHERE IdAceptacionCartaPCN = ',AC.IdAceptacionCartaPCN,char(10),char(13))
	    FROM MM_AceptacionCartaPCN AC (NOLOCK)
        WHERE AC.IdEliminado = @IdEliminacion

        UPDATE AC
        SET AC.IdEstatusEliminado = NULL,
            AC.IdEliminado = NULL
        FROM MM_AceptacionCartaPCN AC (NOLOCK)
        WHERE AC.IdEliminado = @IdEliminacion

		/*RESTAURAR APROBACIÓN FACTURA EN PROCESO DE MM_AceptacionFactura*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado FROM MM_AceptacionFactura WHERE IdAceptacionFactura = ',AF.IdAceptacionFactura,char(10),char(13))
		FROM MM_AceptacionFactura AF (NOLOCK)
        WHERE AF.IdEliminado = @IdEliminacion

		UPDATE AF
        SET AF.IdEstatusEliminado = NULL,
            AF.IdEliminado = NULL
        FROM MM_AceptacionFactura AF (NOLOCK)
        WHERE AF.IdEliminado = @IdEliminacion

		/*RESTAURAR FACTURA EN FI_FACTURA*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado, ComentarioEliminado,EliminadoPor, Activa, IdEliminado FROM FI_Factura WHERE IdFactura = ',F.IdFactura,char(10),char(13))
		FROM FI_Factura F (NOLOCK)
        WHERE F.IdEliminado = @IdEliminacion

        UPDATE F
        SET F.IsEliminado = NULL,
            F.EliminadoEL = NULL,
            F.ComentarioEliminado = '',
            F.EliminadoPor = NULL,
            F.Activa = 1,
            F.IdEliminado = NULL
        FROM FI_Factura F (NOLOCK)
        WHERE F.IdEliminado = @IdEliminacion

		/*RESTAURAR PEDIMENTO*/
		SELECT @DetalleRestauracion = CONCAT(@DetalleRestauracion, 'SELECT IdEstatusEliminado,IdEliminado, IsActivo FROM FI_PedimentoComprobante WHERE IdPedimentoComprobante = ',PC.IdPedimentoComprobante,char(10),char(13))
		FROM  FI_PedimentoComprobante PC
        WHERE PC.IdEliminado = @IdEliminacion

		UPDATE PC
        SET PC.IdEstatusEliminado = NULL,
            PC.IdEliminado = NULL,
			PC.IsActivo = 1
		FROM  FI_PedimentoComprobante PC
        WHERE PC.IdEliminado = @IdEliminacion

		/*GUARDAR DETALLE DE LA RESTAURACIÓN*/
		UPDATE AD_RegistroEliminacion
		SET Activo = 0,
		FechaRecuperacion = GETDATE(),
		ComentarioRecuperacion = @Justificacion,
		RecuperadoPor = @IdUsuario,
		HistorialRecuperacion = @DetalleRestauracion
		WHERE IdEliminacion = @IdEliminacion


		INSERT INTO APP_BitacoraRestauracionProcesosDetalle(
		ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		ID_ELIMINADO,
	    CREADO_EL,
	    CREADO_POR
		)
		SELECT ID,
		ID_PADRE,
		PROCESO,
		ESTATUS,
		IDESTATUS,
		CLASS,
		CLAVE_PROCESO,
		ACCION_EJECUTAR,
		ID_PROCESO,
		ID_PROCESO_PUBLICO,
		@IdEliminacion,
		GETDATE(),
		@IdUsuario
		FROM #PROCESO_HISTORIAL

		SELECT 'PROCESO_RESTAURADO' AS RESPONSE,
		'' AS DETALLE

		RETURN 
		
	END 

	SELECT 'PROCESO_NO_PUEDE_RESTAURARSE' AS RESPONSE,
			'No se encontró el tipo de proceso a recuperar' AS DETALLE
	RETURN 

END 

