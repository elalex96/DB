-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <12/02/2018>
-- Description:	<Valida si el material del catalogo maestro tiene materiales relacionados con el>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidarSiTieneRelacion]
@IdMaterial INT,

@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IsAsociado INT = 
	(
		SELECT COUNT(M.IdMaterial)
		FROM dbo.MM_Material M
		INNER JOIN dbo.MM_Maestro MA
		ON MA.IdMaestro = M.IdMaestro
		WHERE MA.IdMaestro = @IdMaterial
	)

	IF(@IsAsociado > 0)
	BEGIN	
		SELECT 'MATERIAL_ASOCIADO'
	END
	ELSE
	BEGIN
		SELECT 'SIN_RELACION'
	END 

END
