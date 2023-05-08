
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/02/2020>
-- Description:	<Guardado de la configuracion del grid por usuario>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_GuardarConfiguracionGird]
	-- Add the parameters for the stored procedure here
	@IdNombreGrid  VARCHAR(MAX), 
    @Configuracion VARCHAR(MAX), 
    @CountColumns  INT, 
    @IdContrato    INT, 
    @IdUsuario     INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS (SELECT *  FROM dbo.AP_ConfiguracionGrids WHERE IdUsuario = @IdUsuario AND IdNombreGrid = @IdNombreGrid)
	BEGIN
	    
		UPDATE dbo.AP_ConfiguracionGrids
		SET Configuracion = @Configuracion
		WHERE IdUsuario = @IdUsuario
		 AND IdNombreGrid = @IdNombreGrid;

	END
	ELSE
	BEGIN
	    
		INSERT INTO dbo.AP_ConfiguracionGrids
		(
		    IdUsuario,
		    IdNombreGrid,
		    Configuracion,
		    CreadoEn,
		    CantidadColumnas
		)
		VALUES
		(   @IdUsuario,         -- IdUsuario - int
		    @IdNombreGrid,       -- IdNombreGrid - nvarchar(max)
		    @Configuracion,       -- Configuracion - nvarchar(max)
		    GETDATE(), -- CreadoEn - date
		    @CountColumns          -- CantidadColumnas - int
		    )

	END

	SELECT 'SUCCESS'

END
