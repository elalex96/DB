-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11/05/2020>
-- Description:	<Verifica si el proveedor logueado es Jaguar>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/11/2020>
-- Description:	<Se actualiza a una nueva tabla actualizada con los contratos de jaguar>
-- =============================================
create PROCEDURE [dbo].[SP_J_VerificarProveedorJaguar]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS
	(
		--SELECT IdProveedor FROM dbo.Jaguar_Proveedor WHERE IdProveedor = @IdProveedor AND Activo = 1
		select * from S_Proveedor where RazonSocial like '%Jaguar%' and IdProveedor = @IdProveedor
	)
	BEGIN
		SELECT 'JAGUAR'
	END
	ELSE
	begin
		SELECT 'DEFAULT'
	end

END
