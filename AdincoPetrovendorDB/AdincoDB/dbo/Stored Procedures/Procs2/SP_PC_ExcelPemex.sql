-- =============================================
-- Author:		Manuel CD
-- Create date: 20-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ExcelPemex] 
	-- Add the parameters for the stored procedure here
@IdTipoExcelPemex INT,
@NombreArchivo    NVARCHAR(MAX),
@FechaReporte     DATE,
@ExcelArchivo     IMAGE,
@IdUsuario        INT,
@IdContrato       INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

	    /*Actualizar por contratista*/

             DECLARE @IdContratista INT;
             SELECT @IdContratista = CC.IdContratista
             FROM CO_Contratista CC
                  JOIN CO_Contrato C ON CC.IdContratista = C.IdContratista
             WHERE C.IdContrato = @IdContrato;
	    
/**/

             IF EXISTS
(
    SELECT *
    FROM PC_ExcelPemex EP
         JOIN CO_Contrato C ON EP.IdContrato = C.IdContrato
         JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
    WHERE IdTipoExcelPemex = @IdTipoExcelPemex
          AND FechaReporte = @FechaReporte
          AND CC.IdContratista = @IdContratista
)
                 BEGIN
                     UPDATE EP
                       SET
                           ExcelArchivo = @ExcelArchivo,
                           CreadoEn = GETDATE(),
                           CreadoPor = @IdUsuario,
                           NombreArchivo = @NombreArchivo
                     FROM PC_ExcelPemex EP
                          JOIN CO_Contrato C ON EP.IdContrato = C.IdContrato
                          JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
                     WHERE IdTipoExcelPemex = @IdTipoExcelPemex
                       --AND EP.IdContrato = @IdContrato
                           AND FechaReporte = @FechaReporte
                           AND CC.IdContratista = @IdContratista;
                 END;
                 ELSE
                 BEGIN
                     INSERT INTO [dbo].[PC_ExcelPemex]
([IdTipoExcelPemex],
 [NombreArchivo],
 [FechaReporte],
 [ExcelArchivo],
 [CreadoPor],
 [CreadoEn],
 [IdContrato]
)
                     VALUES
(@IdTipoExcelPemex,
 @NombreArchivo,
 @FechaReporte,
 @ExcelArchivo,
 @IdUsuario,
 GETDATE(),
 @IdContrato
);
                 END;

	    /*Insertar en tablas finales*/

             IF(@IdTipoExcelPemex = 10001)
                 BEGIN
                     DELETE PC_Comercializacion_V2
                     WHERE [FechaReporte] = @FechaReporte;
                     INSERT INTO [dbo].[PC_Comercializacion_V2]
([IdContrato],
 [FechaReporte],
 [Factura],
 [FechaFactura],
 [Sociedad],
 [ValorNeto],
 [MonedaValNeto],
 [ImporteImpuesto],
 [Referencia1],
 [CantidadFacturada],
 [UniMedidaVenta],
 [Material],
 [Denominación],
 [NoDocumento],
 [Ejercicio],
 [Moneda],
 [TipoCambio],
 [MonedaLocal],
 [Referencia2],
 [Importe],
 [ImporteML],
 [PosPresupuestaria],
 [CentroGestor],
 [CuentaMayor],
 [DocCompensación],
 [OrganizaciónVentas],
 [CanalDistribución],
 [Sector],
 [Centro],
 [Nombre1],
 [PuestoCarga],
 [Denominación1],
 [Energía],
 [UnidadSalidaCondición],
 [Cliente],
 [NombreCliente1],
 [ImporteDolares],
 [MonedaDolares],
 [NombreCliente2],
 [OficinaVentas],
 [GpoCond],
 [NoOrden],
 [PedCliente],
 [PlanEntrega],
 [FechaComp],
 [FechaPago],
 [FTesorería],
 [FDPP1],
 [FDPPV],
 [CreadoPor],
 [CreadoEn]
)
                            SELECT @IdContrato,
                                   @FechaReporte,
                                   [Factura],
                                   [Fecha factura],
                                   [Sociedad],
                                   [Valor neto],
                                   [Moneda Val# Neto],
                                   [Importe del impuesto],
                                   [Referencia],
                                   [Cantidad facturada],
                                   [Un#medida venta],
                                   [Material],
                                   [Denominación],
                                   [Nº documento],
                                   [Ejercicio],
                                   [Moneda],
                                   [Tipo de cambio],
                                   [Moneda local],
                                   [Referencia1],
                                   [Importe],
                                   [Importe ML],
                                   [Pos#presupuestaria],
                                   [Centro gestor],
                                   [Cuenta de mayor],
                                   [Doc#compensación],
                                   [Organización ventas],
                                   [Canal distribución],
                                   [Sector],
                                   [Centro],
                                   [Nombre 1],
                                   [Puesto de carga],
                                   [Denominación1],
                                   [Energía],
                                   [Unidad de salida de condición],
                                   [Cliente],
                                   [Nombre Cliente],
                                   [Importe en dólares],
                                   [Moneda dólares],
                                   [Nombre del Cliente],
                                   [Oficina Ventas],
                                   [Gpo#Cond#],
                                   [No#Orden],
                                   [Ped#Cliente],
                                   [Plan Entrega],
                                   [FechaComp],
                                   [FechaPago],
                                   [F#Tesorería],
                                   [F#DPP1],
                                   [F#DPPV],
                                   @IdUsuario,
                                   GETDATE()
                            FROM [dbo].[PC_Comercializacion];
                 END;
             IF(@IdTipoExcelPemex = 10002)
                 BEGIN
                     DELETE PC_PMI_V2
                     WHERE [FechaReporte] = @FechaReporte;
                     INSERT INTO [dbo].[PC_PMI_V2]
([IdContrato],
 [FechaReporte],
 [Sociedad],
 [Estado],
 [TipoDoc],
 [NombreCliente],
 [UUID],
 [Ejercicio],
 [Serie],
 [Factura],
 [Emisor],
 [Receptor],
 [FechaFactura],
 [TipoComp],
 [Subtotal],
 [Impuestos],
 [Total],
 [FechaExpedicion],
 [Moneda],
 [Tasa],
 [ClaveCliente],
 [Folio],
 [FechaTimbrado],
 [MetodoPago],
 [CreadoPor],
 [CreadoEn]
)
                            SELECT @IdContrato,
                                   @FechaReporte,
                                   [SOCIEDAD],
                                   [ESTADO],
                                   [TIPO DOCUMENTO],
                                   [NOMBRE CLIENTE],
                                   [UUID],
                                   [EJERCICIO],
                                   [SERIE],
                                   [FACTURA],
                                   [EMISOR],
                                   [RECEPTOR],
                                   [FECHA FACTURA],
                                   [TIPO COMP#],
                                   [SUBTOTAL],
                                   [IMPUESTOS],
                                   [TOTAL],
                                   [FECHA EXPEDICIÓN],
                                   [MONEDA],
                                   [TASA],
                                   [CLAVE CLIENTE],
                                   [FOLIO],
                                   [FECHA TIMBRADO],
                                   [METODO PAGO],
                                   @IdUsuario,
                                   GETDATE()
                            FROM [dbo].[PC_PMI];
                 END;
             IF(@IdTipoExcelPemex = 10003)
                 BEGIN
                     DELETE PC_PTI_V2
                     WHERE [FechaReporte] = @FechaReporte;
                     INSERT INTO [dbo].[PC_PTI_V2]
([IdContrato],
 [FechaReporte],
 [Sociedad],
 [Estado],
 [TipoDoc],
 [NombreCliente],
 [UUID],
 [Ejercicio],
 [Serie],
 [Factura],
 [Emisor],
 [Receptor],
 [FechaFactura],
 [TipoComp],
 [Subtotal],
 [Impuestos],
 [Total],
 [FechaExpedicion],
 [Moneda],
 [Tasa],
 [ClaveCliente],
 [Folio],
 [FechaTimbrado],
 [MetodoPago],
 [CreadoPor],
 [CreadoEn]
)
                            SELECT @IdContrato,
                                   @FechaReporte,
                                   [SOCIEDAD],
                                   [ESTADO],
                                   [TIPO DOCUMENTO],
                                   [NOMBRE CLIENTE],
                                   [UUID],
                                   [EJERCICIO],
                                   [SERIE],
                                   [FACTURA],
                                   [EMISOR],
                                   [RECEPTOR],
                                   [FECHA FACTURA],
                                   [TIPO COMP#],
                                   [SUBTOTAL],
                                   [IMPUESTOS],
                                   [TOTAL],
                                   [FECHA EXPEDICIÓN],
                                   [MONEDA],
                                   [TASA],
                                   [CLAVE CLIENTE],
                                   [FOLIO],
                                   [FECHA TIMBRADO],
                                   [METODO PAGO],
                                   @IdUsuario,
                                   GETDATE()
                            FROM [dbo].[PC_PTI];
                 END;
             IF(@IdTipoExcelPemex = 10004)
                 BEGIN
                     DELETE dbo.PC_VentasAsignacion_V2
                     WHERE [FechaReporte] = @FechaReporte;
                     INSERT INTO [dbo].[PC_VentasAsignacion_V2]
([FechaReporte],
 [ASIGNACIÓN],
 [REGIÓN FISCAL],
 [REGIÓN],
 [POZO SNIP],
 [PRODUCTO POZO],
 [PRODUCCIÓN POZO],
 [CAMPO OFICIAL],
 [PRODUCCIÓN CAMPO],
 [PRODUCTO UNIF],
 [FACTOR = ProdPozo/ProdCampo],
 [PRODUCCIÓN ASIGNACIÓN],
 [PRODUCTO AGRUPA],
 [PRODUCTO VENTA],
 [PUNTO DE VENTA],
 [VENTA CAMPO MES],
 [VENTA ASIGNACIÓN MES],
 [UNIDAD VENTA MES],
 [VENTA ASIGNACIÓN DÍA],
 [UNIDAD VENTA DÍA],
 [VENTA ASIGNACIÓN MES INGLÉS],
 [UNIDAD VENTA MES INGLÉS],
 [VENTA ASIGNACIÓN DÍA INGLÉS],
 [UNIDAD VENTA DÍA INGLÉS],
 [API],
 [S],
 [C1],
 [C2],
 [C3],
 [NC4],
 [IC4],
 [C5+],
 [CO2],
 [H2S],
 [N2],
 [PoderCalorif C1],
 [PoderCalorif C2],
 [PoderCalorif C3],
 [PoderCalorif NC4],
 [PoderCalorif IC4],
 [PoderCalorif C5+],
 [PoderCalorif C1Btu/pc],
 [PoderCalorif C2Btu/pc],
 [PoderCalorif C3Btu/pc],
 [PoderCalorif NC4Btu/pc],
 [PoderCalorif IC4Btu/pc],
 [PoderCalorif C5+Btu/pc],
 [PoderCalorif Total Btu/pc],
 [Volumen C1],
 [Volumen C2],
 [Volumen C3],
 [Volumen NC4],
 [Volumen IC4],
 [Volumen C5+],
 [Energía C1],
 [Energía C2],
 [Energía C3],
 [Energía NC4],
 [Energía IC4],
 [Energía C5+],
 [Energía Total],
 [Ingreso C1],
 [Ingreso C2],
 [Ingreso C3],
 [Ingreso NC4],
 [Ingreso IC4],
 [Ingreso C5+],
 [Precio C1],
 [Precio C2],
 [Precio C3],
 [Precio NC4],
 [Precio IC4],
 [Precio C5+],
 [Precio ],
 [Ingresos Mes USD],
 [Venta Campo mes Facturado],
 [Venta Asignación mes Facturado],
 [Volumen Facturacion],
 [Precio Facturación],
 [Ingresos Mes Calculado USD],
 [CreadoPor],
 [CreadoEn]
)
                            SELECT @FechaReporte,
                                   ASIGNACIÓN,
                                   [REGIÓN FISCAL],
                                   REGIÓN,
                                   [POZO SNIP],
                                   [PRODUCTO POZO],
                                   [PRODUCCIÓN POZO],
                                   [CAMPO OFICIAL],
                                   [PRODUCCIÓN CAMPO],
                                   [PRODUCTO UNIF],
                                   [FACTOR = ProdPozo/ProdCampo],
                                   [PRODUCCIÓN ASIGNACIÓN],
                                   [PRODUCTO AGRUPA],
                                   [PRODUCTO VENTA],
                                   [PUNTO DE VENTA],
                                   [VENTA CAMPO MES],
                                   [VENTA ASIGNACIÓN MES],
                                   [UNIDAD VENTA MES],
                                   [VENTA ASIGNACIÓN DÍA],
                                   [UNIDAD VENTA DÍA],
                                   [VENTA ASIGNACIÓN MES INGLÉS],
                                   [UNIDAD VENTA MES INGLÉS],
                                   [VENTA ASIGNACIÓN DÍA INGLÉS],
                                   [UNIDAD VENTA DÍA INGLÉS],
                                   API,
                                   S,
                                   C1,
                                   C2,
                                   C3,
                                   NC4,
                                   IC4,
                                   [C5+],
                                   CO2,
                                   H2S,
                                   N2,
                                   [PoderCalorif C1],
                                   [PoderCalorif C2],
                                   [PoderCalorif C3],
                                   [PoderCalorif NC4],
                                   [PoderCalorif IC4],
                                   [PoderCalorif C5+],
                                   [PoderCalorif C1Btu/pc],
                                   [PoderCalorif C2Btu/pc],
                                   [PoderCalorif C3Btu/pc],
                                   [PoderCalorif NC4Btu/pc],
                                   [PoderCalorif IC4Btu/pc],
                                   [PoderCalorif C5+Btu/pc],
                                   [PoderCalorif Total Btu/pc],
                                   [Volumen C1],
                                   [Volumen C2],
                                   [Volumen C3],
                                   [Volumen NC4],
                                   [Volumen IC4],
                                   [Volumen C5+],
                                   [Energía C1],
                                   [Energía C2],
                                   [Energía C3],
                                   [Energía NC4],
                                   [Energía IC4],
                                   [Energía C5+],
                                   [Energía Total],
                                   [Ingreso C1],
                                   [Ingreso C2],
                                   [Ingreso C3],
                                   [Ingreso NC4],
                                   [Ingreso IC4],
                                   [Ingreso C5+],
                                   [Precio C1],
                                   [Precio C2],
                                   [Precio C3],
                                   [Precio NC4],
                                   [Precio IC4],
                                   [Precio C5+],
                                   [Precio ],
                                   [Ingresos Mes USD],
                                   [Venta Campo mes Facturado],
                                   [Venta Asignación mes Facturado],
                                   [Volumen Facturacion],
                                   [Precio Facturación],
                                   [Ingresos Mes Calculado USD],
                                   @IdUsuario,
                                   GETDATE()
                            FROM PC_VentasAsignacion
					   WHERE [ASIGNACIÓN] <> ''
                 END;
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
         END;
