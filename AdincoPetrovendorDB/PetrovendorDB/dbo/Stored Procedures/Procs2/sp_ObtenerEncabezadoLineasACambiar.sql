-- =============================================
-- Author:		Pedro Acuña
-- Create date: 22-08-2019
-- Description:	Obtener la informacion de la solped para mostrarla en el encabezado
-- =============================================

CREATE PROCEDURE sp_ObtenerEncabezadoLineasACambiar @IdSolicitudPedido INT
AS
BEGIN
    SELECT sp.IdSolicitudPedido,
           sp.IdContrato,
           sp.IdProveedor,
           p.IdPeriodo,
           sp.IdPresupuesto,
           p.NombrePeriodo,
           pr.Nombre,
           prov.RazonSocial,
           con.NumeroContrato
    FROM dbo.MM_SolicitudPedido sp
        inner JOIN Adinco.dbo.CO_PeriodoContrato p
            ON sp.IdPeriodo = p.IdPeriodo
        inner JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = sp.IdProveedor
        inner JOIN Adinco.dbo.CO_Presupuesto pr
            ON pr.IdPresupuesto = sp.IdPresupuesto
        inner JOIN Adinco.dbo.CO_Contrato con
            ON con.IdContrato = sp.IdContrato
    WHERE sp.IdSolicitudPedido = @IdSolicitudPedido
END

