-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_S_ValidarCodigoVerificacion]
@Correo NVARCHAR(100),
@Codigo NVARCHAR(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    IF EXISTS
	(
		SELECT IdSolicitudRegistroCuenta FROM dbo.S_AutentificacionNuevoRegistro WHERE Correo = @Correo AND CodigoVerificacion = @Codigo
	)
	BEGIN
	DECLARE @IdSolicitudRegistroCuenta INT = (SELECT IdSolicitudRegistroCuenta FROM dbo.S_AutentificacionNuevoRegistro WHERE Correo = @Correo AND CodigoVerificacion = @Codigo)
	DECLARE @FechaRegistro DATETIME = (SELECT FechaRegistro FROM dbo.S_AutentificacionNuevoRegistro WHERE Correo = @Correo AND CodigoVerificacion = @Codigo)

	IF( (SELECT DATEDIFF(MINUTE,@FechaRegistro,GETDATE())) <= 15 )
		BEGIN
		    DECLARE @IsActivo BIT = (SELECT Activo FROM dbo.S_AutentificacionNuevoRegistro WHERE IdSolicitudRegistroCuenta = @IdSolicitudRegistroCuenta)
			IF ( @IsActivo = 1)
			BEGIN
			    UPDATE dbo.S_AutentificacionNuevoRegistro SET Activo = 0 WHERE IdSolicitudRegistroCuenta = @IdSolicitudRegistroCuenta
				SELECT 'VERIFICADO'
			END
				
			ELSE
				SELECT 'USADO' 
		END
		ELSE
		BEGIN
			SELECT 'EXPIRADO'
		END	    
	END
	ELSE
	BEGIN
	    SELECT 'NO_ENCONTRADO'
	END

END
