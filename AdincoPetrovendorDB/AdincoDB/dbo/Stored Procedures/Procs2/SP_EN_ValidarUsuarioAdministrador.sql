USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_ValidarUsuarioAdministrador]    Script Date: 25/01/2022 03:45:47 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/01/2022
-- Description:	Validar si el usuario que va reiniciar es admin
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ValidarUsuarioAdministrador]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IsAdmin INT;

	SELECT @IsAdmin = COUNT(1)
    FROM dbo.AP_PerfilUsuario PU
        JOIN dbo.AP_Perfil P
            ON PU.PerfilID = P.IdPerfil
        JOIN dbo.AP_Rol R
            ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato = @idContrato
          AND (R.Rol LIKE '%Admin%' OR R.ROL LIKE '%SASISOPA%SHELL%');

	IF ISNULL(@IsAdmin,0) > 0
	BEGIN
		--ES USUARIO ADMINISTRADOR
		SELECT 1 AS ISADMIN

	END
	ELSE
	BEGIN 
		--NO ES ADMINISTRADOR
		SELECT 0 AS ISADMIN

	END

END