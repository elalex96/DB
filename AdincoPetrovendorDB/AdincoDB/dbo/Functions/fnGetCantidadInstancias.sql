CREATE FUNCTION [dbo].[fnGetCantidadInstancias]
(
	@IdContratoEntregable INT
)
RETURNS INT
AS
BEGIN
	DECLARE @Cantidad INT

	SELECT @Cantidad = COUNT(1)
	FROM
		EN_InstanciasEntregable (NOLOCK)
	WHERE
		IdContratoEntregable = @IdContratoEntregable
		AND
		Activo = 1

	RETURN @Cantidad
END