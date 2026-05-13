CREATE FUNCTION dbo.fnGetPedidoAprobadores
(
	@pIdOperacion INT,
	@pIdEstatus	INT
)
RETURNS varchar(350)
AS
BEGIN
	DECLARE @Aprobadores VARCHAR (2000) = ''

	SELECT @Aprobadores = @Aprobadores + RTRIM(LTRIM(U.Nombre)) + ', '
	FROM dbo.TA_Tarea AS TA (NOLOCK)
		 JOIN dbo.S_Usuario AS U  (NOLOCK)
		 ON U.IdUsuario = TA.IdAprobador
		 AND TA.idoperacion = @pIdOperacion
		 AND TA.IdEstatus	=	@pIdEstatus
	ORDER BY TA.NoSecuencia

	RETURN ISNULL(SUBSTRING(@Aprobadores,1,LEN(@Aprobadores)-1),'')
END