
--Si existe la factura en Adinco se relaciona y se aprueba

CREATE PROCEDURE dbo.sp_FacturaRelacionaryAprobar
(@IdProveedor        INT, 
 @IdAceptacionPedido INT, 
 @IdUsuario          INT
)
AS
     BEGIN
         DECLARE @IdFacturaPetrov INT, @IdFacturaAdinco INT, @NombreUsuario NVARCHAR(MAX);
         DECLARE @TablaFacturasEnAprobacion TABLE
         (IdAceptacionPedido INT, 
          IdFacturaPetrov    INT, 
          IdPedidoGral       INT, 
          IdPedido           INT, 
          FechaCarga         DATETIME, 
          Proveedor          NVARCHAR(MAX), 
          Estatus            NVARCHAR(500), 
          TipoPedido         NVARCHAR(1000), 
          TotalPedido        MONEY, 
          Moneda             NVARCHAR(50), 
          RFC                NVARCHAR(50), 
          UUID               NVARCHAR(500), 
          IdSolicitudPedido  INT, 
          IdFacturaAdinco    INT, 
          IdOperacion        INT
         );
         SELECT @NombreUsuario = u.Nombre
         FROM dbo.S_Usuario u
         WHERE u.IdUsuario = @IdUsuario;
         IF EXISTS
         (
             SELECT 1
             FROM dbo.MM_AceptacionFactura AS AF
                  INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                  INNER JOIN dbo.TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                  INNER JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                  INNER JOIN dbo.MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                                                    AND PE.IdSubcontratista = O.IdProveedor
                  INNER JOIN dbo.MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
                  INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                      AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                  INNER JOIN dbo.MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador
                                                     AND PG.IdProveedorCliente = PE.IdProveedorCompras
                  INNER JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
                  INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PE.IdMoneda
                  LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                  LEFT JOIN dbo.FI_Factura AS fi ON fi.IdFactura = AF.IdFactura
             WHERE O.IdTipoOperacion = 10
                   AND PE.IdProveedorCompras = @IdProveedor
                   AND O.IdEstatusOperacion = 1 -- en Aprobacion

                   AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                   AND AF.IdAceptacionPedido = @IdAceptacionPedido
         )
             BEGIN
                 INSERT INTO @TablaFacturasEnAprobacion
                 (IdAceptacionPedido, 
                  IdFacturaPetrov, 
                  IdPedidoGral, 
                  IdPedido, 
                  FechaCarga, 
                  Proveedor, 
                  Estatus, 
                  TipoPedido, 
                  TotalPedido, 
                  Moneda, 
                  RFC, 
                  UUID, 
                  IdSolicitudPedido, 
                  IdOperacion
                 )
                        SELECT AF.IdAceptacionPedido, 
                               AF.IdFactura, 
                               PG.IdPedido AS IdPedidoGral, 
                               PE.IdPedido, 
                               O.FechaRegistro, 
                               PR.RazonSocial+' '+ISNULL(PR.RegimenCapital, '') AS Proveedor, 
                               E.Nombre, 
                               TP.TipoPedido, 
                               SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido, 
                               TM.TipoMonedaCorto AS Moneda, 
                               PR.RFC, 
                               fi.UUID, 
                               PE.IdSolicitudPedido, 
                               O.IdOperacion
                        FROM dbo.MM_AceptacionFactura AS AF
                             INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                             INNER JOIN dbo.TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
                             INNER JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                             INNER JOIN dbo.MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
                                                               AND PE.IdSubcontratista = O.IdProveedor
                             INNER JOIN dbo.MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido
                             INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                                 AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                             INNER JOIN dbo.MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador
                                                                AND PG.IdProveedorCliente = PE.IdProveedorCompras
                             INNER JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
                             INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda = PE.IdMoneda
                             LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
                             LEFT JOIN dbo.FI_Factura AS fi ON fi.IdFactura = AF.IdFactura
                        WHERE O.IdTipoOperacion = 10
                              AND PE.IdProveedorCompras = @IdProveedor
                              AND O.IdEstatusOperacion = 1 -- en Aprobacion

                              AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
                              AND AF.IdAceptacionPedido = @IdAceptacionPedido
                        GROUP BY AF.IdAceptacionPedido, 
                                 AF.IdFactura, 
                                 PE.IdPedido, 
                                 O.FechaRegistro, 
                                 PR.RazonSocial, 
                                 PR.RegimenCapital, 
                                 E.Nombre, 
                                 PG.IdPedido, 
                                 TP.TipoPedido, 
                                 TM.TipoMonedaCorto, 
                                 PR.RFC, 
                                 PE.IdSolicitudPedido, 
                                 E.IdEstatus, 
                                 fi.UUID, 
                                 O.IdOperacion
                        ORDER BY AF.IdAceptacionPedido DESC;

                 --se asigna el idfactura de adinco si es que tiene

                 UPDATE t
                   SET 
                       t.IdFacturaAdinco = f.IdFactura
                 FROM @TablaFacturasEnAprobacion t
                      LEFT JOIN Adinco.dbo.FI_Factura f ON f.UUID COLLATE DATABASE_DEFAULT = t.UUID;
                 DELETE @TablaFacturasEnAprobacion
                 WHERE IdFacturaPetrov IS NULL
                       OR IdFacturaAdinco IS NULL;

                 -- ya que se sabe cuales son las facturas que estan en Adinco entonces hay que hacer la relacion

                 INSERT INTO Adinco.dbo.FI_FacturaAdincoPetrovendor
                 (IdFacturaPetrovendor, 
                  IdFacturaAdinco, 
                  FechaIntercambio, 
                  Activo
                 )
                        SELECT IdFacturaPetrov, 
                               IdFacturaAdinco, 
                               GETDATE(), 
                               1
                        FROM @TablaFacturasEnAprobacion
                        WHERE IdFacturaAdinco IS NOT NULL
                              AND IdFacturaPetrov IS NOT NULL;

                 -- aprobar las facturas del lado de petrovendor
                 -- se aprueba la Tarea Aprobadores

                 UPDATE T
                   SET 
                       T.IdEstatus = 2, 
                       T.FechaCambioEstatus = GETDATE(), 
                       T.Comentario = 'Proceso Adinco esta factura se encuentra cargada en Adinco'
                 FROM dbo.MM_AceptacionFactura AS AF
                      INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                                                          AND O.IdTipoOperacion = 10
                      INNER JOIN dbo.TA_Tarea T ON T.IdOperacion = O.IdOperacion
                      INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = AF.IdAceptacionPedido
                      INNER JOIN @TablaFacturasEnAprobacion filtro ON filtro.IdAceptacionPedido = AF.IdAceptacionPedido -- filtro de solo las facturas que se encuentran en Adinco

                 WHERE ap.IdProveedor = @IdProveedor
                       AND filtro.IdAceptacionPedido = @IdAceptacionPedido;

                 -- se agrega al historial

                 INSERT INTO dbo.TA_HistorialFlujoTarea
                 (IdOperacion, 
                  Fecha, 
                  Descripcion, 
                  IdEstadoFlujo
                 )
                        SELECT O.IdOperacion, 
                               GETDATE(), 
                               CONCAT(ISNULL(@NombreUsuario, ''), ' y Proceso Adinco ha Aprobado la Tarea.'), 
                               2
                        FROM dbo.MM_AceptacionFactura AS AF
                             INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                                                                 AND O.IdTipoOperacion = 10
                             INNER JOIN dbo.TA_Tarea T ON T.IdOperacion = O.IdOperacion
                             INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = AF.IdAceptacionPedido
                             INNER JOIN @TablaFacturasEnAprobacion filtro ON filtro.IdAceptacionPedido = AF.IdAceptacionPedido -- filtro de solo las facturas que se encuentran en Adinco

                        WHERE ap.IdProveedor = @IdProveedor
                              AND filtro.IdAceptacionPedido = @IdAceptacionPedido;

                 --se actualiza el estatus general

                 UPDATE O
                   SET 
                       O.IdEstatusOperacion = 2, 
                       O.IdEstadoFlujo = 3, 
                       O.FechaModificacion = GETDATE()
                 FROM dbo.MM_AceptacionFactura AS AF
                      INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                                                          AND O.IdTipoOperacion = 10
                      INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = AF.IdAceptacionPedido
                      INNER JOIN @TablaFacturasEnAprobacion filtro ON filtro.IdAceptacionPedido = AF.IdAceptacionPedido -- filtro de solo las facturas que se encuentran en Adinco

                 WHERE ap.IdProveedor = @IdProveedor
                       AND filtro.IdAceptacionPedido = @IdAceptacionPedido;

                 -- se agrega al historial la finalizacion de la aprobacion

                 INSERT INTO dbo.TA_HistorialFlujoTarea
                 (IdOperacion, 
                  Fecha, 
                  Descripcion, 
                  IdEstadoFlujo
                 )
                        SELECT O.IdOperacion, 
                               GETDATE(), 
                               'Se ha Finalizado la aprobación de la Factura  ', 
                               7
                        FROM dbo.MM_AceptacionFactura AS AF
                             INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                                                                 AND O.IdTipoOperacion = 10
                             INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = AF.IdAceptacionPedido
                             INNER JOIN @TablaFacturasEnAprobacion filtro ON filtro.IdAceptacionPedido = AF.IdAceptacionPedido -- filtro de solo las facturas que se encuentran en Adinco

                        WHERE ap.IdProveedor = @IdProveedor
                              AND filtro.IdAceptacionPedido = @IdAceptacionPedido;

                 --se actualiza el estado de los documentos

                 UPDATE AF
                   SET 
                       AF.IdEstatusXML = 3, 
                       AF.IdEstatusPDF = 3
                 FROM dbo.MM_AceptacionFactura AS AF
                      INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura
                                                          AND O.IdTipoOperacion = 10
                      INNER JOIN dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = AF.IdAceptacionPedido
                      INNER JOIN @TablaFacturasEnAprobacion filtro ON filtro.IdAceptacionPedido = AF.IdAceptacionPedido -- filtro de solo las facturas que se encuentran en Adinco

                 WHERE ap.IdProveedor = @IdProveedor
                       AND filtro.IdAceptacionPedido = @IdAceptacionPedido;
                 SELECT @IdFacturaPetrov = IdFactura
                 FROM dbo.MM_AceptacionFactura
                 WHERE IdAceptacionPedido = @IdAceptacionPedido;
                 IF NOT EXISTS
                 (
                     SELECT 1
                     FROM dbo.CO_Registro
                     WHERE IdFactura = @IdFacturaPetrov
                 )
                     BEGIN

                         -- Se guarda el gasto

                         INSERT INTO dbo.CO_Registro
                         (IdFactura, 
                          MontoRegistro, 
                          InicioEjecucion, 
                          FinEjecucion, 
                          Comentarios, 
                          MesPresentacion, 
                          IdUsuarioCreadoPor, 
                          FecMovto, 
                          IdInstalacion, 
                          CreadoPor, 
                          IdCatalogoCuentasSH, 
                          CentroCostos, 
                          CuentaContable, 
                          IdLineaPresupuestoMes, 
                          Poliza, 
                          CostosAtribuiblesAdministracion, 
                          PCN, 
                          IdGastoRubro, 
                          IdCBSISH, 
                          IdAceptacionPedidoDetalle
                         )
                                SELECT af.IdFactura, 
                                       pd.PrecioUnitario * APDI.Cantidad, 
                                       p.FechaRecepcionServicio, 
                                       ap.Creado, 
                                       CONCAT(pod.MaterialCotizadoTextoC, ' - ', i.NombreInstalacion COLLATE Modern_Spanish_CI_AS), 
                                       DATEADD(MONTH, DATEDIFF(MONTH, 0, p.FechaRecepcionServicio), 0), 
                                       @IdUsuario, 
                                       GETDATE(), 
                                       APDI.IdInstalacion, 
                                       @IdUsuario, 
                                       NULL, 
                                       spdlp.IdCentroCosto, 
                                       NULL, 
                                       APDI.IdLineaPresupuesto, 
                                       NULL, 
                                       0, 
                                       apd.PCN, 
                                       apd.ClasificacionCN, 
                                       vp.IdCatalogoHidrocarburos, 
                                       apd.IdAceptacionPedidoDetalle
                                FROM dbo.MM_AceptacionPedido ap
                                     INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
                                     INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
                                     INNER JOIN dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
                                     INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
                                     INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
                                     LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI ON APDI.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
                                     INNER JOIN Adinco.dbo.CO_Instalacion i ON i.IdInstalacion = APDI.IdInstalacion
                                     LEFT JOIN dbo.MM_PCN_ValoresPesos vp ON vp.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
                                     INNER JOIN dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = ap.IdAceptacionPedido
                                WHERE ap.IdAceptacionPedido = @IdAceptacionPedido;
                     END;
                 SELECT @IdFacturaPetrov = IdFacturaPetrov, 
                        @IdFacturaAdinco = IdFacturaAdinco
                 FROM @TablaFacturasEnAprobacion;
                 EXEC dbo.MM_SP_EnvioDeGastoAdinco 
                      @idFacturaP = @IdFacturaPetrov, 
                      @IdFacturaAdinco = @IdFacturaAdinco;
             END;
             ELSE
             BEGIN
                 RAISERROR('Esta factura ya no se encuentra en aprobación, tiene otro estatus o la consulta del sp sp_FacturaRelacionaryAprobar no devuelve resultados', 16, 1);
             END;
     END;