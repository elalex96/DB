-- =============================================
-- Author:		Pedro Acuña
-- Create date: 05/04/2018
-- Description:	Obtener la cantidad actualizada por material disponibles
-- =============================================
-- Author:		Jose Roman
-- UPDATE date: 19-07-2018
-- Description:	cambio por modificacion al sp "SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5", se agrega una cantidad nueva
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 07/02/2019
-- Description:	se modifica el store ya que esta tardando mucho y causa timeout el sql al cargar las cantidades
-- =============================================
CREATE PROCEDURE SP_ObtenerCantidadesDePedidoActualizada
	( @IdSolicitudPedido INT ,
	  @IdPedido INT 
)
AS
	BEGIN
		DECLARE @IdTipoOperacion INT = 9 --IdTipoOperacion = 9 Aprobación de pedido 
		DECLARE @tablaMaterialesExistentes TABLE
			( CantidadSolicitada FLOAT ,
			  CantidadPorAgregarPedido FLOAT ,
			  CantidadEnPedidoAprobacion FLOAT ,
			  CantidadEnAprobacionRechazada FLOAT ,
			  CatnidadEnConfirmacion FLOAT ,
			  CantidadEnConfirmacionAceptada FLOAT ,
			  CantidadEnConfirmacionRechazada FLOAT ,
			  CantidadEnConfirmacionItemRechazada FLOAT ,
			  CantidadPorSolicitar FLOAT ,
			  MaterialSolicitado NVARCHAR(MAX),
			  CantidadRecibidaPedidoCerrado FLOAT,
			  IdSolicitudPedidoDetalle INT
		)

		DECLARE @tablaRetornoUnidades TABLE
			( Fila INT IDENTITY,
			  IdPedidoDetalle INT ,
			  IdMaterialVendedor INT ,
			  DescripcionCorta NVARCHAR(MAX) ,
			  DescripcionLarga NVARCHAR(MAX) ,
			  Cantidad FLOAT ,
			  CantidadAux FLOAT , --sirve para jugar con el dato cuando el usuario modifico la cantidad, si fue modificado toma la cantidadaux
			  UnidadProveedor NVARCHAR(350) ,
			  PrecioUnitario FLOAT ,
			  Subtotal FLOAT ,
			  TipoMonedaCorto NVARCHAR(MAX) ,
			  DomicilioEntrega NVARCHAR(MAX) ,
			  DisponiblesActualizado FLOAT ,
			  Modificado BIT,	  -- se refiere a que su cantidad fue modificada
			  IdSolicitudPedidoDetalle INT
		)

		INSERT INTO @tablaRetornoUnidades
			( IdPedidoDetalle, IdMaterialVendedor, DescripcionCorta, DescripcionLarga, Cantidad ,
			  UnidadProveedor , PrecioUnitario, Subtotal, TipoMonedaCorto, DomicilioEntrega, Modificado, IdSolicitudPedidoDetalle
		)
		SELECT	PD.IdPedidoDetalle, PD.IdMaterialVendedor, POD.MaterialCotizadoTextoC, POD.MaterialCotizadoTextoL, PD.Cantidad ,
				POD.UnidadProveedor AS UnidadCotizada, PD.PrecioUnitario, PD.Subtotal, TM.TipoMonedaCorto AS Moneda ,
				CONCAT (
					D.Calle, ' ', D.NoInterior, ' ', D.NoExterior, ' ', D.Colonia, ' ', D.Municipio, ' ', D.Estado, ' CP ' ,
					D.CodigoPostal ) AS DomicilioEntrega, CASE WHEN PD.ModificadoPor IS NOT NULL THEN 1 ELSE 0 END,
					SPD.IdSolicitudPedidoDetalle
		  FROM	MM_Pedido AS P
				INNER JOIN MM_PedidoDetalle AS PD
						   ON PD.IdPedido = P.IdPedido
				INNER JOIN MM_PeticionOferta AS PO
						   ON PO.IdPeticionOferta = P.IdPeticionOferta
				INNER JOIN MM_PeticionOfertaDetalle AS POD
						   ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
				INNER JOIN MM_SolicitudPedidoDetalle AS SPD
						   ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
				INNER JOIN S_Proveedor AS PV
						   ON PV.IdProveedor = P.IdSubcontratista
				INNER JOIN TA_Operacion AS O
						   ON O.IdDocumento = P.IdSolicitudPedido
				INNER JOIN TA_Prioridad AS PR
						   ON PR.IdPrioridad = O.IdPrioridad
				INNER JOIN TA_Vencimiento AS V
						   ON V.IdVencimiento = O.IdVigencia
				INNER JOIN TA_TipoOperacion AS TTO
						   ON TTO.IdTipoOperacion = O.IdTipoOperacion
				INNER JOIN TA_Estatus AS E
						   ON E.IdEstatus = O.IdEstatusOperacion
				INNER JOIN PV_TipoMoneda AS TM
						   ON TM.IdMoneda = PD.IdMoneda
				INNER JOIN DG_Domicilio AS D
						   ON D.IdDomicilio = SPD.IdDomicilioEntrega
				INNER JOIN dbo.MM_HorasVigenciaPedido AS HV
						   ON HV.IdPedido = P.IdPedido
		 WHERE
				O.IdTipoOperacion = @IdTipoOperacion
				AND P.IdSolicitudPedido = @IdSolicitudPedido
				AND P.IdPedido = @IdPedido
		 GROUP BY PD.IdPedidoDetalle, PD.IdMaterialVendedor, POD.MaterialCotizadoTextoC, POD.UnidadProveedor ,
				  PD.PrecioUnitario, PD.Cantidad, TM.TipoMonedaCorto, PD.Subtotal, PD.RecepcionPedido, PD.Subtotal ,
				  PD.PorcentajeContenidoNacional, D.Calle, D.NoInterior, D.NoExterior, D.Colonia, D.Municipio, D.Estado ,
				  D.CodigoPostal, HV.FechaVigencia, P.IdPedido, P.RecepcionServicio, pod.MaterialCotizadoTextoL,PD.ModificadoPor,
				  SPD.IdSolicitudPedidoDetalle
		

		
-- ***************************************************		-- INICIO CALCULO DE CANTIDADES -- ***********************************************************************

	
	
	DECLARE @tablaCantidades TABLE(IdSolicitudPedidoDetalle INT, MaterialSolicitado NVARCHAR(MAX), CantidadSolicitada FLOAT, AddCantidadTemporal FLOAT )
	
	INSERT INTO @tablaCantidades
		( IdSolicitudPedidoDetalle, MaterialSolicitado, CantidadSolicitada, AddCantidadTemporal )
	SELECT  POD.IdSolicitudPedidoDetalle, m.DescripcionCorta AS NOMBRE_MATERIAL, 
			SPD.Cantidad, ROUND(ISNULL(SUM(POD.AddCantidadTemp),0),2) AS CM_PEDIDO_TEMP
	  FROM	dbo.MM_SolicitudPedido SP
			INNER JOIN dbo.MM_SolicitudPedidoDetalle SPD
					   ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
			INNER JOIN dbo.MM_Material m
					   ON m.IdMaterial = SPD.IdMaterial
			INNER JOIN dbo.MM_PeticionOfertaDetalle POD ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle 
			AND POD.AddValidado=1 
	 WHERE	SP.IdSolicitudPedido = @IdSolicitudPedido
	 GROUP BY POD.IdSolicitudPedidoDetalle, m.DescripcionCorta, SPD.Cantidad


	 DECLARE @tablaAprobacionPedidoPendientes TABLE (IdSolicitudPedidoDetalle INT, CantidadPedidoEnAprobacion FLOAT)
	 
	 --#Materiales en aprobación de pedido pendientes
	INSERT INTO @tablaAprobacionPedidoPendientes
		( IdSolicitudPedidoDetalle, CantidadPedidoEnAprobacion )
	SELECT  SPD.IdSolicitudPedidoDetalle, ROUND(ISNULL(SUM(PD.Cantidad),0),2) AS CM_PEDIDO_EN_APROBACION
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.Version= O.NoVersion
	INNER JOIN @tablaCantidades tablaCantidades ON SPD.IdSolicitudPedidoDetalle = tablaCantidades.IdSolicitudPedidoDetalle
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido	
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND O.IdEstatusOperacion= 1
	GROUP BY SPD.IdSolicitudPedidoDetalle


	DECLARE @tablaAprobacionPedidoRechazado TABLE (IdSolicitudPedidoDetalle INT, CantidadPedidoEnAprobacionRechazado FLOAT)
	--#Materiales en aprobación de pedido rechazados
	INSERT INTO @tablaAprobacionPedidoRechazado
		( IdSolicitudPedidoDetalle, CantidadPedidoEnAprobacionRechazado )
	SELECT SPD.IdSolicitudPedidoDetalle, ROUND(ISNULL(SUM(PD.Cantidad),0),2) AS CM_PEDIDO_EN_APROBACION_RECHAZADO
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
		AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.VersioN= O.NoVersion
	WHERE SP.IdSolicitudPedido =  @IdSolicitudPedido
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND O.IdEstatusOperacion= 3
	GROUP BY SPD.IdSolicitudPedidoDetalle
	

	DECLARE @tablaAprobacionPedidoAceptadoyEsperaConfirmacion TABLE (IdSolicitudPedidoDetalle INT, CantidadPedidoAprobadoEnRecepcion FLOAT)
	--#Materiales en aprobación de pedido aceptado y en espera de confirmación de pedido 
	INSERT INTO @tablaAprobacionPedidoAceptadoyEsperaConfirmacion
		( IdSolicitudPedidoDetalle, CantidadPedidoAprobadoEnRecepcion )
	SELECT SPD.IdSolicitudPedidoDetalle, ROUND(ISNULL(SUM(PD.Cantidad),0),2) AS CM_PEDIDO_APROBADO_EN_RECEPCION
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.VersioN= O.NoVersion
	INNER JOIN [dbo].[MM_HorasVigenciaPedido] AS PHV ON PHV.IdPedido=P.IdPedido
	LEFT JOIN dbo.MM_HorasVigenciaPedidoHistorial AS HVPH ON HVPH.IdPedido = P.IdPedido
	WHERE SP.IdSolicitudPedido =  @IdSolicitudPedido
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND O.IdEstatusOperacion= 2 
	AND PHV.FechaVigencia > GETDATE() 
	AND P.RecepcionServicio IS NULL
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND HVPH.IdHorasVigencia IS NULL
	AND ISNULL(P.Cerrado, 0) <> 1 --> PEDIDO NO CERRADO
	GROUP BY SPD.IdSolicitudPedidoDetalle

	DECLARE @tablaAprobacionPedidoAceptadoyEnConfirmacionDePedidoAceptada TABLE (IdSolicitudPedidoDetalle INT, CantidadPedidoAprobadoEnRecepcionConfirmada FLOAT)
	--#Materiales en aprobación de pedido aceptado y en confirmación de pedido aceptada
	INSERT INTO @tablaAprobacionPedidoAceptadoyEnConfirmacionDePedidoAceptada
		( IdSolicitudPedidoDetalle, CantidadPedidoAprobadoEnRecepcionConfirmada )
	SELECT SPD.IdSolicitudPedidoDetalle, ROUND(ISNULL(SUM(PD.Cantidad),0),2) AS CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.Version= O.NoVersion
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
	AND O.IdTipoOperacion = @IdTipoOperacion
	AND O.IdEstatusOperacion= 2
	AND P.RecepcionServicio= 1
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND PD.RecepcionPedido = 1
	AND ISNULL(P.Cerrado, 0) <> 1 --> PEDIDO NO CERRADO
	GROUP BY SPD .IdSolicitudPedidoDetalle

	DECLARE @tablaAprobacionPedidoAceptadoyEnConfirmacionDePedidoAceptadaMaterialRechazado TABLE (IdSolicitudPedidoDetalle INT, CantidadPedidoAprobadoEnRecepcionRechazada FLOAT)
	--#Materiales en aprobación de pedido aceptado y en confirmación de pedido aceptada pero material con confirmación de pedido rechazado
	INSERT INTO @tablaAprobacionPedidoAceptadoyEnConfirmacionDePedidoAceptadaMaterialRechazado
		( IdSolicitudPedidoDetalle, CantidadPedidoAprobadoEnRecepcionRechazada )
	SELECT SPD.IdSolicitudPedidoDetalle,  ROUND(ISNULL(SUM(PD.Cantidad),0), 2) AS CM_PEDIDO_APROBADO_EN_RECEPCION_RECHAZADA
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.VersioN= O.NoVersion
	WHERE SP.IdSolicitudPedido =  @IdSolicitudPedido
	AND O.IdTipoOperacion = @IdTipoOperacion 	
	AND O.IdEstatusOperacion= 2
	AND (P.RecepcionServicio= 1
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND PD.RecepcionPedido = 0)  
	GROUP BY SPD .IdSolicitudPedidoDetalle

	DECLARE @tablaAprobacionPedidoAprobadoEnRecepcionConfirmadaItemRechazado TABLE (IdSolicitudPedidoDetalle INT, CantidadPedidoAprobadoEnRecepcionConfirmadaItemRechazado FLOAT)
	INSERT INTO @tablaAprobacionPedidoAprobadoEnRecepcionConfirmadaItemRechazado
		( IdSolicitudPedidoDetalle, CantidadPedidoAprobadoEnRecepcionConfirmadaItemRechazado )
	SELECT SPD.IdSolicitudPedidoDetalle, ROUND(ISNULL(SUM(PD.Cantidad),0),2) AS CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA_ITEM_RECHAZADO
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
		AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.VersioN= O.NoVersion
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido 	
	AND O.IdTipoOperacion = @IdTipoOperacion
	AND O.IdEstatusOperacion= 2
	AND (P.RecepcionServicio= 0
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND PD.RecepcionPedido = 0)
	GROUP BY SPD .IdSolicitudPedidoDetalle

	DECLARE @tablaMaterialesRecibidosEnPedidoCerrado TABLE (IdSolicitudPedidoDetalle INT, CantidadRecibidosEnPedidoCerrado FLOAT)
	--CANTIDAD DE MATERIALES RECIBIDOS EN LA ACEPTACION DE SERVICIO EN EL CASO QUE EL PEDIDO SE ENCUENTRE CERRADO
	INSERT INTO @tablaMaterialesRecibidosEnPedidoCerrado
		( IdSolicitudPedidoDetalle, CantidadRecibidosEnPedidoCerrado )
	SELECT SPD.IdSolicitudPedidoDetalle, ROUND(ISNULL(SUM(apd.Cantidad), 0), 2) AS CM_RECIBIDOS_EN_PEDIDO_CERRADO
	FROM dbo.MM_AceptacionPedidoDetalle apd 
	INNER JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = apd.IdPedidoDetalle 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	AND P.Version= O.NoVersion
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido 
	AND O.IdTipoOperacion = @IdTipoOperacion
	AND O.IdEstatusOperacion= 2
	AND P.RecepcionServicio= 1
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND ISNULL(P.Cerrado, 0) = 1 --> PEDIDO CERRADO
	GROUP BY SPD .IdSolicitudPedidoDetalle

	INSERT INTO @tablaMaterialesExistentes
		( CantidadSolicitada, CantidadPorAgregarPedido, CantidadEnPedidoAprobacion, CantidadEnAprobacionRechazada ,
		  CatnidadEnConfirmacion , CantidadEnConfirmacionAceptada, CantidadEnConfirmacionRechazada ,
		  CantidadEnConfirmacionItemRechazada , MaterialSolicitado, CantidadRecibidaPedidoCerrado, CantidadPorSolicitar, IdSolicitudPedidoDetalle )
	SELECT	ISNULL ( t1.CantidadSolicitada, 0 ) AS CantidadSolicitada,
			ISNULL ( t1.AddCantidadTemporal, 0 ) AS CantidadPorAgregarPedido,
			ISNULL ( t2.CantidadPedidoEnAprobacion, 0 ) AS CantidadEnPedidoAprobacion,
			ISNULL(t3.CantidadPedidoEnAprobacionRechazado, 0) AS CantidadEnAprobacionRechazada, 
			ISNULL(t4.CantidadPedidoAprobadoEnRecepcion,0 ) AS CantidadEnConfirmacion, 
			ISNULL(t5.CantidadPedidoAprobadoEnRecepcionConfirmada, 0)AS CantidadEnConfirmacionAceptada,
			ISNULL(t6.CantidadPedidoAprobadoEnRecepcionRechazada,0) AS CantidadEnConfirmacionRechazada,
			ISNULL(t7.CantidadPedidoAprobadoEnRecepcionConfirmadaItemRechazado, 0) AS CantidadEnConfirmacionitemRechazada,
			t1.MaterialSolicitado, ISNULL ( t8.CantidadRecibidosEnPedidoCerrado, 0 ) AS CantidadRecibidaPedidoCerrado,
			( ISNULL ( t1.CantidadSolicitada, 0 )
					  - ( ISNULL ( t1.AddCantidadTemporal, 0 ) + ISNULL ( t2.CantidadPedidoEnAprobacion, 0 )
						  + ISNULL ( t5.CantidadPedidoAprobadoEnRecepcionConfirmada, 0 )
						  + ISNULL ( t4.CantidadPedidoAprobadoEnRecepcion, 0 ) + ISNULL ( t8.CantidadRecibidosEnPedidoCerrado, 0 ))) AS CantidadPorSolicitar,
						  t1.IdSolicitudPedidoDetalle
	  FROM	@tablaCantidades t1
			LEFT JOIN @tablaAprobacionPedidoPendientes t2
					  ON t1.IdSolicitudPedidoDetalle = t2.IdSolicitudPedidoDetalle
			LEFT JOIN @tablaAprobacionPedidoRechazado t3
					  ON t1.IdSolicitudPedidoDetalle = t3.IdSolicitudPedidoDetalle
			LEFT JOIN @tablaAprobacionPedidoAceptadoyEsperaConfirmacion t4
					  ON t1.IdSolicitudPedidoDetalle = t4.IdSolicitudPedidoDetalle
			LEFT JOIN @tablaAprobacionPedidoAceptadoyEnConfirmacionDePedidoAceptada t5
					  ON t1.IdSolicitudPedidoDetalle = t5.IdSolicitudPedidoDetalle
			LEFT JOIN @tablaAprobacionPedidoAceptadoyEnConfirmacionDePedidoAceptadaMaterialRechazado t6
					  ON t1.IdSolicitudPedidoDetalle = t6.IdSolicitudPedidoDetalle
			LEFT JOIN @tablaAprobacionPedidoAprobadoEnRecepcionConfirmadaItemRechazado t7
					  ON t1.IdSolicitudPedidoDetalle = t7.IdSolicitudPedidoDetalle
			LEFT JOIN @tablaMaterialesRecibidosEnPedidoCerrado t8
					  ON t1.IdSolicitudPedidoDetalle = t8.IdSolicitudPedidoDetalle

-- ***************************************************		--FIN CALCULO DE CANTIDADES -- ***********************************************************************
		--SELECT * FROM @tablaMaterialesExistentes
		----actualizo del historico la cantidad, si es que fue modificada y perdio el valor de la cantidad actual
		UPDATE tablaRetorno
		SET	   tablaRetorno.CantidadAux = pedDetalleHisto.Cantidad
		FROM   @tablaRetornoUnidades tablaRetorno
		LEFT JOIN dbo.MM_SolicitudPedidoDetalle solPedDetalle
			ON solPedDetalle.IdSolicitudPedidoDetalle = tablaRetorno.IdSolicitudPedidoDetalle
		INNER JOIN dbo.MM_PedidoDetalle pedidoDetalle
			ON pedidoDetalle.IdMaterial = solPedDetalle.IdMaterial
		LEFT JOIN dbo.MM_PedidoDetalleHistorico pedDetalleHisto
			ON pedidoDetalle.IdPedidoDetalle = pedDetalleHisto.IdPedidoDetalle
		WHERE
			   @IdPedido = pedidoDetalle.IdPedido
			   AND @IdSolicitudPedido = solPedDetalle.IdSolicitudPedido
			   AND pedDetalleHisto.Cantidad IS NOT NULL
			   AND pedDetalleHisto.ModificadoPor IS NULL --cuando es nulo se refiere que fue la primera vez que se agrego al historico


			SELECT	retorno.IdSolicitudPedidoDetalle, retorno.IdMaterialVendedor, retorno.DescripcionCorta ,
			CASE WHEN retorno.CantidadAux IS NOT NULL THEN
					 retorno.CantidadAux
				ELSE
					retorno.Cantidad
			END AS Cantidad, ISNULL(cantidadExistente.CantidadPorSolicitar, 0) AS DisponiblesActualizado ,
			( CASE WHEN Modificado != 1 THEN --cuando no fue modificado entonces debe de colocar el valor sugerido y cuando ya fue modificado la cantidad modificada
			( CASE WHEN retorno.Cantidad <= ISNULL(cantidadExistente.CantidadPorSolicitar, 0) THEN
					   retorno.Cantidad
				  WHEN retorno.Cantidad > ISNULL(cantidadExistente.CantidadPorSolicitar, 0) THEN
					  ISNULL(cantidadExistente.CantidadPorSolicitar, 0)
				  WHEN ISNULL(cantidadExistente.CantidadPorSolicitar, 0) = 0 THEN
					  0
			  END )
				  ELSE
					  Cantidad
			  END ) AS ASolicitar, retorno.UnidadProveedor, retorno.PrecioUnitario ,
			( CASE WHEN retorno.Modificado != 1 THEN --cuando no fue modificado entonces debe de colocar el valor sugerido y cuando ya fue modificado la cantidad modificada
			( CASE WHEN retorno.Cantidad <= ISNULL(cantidadExistente.CantidadPorSolicitar, 0) THEN
					   retorno.Cantidad
				  WHEN retorno.Cantidad > ISNULL(cantidadExistente.CantidadPorSolicitar, 0) THEN
					  ISNULL(cantidadExistente.CantidadPorSolicitar, 0)
				  WHEN ISNULL(cantidadExistente.CantidadPorSolicitar, 0) = 0 THEN
					  0
			  END )
				  ELSE
					  retorno.Cantidad
			  END ) * retorno.PrecioUnitario AS Subtotal, retorno.TipoMonedaCorto, retorno.DomicilioEntrega ,
			retorno.Modificado, retorno.CantidadAux
	  FROM	@tablaRetornoUnidades retorno
			LEFT JOIN @tablaMaterialesExistentes cantidadExistente
					  ON retorno.IdSolicitudPedidoDetalle = cantidadExistente.IdSolicitudPedidoDetalle
	 GROUP BY retorno.IdSolicitudPedidoDetalle, IdMaterialVendedor, DescripcionCorta, Cantidad, DisponiblesActualizado, Modificado ,
			  UnidadProveedor , PrecioUnitario, Subtotal, TipoMonedaCorto, DomicilioEntrega, CantidadAux, cantidadExistente.CantidadPorSolicitar
	 ORDER BY IdSolicitudPedidoDetalle
	END
