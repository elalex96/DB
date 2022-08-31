USE Petrovendor
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_AX_ConsultaBitacorasSoporte'
)
    DROP PROCEDURE SP_AX_ConsultaBitacorasSoporte;
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: <30-08-2022>
-- Description:	<Consulta de la bitácora de carso segun el tipo de tabla solicitado>
-- =============================================
CREATE PROCEDURE dbo.SP_AX_ConsultaBitacorasSoporte
@TIPO VARCHAR(100),
@FECHAINICIO DATETIME,
@FECHAFIN DATETIME 
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
-- 1
IF @TIPO ='AX_BitacoraProveedorGanador'
BEGIN 

	SELECT 
	Currency,
	ItemId,
	Observations,
	Qty,
	Price,
	RecID,
	Unit,
	RFC,
	DataAreaID,
	PedidoADINCO,
	OCIIFormat,
	FechaRegistro
	FROM AX_BitacoraProveedorGanador (NOLOCK)
	WHERE CAST(FechaRegistro AS DATE) 
	BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)

END 

-- 2		
IF @TIPO ='AX_ComparativaLog'
BEGIN 

	SELECT 
	   Id
      ,FechaRegistro
      ,LineaPresupuesto
      ,Item
      ,Cantidad
      ,Unidad
      ,LugarEntrega
      ,Instalacion
      ,FechaEntrega
      ,TipoAdjudicacion
      ,JustificacionPedido
      ,CentroCosto
      ,Aprobadores
      ,MensajeAprobacion
      ,IdComparativa
      ,IdPosicion
      ,DataAreaID
      ,FechaEntregaExist
      ,IdProveedor
      ,IdUsuario
      ,p1
      ,p2
      ,p3
      ,p4
      ,p5
      ,p6
      ,p7
      ,p8
      ,p9
      ,p10
	FROM AX_ComparativaLog (NOLOCK)
	WHERE CAST(FechaRegistro AS DATE) 
	BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)

END 
-- 3
IF @TIPO ='Ax_BitacoraCarso'
BEGIN 
      SELECT
	  Id
      ,ErrorMotivo
      ,Lugar
      ,Comparativa
      ,DataAreaId
      ,RecId
      ,Accion
      ,FechaRegistro
      ,IdPedido
      ,IdOc
      ,ItemAceptacion
      ,UUID_Principal
      ,UUID_Complemento
      ,IdAsientoPago
	  FROM Ax_BitacoraCarso  (NOLOCK)
	  WHERE CAST(FechaRegistro AS DATE) 
	BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)
END 

-- 4
IF @TIPO ='AX_Bitacora'
BEGIN 
      SELECT IdBitacora
      ,DataAreaId
      ,FechaAcceso
      ,FechaSalida
      ,Error
      ,Observacion
      ,IdComparativa
      ,IpAddress
      ,HostName
	FROM AX_Bitacora  (NOLOCK)
	WHERE CAST(FechaAcceso AS DATE) 
	BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)
END 

-- 5
IF @TIPO ='Ax_PedidoLog'
BEGIN 
      SELECT RFC
      ,DataAreaId
      ,IdPedidoAdinco
      ,OCIPurchId
      ,OCIIdFormat
      ,CurrencyCode
      ,ItemId
      ,Observations
      ,Price
      ,Qty
      ,RecId
      ,UnitId
      ,IdSolicitudPedido
      ,FechaRegistro
    FROM Ax_PedidoLog  (NOLOCK)
	WHERE CAST(FechaRegistro AS DATE) BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)
END 
-- 6
IF @TIPO ='AX_RemisionLog'
BEGIN 
      SELECT IdOC
      ,RECID
      ,DataAreaId
      ,IdPedido
      ,Item
      ,Cantidad
      ,Asiento
      ,fecharegistro	 
      ,idRemisionCARSO
    FROM AX_RemisionLog  (NOLOCK)
	WHERE CAST(fecharegistro AS DATE) 
	BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)
END 

-- 7
IF @TIPO ='AX_AsientoFacturaLog'
BEGIN 
      SELECT UUID
      ,DataAreaId
      ,CuentaSectorHidrocarburos
      ,NumeroPoliza
      ,RECID
      ,FechaRegistro
   FROM AX_AsientoFacturaLog  (NOLOCK)
	WHERE CAST(FechaRegistro AS DATE)  BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)
END 

-- 8
IF @TIPO ='Ax_ComparativaErrorLog'
BEGIN   
   SELECT Id
      ,IdDinamicsAx
      ,IdDocumento
      ,Motivo
      ,FechaRegistro
  FROM Ax_ComparativaErrorLog  (NOLOCK)
  WHERE CAST(FechaRegistro AS DATE)  BETWEEN CAST(@FECHAINICIO AS DATE) AND CAST(@FECHAFIN AS DATE)
END 

END TRY
BEGIN CATCH	
	SELECT 'ERROR-SP_AX_ConsultaBitacorasSoporte(TIPO:'+ISNULL(@TIPO,'NA')+'): ['+ ERROR_MESSAGE() + '] LINEA ['+ CAST(ERROR_LINE() AS VARCHAR)+']';	
END CATCH

END;
