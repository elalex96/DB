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
create PROCEDURE [dbo].[sp_ConsultaDeInsercionCompraDirecta_EX] 
    @idUsuario INT,
    @aprobadaRechazada INT,
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN
    IF (@aprobadaRechazada IN ( 1, 2))
    BEGIN
        SELECT CASE
                   WHEN (TE.IdEstatus = 1) THEN
                       'Pendiente'
                   WHEN (TE.IdEstatus = 2) THEN
                       'Aprobada'
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada'
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
               centroCosto.CentroCosto AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
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
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable            
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador = fiFact.IdFactura AND PG.IdTipoPedido=1 AND TAO.IdProveedor=PG.IdProveedorCliente
			LEFT JOIN dbo.S_Proveedor AS P ON P.RFC = fiFact.Emisor
			LEFT JOIN Adinco.dbo.CO_Contrato AS C
			ON fiFact.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual
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
                       'Aprobada'
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada'
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
               centroCosto.CentroCosto AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
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
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable            
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador = fiFact.IdFactura AND PG.IdTipoPedido=1 AND TAO.IdProveedor=PG.IdProveedorCliente
			LEFT JOIN dbo.S_Proveedor AS P ON P.RFC = fiFact.Emisor
			LEFT JOIN Adinco.dbo.CO_Contrato AS C
			ON fiFact.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual
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
                       'Aprobada'
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada'
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
               centroCosto.CentroCosto AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
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
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable
            --LEFT JOIN dbo.CO_LineaPresupuestoMes linea
            --    ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
				LEFT JOIN dbo.S_Proveedor AS P ON P.RFC = fiFact.Emisor
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador = fiFact.IdFactura AND PG.IdTipoPedido=1 AND TAO.IdProveedor=PG.IdProveedorCliente
			LEFT JOIN Adinco.dbo.CO_Contrato AS C
			ON fiFact.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual
        WHERE TAO.IdTipoOperacion = 14
			  --AND fiFact.IsEliminado != 1
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
                       'Aprobada'
                   WHEN (TE.IdEstatus = 3) THEN
                       'Rechazada'
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
               centroCosto.CentroCosto AS CentroCosto,
               cuentaContable.Descripcion AS Cuentacontable,
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
        FROM dbo.CO_Registro AS coRegistro
            LEFT JOIN dbo.FI_Factura AS fiFact
                ON coRegistro.IdFactura = fiFact.IdFactura
            LEFT JOIN TA_Operacion AS TAO
                ON TAO.IdDocumento = coRegistro.IdFactura
            LEFT JOIN TA_Estatus AS TE
                ON TE.IdEstatus = TAO.IdEstatusOperacion
            LEFT JOIN dbo.CC_CentroCosto centroCosto
                ON centroCosto.IdCentroCosto = coRegistro.CentroCostos
            LEFT JOIN dbo.DG_CuentaContable cuentaContable
                ON cuentaContable.Id = coRegistro.CuentaContable
            --LEFT JOIN dbo.CO_LineaPresupuestoMes linea
            --    ON linea.IdLineaPresupuestoMes = coRegistro.IdLineaPresupuestoMes
            LEFT JOIN dbo.CO_CatalogoCuentaSH cuentaSh
                ON cuentaSh.IdCatalogoCuentasSH = coRegistro.IdCatalogoCuentasSH
            LEFT JOIN dbo.CO_Instalacion instalacion
                ON instalacion.IdInstalacion = coRegistro.IdInstalacion
				LEFT JOIN dbo.S_Proveedor AS P ON P.RFC = fiFact.Emisor
			LEFT JOIN dbo.MM_Pedidos PG
				ON PG.IdIdentificador = fiFact.IdFactura AND PG.IdTipoPedido=1 AND TAO.IdProveedor=PG.IdProveedorCliente
			LEFT JOIN Adinco.dbo.CO_Contrato AS C
			ON fiFact.IdContrato = C.IdContrato    
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual
        WHERE TAO.IdTipoOperacion = 14
               AND TAO.idproveedor = @IdProveedor          
        ORDER BY coRegistro.IdRegistro DESC
    END
END



