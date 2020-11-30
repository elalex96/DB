CREATE PROCEDURE [dbo].[sp_EliminarRelacionProveedorSubcontratista] (@idRelacion INT)
AS
BEGIN
    DELETE dbo.PV_RelacionProveedorSubcotratista
    WHERE IdRelacion = @idRelacion
END
