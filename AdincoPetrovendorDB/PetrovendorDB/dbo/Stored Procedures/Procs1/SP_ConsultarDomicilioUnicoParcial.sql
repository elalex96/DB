-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDomicilioUnicoParcial]
@IdProveedor INT,
@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	CREATE TABLE #TEMPDOMICILIO(
	IdRow INT,IdDomicilio INT
	)

	INSERT INTO #TEMPDOMICILIO SELECT
	                ROW_NUMBER() OVER(ORDER BY P.IdPedido  ASC) AS IdRow,
	                D.IdDomicilio as domicilio
					FROM MM_Pedido AS P
					INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
					INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
					INNER JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
					INNER JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
					INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
					INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
					INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
					INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
					INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
					INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
					INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
					INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
					INNER JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
					WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedor AND P.IdPedido = @IdPedido


	DECLARE @CONTADOR_DOMICILIO INT
	DECLARE @CONTADOR INT = 1
	SET @CONTADOR_DOMICILIO = (SELECT COUNT(D.IdDomicilio) AS DomicilioEntrega
					FROM MM_Pedido AS P
					INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
					INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
					INNER JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
					INNER JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
					INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
					INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
					INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
					INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
					INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
					INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
					INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
					INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
					INNER JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
					WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedor AND P.IdPedido = @IdPedido
					)
	 
	 --DECLARE @DOMICILIOS_REPETIDOS INT 
	 --DECLARE @ACUMULADOR INT = 0

	 DECLARE @DOMICILIO INT
	 SET @DOMICILIO = (SELECT IdDomicilio FROM #TEMPDOMICILIO WHERE IdRow = 1)

	 DECLARE @ID_DOMICILIO INT
	 SET @ID_DOMICILIO = (SELECT COUNT(IdDomicilio) AS cantidad FROM #TEMPDOMICILIO WHERE IdDomicilio = @DOMICILIO)

	 IF (@ID_DOMICILIO = @CONTADOR_DOMICILIO)
	 BEGIN
	                SELECT TOP 1 CONCAT(D.Calle,' ',D.NoInterior,' ',D.NoExterior,' ', D.Colonia ,' ',D.Municipio ,' ', D.Estado , ' CP ',D.CodigoPostal) AS DomicilioEntrega
					FROM MM_Pedido AS P
					INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
					INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
					INNER JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
					INNER JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
					INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
					INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
					INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
					INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
					INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
					INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
					INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
					INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
					INNER JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
					WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedor AND P.IdPedido = @IdPedido
	 END
	 ELSE
	 BEGIN
	 	            SELECT  CONCAT(D.Calle,' ',D.NoInterior,' ',D.NoExterior,' ', D.Colonia ,' ',D.Municipio ,' ', D.Estado , ' CP ',D.CodigoPostal) AS DomicilioEntrega
					FROM MM_Pedido AS P
					INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
					INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
					INNER JOIN MM_PeticionOfertaDetalle AS POD ON POd.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
					INNER JOIN MM_SolicitudPedidoDetalle AS SPD on SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
					INNER JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
					INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
					INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
					INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
					INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
					INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
					INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
					INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
					INNER JOIN DG_Domicilio AS D ON D.IdDomicilio = SPD.IdDomicilioEntrega
					WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedor AND P.IdPedido = @IdPedido
	 END


	 

END

