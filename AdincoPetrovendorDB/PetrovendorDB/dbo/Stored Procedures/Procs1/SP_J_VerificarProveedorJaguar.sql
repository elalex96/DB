-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11/05/2020>
-- Description:	<Verifica si el proveedor logueado es Jaguar>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/11/2020>
-- Description:	<Se actualiza a una nueva tabla actualizada con los contratos de jaguar>
-- =============================================
CREATE PROCEDURE [dbo].[SP_J_VerificarProveedorJaguar]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS
	(
		SELECT IdOperadora FROM dbo.CO_CONTRATOSJAGUAR WHERE IdOperadora = @IdProveedor AND Activo = 1
	)
	BEGIN
		SELECT 'JAGUAR'
	END
	ELSE
		SELECT 'DEFAULT'


END
