-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/03/2022>
-- Description:	<Guardar fecha vigencia REPSE>
-- =============================================
CREATE PROCEDURE SP_DOC_AgregarFechaVigenciaREPSE 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@FechaVigenciaREPSE DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE S_Proveedor
	SET FechaVigenciaREPSE = @FechaVigenciaREPSE
	WHERE IdProveedor = @IdProveedor;

END
