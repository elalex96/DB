use Petrovendor
GO
DROP PROC IF EXISTS sp_ConsultaDeInsercionCompraDirecta
GO
-- =============================================
-- Author:		PEDRO 
-- Create date: 29/12/2017
-- Description: Consulta de compras directas 
-- =============================================
-- Author:		PEDRO 
-- Update date: 29/12/2017
-- Description: Agregue filtro de todos  
-- =============================================
-- Author:		DAC 
-- Update date: 06/03/2018
-- Description: Agregue LEFT de área contractual
-- =============================================
-- Author:		Alexander Gomez 
-- Update date: 14/03/2018
-- Description: Agregado del filtrado del eliminado logico
-- =============================================
-- Author:		Jose Roman
-- Update date: 28/03/2018
-- Description: Se agrega Moneda a la consulta y parametros de contrato
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 22/07/2019
-- Description: se agrego la fecha de aprobacion
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 02/05/2020
-- Description: se agrego la cuenta bancaria
-- =============================================
-- Author:		Luis Davi De La Cruz
-- Update date: 19/02/2021
-- Description: se selecciona la fecha máxima de la bitacora de la operación
-- =============================================
-- Author:		Luis Davi De La Cruz
-- Update date: 29/02/2024
-- Description: Se agrega mejoras de estándares issue #2662
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaDeInsercionCompraDirecta] -- 0,2,420
    @idUsuario			INT,
    @aprobadaRechazada	INT,
	@IdProveedor		INT,
    @IdContrato			INT = null,
    @FechaRegistro		DATETIME = null
AS
BEGIN
	
	DECLARE	@TablaFecha TABLE (IdOperacion INT, Fecha NVARCHAR(MAX))


	INSERT INTO @TablaFecha (IdOperacion, Fecha)
	SELECT tao.IdOperacion, FORMAT(tarea.fecha,'dd/MM/yy hh:mm:ss tt') FROM 
	(
		SELECT IdOperacion, Max(Fecha) as fecha  
		FROM TA_HistorialFlujoTarea
		WHERE IdEstadoFlujo = 7
		GROUP BY IdOperacion
	) tarea
	INNER JOIN TA_Operacion tao
	ON tarea.IdOperacion = tao.IdOperacion
	where tao.IdProveedor = @IdProveedor AND tao.IdTipoOperacion = 14
	ORDER BY tarea.fecha DESC
 
    IF (@aprobadaRechazada IN ( 1, 2))
    BEGIN
        SELECT CASE
                   WHEN (TE.IdEstatus = 1) THEN
                       'Pendiente' 
                   WHEN (TE.IdEstatus = 2) THEN
                       'Aprobada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 4) THEN
                       'Cancelado por Rechazo'
                   WHEN (TE.IdEstatus = 5) THEN
                       'Cancelado por Vencimiento'
                   WHEN (TE.IdEstatus = 6) THEN
                       'Cancelado por Asignador'
                   WHEN (TE.IdEstatus = 7) THEN
                       'Cancelado por Reasignación'
					WHEN (TE.IdEstatus = 10) THEN
                       'Cancelado por Eliminación'
               END AS Estatus,
               TE.IdEstatus,
			   coRegistro.IdRegistro,
			   TAO.IdFlujoTarea,
			   TAO.IdOperacion,
			   CASE
					WHEN TE.IdEstatus = 2 THEN CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID, ' - Aprobada el ' , CAST(fecha.Fecha AS NVARCHAR(MAX)))
					ELSE CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID)
				END AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
			   PG.CuentaBancaria,
               cuentaSh.Descripcion AS CuentaSh,
               fiFact.CreadoEn AS Fecha,
               TAO.IdVigencia AS Vigencia,
               coRegistro.IdLineaPresupuestoMes AS LineaPresupuesto,
               coRegistro.MontoRegistro AS MontoRegistro,
               fiFact.SubTotal AS Subtotal,
               coRegistro.InicioEjecucion,
               coRegistro.FinEjecucion,
               instalacion.NombreInstalacion,
			   coRegistro.IdFactura,
			   ISNULL(p.RazonSocial,'') +' '+ISNULL(p.RegimenCapital,'') AS Proveedor,
			   PG.IdPedido AS IdPedidoGeneral,
			   AC.NombreAreaContractual AS AreaContractual,
			   fiFact.Moneda
        FROM dbo.CO_Registro AS coRegistro (NOLOCK)
            LEFT JOIN dbo.FI_Factura AS fiFact (NOLOCK)
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN dbo.TA_Operacion AS TAO (NOLOCK)
                ON coRegistro.IdFactura = TAO.IdDocumento
            LEFT JOIN dbo.TA_Estatus AS TE (NOLOCK)
                ON TAO.IdEstatusOperacion = TE.IdEstatus
            LEFT JOIN dbo.CC_CentroCosto centroCosto (NOLOCK)
                ON coRegistro.CentroCostos = centroCosto.IdCentroCosto
            LEFT JOIN dbo.DG_CuentaContable cuentaContable (NOLOCK)
                ON coRegistro.CuentaContable = cuentaContable.Id
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh (NOLOCK)
                ON coRegistro.IdCatalogoCuentasSH = cuentaSh.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion (NOLOCK)
                ON coRegistro.IdInstalacion = instalacion.IdInstalacion
			LEFT JOIN dbo.MM_Pedidos PG (NOLOCK)
				ON fiFact.IdFactura = PG.IdIdentificador
				AND TAO.IdProveedor = PG.IdProveedorCliente
				AND PG.IdTipoPedido=1 
			LEFT JOIN dbo.S_Proveedor AS P (NOLOCK)
				ON fiFact.Emisor = P.RFC
			LEFT JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
				ON C.IdContrato = fiFact.IdContrato
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK)
				ON C.IdAreaContractual = AC.IdAreaContractual
			LEFT JOIN @TablaFecha fecha
				ON TAO.IdOperacion = fecha.IdOperacion
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.idproveedor = @IdProveedor
              AND TE.IdEstatus = @aprobadaRechazada
			  AND fiFact.IsEliminado IS NULL
			  
        ORDER BY coRegistro.IdRegistro DESC
    END
	--FACTURAS ELIMINADAS
	IF @aprobadaRechazada = 10
    BEGIN
        SELECT CASE
                   WHEN (TE.IdEstatus = 1) THEN
                       'Pendiente'
                   WHEN (TE.IdEstatus = 2) THEN
                       'Aprobada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 4) THEN
                       'Cancelado por Rechazo'
                   WHEN (TE.IdEstatus = 5) THEN
                       'Cancelado por Vencimiento'
                   WHEN (TE.IdEstatus = 6) THEN
                       'Cancelado por Asignador'
                   WHEN (TE.IdEstatus = 7) THEN
                       'Cancelado por Reasignación'
					WHEN (TE.IdEstatus = 10) THEN
                       'Cancelado por Eliminación'
               END AS Estatus,
               TE.IdEstatus,
			   coRegistro.IdRegistro,
			   TAO.IdFlujoTarea,
			   TAO.IdOperacion,
               CASE
					WHEN TE.IdEstatus = 2 THEN CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID, ' - Aprobada el ' , CAST(fecha.Fecha AS NVARCHAR(MAX)))
					ELSE CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID)
				END AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
			   PG.CuentaBancaria,
               cuentaSh.Descripcion AS CuentaSh,
               fiFact.CreadoEn AS Fecha,
               TAO.IdVigencia AS Vigencia,
               coRegistro.IdLineaPresupuestoMes AS LineaPresupuesto,
               coRegistro.MontoRegistro AS MontoRegistro,
               fiFact.SubTotal AS Subtotal,
               coRegistro.InicioEjecucion,
               coRegistro.FinEjecucion,
               instalacion.NombreInstalacion,
			   coRegistro.IdFactura,
			   ISNULL(p.RazonSocial,'') +' '+ISNULL(p.RegimenCapital,'') AS Proveedor,
			   PG.IdPedido AS IdPedidoGeneral,
			   AC.NombreAreaContractual AS AreaContractual ,
			   fiFact.Moneda
        FROM dbo.CO_Registro AS coRegistro (NOLOCK)
            LEFT JOIN dbo.FI_Factura AS fiFact (NOLOCK)
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO (NOLOCK)
                ON coRegistro.IdFactura = TAO.IdDocumento
            LEFT JOIN TA_Estatus AS TE (NOLOCK)
                ON TAO.IdEstatusOperacion = TE.IdEstatus
            LEFT JOIN dbo.CC_CentroCosto centroCosto (NOLOCK)
                ON coRegistro.CentroCostos = centroCosto.IdCentroCosto
            LEFT JOIN dbo.DG_CuentaContable cuentaContable (NOLOCK)
                ON coRegistro.CuentaContable = cuentaContable.Id
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh (NOLOCK)
                ON coRegistro.IdCatalogoCuentasSH = cuentaSh.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion (NOLOCK)
                ON coRegistro.IdInstalacion = instalacion.IdInstalacion
			LEFT JOIN dbo.MM_Pedidos PG (NOLOCK)
				ON fiFact.IdFactura = PG.IdIdentificador
				AND TAO.IdProveedor = PG.IdProveedorCliente
				AND PG.IdTipoPedido=1 
			LEFT JOIN dbo.S_Proveedor AS P (NOLOCK)
				ON fiFact.Emisor = P.RFC
			LEFT JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
				ON C.IdContrato = fiFact.IdContrato
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK)
				ON C.IdAreaContractual = AC.IdAreaContractual
			LEFT JOIN @TablaFecha fecha 
				ON TAO.IdOperacion = fecha.IdOperacion
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.idproveedor = @IdProveedor
              AND TE.IdEstatus = @aprobadaRechazada
			  AND fiFact.IsEliminado = 1
			  
        ORDER BY coRegistro.IdRegistro DESC
    END
    
	--- EN APROBACION
	IF @aprobadaRechazada = 0
    BEGIN
        SELECT CASE
                   WHEN (TE.IdEstatus = 1) THEN
                       'Pendiente'
                   WHEN (TE.IdEstatus = 2) THEN
                       'Aprobada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 4) THEN
                       'Cancelado por Rechazo'
                   WHEN (TE.IdEstatus = 5) THEN
                       'Cancelado por Vencimiento'
                   WHEN (TE.IdEstatus = 6) THEN
                       'Cancelado por Asignador'
                   WHEN (TE.IdEstatus = 7) THEN
                       'Cancelado por Reasignación'
					WHEN (TE.IdEstatus = 10) THEN
                       'Cancelado por Eliminación'
               END AS Estatus,
               TE.IdEstatus,
			   coRegistro.IdRegistro,
			   TAO.IdFlujoTarea,
			   TAO.IdOperacion,
               CASE
					WHEN TE.IdEstatus = 2 THEN CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID, ' - Aprobada el ' , CAST(fecha.Fecha AS NVARCHAR(MAX)))
					ELSE CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID)
				END AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
			   PG.CuentaBancaria,
               cuentaSh.Descripcion AS CuentaSh,
               fiFact.CreadoEn AS Fecha,
               TAO.IdVigencia AS Vigencia,
               coRegistro.IdLineaPresupuestoMes AS LineaPresupuesto,
               coRegistro.MontoRegistro AS MontoRegistro,
               fiFact.SubTotal AS Subtotal,
               coRegistro.InicioEjecucion,
               coRegistro.FinEjecucion,
               instalacion.NombreInstalacion,
			   coRegistro.IdFactura,
			    ISNULL(p.RazonSocial,'') +' '+ISNULL(p.RegimenCapital,'') AS Proveedor,
			    PG.IdPedido AS IdPedidoGeneral,
				AC.NombreAreaContractual AS AreaContractual,
			   fiFact.Moneda
        FROM dbo.CO_Registro AS coRegistro (NOLOCK)
            LEFT JOIN dbo.FI_Factura AS fiFact (NOLOCK)
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO (NOLOCK)
                ON coRegistro.IdFactura = TAO.IdDocumento
            LEFT JOIN TA_Estatus AS TE (NOLOCK)
                ON TAO.IdEstatusOperacion = TE.IdEstatus
            LEFT JOIN dbo.CC_CentroCosto centroCosto (NOLOCK)
                ON coRegistro.CentroCostos = centroCosto.IdCentroCosto
            LEFT JOIN dbo.DG_CuentaContable cuentaContable (NOLOCK)
                ON coRegistro.CuentaContable = cuentaContable.Id
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh (NOLOCK)
                ON coRegistro.IdCatalogoCuentasSH = cuentaSh.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion (NOLOCK)
                ON coRegistro.IdInstalacion = instalacion.IdInstalacion
			LEFT JOIN dbo.S_Proveedor AS P (NOLOCK)
				ON fiFact.Emisor = P.RFC
			LEFT JOIN dbo.MM_Pedidos PG (NOLOCK)
				ON fiFact.IdFactura = PG.IdIdentificador
				AND TAO.IdProveedor = PG.IdProveedorCliente
				AND PG.IdTipoPedido=1 
			LEFT JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
				ON fiFact.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK)
				ON C.IdAreaContractual = AC.IdAreaContractual
			LEFT JOIN @TablaFecha fecha 
				ON TAO.IdOperacion = fecha.IdOperacion
        WHERE TAO.IdTipoOperacion = 14
              AND TAO.idproveedor = @IdProveedor
              AND TE.IdEstatus NOT IN ( 1, 2 )
			  AND fiFact.IsEliminado IS NULL
        ORDER BY coRegistro.IdRegistro DESC
    END

	---TODOS
	IF @aprobadaRechazada = 3
    BEGIN
        SELECT CASE
                   WHEN (TE.IdEstatus = 1) THEN
                       'En aprobación'
                   WHEN (TE.IdEstatus = 2) THEN
                       'Aprobada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada el ' + CAST(fecha.Fecha AS NVARCHAR(MAX))
                   WHEN (TE.IdEstatus = 4) THEN
                       'Cancelado por Rechazo'
                   WHEN (TE.IdEstatus = 5) THEN
                       'Cancelado por Vencimiento'
                   WHEN (TE.IdEstatus = 6) THEN
                       'Cancelado por Asignador'
                   WHEN (TE.IdEstatus = 7) THEN
                       'Cancelado por Reasignación'
					   WHEN (TE.IdEstatus = 8) THEN
                       'Cancelado por Eliminación'
					   WHEN (TE.IdEstatus = 10) THEN
                       'Cancelado por Eliminación'
               END AS Estatus,
               TE.IdEstatus,
			   coRegistro.IdRegistro,
			   TAO.IdFlujoTarea,
			   TAO.IdOperacion,
               CASE
					WHEN TE.IdEstatus = 2 THEN CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID, ' - Aprobada el ' , CAST(fecha.Fecha AS NVARCHAR(MAX)))
					ELSE CONCAT('Centro Costos: ', ISNULL(centroCosto.CentroCosto, 'S/CC'), ' Factura: ', fiFact.UUID)
				END AS CentroCosto,
			   cuentaContable.Descripcion AS Cuentacontable,
			   PG.CuentaBancaria,
               cuentaSh.Descripcion AS CuentaSh,
               fiFact.CreadoEn AS Fecha,
               TAO.IdVigencia AS Vigencia,
               coRegistro.IdLineaPresupuestoMes AS LineaPresupuesto,
               coRegistro.MontoRegistro AS MontoRegistro,
               fiFact.SubTotal AS Subtotal,
               coRegistro.InicioEjecucion,
               coRegistro.FinEjecucion,
               instalacion.NombreInstalacion,
			   coRegistro.IdFactura,
			    ISNULL(p.RazonSocial,'') +' '+ISNULL(p.RegimenCapital,'') AS Proveedor,
				 PG.IdPedido AS IdPedidoGeneral,
				  AC.NombreAreaContractual AS AreaContractual,
			   fiFact.Moneda 
        FROM dbo.CO_Registro AS coRegistro (NOLOCK)
            LEFT JOIN dbo.FI_Factura AS fiFact (NOLOCK)
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO (NOLOCK)
                ON coRegistro.IdFactura = TAO.IdDocumento
            LEFT JOIN TA_Estatus AS TE (NOLOCK)
                ON TAO.IdEstatusOperacion = TE.IdEstatus
            LEFT JOIN dbo.CC_CentroCosto centroCosto (NOLOCK)
                ON coRegistro.CentroCostos = centroCosto.IdCentroCosto
			LEFT JOIN dbo.DG_CuentaContable cuentaContable (NOLOCK)
                ON coRegistro.CuentaContable = cuentaContable.Id
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh (NOLOCK)
                ON coRegistro.IdCatalogoCuentasSH = cuentaSh.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion (NOLOCK)
                ON coRegistro.IdInstalacion= instalacion.IdInstalacion
			LEFT JOIN dbo.S_Proveedor AS P (NOLOCK)
				ON fiFact.Emisor = P.RFC
			LEFT JOIN dbo.MM_Pedidos PG (NOLOCK)
				ON fiFact.IdFactura = PG.IdIdentificador
				AND TAO.IdProveedor = PG.IdProveedorCliente
				AND PG.IdTipoPedido = 1 
			LEFT JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
				ON fiFact.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK)
				ON C.IdAreaContractual = AC.IdAreaContractual
			LEFT JOIN @TablaFecha fecha 
				ON TAO.IdOperacion = fecha.IdOperacion
        WHERE TAO.IdTipoOperacion = 14
               AND TAO.idproveedor = @IdProveedor          
        ORDER BY coRegistro.IdRegistro DESC
    END
END
