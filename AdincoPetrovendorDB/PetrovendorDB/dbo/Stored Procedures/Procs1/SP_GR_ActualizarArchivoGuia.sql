-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11-02-18>
-- Description:	<Actualiza el archivo ppsx>
-- =============================================
CREATE PROCEDURE SP_GR_ActualizarArchivoGuia
@Archivo IMAGE,
@IdGuia INT,

@Contrato INT = NULL,
@Usuario INT = NULL ,
@FechaRegistro DATETIME = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.GuiasRapidas
	SET
    Archivo = @Archivo
	WHERE IdGuiaRapida = @IdGuia
	
	SELECT 'ACTUALIZADO'

END
