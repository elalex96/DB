-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/02/2020>
-- Description:	<Consulta de la configuracion del grid guardada por usuario>
-- =============================================
create PROCEDURE [dbo].[SP_MM_RestaurarConfigUsuarioGird] 
	-- Add the parameters for the stored procedure here
	@IdNombreGrid VARCHAR(MAX), 
    @CountColumns INT, 
    @IdContrato   INT, 
    @IdUsuario    INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CANTIDADCOLUMNAS INT;

	IF EXISTS (SELECT * FROM dbo.AP_ConfiguracionGrids WHERE IdUsuario = @IdUsuario AND IdNombreGrid = @IdNombreGrid)
	BEGIN
	    
		SELECT @CANTIDADCOLUMNAS = ISNULL(CantidadColumnas,0)
		FROM dbo.AP_ConfiguracionGrids 
		WHERE IdUsuario = @IdUsuario
			AND IdNombreGrid = @IdNombreGrid;

			IF(@CountColumns <> @CANTIDADCOLUMNAS)
			BEGIN
			    
				DELETE FROM dbo.AP_ConfiguracionGrids
				WHERE IdUsuario = @IdUsuario
					AND IdNombreGrid = @IdNombreGrid;

			END
			ELSE
			BEGIN
			    
				SELECT
					Configuracion
				FROM dbo.AP_ConfiguracionGrids
				WHERE IdUsuario = @IdUsuario
					AND IdNombreGrid = @IdNombreGrid;

			END

	END

END
