-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_CF_ConsultarDeclaracionFiscal
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Anio INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = NULL,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [IdDeclaracionFiscal], [NombreDoc] FROM [CF_DeclaracionFiscal] WHERE [IdProveedor] = @IdProveedor
END

