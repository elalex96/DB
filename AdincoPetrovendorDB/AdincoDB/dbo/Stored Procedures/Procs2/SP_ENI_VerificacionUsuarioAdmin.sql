USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_ENI_VerificacionUsuarioAdmin]    Script Date: 04/06/2021 01:34:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <02-06-2021>
-- Description:	<Verificar si el usuario logueado es admin>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_VerificacionUsuarioAdmin]
	-- Add the parameters for the stored procedure here
	@IdUsuario  INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ADMIN BIT = 0; 
	DECLARE @TIPOUSUARIO NVARCHAR(100) = (SELECT TOP 1 R.Rol
											FROM dbo.AP_Usuario AS US
											JOIN dbo.AP_PerfilUsuario AS PU ON US.UsuarioID = PU.UsuarioID
											JOIN dbo.AP_Perfil as P ON PU.PerfilID = P.IdPerfil
											JOIN dbo.AP_Rol AS R ON P.IdPerfil = R.IdRol
										WHERE US.UsuarioID = @IdUsuario AND P.IdContrato = @IdContrato);

	IF @TIPOUSUARIO <> 'Admon Contrato'
	BEGIN

		SET @ADMIN = 1;

	END

	SELECT @ADMIN;

END