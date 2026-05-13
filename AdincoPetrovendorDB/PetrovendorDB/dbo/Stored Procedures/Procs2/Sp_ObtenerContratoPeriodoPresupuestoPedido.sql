

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 12/06/2019
-- Description:	Obtner el contrato de la solped y el periodo y presupuesto
-- =============================================

CREATE PROCEDURE Sp_ObtenerContratoPeriodoPresupuestoPedido
    @IdPedido INT, @IdProveedor INT
AS
    BEGIN
        SELECT
                sp.IdContrato, sp.IdPeriodo, sp.IdPresupuesto, per.NombrePeriodo, pre.Nombre
        FROM
                dbo.MM_Pedidos         ps
            INNER JOIN
                dbo.MM_Pedido          p
                    ON ps.IdIdentificador = p.IdPedido
                       AND p.IdProveedorCompras = @IdProveedor
            INNER JOIN
                dbo.MM_PedidoDetalle   pd
                    ON pd.IdPedido = p.IdPedido
            INNER JOIN
                dbo.MM_SolicitudPedido sp
                    ON sp.IdSolicitudPedido = p.IdSolicitudPedido
                       AND sp.IdProveedor = @IdProveedor
			LEFT JOIN Adinco.dbo.CO_PeriodoContrato per ON per.IdPeriodo = sp.IdPeriodo
			LEFT JOIN Adinco.dbo.CO_Presupuesto pre ON pre.IdPresupuesto = sp.IdPresupuesto
        WHERE
                ps.IdPedido = @IdPedido
    END