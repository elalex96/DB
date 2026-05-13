-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_DG_ActualizarEmpresaRelacionada 
@IdRelacion INT,
@IdSubcontratista INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.PV_RelacionProveedorSubcotratista
	SET
	IdSubcontratista = @IdSubcontratista
	WHERE IdRelacion = @IdRelacion

END
