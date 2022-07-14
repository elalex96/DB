CREATE PROCEDURE [dbo].[SP_EPT_PresupuestosRelacionadosEPTDetalle]
    @IdEPTDetalle INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT EPT_ImportacionLayoutDetallePresupuestos.Id,
           CONCAT(
                     EPT_ImportacionLayoutDetallePresupuestos.Presupuesto,
                     ' - [',
                     CO_Presupuesto.IdPresupuestoCNH,
                     ' - ',
                     CO_Presupuesto.Nombre,
                     ']'
                 ) AS Presupuesto,
           CASE
               WHEN EPT_ImportacionLayoutDetallePresupuestos.Activo = 1 THEN
                   'Activo'
               ELSE
                   'Inactivo'
           END AS Activo
    FROM EPT_ImportacionLayoutDetallePresupuestos
        JOIN CO_Presupuesto
            ON EPT_ImportacionLayoutDetallePresupuestos.ImportacionLayoutDetalleId = @IdEPTDetalle
               AND EPT_ImportacionLayoutDetallePresupuestos.PresupuestoId = CO_Presupuesto.IdPresupuesto
END;