-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDocTerminosYCondiciones]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TIENE_TERMINOS INT 
	SET @TIENE_TERMINOS = (SELECT COUNT (IdTerminosYCondiciones) FROM TC_TerminosYCondicionesDocV2 WHERE IdProveedor = @IdProveedor AND IsActivo = 1)

	IF (@TIENE_TERMINOS > 0)
	BEGIN
	SELECT  Documento  FROM TC_TerminosYCondicionesDocV2 WHERE IdProveedor = @IdProveedor
	END
	ELSE
	BEGIN
	SELECT 'SIN_TERMINOS'
	END
	
END

