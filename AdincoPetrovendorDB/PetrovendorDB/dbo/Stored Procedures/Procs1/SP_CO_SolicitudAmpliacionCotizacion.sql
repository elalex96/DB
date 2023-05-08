-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/05/2018
-- Description:	Guardado de la justificacion del la solicitud del provedor para cambiar el plazo de cotizacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_SolicitudAmpliacionCotizacion] 
	-- Add the parameters for the stored procedure here
	
	@IdPeticionOferta INT,
	@IdProveedor INT,
	@Justificacion NVARCHAR(MAX),

	/*--------------------
    parametros contrato
  --------------------*/
    @IdContrato INT = null,
    @IdUsuario INT = null,
    @FechaRegistro DATETIME = null
/*--------------------
  --------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MM_PeticionOferta
		SET JustificacionAmplicacion = @Justificacion,
			AmpliacionPor = @IdProveedor
	WHERE IdPeticionOferta = @IdPeticionOferta
	
	SELECT @IdPeticionOferta
END
