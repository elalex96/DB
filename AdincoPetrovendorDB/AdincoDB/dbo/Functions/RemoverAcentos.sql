-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-09-14
-- Description:	
-- =============================================
CREATE FUNCTION RemoverAcentos ( @Cadena NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN

	RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Cadena, 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u'),'/',''),'-',' '),'.','')

END
