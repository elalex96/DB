CREATE PROCEDURE [dbo].[SP_EPT_DesActivarPresupuestoRelacionadoEPTDetalle]
    @Id INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;   
    UPDATE EPT_ImportacionLayoutDetallePresupuestos
    SET Activo = 0, ModificadoEn = GETDATE(), ModificadoPor = @IdUsuario
    WHERE Id = @Id
END;