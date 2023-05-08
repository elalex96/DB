-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_InsertarVersionIteracion]
	-- Add the parameters for the stored procedure here
	@version NVARCHAR(MAX),
	@modulo NVARCHAR(MAX),
	@icono NVARCHAR(MAX),
	@versionactual BIT,
	@aplicacion NVARCHAR(MAX),
	@tipoactualizacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.RegistroIteraciones
	(
	    VersionIteracion,
	    Modulo,
	    IconoModulo,
	    FechaRegistro,
	    VersionActual,
		Aplicacion,
		TipoActualizacion
	)
	VALUES
	(   @version,       -- VersionIteracion - nvarchar(50)
	    @modulo,       -- Modulo - nvarchar(max)
	    @icono,       -- IconoModulo - nvarchar(max)
	    GETDATE(), -- FechaRegistro - datetime
	    @versionactual,       -- VersionActual - bit
	    @aplicacion,
		@tipoactualizacion
		)

		SELECT @@IDENTITY
END
