
-- =============================
-- Author:		Jose Roman
-- Create date: 08-11-2018
-- Description: Funcion para obtener el total de una aceptacion
-- =============================================
CREATE FUNCTION FN_AprobadoresPorFactura
(
	@IdAceptacionFactura INT
)
RETURNS NVARCHAR(3000)
AS
BEGIN
	DECLARE @Aprobadores NVARCHAR(3000),
			@Nombre NVARCHAR(3000)

	SELECT @Aprobadores = COALESCE(@Aprobadores + ', ', '') + u.Nombre
	FROM dbo.MM_AceptacionFactura af
	INNER JOIN dbo.TA_Operacion o ON o.IdDocumento = af.IdAceptacionFactura AND o.IdTipoOperacion = 10
	INNER JOIN dbo.TA_Tarea t ON t.IdOperacion = o.IdOperacion
	INNER JOIN dbo.S_Usuario u ON u.IdUsuario = t.IdAprobador
	WHERE af.IdAceptacionFactura = @IdAceptacionFactura
	
	RETURN @Aprobadores
END
