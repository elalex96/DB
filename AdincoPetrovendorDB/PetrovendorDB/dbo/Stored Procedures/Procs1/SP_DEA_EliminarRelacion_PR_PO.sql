
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/08/2019>
-- Description:	<Eliminar relacion PR - PO>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_EliminarRelacion_PR_PO]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@ID_R_PR_PO INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE dbo.DEA_Relacion_PR_PO
	WHERE ID_R_PR_PO = @ID_R_PR_PO

END
