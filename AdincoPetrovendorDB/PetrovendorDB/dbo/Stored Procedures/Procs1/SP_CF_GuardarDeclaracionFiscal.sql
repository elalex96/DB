
CREATE PROCEDURE [dbo].[SP_CF_GuardarDeclaracionFiscal]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@DeclaracionFiscal nvarchar(max),
	@IdUsuario int,
	@NombreDoc varchar(max),
	@Anio INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN
	
	insert into CF_DeclaracionFiscal
		(IdProveedor, DeclaracionFiscal, SubidoPor, FechaCarga, NombreDoc, Anio)
	values(@IdProveedor, @DeclaracionFiscal, @IdUsuario, GETDATE(), @NombreDoc, @Anio)

	SELECT @@IDENTITY

END
