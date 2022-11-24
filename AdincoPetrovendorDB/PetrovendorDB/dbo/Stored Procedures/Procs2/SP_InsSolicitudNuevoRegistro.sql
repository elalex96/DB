-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_InsSolicitudNuevoRegistro
@Correo NVARCHAR(100),
@Codigo NVARCHAR(50),
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbo.S_AutentificacionNuevoRegistro
	(
	    Correo,
	    CodigoVerificacion,
	    IdUsuario,
	    FechaRegistro,
		Activo
	)
	VALUES
	(   @Correo,      -- Correo - nvarchar(100)
	    @Codigo,      -- CodigoVerificacion - nvarchar(50)
	    @IdUsuario,        -- IdUsuario - int
	    GETDATE(), -- FechaRegistro - datetime,
		1
	)

	SELECT @@IDENTITY

END
