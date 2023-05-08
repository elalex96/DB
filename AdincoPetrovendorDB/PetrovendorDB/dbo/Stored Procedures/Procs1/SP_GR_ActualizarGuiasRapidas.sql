-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11-02-2018>
-- Description:	<Actualiza las guias rapidas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GR_ActualizarGuiasRapidas]
@IdGuiaRapida INT,
@NombreGuia NVARCHAR(300),
@Modulo NVARCHAR(MAX),
@Plataforma NVARCHAR(MAX),

@Contrato INT = NULL,
@Usuario INT = NULL ,
@FechaRegistro DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NombreActual NVARCHAR(300) = (SELECT NombreGuia FROM dbo.GuiasRapidas WHERE IdGuiaRapida =@IdGuiaRapida)

	DECLARE @tipo NVARCHAR(300) = RIGHT(@NombreGuia,4)

    IF(@tipo != 'ppsx' AND @tipo != 'pptx')
	BEGIN
		IF(@NombreGuia NOT LIKE  '%ppsx%')
		BEGIN
			SET @NombreGuia = @NombreGuia + '.' + RIGHT(@NombreActual,4)
		END
		ELSE IF (@NombreGuia NOT LIKE '%pptx%')
		BEGIN
			SET @NombreGuia = @NombreGuia + '.' + RIGHT(@NombreActual,4)
		END 
	END
    
	UPDATE dbo.GuiasRapidas
	SET
	NombreGuia = @NombreGuia,
	Modulo = @Modulo,
	Plataforma = @Plataforma
	WHERE IdGuiaRapida = @IdGuiaRapida

	SELECT 'ACTUALIZADO'

END
