-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/10/2022
-- Description:	validacion del proveedor WDEA y Rol
-- =============================================
CREATE PROCEDURE SP_DEA_ValidarProveedorRol --907,2572
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RFC_ACTUAL NVARCHAR(200), @EXISTE_RFC INT, @USUARIO_EDITOR INT;

	set @RFC_ACTUAL = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor=@IdProveedor)
	set @EXISTE_RFC = (SELECT COUNT(IdProveedor) 
						FROM DEA_Proveedor 
						WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) 
						AND Activo = 1);

	SET @USUARIO_EDITOR = (SELECT TOP 1
								UR.S_RolUsuario
							FROM S_UsuarioRol AS UR
							JOIN S_Rol AS R
								ON UR.IdRol = R.IdRol
							WHERE R.Rol = 'Editor de Pedido'
							AND UR.IdUsuario = @IdUsuario
							AND Activo = 1);

	IF ISNULL(@EXISTE_RFC,0)  >0 
	BEGIN 

		IF ISNULL(@USUARIO_EDITOR,0) = 0
		BEGIN

			SELECT 'SEGUIR_PROCESO'

		END
		ELSE
		BEGIN

			SELECT 'CAMBIAR_PROCESO'

		END
	END 
	ELSE 
	BEGIN 

		SELECT 'SEGUIR_PROCESO'

	END
	
END
