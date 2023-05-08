/****** Object:  StoredProcedure [dbo].[SP_EN_VerificacionOpcionesEquinor]    Script Date: 30/03/2021 12:22:51 p. m. ******/
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/02/2021>
-- Description:	<Verificacion de usuario equinor y admin para visualizar opciones de SubeHistorico.aspx(ISSUE 140 - ENTREGABLES)>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_VerificacionOpcionesEquinor]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Contratos TABLE (IdContrato INT);
	DECLARE @IsEquinor BIT = 0;
	--DECLARE @RolUsuario INT = ();

    -- Insert statements for procedure here
	INSERT INTO @Contratos (IdContrato) VALUES (3);--MEXICO PRUEBAS DEV
	INSERT INTO @Contratos
	SELECT
		CON.IdContrato
	FROM dbo.CO_Contrato AS CON
	JOIN dbo.CO_Contratista AS CI
		ON CON.IdContratista = CI.IdContratista
	WHERE CI.RFC = 'SEM150122M86'--EQUINOR

	IF EXISTS (SELECT * FROM @Contratos WHERE IdContrato = @IdContrato)
	BEGIN

		IF EXISTS (SELECT
					PU.UsuarioID
					FROM dbo.AP_PerfilUsuario AS PU
						JOIN dbo.AP_Perfil AS P 
							ON PU.PerfilID = P.IdPerfil
						JOIN dbo.AP_Rol AS R
							ON P.IdRol = R.IdRol
					WHERE PU.UsuarioID = @IdUsuario
						AND P.IdContrato = @IdContrato
						AND R.Rol LIKE '%Administra%Entregables%'
										
					)
		BEGIN

			SET @IsEquinor = 1;

		END

	END

	SELECT @IsEquinor;

END
