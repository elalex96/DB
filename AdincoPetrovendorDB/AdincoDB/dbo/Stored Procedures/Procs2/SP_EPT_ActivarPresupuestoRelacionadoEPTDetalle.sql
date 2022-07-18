CREATE PROCEDURE [dbo].[SP_EPT_ActivarPresupuestoRelacionadoEPTDetalle]
    @Id INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;   
    UPDATE EPT_ImportacionLayoutDetallePresupuestos
    SET Activo = 1, ModificadoEn = GETDATE(), ModificadoPor = @IdUsuario
    WHERE Id = @Id
END;