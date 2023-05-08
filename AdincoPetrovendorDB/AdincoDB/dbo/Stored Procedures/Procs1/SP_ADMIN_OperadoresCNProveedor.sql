-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/06/2021>
-- Description:	<Consulta para verificar las operadores que pueden generar carta CN DE PROVEEDOR A PROVEEDOR>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADMIN_OperadoresCNProveedor]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		IdProveedor,
		RFC,
		Observaciones,
		Activo
	FROM dbo.DEA_Proveedor
	--WHERE Activo = 1

END