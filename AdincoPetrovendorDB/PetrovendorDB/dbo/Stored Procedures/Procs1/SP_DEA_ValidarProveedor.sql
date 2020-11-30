
-- =============================================
CREATE PROCEDURE SP_DEA_ValidarProveedor
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int
	
AS
BEGIN
	
	DECLARE @RFC_ACTUAL NVARCHAR(MAX)
	SELECT @RFC_ACTUAL=RFC FROM dbo.S_Proveedor WHERE IdProveedor=@IdProveedor 

	DECLARE @EXISTE_RFC INT = (SELECT COUNT(IdProveedor) FROM DEA_Proveedor WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) AND Activo=1)

	IF ISNULL(@EXISTE_RFC,0)  >0 
	BEGIN 
		SELECT 'CAMBIAR_PROCESO'
	END 
	ELSE 
	BEGIN 
		SELECT 'SEGUIR_PROCESO'
	END 

END
