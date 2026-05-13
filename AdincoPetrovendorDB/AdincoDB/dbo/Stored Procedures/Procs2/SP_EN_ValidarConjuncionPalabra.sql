CREATE PROCEDURE SP_EN_ValidarConjuncionPalabra
	-- Add the parameters for the stored procedure here
	@Palabra VARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @EXISTE BIT = 0;

	SELECT
		@EXISTE = CASE	
					WHEN Palabra != '' THEN 1
					ELSE 0
				END
	FROM EN_ConjuncionesDocumentos
	WHERE Palabra = CONCAT(' ',@Palabra,' ')
	AND Activo = 1;

	SELECT @EXISTE AS EXISTE;

END