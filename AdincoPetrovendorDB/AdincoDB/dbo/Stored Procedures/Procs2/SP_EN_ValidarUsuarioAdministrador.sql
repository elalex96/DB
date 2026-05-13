-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/01/2022
-- Description:	Validar si el usuario que va reiniciar es admin
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ValidarUsuarioAdministrador]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdContrato INT,
	@IdInstanciaEntregable INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Admins INT;
	DECLARE @Aprobadors INT;
	DECLARE @EsAdmin BIT = 0;
	DECLARE @EsAprobador BIT = 0;

	--BUSQUEDA DE PERMISOS DE ADMINISTRADOR
	SELECT 
		@Admins = COUNT(1)
    FROM dbo.AP_PerfilUsuario PU
        JOIN dbo.AP_Perfil P
            ON PU.PerfilID = P.IdPerfil
        JOIN dbo.AP_Rol R
            ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato = @idContrato
          AND (R.Rol LIKE '%Admin%' OR R.ROL LIKE '%SASISOPA%SHELL%');

	--BUSQUEDA DE PERMISOS DE APROBADOR
	SELECT
          @Aprobadors = CASE ISNULL(EXAR.idUsuario, 0)
						   WHEN 0 THEN A.idUsuario
						   ELSE EXAR.idUsuario
					  END
    FROM dbo.EN_InstanciasEntregable I
        JOIN dbo.EN_Actividad A
            ON I.ActividadID = A.ActividadID
        LEFT JOIN dbo.EN_ExcepcionesActividad EXAR
            ON A.ActividadID = EXAR.ActividadIDExcepcion
               AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables
    WHERE idInstanciaEntregable = @IdInstanciaEntregable;

	IF ISNULL(@Admins,0) > 0
	BEGIN
		--ES USUARIO ADMINISTRADOR
		SET @EsAdmin = 1;

	END;

	IF ISNULL(@Aprobadors,0) > 0
	BEGIN

		IF (@Aprobadors = @IdUsuario)
		BEGIN
			
			--ES USUARIO APROBADOR
			SET @EsAprobador = 1;

		END;

	END;

	SELECT 
		@EsAdmin AS EsAdmin,
		@EsAprobador AS EsAprobador;

END