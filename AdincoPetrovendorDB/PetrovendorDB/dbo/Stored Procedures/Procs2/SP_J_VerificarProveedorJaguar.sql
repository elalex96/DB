-- =============================================
-- Author:		Alexander Gomez
-- Update:		09-08-2021
-- Description:	Validacion para operadora jaguar
-- =============================================
CREATE PROCEDURE [dbo].[SP_J_VerificarProveedorJaguar]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @RFCACTUAL NVARCHAR(100)= (SELECT TOP 1 RFC FROM S_Proveedor WHERE IdProveedor = @IdProveedor);

	IF EXISTS
	(
		SELECT IdProveedor FROM dbo.Jaguar_Proveedor WHERE RFC = @RFCACTUAL
		--select * from S_Proveedor where RazonSocial like '%Jaguar%' and IdProveedor = @IdProveedor
	)
	BEGIN
		SELECT 'JAGUAR'
	END
	ELSE
	begin
		SELECT 'DEFAULT'
	end

END