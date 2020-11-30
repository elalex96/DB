CREATE VIEW [dbo].[ReporteProcesoDEA_PEDIDO_Tableau]
AS
     SELECT IdSolicitudPedido AS No_Solicitud_Pedido, 
            CentroCosto AS Centro_Costo, 
            Requisitor, 
            FechaRegistro AS Fecha_Registro, 
            FechaAccion AS Fecha_Accion, 
            Usuario, 
            Accion, 
            Estatus, 
            Tiempo
     FROM dbo.ProcesoDEA_Pedidos_Tableau;
