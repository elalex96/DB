-- =============================================
-- Author:		Pedro Acuña
-- Create date: 06/04/2018
-- Description:	se adecua ya que ahora se puede añadir mas tiempo de vigencia al pedido, se descartan las cantidades que ya fueron reactivadas
-- =============================================
-- ============================================= 
-- Author:		Daniel AC
-- Create date: 18/12/2017
-- Description:	Se agrega variable para tomar en cuenta los pedidos que estan aprobados pero con estatus de aprobación sin documento adecuación DEA
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Agregue validación que si es un Proveedor de CARSO no agregar Marca, Modelo, No Parte a Descripción material  cotizado
-- =============================================
create PROCEDURE [dbo].[SP_MM_ConsultarEstatusCantidadesMaterialSPD_MV1_5] 
	@IdSolicitudPedidoDetalle INT,
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdTipoOperacion INT = 9 --IdTipoOperacion = 9 Aprobación de pedido 
	DECLARE @CM_SOLICITADOS FLOAT
	DECLARE @CM_PEDIDO_TEMP FLOAT
	DECLARE @CM_PEDIDO_EN_APROBACION FLOAT
	DECLARE @CM_PEDIDO_EN_APROBACION_RECHAZADO FLOAT
	DECLARE @CM_PEDIDO_APROBADO_EN_RECEPCION FLOAT
	DECLARE @CM_PEDIDO_APROBADO_SIN_DOCUMENTO_EN_RECEPCION FLOAT
	DECLARE @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA FLOAT
	DECLARE @CM_PEDIDO_APROBADO_EN_RECEPCION_RECHAZADA FLOAT
	DECLARE @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA_ITEM_RECHAZADO FLOAT
	DECLARE @CM_FALTANTANTES FLOAT
	DECLARE @NOMBRE_MATERIAL NVARCHAR(MAX)
	DECLARE @CM_RECIBIDOS_EN_PEDIDO_CERRADO FLOAT

	--VALIDACIÓN CARSO ---	
	DECLARE @EsProveedorDeCARSO INT 
	--CREATE TABLE #ProveedoresCARSO(IdProveedor INT)
	DECLARE @ProveedoresCARSO TABLE(IdProveedor INT)
	INSERT INTO @ProveedoresCARSO (IdProveedor)
	VALUES
	(650 )
	--INSERT INTO #ProveedoresCARSO(IdProveedor)VALUES(650) ---VALOR A EDITAR SEGÚN EL PROVEEDOR CARSO ##EDITAR##
		
	SELECT @EsProveedorDeCARSO= COUNT(IdProveedor)
	FROM @ProveedoresCARSO 
	WHERE IdProveedor IN (
			SELECT  SP.IdProveedor
			FROM dbo.MM_SolicitudPedido SP 
			INNER JOIN dbo.MM_SolicitudPedidoDetalle SPD ON SP.IdSolicitudPedido=SPD.IdSolicitudPedido 
			WHERE SPD.IdSolicitudPedidoDetalle=@IdSolicitudPedidoDetalle)
	--FIN VALIDACIÓN CARSO --
	
	IF @EsProveedorDeCARSO >0 
	BEGIN
		SET @NOMBRE_MATERIAL = (SELECT M.DescripcionCorta--M.DescripcionCorta
							FROM dbo.MM_Material AS M 
							INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdMaterial = M.IdMaterial
							WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle)
	END 
	ELSE 
	BEGIN 
		SET @NOMBRE_MATERIAL = (SELECT
							    M.DescripcionCorta
								--CONCAT (M.DescripcionCorta,
								--' Marca: ', CASE WHEN ISNULL(LEN(M.Marca),0)>0 THEN M.Marca ELSE ' S/M' END,
								--' Modelo: ', CASE WHEN ISNULL(LEN(M.Modelo),0)>0 THEN M.Modelo ELSE ' S/M' END,
								--' No. Parte: ',CASE WHEN ISNULL(LEN(M.NumeroParte),0)>0 THEN M.NumeroParte  ELSE ' S/NP' END )--M.DescripcionCorta
								FROM dbo.MM_Material AS M 
								INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdMaterial = M.IdMaterial
								WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle) 

	END 
	

	--#Materiales Solicitados desde la Solicitud de pedido
	SET @CM_SOLICITADOS = (SELECT SPD.Cantidad
	FROM dbo.MM_SolicitudPedidoDetalle AS SPD
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= SPD.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle)

	--#Materiales que estan agregados al pedido temporal
	SET @CM_PEDIDO_TEMP =(SELECT ROUND(ISNULL(SUM(POD.AddCantidadTemp),0),2)
	FROM dbo.MM_PeticionOfertaDetalle AS POD 
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = POD.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.AddPedidoTemp = 1 
	AND POD.AddValidado=1 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle	
	AND SPD.IdMaterial= POD.IdMaterial)


	--#Materiales en aprobación de pedido pendientes
	SET @CM_PEDIDO_EN_APROBACION =(SELECT ROUND(ISNULL(SUM(PD.Cantidad),0),2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND P.Version= O.NoVersion
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND O.IdEstatusOperacion= 1)


	--#Materiales en aprobación de pedido rechazados
	SET @CM_PEDIDO_EN_APROBACION_RECHAZADO =(SELECT ROUND(ISNULL(SUM(PD.Cantidad),0),2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND P.VersioN= O.NoVersion
	AND O.IdEstatusOperacion= 3)
	

	--#Materiales en aprobación de pedido aceptado y en espera de confirmación de pedido 
	SET @CM_PEDIDO_APROBADO_EN_RECEPCION =(SELECT ROUND(ISNULL(SUM(PD.Cantidad),0),2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	INNER JOIN [dbo].[MM_HorasVigenciaPedido] AS PHV ON PHV.IdPedido=P.IdPedido
	LEFT JOIN dbo.MM_HorasVigenciaPedidoHistorial AS HVPH ON HVPH.IdPedido = P.IdPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND P.VersioN= O.NoVersion
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND O.IdEstatusOperacion= 2 
	AND PHV.FechaVigencia > GETDATE() 
	AND P.RecepcionServicio IS NULL
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND HVPH.IdHorasVigencia IS NULL
	AND ISNULL(P.Cerrado, 0) <> 1) --> PEDIDO NO CERRADO

	---ADECUACIÓN DEA SOLO LOS APROBADOS SIN DOCUMENTOS = A APROBADO SIN CONFIRMACIÓN

	SET @CM_PEDIDO_APROBADO_SIN_DOCUMENTO_EN_RECEPCION = (SELECT ROUND(ISNULL(SUM(PD.Cantidad),0),2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	INNER JOIN [dbo].[MM_HorasVigenciaPedido] AS PHV ON PHV.IdPedido=P.IdPedido
	LEFT JOIN dbo.MM_HorasVigenciaPedidoHistorial AS HVPH ON HVPH.IdPedido = P.IdPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND P.VersioN= O.NoVersion
	AND O.IdTipoOperacion = @IdTipoOperacion 
	AND O.IdEstatusOperacion= 11 ---> APROBADO SIN DOCUMENTO
	--AND PHV.FechaVigencia > GETDATE() 
	AND P.RecepcionServicio IS NULL
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	--AND HVPH.IdHorasVigencia IS NULL
	AND ISNULL(P.Cerrado, 0) <> 1) --> PEDIDO NO CERRADO

	SET @CM_PEDIDO_APROBADO_SIN_DOCUMENTO_EN_RECEPCION = ISNULL(@CM_PEDIDO_APROBADO_SIN_DOCUMENTO_EN_RECEPCION,0)


	--#Materiales en aprobación de pedido aceptado y en confirmación de pedido aceptada
	SET @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA=(SELECT ROUND(ISNULL(SUM(PD.Cantidad),0),2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND O.IdTipoOperacion = @IdTipoOperacion
	AND P.Version= O.NoVersion
	AND O.IdEstatusOperacion= 2
	AND P.RecepcionServicio= 1
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND PD.RecepcionPedido = 1
	AND ISNULL(P.Cerrado, 0) <> 1) --> PEDIDO NO CERRADO

	--#Materiales en aprobación de pedido aceptado y en confirmación de pedido aceptada pero material con confirmación de pedido rechazado
	SET @CM_PEDIDO_APROBADO_EN_RECEPCION_RECHAZADA =(SELECT ROUND(ISNULL(SUM(PD.Cantidad),0), 2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND O.IdTipoOperacion =@IdTipoOperacion 
	AND P.VersioN= O.NoVersion
	AND O.IdEstatusOperacion= 2
	AND (P.RecepcionServicio= 1
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND PD.RecepcionPedido = 0))  --[SP_MM_ConsultarEstatusCantidadesMaterialSPD] 2776

	SET @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA_ITEM_RECHAZADO= (SELECT ROUND(ISNULL(SUM(PD.Cantidad),0),2)
	FROM dbo.MM_PedidoDetalle AS PD 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND O.IdTipoOperacion =@IdTipoOperacion 
	AND P.VersioN= O.NoVersion
	AND O.IdEstatusOperacion= 2
	AND (P.RecepcionServicio= 0
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND PD.RecepcionPedido = 0))

	--CANTIDAD DE MATERIALES RECIBIDOS EN LA ACEPTACION DE SERVICIO EN EL CASO QUE EL PEDIDO SE ENCUENTRE CERRADO
	SET --@CM_RECIBIDOS_EN_PEDIDO_CERRADO = (SELECT ROUND(ISNULL(SUM(apd.Cantidad), 0), 2) 
		@CM_RECIBIDOS_EN_PEDIDO_CERRADO = (SELECT ISNULL(SUM(apd.Cantidad), 0) 
	FROM dbo.MM_AceptacionPedidoDetalle apd 
	JOIN	MM_AceptacionPedido	AP
		ON	apd.IdAceptacionPedido	=	AP.IdAceptacionPedido
		AND ISNULL(AP.IdEliminado,0)	=	0
	INNER JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = apd.IdPedidoDetalle 
	INNER JOIN dbo.MM_Pedido AS P ON P.IdPedido = PD.IdPedido
	INNER JOIN dbo.MM_PeticionOferta AS PO ON PO.IdPeticionOferta = P.IdPeticionOferta
	INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
	INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= PO.IdSolicitudPedido
	INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido	
	INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
	WHERE SPD.IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle 
	AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
	AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
	AND O.IdTipoOperacion = @IdTipoOperacion
	AND P.Version= O.NoVersion
	AND O.IdEstatusOperacion= 2
	AND P.RecepcionServicio= 1
	AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> NO ESTEN CON ESTATUS ELIMINADO
	AND ISNULL(P.Cerrado, 0) = 1) --> PEDIDO CERRADO
	
	--AGREGAR LOS APROBADOS SIN DOCUMENTOS A LA CANTIDAD DE APROBADOS 
	SET @CM_PEDIDO_APROBADO_EN_RECEPCION= (ISNULL(@CM_PEDIDO_APROBADO_EN_RECEPCION,0) 
										  +ISNULL(@CM_PEDIDO_APROBADO_SIN_DOCUMENTO_EN_RECEPCION,0))

	--select @CM_SOLICITADOS, @CM_PEDIDO_TEMP, @CM_PEDIDO_EN_APROBACION, @CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA, @CM_PEDIDO_APROBADO_EN_RECEPCION, @CM_RECIBIDOS_EN_PEDIDO_CERRADO

	SET @CM_FALTANTANTES = (@CM_SOLICITADOS  - 
	(@CM_PEDIDO_TEMP 
	+ @CM_PEDIDO_EN_APROBACION	
	+@CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA
	+@CM_PEDIDO_APROBADO_EN_RECEPCION
	+@CM_RECIBIDOS_EN_PEDIDO_CERRADO))

	 
	SELECT @CM_SOLICITADOS AS CantidadSolicitada,
	ROUND(@CM_PEDIDO_TEMP, 2) AS CantidadPorAgregarPedido,
	ROUND(@CM_PEDIDO_EN_APROBACION,2) AS CantidadEnPedidoAprobacion,
	ROUND(@CM_PEDIDO_EN_APROBACION_RECHAZADO,2) AS CantidadEnAprobacionRechazada, 
	ROUND(@CM_PEDIDO_APROBADO_EN_RECEPCION,2) AS CantidadEnConfirmacion, 
	ROUND(@CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA,2) AS CantidadEnConfirmacionAceptada,
	ROUND(@CM_PEDIDO_APROBADO_EN_RECEPCION_RECHAZADA,2) AS CantidadEnConfirmacionRechazada,
	ROUND(@CM_PEDIDO_APROBADO_EN_RECEPCION_CONFIRMADA_ITEM_RECHAZADO,2) AS CantidadEnConfirmacionitemRechazada,
	ROUND(@CM_FALTANTANTES,3) AS CantidadPorSolicitar,
	@NOMBRE_MATERIAL AS MaterialSolicitado,
	ROUND(@CM_RECIBIDOS_EN_PEDIDO_CERRADO, 2) AS CantidadRecibidaPedidoCerrado
	
END
