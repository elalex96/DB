-- =============================================
-- Author:		<Alexander G>
-- Create date: <07/12/2017>
-- Description:	<SP que consulta de generales de una orden de compra deacuerdo al pedido>
-- =============================================
-- Author:		Daniel Ac
-- Update date: <07/02/2018>
-- Description:	Agregue campos de tipo de pedido
-- =============================================
-- Author:		Alexander Gomez 
-- Update date: 12/03/2018
-- Description:	Se removio el campo de nombre de vialidad
-- =============================================
-- Author:		Alexander Gomez 
-- Update date: 21/03/2018
-- Description:	Se cambio el left join para obtener el tipo de orden de comrpa
-- =============================================
-- Author:		Daniel AC
-- Create date: <28-10-2019>
-- Description:	<Se toman los dias de credito desde la tabla MM_PedidoDetalle>
-- =============================================
CREATE  PROCEDURE SP_RPT_OCM_CabeceraGeneralesOrdenCompra 
	-- Add the parameters for the stored procedure here
	@IdPedido INT,
		/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT=NULL,
    @IdUsuario     INT=NULL,
    @FechaRegistro DATETIME=NULL
	/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DOMICILIOENTREGA NVARCHAR(MAX)
	DECLARE @OPERADOR INT = (SELECT IdProveedorCompras FROM MM_Pedido P WHERE IdPedido = @IdPedido)
	DECLARE @PROVEEDOR INT = (SELECT P.IdSubcontratista FROM MM_Pedido P WHERE IdPedido = @IdPedido)

	--DECLARE @CONDICIONES_PAGO NVARCHAR(30)
 --   DECLARE @EXISTEN_CONDICIONES_PAGO INT = (SELECT COUNT(CP.IdCondicionPago) FROM PV_CondicionesPago CP
	--									    INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista = CSC.IdRelacion
	--									    INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista 
	--									    WHERE CSC.IdContratista = @PROVEEDOR AND CSC.IdSubContratista = @OPERADOR AND CSC.IsActivo = 1)
	--IF (@EXISTEN_CONDICIONES_PAGO > 0)
	--BEGIN
	--DECLARE @TIENE_CREDITO BIT = (SELECT CP.Credito FROM PV_CondicionesPago CP 
	--                              INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista = CSC.IdRelacion
	--						      INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista 
	--						      WHERE CSC.IdContratista = @PROVEEDOR  AND CSC.IdSubContratista = @OPERADOR AND CSC.IsActivo = 1)
	--	IF(@TIENE_CREDITO = 1)
	--	BEGIN
	--      SET @CONDICIONES_PAGO = (SELECT CP.DiasCredito FROM PV_CondicionesPago CP 
	--                              INNER JOIN PV_ContratistaSubContratista CSC ON CP.IdContratistaSubContratista = CSC.IdRelacion
	--						      INNER JOIN S_Proveedor P ON P.IdProveedor = CSC.IdContratista 
	--						      WHERE CSC.IdContratista = @PROVEEDOR AND CSC.IdSubContratista = @OPERADOR AND CSC.IsActivo = 1)

	--	 SELECT @CONDICIONES_PAGO = @CONDICIONES_PAGO + ' días de crédito'

	--	END
	--	ELSE
	--	BEGIN
	--	SELECT @CONDICIONES_PAGO = 'Contado'
	--	END
	--END
	--ELSE
	--BEGIN
	--SELECT @CONDICIONES_PAGO = 'Contado'
	--END

	DECLARE @ENTREGAUNICA BIT = (SELECT SP.UnicoDomicilioEntrega FROM dbo.MM_SolicitudPedido AS SP
									LEFT JOIN dbo.MM_Pedido AS P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
									WHERE P.IdPedido = @IdPedido)

	IF @ENTREGAUNICA = 1
	BEGIN
		SET @DOMICILIOENTREGA = (SELECT CONCAT('Calle.' ,DO.Calle, ' , N°Ext: ',DO.NoExterior, ' , N°Int: ', DO.NoInterior, ' , Col.', DO.Colonia, ', C.P.',DO.CodigoPostal,' , ',DO.Municipio,',',DO.Estado,',',DO.Pais)
									FROM dbo.MM_SolicitudPedido AS SP
									LEFT JOIN dbo.MM_Pedido AS P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
									LEFT JOIN dbo.DG_Domicilio AS DO ON DO.IdDomicilio = SP.IdDomicilioEntrega
									WHERE P.IdPedido = @IdPedido)
	END


	DECLARE @CondionesPago NVARCHAR(MAX) 

	SELECT 
	@CondionesPago=CASE WHEN pd.IdCondicionPago = 1 THEN --> CREDITO
	CONCAT(pd.DiasCredito, CASE WHEN PD.DiasCredito=1 THEN ' días' ELSE ' días' END,' de ', cp.CondicionPago)
	ELSE 
	CONCAT(cp.CondicionPago,'')
	END 
	FROM dbo.MM_PedidoDetalle pd
	LEFT JOIN dbo.MM_CondicionPago cp ON cp.IdCondicionPago = pd.IdCondicionPago
	WHERE IdPedido =@IdPedido

	SELECT DISTINCT
	--CONDICIONESDEPAGO = CASE 
	--						WHEN P.DiasCredito > 0 THEN CONCAT(CAST(p.DiasCredito AS NVARCHAR(30)), ' días de crédito')
	--						ELSE 'Contado'
	--					END,
	CONDICIONESDEPAGO =  CASE WHEN P.UnicaCondicionPago = 1 THEN 
						CONCAT(@CondionesPago,'')
						ELSE 
						'Diferidas para las partidas de la orden de compra'
						END,
	TM.TipoMoneda AS MONEDA,
	TPS.TipoPedido AS TIPODECOMPRA,
	@DOMICILIOENTREGA AS DOMICILIOENTREGA,
	--CASE WHEN SP.EntregasParciales = 1 THEN
	--	CONVERT(VARCHAR(11),SP.FechaEntregaRequerida,103) +' - '+ CONVERT(VARCHAR(11),SP.FechaEntregaFinRequerida,103) 
	--ELSE 
	--	CONVERT(VARCHAR(11),SP.FechaEntregaRequerida,103) 
	--END AS FECHAENTREGA,
	CONVERT(VARCHAR(20),P.FechaEntregaPedido ,103) AS FECHAENTREGA,
	SU.Nombre AS NOMBRECOMPRADOR,
	PR.Telefono AS TELEFONO,
	SU.Correo AS CORREO,
	TP.TipoPedido
	
	FROM
	dbo.MM_Pedido AS P
	LEFT JOIN dbo.MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
	LEFT JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PD.IdMoneda
	LEFT JOIN dbo.MM_Pedidos AS PG ON PG.IdIdentificador = P.IdPedido AND PG.IdProveedorCliente = P.IdProveedorCompras
	LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
	--LEFT JOIN dbo.FI_Factura AS FA ON FA.IdFactura = PG.IdIdentificador
	LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	LEFT JOIN dbo.S_Usuario AS SU ON SU.IdUsuario = P.CreadoPor
	LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
	LEFT JOIN dbo.MM_TipoPedido AS TPS ON TPS.IdTipoPedido = PG.IdTipoPedido

	WHERE P.IdPedido = @IdPedido
END


	 


