CREATE PROC SP_EN_GuardaConjuncionPalabra
@Palabra varchar(500),
@Sustitucion varchar(200),
@IdUsuario int,
@Activo bit
AS
BEGIN
	IF EXISTS (SELECT 1 FROM EN_ConjuncionesDocumentos WHERE PALABRA = CONCAT(' ',@Palabra,' ') and Activo = 0)
	BEGIN
		UPDATE EN_ConjuncionesDocumentos
		set activo = 1,
		Sustitucion = LTRIM(RTRIM(isnull(@Sustitucion,'')))
		where 
		PALABRA = CONCAT(' ',@Palabra,' ')
	END
	ELSE
	BEGIN
		INSERT INTO EN_ConjuncionesDocumentos
			(Palabra,					Sustitucion,								Activo,
			CreadoPor,					CreadoEl) 
			values 
			(CONCAT(' ',@Palabra,' '),	LTRIM(RTRIM(isnull(@Sustitucion,''))),		1,
			@IdUsuario,					GETDATE()
			)
	END

END