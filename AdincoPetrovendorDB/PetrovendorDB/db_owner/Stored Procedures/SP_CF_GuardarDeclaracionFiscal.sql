
CREATE PROCEDURE [db_owner].[SP_CF_GuardarDeclaracionFiscal]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@DeclaracionFiscal nvarchar(max),
	@IdUsuario int,
	@NombreDoc varchar(max)

AS
BEGIN
	
	insert into CF_DeclaracionFiscal
		(IdProveedor, DeclaracionFiscal, SubidoPor, FechaCarga, NombreDoc)
	values(@IdProveedor, @DeclaracionFiscal, @IdUsuario, GETDATE(), @NombreDoc)

END
