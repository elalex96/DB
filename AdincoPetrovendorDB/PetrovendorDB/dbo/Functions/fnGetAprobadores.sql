CREATE FUNCTION dbo.fnGetAprobadores
(
	@pIdOperacion INT
)
RETURNS varchar(350)
AS
BEGIN
	DECLARE @Aprobadores VARCHAR (2000) = '',
	@Secuencia INT

	SELECT @Aprobadores = @Aprobadores + RTRIM(LTRIM(ISNULL(U.Nombre,''))) + ', ',
		@Secuencia = TA.NoSecuencia
	FROM dbo.TA_Tarea AS TA (NOLOCK)
		 JOIN dbo.S_Usuario AS U  (NOLOCK)
		 ON U.IdUsuario = TA.IdAprobador
		 AND TA.idoperacion = @pIdOperacion
		 AND TA.Activo	=	1
	GROUP BY
		RTRIM(LTRIM(ISNULL(U.Nombre,''))),
		TA.NoSecuencia
	ORDER BY TA.NoSecuencia

	IF LEN(@Aprobadores) <= 2
		SELECT @Aprobadores = '    '

	RETURN ISNULL(SUBSTRING(@Aprobadores,1,LEN(@Aprobadores)-1),'')

END