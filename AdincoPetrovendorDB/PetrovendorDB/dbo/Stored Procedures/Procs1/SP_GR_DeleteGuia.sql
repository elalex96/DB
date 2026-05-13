-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11-02-2018>
-- Description:	<Elimina las guias rapidas>
-- =============================================
CREATE PROCEDURE SP_GR_DeleteGuia
@IdGuiaRapida INT,

@Contrato INT = NULL,
@Usuario INT = NULL ,
@FechaRegistro DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.GuiasRapidas SET Activo = 0 
	WHERE IdGuiaRapida = @IdGuiaRapida

	SELECT 'ELIMINADO'

END
