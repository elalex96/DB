CREATE FUNCTION dbo.fnGetPantallasMenu
(
	@Url varchar(250),
	@Idioma int
)
RETURNS varchar(2000)
AS
BEGIN
	DECLARE @Opciones VARCHAR (2000) = ''

	SELECT @Opciones = @Opciones + RTRIM(LTRIM(ISNULL(CASE @Idioma
           WHEN 2 THEN
             ISNULL(InnerHtmlingles,InnerHtml)
           ELSE
               InnerHtml
       END,''))) + ', '
	FROM AP_MENUD WHERE Url=@Url

	SELECT
		@Opciones	= CASE WHEN @Opciones <> '' THEN ISNULL(SUBSTRING(@Opciones,1,LEN(@Opciones)-1),'') ELSE @Opciones END

	RETURN @Opciones
END
