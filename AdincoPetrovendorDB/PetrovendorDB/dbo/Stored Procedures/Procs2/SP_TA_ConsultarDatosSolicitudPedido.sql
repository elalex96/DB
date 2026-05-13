-- =============================================
-- Author:		Daniel AC
-- Create date: 15-09-17
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarDatosSolicitudPedido]
	-- Add the parameters for the stored procedure here
	---execute  SP_TA_ConsultarEncabezadoPrePedidoGral 420, 1154
	@IdProveedor int, 
	@IdPedido INT
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdSolicitudPedido INT 
	DECLARE @IdFactura INT 
	DECLARE @IVA DECIMAL(18,2)
	DECLARE @MONTO_FINAL DECIMAL(18,2)
    -- Insert statements for procedure here
	
	----- IdTipoOperacion = 9--> Aprobación de pedido

	DECLARE @PROVEDORACTUAL VARCHAR(MAX) = (SELECT CONCAT(RazonSocial, RegimenCapital) FROM S_Proveedor WHERE IdProveedor = @IdProveedor)
	DECLARE @PROVEDORACTUALDOMICILIO VARCHAR(MAX) = (SELECT CONCAT('Col.',DF.Colonia,' ','Calle.',DF.NombreViabilidad,' ','N°Interior.', DF.NoExterior,' ','N°Exterior.', DF.NoInterior,' ','CP.',DF.CodigoPostal)
											FROM S_Proveedor AS PV
											INNER JOIN DG_Domicilio AS DF ON DF.IdProveedor = PV.IdProveedor AND DF.IdTipoDomicilio = 1 
											--AND DF.Activo = 1
											WHERE PV.IdProveedor = @IdProveedor)

    /*----------------- CONSULTAR CONDICIONES DE PAGO ----------------*/
	DECLARE @PROVEEDOR_VENTAS INT = (SELECT IdSubContratista FROM MM_Pedido P WHERE IdProveedorCompras = @IdProveedor AND IdPedido = @IdPedido)	                                        
    DECLARE @CONDICIONES_PAGO NVARCHAR(30)
    DECLARE @EXISTEN_CONDICIONES_PAGO INT = (SELECT COUNT(CP.IdCondicionPago) FROM PV_CondicionesPago CP
										    INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista = CSC.IdRelacion
										    INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista 
										    WHERE CSC.IdContratista = @PROVEEDOR_VENTAS AND CSC.IdSubContratista = @IdProveedor)
	IF (@EXISTEN_CONDICIONES_PAGO > 0)
	BEGIN
	DECLARE @TIENE_CREDITO BIT = (SELECT CP.Credito FROM PV_CondicionesPago CP 
	                              INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista = CSC.IdRelacion
							      INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista 
							      WHERE CSC.IdContratista = @PROVEEDOR_VENTAS AND CSC.IdSubContratista = @IdProveedor)
		IF(@TIENE_CREDITO = 1)
		BEGIN
	      SET @CONDICIONES_PAGO = (SELECT CP.DiasCredito FROM PV_CondicionesPago CP 
	                              INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista = CSC.IdRelacion
							      INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista 
							      WHERE CSC.IdContratista = @PROVEEDOR_VENTAS AND CSC.IdSubContratista = @IdProveedor)

		 SELECT @CONDICIONES_PAGO = @CONDICIONES_PAGO + ' días de crédito'

		END
		ELSE
		BEGIN
		SELECT @CONDICIONES_PAGO = 'Contado'
		END
	END
	ELSE
	BEGIN
	SELECT @CONDICIONES_PAGO = 'Contado'
	END
	/*----------------- FIN CONDICIONES DE PAGO ----------------*/
	
	/*
	PEDIDO GENERADO POR COMPRA DIRECTA 
	
	
	*/
    SET @IdSolicitudPedido =(SELECT IdSolicitudPedido FROM dbo.MM_Pedido WHERE IdPedido= @IdPedido)

	SET @IdFactura = (SELECT IdFactura FROM dbo.CO_RegistroPedido WHERE IdSolicitudPedido=@IdSolicitudPedido)
	IF @IdFactura IS NOT NULL 
	BEGIN 
		SET @MONTO_FINAL =(SELECT MontoConIva FROM dbo.FI_Factura  WHERE IdFactura= @IdFactura)
		SET @IVA =(SELECT (ISNULL(MontoConIva,0) - ISNULL(SubTotal,0)) FROM dbo.FI_Factura  WHERE IdFactura= @IdFactura)
		 
	END 

	SELECT 	
	PG.IdPedido,
	P.IdSolicitudPedido,
	SUM(PD.Subtotal) AS SubtotalPedido,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	IdEstatusOperacion, 
	O.Descripcion, 
	PV.RFC,
	PV.Telefono,
	U.Correo,
	ISNULL(PV.RazonSocial,'') +' ' + ISNULL(PV.RegimenCapital,'') AS Cliente,
	PV.Municipio +' '+PV.Entidad AS LugarCliente,
	CONCAT('Col.',DF.Colonia,' ','Calle.',DF.NombreViabilidad,' ','N°Interior.', DF.NoExterior,' ','N°Exterior.', DF.NoInterior,' ','CP.',DF.CodigoPostal) AS Domicilio,
	IP.Imagen AS Logo,
	E.Nombre, 
	U.Nombre AS Elaboro,
	O.FechaRegistro,
	H.FechaVigencia,
	P.Version,
	@PROVEDORACTUAL AS ProveedorActual,
	@PROVEDORACTUALDOMICILIO as DomicilioProveedorActual,
	CASE P.RecepcionServicio WHEN 1 THEN 'CONFIRMADA_ACEPTADA' WHEN 0 THEN 'CONFIRMACION_RECHAZADA' ELSE 'EN_RECEPCION' END AS ESTATUS,
	PSP.Prioridad,
	TSP.TipoSolicitudPedido,
	CAST(P.IdSolicitudPedido AS NVARCHAR(100)) + ' ' + 'Versión' + ' ' + CAST(P.Version AS NVARCHAR(100)) AS concatVersion,
	TM.TipoMonedaCorto AS Moneda,	
	CASE WHEN @IdFactura IS NOT NULL THEN @IVA ELSE  ISNULL(PD.PorcentajeIVA,0) END AS PorcentajeIVA,
	CASE WHEN @IdFactura <> 0 THEN ISNULL(@MONTO_FINAL,0) ELSE SUM(PD.Subtotal) END AS Total,
  	@CONDICIONES_PAGO AS CondicionesDePago
	FROM MM_Pedido AS P
	INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
	INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
	LEFT JOIN S_ImagenPerfil AS IP ON IP.IdProveedor = P.IdSubcontratista
	LEFT JOIN DG_Domicilio AS DF ON DF.IdProveedor = P.IdSubcontratista AND DF.IdTipoDomicilio = 1
	INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
	INNER JOIN S_Usuario AS U  ON U.IdUsuario = O.IdAsignador
	INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
	INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
	INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
	INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
	INNER JOIN dbo.MM_HorasVigenciaPedido AS H ON H.IdPedido = P.IdPedido
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
	INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= PD.IdMoneda
	INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdTipoPedido = 2 AND PG.IdProveedorCliente = @IdProveedor
	WHERE O.IdTipoOperacion = 9 AND O.IdProveedor = @IdProveedor   AND P.IdPedido = @IdPedido
	GROUP BY 
	PG.IdPedido, 
	P.IdSolicitudPedido,
	O.IdFlujoTarea, 
	O.IdOperacion, 
	O.IdEstatusOperacion, 
	O.Descripcion, 
	PV.RazonSocial,	
	PV.RegimenCapital,
	Pv.Municipio,
	PV.Entidad, 
	E.Nombre,
	O.FechaRegistro,
	U.Nombre,
	H.FechaVigencia,
	P.Version,
	P.RecepcionServicio,
	DF.Colonia,
	DF.NombreViabilidad,
	DF.NoExterior,
	DF.NoInterior,
	DF.CodigoPostal,
	IP.Imagen,
	PV.RFC,
	PV.Telefono,
	U.Correo,
	PSP.Prioridad,
	TSP.TipoSolicitudPedido,
	TM.TipoMonedaCorto,
	PD.PorcentajeIVA
  ---AND O.IdEstatusOperacion = 2
END

