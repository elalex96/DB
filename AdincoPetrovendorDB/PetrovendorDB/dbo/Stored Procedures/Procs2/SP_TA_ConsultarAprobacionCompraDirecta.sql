CREATE PROCEDURE SP_TA_ConsultarAprobacionCompraDirecta @IdOperacion INT
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT O.IdOperacion, 
                O.IdDocumento, 
                U.Nombre, 
                O.IdEstatusOperacion, 
                O.IdFlujoTarea, 
                E.Nombre, 
                T.IdEstatus, 
                O.FechaRegistro, 
                O.Descripcion, 
                PG.IdPedido AS IdPedidoGeneral, 
                f.Moneda
         FROM TA_Operacion AS O
              INNER JOIN S_Proveedor AS P ON P.IdProveedor = O.IdProveedor
              INNER JOIN S_UsuarioProveedor AS US ON US.IdProveedor = P.IdProveedor
              INNER JOIN S_Usuario AS U ON U.IdUsuario = O.IdAsignador
              INNER JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador = O.IdDocumento
                                              AND PG.IdTipoPedido = 1
                                              AND O.IdProveedor = PG.IdProveedorCliente
              INNER JOIN dbo.TA_Tarea T ON T.IdOperacion = O.IdOperacion
              INNER JOIN TA_Estatus AS E ON E.IdEstatus = T.IdEstatus
              INNER JOIN dbo.FI_Factura AS f ON f.IdFactura = pg.IdIdentificador
         WHERE O.IdOperacion = @IdOperacion
         GROUP BY O.IdOperacion, 
                  O.IdDocumento, 
                  U.Nombre, 
                  O.IdEstatusOperacion, 
                  O.IdFlujoTarea, 
                  E.Nombre, 
                  t.IdEstatus, 
                  O.FechaRegistro, 
                  O.Descripcion, 
                  PG.IdPedido, 
                  f.Moneda;
     END;