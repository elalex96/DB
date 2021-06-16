-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/06/2021>
-- Description:	<Consulta para verificar las operadores que pueden generar carta CN DE PROVEEDOR A PROVEEDOR>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADMIN_UPD_OperadoresCNProveedor]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@RFC NVARCHAR(100),
	@Observaciones NVARCHAR(1000),
	@Activo BIT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.DEA_Proveedor
	SET RFC = @RFC,
		Observaciones =@Observaciones,
		Activo = @Activo
	WHERE IdProveedor = @IdProveedor;

END
